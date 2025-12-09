//
//  MosaicBoardState.swift
//  DivideNumber
//
//  Game board state model
//

import Foundation

/// Represents the current state of the game board
class MosaicBoardState: Codable {
    let difficultyTier: LabyrinthDifficulty
    private(set) var tileMatrix: [[CeramicTilePiece?]]

    /// Creates an empty board with the specified difficulty
    init(difficultyTier: LabyrinthDifficulty) {
        self.difficultyTier = difficultyTier
        let dimension = difficultyTier.matrixDimension
        self.tileMatrix = Array(repeating: Array(repeating: nil, count: dimension), count: dimension)
    }

    /// Returns the board dimension
    var matrixDimension: Int {
        return difficultyTier.matrixDimension
    }

    /// Gets the tile at the specified coordinate
    func retrieveTile(at coordinate: GridCoordinate) -> CeramicTilePiece? {
        guard coordinate.isWithinBounds(dimension: matrixDimension) else { return nil }
        return tileMatrix[coordinate.rowIndex][coordinate.columnIndex]
    }

    /// Places a tile at the specified coordinate
    func installTile(_ tile: CeramicTilePiece, at coordinate: GridCoordinate) {
        guard coordinate.isWithinBounds(dimension: matrixDimension) else { return }
        tileMatrix[coordinate.rowIndex][coordinate.columnIndex] = tile
    }

    /// Removes the tile at the specified coordinate
    func expungeTile(at coordinate: GridCoordinate) {
        guard coordinate.isWithinBounds(dimension: matrixDimension) else { return }
        tileMatrix[coordinate.rowIndex][coordinate.columnIndex] = nil
    }

    /// Replaces the tile at the specified coordinate with a new tile
    func transmutateTile(at coordinate: GridCoordinate, withMagnitude newMagnitude: Int) {
        guard coordinate.isWithinBounds(dimension: matrixDimension),
              let existingTile = tileMatrix[coordinate.rowIndex][coordinate.columnIndex] else { return }

        let newTile = existingTile.metamorphosedPiece(withMagnitude: newMagnitude)
        tileMatrix[coordinate.rowIndex][coordinate.columnIndex] = newTile
    }

    /// Checks if a coordinate is empty
    func isVacant(at coordinate: GridCoordinate) -> Bool {
        guard coordinate.isWithinBounds(dimension: matrixDimension) else { return false }
        return tileMatrix[coordinate.rowIndex][coordinate.columnIndex] == nil
    }

    /// Returns all empty coordinates on the board
    func vacantCoordinates() -> [GridCoordinate] {
        var empty: [GridCoordinate] = []
        for row in 0..<matrixDimension {
            for col in 0..<matrixDimension {
                let coord = GridCoordinate(rowIndex: row, columnIndex: col)
                if isVacant(at: coord) {
                    empty.append(coord)
                }
            }
        }
        return empty
    }

    /// Returns all occupied coordinates on the board
    func occupiedCoordinates() -> [GridCoordinate] {
        var occupied: [GridCoordinate] = []
        for row in 0..<matrixDimension {
            for col in 0..<matrixDimension {
                let coord = GridCoordinate(rowIndex: row, columnIndex: col)
                if !isVacant(at: coord) {
                    occupied.append(coord)
                }
            }
        }
        return occupied
    }

    /// Checks if the board is completely full
    var isCompletelyOccupied: Bool {
        return vacantCoordinates().isEmpty
    }

    /// Returns the count of tiles on the board
    var occupiedCellCount: Int {
        return occupiedCoordinates().count
    }

    /// Creates a deep copy of the board state
    func duplicateState() -> MosaicBoardState {
        let copy = MosaicBoardState(difficultyTier: difficultyTier)
        for row in 0..<matrixDimension {
            for col in 0..<matrixDimension {
                copy.tileMatrix[row][col] = tileMatrix[row][col]
            }
        }
        return copy
    }
}
