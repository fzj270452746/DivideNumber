//
//  SessionOrchestrator.swift
//  DivideNumber
//
//  Main game session controller
//

import Foundation

/// Game state enumeration
enum SessionPhase {
    case awaiting        // Waiting for player input
    case processing      // Processing elimination
    case concluded       // Game over
}

/// Delegate protocol for game session events
protocol SessionOrchestratorDelegate: AnyObject {
    func orchestratorDidUpdateScore(_ newScore: Int)
    func orchestratorDidChangePhase(_ phase: SessionPhase)
    func orchestratorDidPlaceTile(_ tile: CeramicTilePiece, at coordinate: GridCoordinate)
    func orchestratorDidProcessElimination(_ outcome: EliminationOutcome)
    func orchestratorDidCompleteEliminations(_ resolution: PlacementResolution)
    func orchestratorDidEndGame(finalScore: Int)
    func orchestratorDidUpdateDispensary()
    func orchestratorDidUpdateHoldSlot(_ tile: CeramicTilePiece?)
}

/// Main orchestrator for a game session
class SessionOrchestrator {

    // MARK: - Properties

    weak var sessionDelegate: SessionOrchestratorDelegate?

    let difficultyTier: LabyrinthDifficulty
    private(set) var boardState: MosaicBoardState
    private(set) var eliminationEngine: CascadeEliminationEngine
    private(set) var tileDispensary: TileDispensaryManager

    private(set) var accumulatedScore: Int = 0
    private(set) var currentPhase: SessionPhase = .awaiting

    // MARK: - Initialization

    init(difficultyTier: LabyrinthDifficulty) {
        self.difficultyTier = difficultyTier
        self.boardState = MosaicBoardState(difficultyTier: difficultyTier)
        self.eliminationEngine = CascadeEliminationEngine()
        self.tileDispensary = TileDispensaryManager()

        self.eliminationEngine.cascadeDelegate = self
    }

    // MARK: - Public Methods

    /// Attempts to place the current tile at the specified coordinate
    func attemptPlacement(at coordinate: GridCoordinate) -> Bool {
        guard currentPhase == .awaiting else { return false }
        guard boardState.isVacant(at: coordinate) else { return false }
        guard let tileToPlace = tileDispensary.consumeCurrentTile() else { return false }

        executePlacement(tile: tileToPlace, at: coordinate)
        return true
    }

    /// Attempts to place the held tile at the specified coordinate
    func attemptHeldTilePlacement(at coordinate: GridCoordinate) -> Bool {
        guard currentPhase == .awaiting else { return false }
        guard boardState.isVacant(at: coordinate) else { return false }
        guard let heldTile = tileDispensary.deployReservedTile() else { return false }

        sessionDelegate?.orchestratorDidUpdateHoldSlot(nil)
        executePlacement(tile: heldTile, at: coordinate)
        return true
    }

    /// Toggles the hold operation
    func toggleHold() -> Bool {
        guard currentPhase == .awaiting else { return false }

        let success = tileDispensary.toggleHoldOperation()
        if success {
            sessionDelegate?.orchestratorDidUpdateHoldSlot(tileDispensary.reservedTile)
            sessionDelegate?.orchestratorDidUpdateDispensary()
        }
        return success
    }

    /// Gets the current tile from dispensary
    var currentTile: CeramicTilePiece? {
        return tileDispensary.currentDispensedTile
    }

    /// Gets the next tile from dispensary
    var nextTile: CeramicTilePiece? {
        return tileDispensary.upcomingTile
    }

    /// Gets the held tile
    var heldTile: CeramicTilePiece? {
        return tileDispensary.reservedTile
    }

    /// Checks if the game is over
    func evaluateGameConclusion() -> Bool {
        if boardState.isCompletelyOccupied {
            concludeGame()
            return true
        }
        return false
    }

    /// Resets the game session
    func resetSession() {
        boardState = MosaicBoardState(difficultyTier: difficultyTier)
        tileDispensary.resetDispensary()
        accumulatedScore = 0
        currentPhase = .awaiting

        sessionDelegate?.orchestratorDidUpdateScore(0)
        sessionDelegate?.orchestratorDidChangePhase(.awaiting)
        sessionDelegate?.orchestratorDidUpdateDispensary()
        sessionDelegate?.orchestratorDidUpdateHoldSlot(nil)
    }

    // MARK: - Private Methods

    private func executePlacement(tile: CeramicTilePiece, at coordinate: GridCoordinate) {
        currentPhase = .processing
        sessionDelegate?.orchestratorDidChangePhase(.processing)
        sessionDelegate?.orchestratorDidPlaceTile(tile, at: coordinate)

        // Process elimination (this will call delegate methods as eliminations occur)
        let resolution = eliminationEngine.processPlacement(
            tile: tile,
            at: coordinate,
            on: boardState
        )

        // Update score
        accumulatedScore += resolution.totalPoints
        sessionDelegate?.orchestratorDidUpdateScore(accumulatedScore)

        // Check for game over
        if evaluateGameConclusion() {
            return
        }

        // Return to awaiting state
        currentPhase = .awaiting
        sessionDelegate?.orchestratorDidChangePhase(.awaiting)
        sessionDelegate?.orchestratorDidUpdateDispensary()
    }

    private func concludeGame() {
        currentPhase = .concluded
        sessionDelegate?.orchestratorDidChangePhase(.concluded)
        sessionDelegate?.orchestratorDidEndGame(finalScore: accumulatedScore)

        // Save score to leaderboard
        ArchivalVaultManager.shared.preserveScore(accumulatedScore, for: difficultyTier)
    }
}

// MARK: - CascadeEliminationDelegate

extension SessionOrchestrator: CascadeEliminationDelegate {
    func engineDidPerformElimination(_ outcome: EliminationOutcome) {
        sessionDelegate?.orchestratorDidProcessElimination(outcome)
    }

    func engineDidCompleteAllEliminations(_ resolution: PlacementResolution) {
        sessionDelegate?.orchestratorDidCompleteEliminations(resolution)
    }
}
