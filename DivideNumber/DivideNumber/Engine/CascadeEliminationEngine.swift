//
//  CascadeEliminationEngine.swift
//  DivideNumber
//
//  Core game logic engine for tile elimination
//

import Foundation

/// Delegate protocol for elimination events
protocol CascadeEliminationDelegate: AnyObject {
    func engineDidPerformElimination(_ outcome: EliminationOutcome)
    func engineDidCompleteAllEliminations(_ resolution: PlacementResolution)
}

/// Engine responsible for handling tile elimination logic
class CascadeEliminationEngine {

    // MARK: - Properties

    weak var cascadeDelegate: CascadeEliminationDelegate?

    /// Base points multiplier for same-number elimination
    private let identicalBonusMultiplier: Int = 10

    /// Base points multiplier for division elimination
    private let quotientBonusMultiplier: Int = 10

    /// Chain bonus multiplier base (1.2^n)
    private let chainAmplificationBase: Double = 1.2

    // MARK: - Public Methods

    /// Process a tile placement and execute all resulting eliminations
    func processPlacement(
        tile: CeramicTilePiece,
        at coordinate: GridCoordinate,
        on boardState: MosaicBoardState
    ) -> PlacementResolution {

        // Place the tile first
        boardState.installTile(tile, at: coordinate)

        var allEliminations: [EliminationOutcome] = []
        var totalPoints: Int = 0
        var currentChainDepth: Int = 0

        // Use BFS to process chain reactions
        var coordinatesToProcess: [GridCoordinate] = [coordinate]
        var processedInCurrentWave: Set<String> = []

        while !coordinatesToProcess.isEmpty {
            var nextWaveCoordinates: [GridCoordinate] = []
            processedInCurrentWave.removeAll()

            for currentCoord in coordinatesToProcess {
                guard !processedInCurrentWave.contains(currentCoord.lexiconKey) else { continue }
                processedInCurrentWave.insert(currentCoord.lexiconKey)

                guard let currentTile = boardState.retrieveTile(at: currentCoord) else { continue }

                // Step 1: Check for identical eliminations first
                let identicalResult = processIdenticalEliminations(
                    for: currentTile,
                    at: currentCoord,
                    on: boardState,
                    chainDepth: currentChainDepth
                )

                if let elimination = identicalResult.elimination {
                    allEliminations.append(elimination)
                    totalPoints += elimination.earnedPoints
                    cascadeDelegate?.engineDidPerformElimination(elimination)

                    // Add affected neighbors for next wave processing
                    for affectedCoord in identicalResult.affectedNeighbors {
                        if !processedInCurrentWave.contains(affectedCoord.lexiconKey) {
                            nextWaveCoordinates.append(affectedCoord)
                        }
                    }
                    continue // Move to next coordinate since this one was eliminated
                }

                // Step 2: Check for division eliminations (only if no identical)
                let divisionResult = processDivisionEliminations(
                    for: currentTile,
                    at: currentCoord,
                    on: boardState,
                    chainDepth: currentChainDepth
                )

                if let elimination = divisionResult.elimination {
                    allEliminations.append(elimination)
                    totalPoints += elimination.earnedPoints
                    cascadeDelegate?.engineDidPerformElimination(elimination)

                    // The transformed coordinate needs to be checked again
                    if let transformedCoord = elimination.transformedCoordinate {
                        nextWaveCoordinates.append(transformedCoord)
                    }

                    // Add affected neighbors for next wave processing
                    for affectedCoord in divisionResult.affectedNeighbors {
                        if !processedInCurrentWave.contains(affectedCoord.lexiconKey) {
                            nextWaveCoordinates.append(affectedCoord)
                        }
                    }
                }
            }

            coordinatesToProcess = nextWaveCoordinates
            if !nextWaveCoordinates.isEmpty {
                currentChainDepth += 1
            }
        }

        let resolution: PlacementResolution
        if allEliminations.isEmpty {
            resolution = .simplePlacement()
        } else {
            resolution = .successful(
                eliminations: allEliminations,
                totalPoints: totalPoints,
                maxChainDepth: currentChainDepth
            )
        }

        cascadeDelegate?.engineDidCompleteAllEliminations(resolution)
        return resolution
    }

    // MARK: - Private Methods

    private struct EliminationProcessResult {
        let elimination: EliminationOutcome?
        let affectedNeighbors: [GridCoordinate]
    }

