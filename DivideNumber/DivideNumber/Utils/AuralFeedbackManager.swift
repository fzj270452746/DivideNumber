//
//  AuralFeedbackManager.swift
//  DivideNumber
//
//  Sound and haptic feedback manager
//

import UIKit
import AudioToolbox

/// Manages haptic and audio feedback
class AuralFeedbackManager {

    // MARK: - Singleton

    static let shared = AuralFeedbackManager()

    private init() {}

    // MARK: - Haptic Feedback

    /// Light impact feedback for tile selection
    func emitLightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Medium impact feedback for tile placement
    func emitMediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Heavy impact feedback for eliminations
    func emitHeavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Success notification feedback
    func emitSuccessNotification() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Warning notification feedback
    func emitWarningNotification() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// Error notification feedback
    func emitErrorNotification() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    /// Selection changed feedback
    func emitSelectionChange() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Combined Feedback

    /// Feedback for placing a tile
    func emitPlacementFeedback() {
        emitMediumImpact()
    }

    /// Feedback for elimination
    func emitEliminationFeedback() {
        emitHeavyImpact()
    }

    /// Feedback for chain reaction
    func emitChainReactionFeedback() {
        emitSuccessNotification()
    }

    /// Feedback for invalid action
    func emitInvalidActionFeedback() {
        emitErrorNotification()
    }

    /// Feedback for game over
    func emitGameOverFeedback() {
        emitWarningNotification()
    }

    /// Feedback for button tap
    func emitButtonTapFeedback() {
        emitLightImpact()
    }
}
