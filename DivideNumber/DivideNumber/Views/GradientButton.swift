//
//  GradientButton.swift
//  DivideNumber
//
//  Custom styled button with gradient background
//

import UIKit

/// Custom button with gradient background and styling
class GradientButton: UIButton {

    // MARK: - Properties

    private let gradientLayer = CAGradientLayer()

    private var primaryColor: UIColor = ChromaticPalette.aurelianAccent
    private var secondaryColor: UIColor = UIColor(hex: "#FFA000")

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureVisualHierarchy()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureVisualHierarchy()
    }

    convenience init(title: String, primaryColor: UIColor = ChromaticPalette.aurelianAccent, secondaryColor: UIColor = UIColor(hex: "#FFA000")) {
        self.init(frame: .zero)
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        setTitle(title, for: .normal)
        updateGradientColors()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = bounds.height / 2
    }

    // MARK: - Configuration

    private func configureVisualHierarchy() {
        // Gradient background
        gradientLayer.colors = [primaryColor.cgColor, secondaryColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3

        // Title styling
        setTitleColor(ChromaticPalette.ebonyText, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)

        // Add touch handlers
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    private func updateGradientColors() {
        gradientLayer.colors = [primaryColor.cgColor, secondaryColor.cgColor]
    }

    // MARK: - Touch Handlers

    @objc private func handleTouchDown() {
        AuralFeedbackManager.shared.emitButtonTapFeedback()
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.layer.shadowOpacity = 0.15
        }
    }

    @objc private func handleTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.layer.shadowOpacity = 0.3
        }
    }

    // MARK: - Public Methods

    /// Sets the gradient colors
    func setGradientColors(primary: UIColor, secondary: UIColor) {
        self.primaryColor = primary
        self.secondaryColor = secondary
        updateGradientColors()
    }

    /// Sets the button enabled state with visual feedback
    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.alpha = self.isEnabled ? 1.0 : 0.5
            }
        }
    }
}

// MARK: - IconButton

/// Circular button with icon
class IconButton: UIButton {

    // MARK: - Properties

    private var iconColor: UIColor = ChromaticPalette.alabasterText
    private var backgroundTint: UIColor = ChromaticPalette.slateCardBackground

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureVisualHierarchy()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureVisualHierarchy()
    }

    convenience init(iconName: String, iconColor: UIColor = ChromaticPalette.alabasterText, backgroundTint: UIColor = ChromaticPalette.slateCardBackground) {
        self.init(frame: .zero)
        self.iconColor = iconColor
        self.backgroundTint = backgroundTint
        backgroundColor = backgroundTint

        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: iconName, withConfiguration: config)
        setImage(image, for: .normal)
        tintColor = iconColor
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }

    // MARK: - Configuration

    private func configureVisualHierarchy() {
        backgroundColor = backgroundTint
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2

        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func handleTouchDown() {
        AuralFeedbackManager.shared.emitButtonTapFeedback()
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    @objc private func handleTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}
