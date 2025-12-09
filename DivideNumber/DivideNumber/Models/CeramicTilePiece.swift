//
//  CeramicTilePiece.swift
//  DivideNumber
//
//  Mahjong tile data model
//

import Foundation

/// Represents a single mahjong tile with suit and numerical value
struct CeramicTilePiece: Equatable, Codable {
    let vesselKind: VesselTileKind
    let numeralMagnitude: Int

    /// Unique identifier for this tile instance
    let fragmentIdentifier: String

    /// Creates a new mahjong tile
    /// - Parameters:
    ///   - vesselKind: The suit of the tile (Koait, Taydd, Doisn)
    ///   - numeralMagnitude: The numerical value (1-9)
    init(vesselKind: VesselTileKind, numeralMagnitude: Int) {
        self.vesselKind = vesselKind
        self.numeralMagnitude = max(1, min(9, numeralMagnitude))
        self.fragmentIdentifier = UUID().uuidString
    }

    /// Creates a tile with a specific identifier (for copying/transforming)
    init(vesselKind: VesselTileKind, numeralMagnitude: Int, fragmentIdentifier: String) {
        self.vesselKind = vesselKind
        self.numeralMagnitude = max(1, min(9, numeralMagnitude))
        self.fragmentIdentifier = fragmentIdentifier
    }

    /// Returns the asset image name for this tile
    var pictogramAssetDesignation: String {
        return "\(vesselKind.heraldicPrefix)-\(numeralMagnitude)"
    }

    /// Creates a random tile
    static func stochasticPiece() -> CeramicTilePiece {
        let randomKind = VesselTileKind.stochasticKind()
        let randomValue = Int.random(in: 1...9)
        return CeramicTilePiece(vesselKind: randomKind, numeralMagnitude: randomValue)
    }

    /// Creates a new tile with a different value but same suit and identifier
    func metamorphosedPiece(withMagnitude newMagnitude: Int) -> CeramicTilePiece {
        return CeramicTilePiece(
            vesselKind: self.vesselKind,
            numeralMagnitude: newMagnitude,
            fragmentIdentifier: UUID().uuidString
        )
    }

    /// Check if two tiles have the same numerical value
    func hasSameMagnitude(as otherPiece: CeramicTilePiece) -> Bool {
        return self.numeralMagnitude == otherPiece.numeralMagnitude
    }

    /// Check if this tile can divide another tile (A % B == 0 where A > B)
    func canPerformDivision(upon otherPiece: CeramicTilePiece) -> Bool {
        // Number 1 can only match with 1, not participate in division
        if self.numeralMagnitude == 1 || otherPiece.numeralMagnitude == 1 {
            return false
        }

        let larger = max(self.numeralMagnitude, otherPiece.numeralMagnitude)
        let smaller = min(self.numeralMagnitude, otherPiece.numeralMagnitude)

        return larger != smaller && larger % smaller == 0
    }

    /// Returns the quotient when dividing the larger by smaller
    func divisionQuotient(with otherPiece: CeramicTilePiece) -> Int? {
        guard canPerformDivision(upon: otherPiece) else { return nil }

        let larger = max(self.numeralMagnitude, otherPiece.numeralMagnitude)
        let smaller = min(self.numeralMagnitude, otherPiece.numeralMagnitude)

        return larger / smaller
    }

    static func == (lhs: CeramicTilePiece, rhs: CeramicTilePiece) -> Bool {
        return lhs.fragmentIdentifier == rhs.fragmentIdentifier
    }
}
