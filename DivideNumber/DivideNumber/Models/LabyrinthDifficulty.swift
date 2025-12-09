//
//  LabyrinthDifficulty.swift
//  DivideNumber
//
//  Game difficulty enumeration
//

import Foundation

/// Represents the game difficulty levels
enum LabyrinthDifficulty: Int, CaseIterable, Codable {
    case novice = 3      // 3×3 board
    case adept = 4       // 4×4 board
    case virtuoso = 5    // 5×5 board

    /// Returns the board dimension for this difficulty
    var matrixDimension: Int {
        return rawValue
    }

    /// Returns the total number of cells on the board
    var totalCellCount: Int {
        return rawValue * rawValue
    }

    /// Display name for this difficulty
    var epithetLabel: String {
        switch self {
        case .novice: return "Easy"
        case .adept: return "Medium"
        case .virtuoso: return "Hard"
        }
    }

    /// Subtitle description
    var subsidiaryDescription: String {
        return "\(rawValue)×\(rawValue)"
    }

    /// Leaderboard key for UserDefaults
    var archiveKeyDesignation: String {
        switch self {
        case .novice: return "leaderboard_novice"
        case .adept: return "leaderboard_adept"
        case .virtuoso: return "leaderboard_virtuoso"
        }
    }

    /// Icon name for difficulty selection
    var emblemGlyphName: String {
        switch self {
        case .novice: return "leaf.fill"
        case .adept: return "flame.fill"
        case .virtuoso: return "bolt.fill"
        }
    }

    /// Theme color for this difficulty (as hex string)
    var chromaticHueHex: String {
        switch self {
        case .novice: return "#4CAF50"
        case .adept: return "#FF9800"
        case .virtuoso: return "#F44336"
        }
    }
}
