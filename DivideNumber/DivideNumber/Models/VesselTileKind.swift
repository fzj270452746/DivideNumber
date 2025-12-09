//
//  VesselTileKind.swift
//  DivideNumber
//
//  Mahjong tile suit enumeration
//

import Foundation

/// Represents the three mahjong tile suits
enum VesselTileKind: String, CaseIterable, Codable {
    case koait = "Koait"  // 筒 (Dots)
    case taydd = "Taydd"  // 万 (Characters)
    case doisn = "Doisn"  // 条 (Bamboo)

    /// Returns the display name for the suit
    var quintetLabel: String {
        switch self {
        case .koait: return "Dots"
        case .taydd: return "Characters"
        case .doisn: return "Bamboo"
        }
    }

    /// Returns the asset name prefix for this suit
    var heraldicPrefix: String {
        return rawValue
    }

    /// Generates a random suit
    static func stochasticKind() -> VesselTileKind {
        return allCases.randomElement() ?? .koait
    }
}
