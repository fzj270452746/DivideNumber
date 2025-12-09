//
//  EliminationOutcome.swift
//  DivideNumber
//
//  Represents the result of an elimination action
//

import Foundation

/// Types of elimination that can occur
enum AnnihilationCategory {
    case identical      // Same number elimination
    case quotient       // Division elimination
}

/// Represents a single elimination event
struct EliminationOutcome {
    let category: AnnihilationCategory
    let involvedCoordinates: [GridCoordinate]
    let removedMagnitudes: [Int]
    let transformedCoordinate: GridCoordinate?
    let resultantMagnitude: Int?
    let earnedPoints: Int
    let chainDepth: Int

    /// Creates an identical elimination outcome
    static func identicalElimination(
        coordinates: [GridCoordinate],
        magnitudes: [Int],
        points: Int,
        chainDepth: Int
    ) -> EliminationOutcome {
        return EliminationOutcome(
            category: .identical,
            involvedCoordinates: coordinates,
            removedMagnitudes: magnitudes,
            transformedCoordinate: nil,
            resultantMagnitude: nil,
            earnedPoints: points,
            chainDepth: chainDepth
        )
    }

    /// Creates a quotient elimination outcome
    static func quotientElimination(
        removedCoordinate: GridCoordinate,
        transformedCoordinate: GridCoordinate,
        removedMagnitude: Int,
        resultantMagnitude: Int,
        points: Int,
        chainDepth: Int
    ) -> EliminationOutcome {
        return EliminationOutcome(
            category: .quotient,
            involvedCoordinates: [removedCoordinate, transformedCoordinate],
            removedMagnitudes: [removedMagnitude],
            transformedCoordinate: transformedCoordinate,
            resultantMagnitude: resultantMagnitude,
            earnedPoints: points,
            chainDepth: chainDepth
        )
    }
}

/// Represents the complete result of placing a tile
struct PlacementResolution {
    let eliminations: [EliminationOutcome]
    let totalPoints: Int
    let maxChainDepth: Int
    let wasSuccessful: Bool

    static func successful(
        eliminations: [EliminationOutcome],
        totalPoints: Int,
        maxChainDepth: Int
    ) -> PlacementResolution {
        return PlacementResolution(
            eliminations: eliminations,
            totalPoints: totalPoints,
            maxChainDepth: maxChainDepth,
            wasSuccessful: true
        )
    }

    static func simplePlacement() -> PlacementResolution {
        return PlacementResolution(
            eliminations: [],
            totalPoints: 0,
            maxChainDepth: 0,
            wasSuccessful: true
        )
    }

    static func failed() -> PlacementResolution {
        return PlacementResolution(
            eliminations: [],
            totalPoints: 0,
            maxChainDepth: 0,
            wasSuccessful: false
        )
    }
}
