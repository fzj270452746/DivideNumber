//
//  TileDispensaryManager.swift
//  DivideNumber
//
//  Manages tile generation and dealing
//

import Foundation

/// Delegate protocol for tile dispensary events
protocol TileDispensaryDelegate: AnyObject {
    func dispensaryDidUpdateQueue(_ queue: [CeramicTilePiece])
}

/// Manages the tile queue and hold slot
class TileDispensaryManager {

    // MARK: - Properties

    weak var dispensaryDelegate: TileDispensaryDelegate?

    /// Current tile queue (max 2 tiles)
    private(set) var pendingTileQueue: [CeramicTilePiece] = []

    /// Hold slot tile
    private(set) var reservedTile: CeramicTilePiece?

    /// Maximum queue size
    private let maxQueueCapacity: Int = 2

    /// Whether hold was used this turn
    private(set) var holdExercisedThisTurn: Bool = false

    // MARK: - Initialization

    init() {
        replenishQueue()
    }

    // MARK: - Public Methods

    /// Gets the current tile (first in queue)
    var currentDispensedTile: CeramicTilePiece? {
        return pendingTileQueue.first
    }

    /// Gets the next tile (second in queue)
    var upcomingTile: CeramicTilePiece? {
        return pendingTileQueue.count > 1 ? pendingTileQueue[1] : nil
    }

    /// Consumes the current tile and advances the queue
    func consumeCurrentTile() -> CeramicTilePiece? {
        guard !pendingTileQueue.isEmpty else { return nil }

        let consumedTile = pendingTileQueue.removeFirst()
        replenishQueue()
        holdExercisedThisTurn = false
        dispensaryDelegate?.dispensaryDidUpdateQueue(pendingTileQueue)

        return consumedTile
    }

    /// Attempts to place current tile in hold slot (only if hold slot is empty)
    func toggleHoldOperation() -> Bool {
        guard !holdExercisedThisTurn else { return false }
        guard let currentTile = pendingTileQueue.first else { return false }

        // Only allow hold if the slot is empty
        guard reservedTile == nil else { return false }

        holdExercisedThisTurn = true

        // Place current in hold, advance queue
        reservedTile = currentTile
        pendingTileQueue.removeFirst()
        replenishQueue()

        dispensaryDelegate?.dispensaryDidUpdateQueue(pendingTileQueue)
        return true
    }

    /// Uses the held tile (places it as current)
    func deployReservedTile() -> CeramicTilePiece? {
        guard let held = reservedTile else { return nil }
        reservedTile = nil
        return held
    }

    /// Resets the dispensary to initial state
    func resetDispensary() {
        pendingTileQueue.removeAll()
        reservedTile = nil
        holdExercisedThisTurn = false
        replenishQueue()
        dispensaryDelegate?.dispensaryDidUpdateQueue(pendingTileQueue)
    }

    // MARK: - Private Methods

    /// Ensures the queue has the maximum number of tiles
    private func replenishQueue() {
        while pendingTileQueue.count < maxQueueCapacity {
            let newTile = CeramicTilePiece.stochasticPiece()
            pendingTileQueue.append(newTile)
        }
    }
}
