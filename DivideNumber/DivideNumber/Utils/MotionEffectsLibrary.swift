//
//  MotionEffectsLibrary.swift
//  DivideNumber
//
//  Animation utilities and effects
//

import UIKit

/// Library of reusable animation effects
struct MotionEffectsLibrary {

    // MARK: - Duration Constants

    static let quickDuration: TimeInterval = 0.2
    static let standardDuration: TimeInterval = 0.3
    static let extendedDuration: TimeInterval = 0.5

    // MARK: - Scale Animations

    /// Bounce scale effect for button taps
    static func applyBounceEffect(to view: UIView, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: quickDuration,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                view.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: quickDuration,
                    delay: 0,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 0.5,
                    options: [],
                    animations: {
                        view.transform = .identity
                    },
                    completion: { _ in
                        completion?()
                    }
                )
            }
        )
    }

    /// Pop-in scale animation
    static func applyPopInEffect(to view: UIView, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        view.alpha = 0

        UIView.animate(
            withDuration: standardDuration,
            delay: delay,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: [],
            animations: {
                view.transform = .identity
                view.alpha = 1
            },
            completion: { _ in
                completion?()
            }
        )
    }

    /// Pop-out scale animation
    static func applyPopOutEffect(to view: UIView, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: quickDuration,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                view.alpha = 0
            },
            completion: { _ in
                completion?()
            }
        )
    }

    // MARK: - Fade Animations

    /// Fade in animation
    static func applyFadeIn(to view: UIView, duration: TimeInterval = standardDuration, completion: (() -> Void)? = nil) {
        view.alpha = 0
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }

    /// Fade out animation
    static func applyFadeOut(to view: UIView, duration: TimeInterval = standardDuration, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 0
        }, completion: { _ in
            completion?()
        })
    }

    // MARK: - Shake Animation

    /// Shake effect for errors or invalid actions
    static func applyShakeEffect(to view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-10, 10, -8, 8, -5, 5, -2, 2, 0]
        view.layer.add(animation, forKey: "shake")
    }

    // MARK: - Glow Animation

    /// Pulsing glow effect
    static func applyPulsingGlow(to view: UIView, color: UIColor) {
        view.layer.shadowColor = color.cgColor
        view.layer.shadowRadius = 0
        view.layer.shadowOpacity = 0
        view.layer.shadowOffset = .zero

        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = 15
        glowAnimation.duration = 0.5
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity

        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 0.8
        opacityAnimation.duration = 0.5
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity

        view.layer.add(glowAnimation, forKey: "glowRadius")
        view.layer.add(opacityAnimation, forKey: "glowOpacity")
    }

    /// Removes glow effect
    static func removeGlowEffect(from view: UIView) {
        view.layer.removeAnimation(forKey: "glowRadius")
        view.layer.removeAnimation(forKey: "glowOpacity")
        view.layer.shadowOpacity = 0
    }

    // MARK: - Number Change Animation

    /// Animates a number change in a label
    static func animateNumberChange(in label: UILabel, to newValue: Int, duration: TimeInterval = standardDuration) {
        guard let currentText = label.text,
              let currentValue = Int(currentText.replacingOccurrences(of: ",", with: "")) else {
            label.text = "\(newValue)"
            return
        }

        let steps = 20
        let stepDuration = duration / Double(steps)
        let increment = Double(newValue - currentValue) / Double(steps)

        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                let value = currentValue + Int(increment * Double(i))
                label.text = NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
            }
        }
    }

    // MARK: - Floating Score Animation

    /// Creates a floating score label animation
    static func showFloatingScore(_ points: Int, at position: CGPoint, in parentView: UIView, color: UIColor = ChromaticPalette.aurelianAccent) {
        let label = UILabel()
        label.text = "+\(points)"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = color
        label.textAlignment = .center
        label.sizeToFit()
        label.center = position
        label.alpha = 1

        parentView.addSubview(label)

        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                label.center = CGPoint(x: position.x, y: position.y - 60)
                label.alpha = 0
                label.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            },
            completion: { _ in
                label.removeFromSuperview()
            }
        )
    }

    // MARK: - Explosion Effect

    /// Creates particle explosion effect for elimination
    static func createEliminationBurst(at center: CGPoint, in parentView: UIView, color: UIColor) {
        let particleCount = 8
        let particleSize: CGFloat = 8

        for i in 0..<particleCount {
            let particle = UIView(frame: CGRect(x: 0, y: 0, width: particleSize, height: particleSize))
            particle.backgroundColor = color
            particle.layer.cornerRadius = particleSize / 2
            particle.center = center
            parentView.addSubview(particle)

            let angle = (CGFloat(i) / CGFloat(particleCount)) * .pi * 2
            let distance: CGFloat = 50

            let endX = center.x + cos(angle) * distance
            let endY = center.y + sin(angle) * distance

            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                options: [.curveEaseOut],
                animations: {
                    particle.center = CGPoint(x: endX, y: endY)
                    particle.alpha = 0
                    particle.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                },
                completion: { _ in
                    particle.removeFromSuperview()
                }
            )
        }
    }
}
