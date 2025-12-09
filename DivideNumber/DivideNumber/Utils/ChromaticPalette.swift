//
//  ChromaticPalette.swift
//  DivideNumber
//
//  Color definitions and utilities
//

import UIKit

/// Central color palette for the game
struct ChromaticPalette {

    // MARK: - Primary Colors

    /// Deep jade green - primary brand color
    static let jadePrimary = UIColor(hex: "#1B5E20")

    /// Warm gold - accent color
    static let aurelianAccent = UIColor(hex: "#FFD700")

    /// Crimson red - for important actions/warnings
    static let vermilionAlert = UIColor(hex: "#C62828")

    // MARK: - Background Colors

    /// Dark background for main screens
    static let obsidianBackground = UIColor(hex: "#1A1A2E")

    /// Slightly lighter background for cards
    static let slateCardBackground = UIColor(hex: "#16213E")

    /// Board background color
    static let mahoganyBoardBase = UIColor(hex: "#3D2914")

    /// Board cell background
    static let ivoryCell = UIColor(hex: "#F5F5DC")

    /// Board cell border
    static let bronzeCellBorder = UIColor(hex: "#8B4513")

    // MARK: - Text Colors

    /// Primary text color (light)
    static let alabasterText = UIColor(hex: "#F5F5F5")

    /// Secondary text color
    static let pearlSecondaryText = UIColor(hex: "#B0B0B0")

    /// Dark text for light backgrounds
    static let ebonyText = UIColor(hex: "#1A1A1A")

    // MARK: - Tile Colors

    /// Koait (Dots) suit color
    static let koaitSuitTint = UIColor(hex: "#E53935")

    /// Taydd (Characters) suit color
    static let tayddSuitTint = UIColor(hex: "#43A047")

    /// Doisn (Bamboo) suit color
    static let doisnSuitTint = UIColor(hex: "#1E88E5")

    // MARK: - Difficulty Colors

    /// Easy mode color
    static let noviceGreen = UIColor(hex: "#4CAF50")

    /// Medium mode color
    static let adeptOrange = UIColor(hex: "#FF9800")

    /// Hard mode color
    static let virtuosoRed = UIColor(hex: "#F44336")

    // MARK: - Effect Colors

    /// Glow effect color
    static let luminousGlow = UIColor(hex: "#FFE082")

    /// Success effect color
    static let triumphantGreen = UIColor(hex: "#69F0AE")

    /// Chain bonus color
    static let cascadePurple = UIColor(hex: "#AB47BC")

    // MARK: - Gradient Sets

    static var homeGradientColors: [CGColor] {
        return [
            UIColor(hex: "#1A1A2E").cgColor,
            UIColor(hex: "#16213E").cgColor,
            UIColor(hex: "#0F3460").cgColor
        ]
    }

    static var boardGradientColors: [CGColor] {
        return [
            UIColor(hex: "#3D2914").cgColor,
            UIColor(hex: "#5D4037").cgColor,
            UIColor(hex: "#3D2914").cgColor
        ]
    }

    static var buttonGradientColors: [CGColor] {
        return [
            UIColor(hex: "#FFD700").cgColor,
            UIColor(hex: "#FFA000").cgColor
        ]
    }

    // MARK: - Utility Methods

    /// Returns the tint color for a tile suit
    static func tintForSuit(_ suit: VesselTileKind) -> UIColor {
        switch suit {
        case .koait: return koaitSuitTint
        case .taydd: return tayddSuitTint
        case .doisn: return doisnSuitTint
        }
    }

    /// Returns the color for a difficulty level
    static func colorForDifficulty(_ difficulty: LabyrinthDifficulty) -> UIColor {
        switch difficulty {
        case .novice: return noviceGreen
        case .adept: return adeptOrange
        case .virtuoso: return virtuosoRed
        }
    }
}

// MARK: - UIColor Extension

extension UIColor {
    /// Creates a UIColor from a hex string
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    /// Returns a lighter version of the color
    func luminanceAdjusted(by factor: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return UIColor(
            hue: hue,
            saturation: saturation,
            brightness: min(brightness * (1 + factor), 1.0),
            alpha: alpha
        )
    }

    /// Returns the color with adjusted alpha
    func withOpacityLevel(_ opacity: CGFloat) -> UIColor {
        return withAlphaComponent(opacity)
    }
}