    /// Process identical number eliminations for a tile
    private func processIdenticalEliminations(
        for tile: CeramicTilePiece,
        at coordinate: GridCoordinate,
        on boardState: MosaicBoardState,
        chainDepth: Int
    ) -> EliminationProcessResult {

        let neighbors = coordinate.adjacentQuadrant(withinBounds: boardState.matrixDimension)
        var identicalCoordinates: [GridCoordinate] = []
        var identicalMagnitudes: [Int] = []

        // Find all identical neighbors
        for neighborCoord in neighbors {
            if let neighborTile = boardState.retrieveTile(at: neighborCoord),
               neighborTile.hasSameMagnitude(as: tile) {
                identicalCoordinates.append(neighborCoord)
                identicalMagnitudes.append(neighborTile.numeralMagnitude)
            }
        }

        guard !identicalCoordinates.isEmpty else {
            return EliminationProcessResult(elimination: nil, affectedNeighbors: [])
        }

        // Include the placed tile in elimination
        identicalCoordinates.append(coordinate)
        identicalMagnitudes.append(tile.numeralMagnitude)

        // Calculate points with chain bonus
        let basePoints = identicalMagnitudes.reduce(0, +) * identicalBonusMultiplier
        let chainMultiplier = pow(chainAmplificationBase, Double(chainDepth))
        let finalPoints = Int(Double(basePoints) * chainMultiplier)

        // Remove all identical tiles
        var affectedNeighbors: [GridCoordinate] = []
        for coord in identicalCoordinates {
            // Get neighbors before removal for chain processing
            let coordNeighbors = coord.adjacentQuadrant(withinBounds: boardState.matrixDimension)
            affectedNeighbors.append(contentsOf: coordNeighbors)
            boardState.expungeTile(at: coord)
        }

        // Remove duplicates and already processed coordinates
        affectedNeighbors = affectedNeighbors.filter { coord in
            !identicalCoordinates.contains(coord) && boardState.retrieveTile(at: coord) != nil
        }

        let elimination = EliminationOutcome.identicalElimination(
            coordinates: identicalCoordinates,
            magnitudes: identicalMagnitudes,
            points: finalPoints,
            chainDepth: chainDepth
        )

        return EliminationProcessResult(elimination: elimination, affectedNeighbors: affectedNeighbors)
    }

    /// Process division eliminations for a tile
    private func processDivisionEliminations(
        for tile: CeramicTilePiece,
        at coordinate: GridCoordinate,
        on boardState: MosaicBoardState,
        chainDepth: Int
    ) -> EliminationProcessResult {

        // Number 1 doesn't participate in division
        guard tile.numeralMagnitude != 1 else {
            return EliminationProcessResult(elimination: nil, affectedNeighbors: [])
        }

        let neighbors = coordinate.adjacentQuadrant(withinBounds: boardState.matrixDimension)
        var affectedNeighbors: [GridCoordinate] = []

        for neighborCoord in neighbors {
            guard let neighborTile = boardState.retrieveTile(at: neighborCoord),
                  neighborTile.numeralMagnitude != 1,
                  tile.canPerformDivision(upon: neighborTile) else { continue }

            let currentMagnitude = tile.numeralMagnitude
            let neighborMagnitude = neighborTile.numeralMagnitude

            let larger = max(currentMagnitude, neighborMagnitude)
            let smaller = min(currentMagnitude, neighborMagnitude)
            let quotient = larger / smaller

            // Determine which tile gets transformed and which gets removed
            let isCurrentLarger = currentMagnitude > neighborMagnitude
            let transformedCoord = isCurrentLarger ? coordinate : neighborCoord
            let removedCoord = isCurrentLarger ? neighborCoord : coordinate
            let removedMagnitude = smaller

            // Calculate points with chain bonus
            let basePoints = removedMagnitude * quotientBonusMultiplier
            let chainMultiplier = pow(chainAmplificationBase, Double(chainDepth))
            let finalPoints = Int(Double(basePoints) * chainMultiplier)

            // Perform the elimination
            boardState.expungeTile(at: removedCoord)
            boardState.transmutateTile(at: transformedCoord, withMagnitude: quotient)

            // Get neighbors of the transformed tile for chain processing
            let transformedNeighbors = transformedCoord.adjacentQuadrant(withinBounds: boardState.matrixDimension)
            affectedNeighbors.append(contentsOf: transformedNeighbors.filter { $0 != removedCoord })

            let elimination = EliminationOutcome.quotientElimination(
                removedCoordinate: removedCoord,
                transformedCoordinate: transformedCoord,
                removedMagnitude: removedMagnitude,
                resultantMagnitude: quotient,
                points: finalPoints,
                chainDepth: chainDepth
            )

            return EliminationProcessResult(elimination: elimination, affectedNeighbors: affectedNeighbors)
        }

        return EliminationProcessResult(elimination: nil, affectedNeighbors: [])
    }
}
