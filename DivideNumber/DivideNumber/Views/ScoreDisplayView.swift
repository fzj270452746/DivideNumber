//
//  ScoreDisplayView.swift
//  DivideNumber
//
//  Score and high score display component
//

import UIKit

/// View displaying current score and high score
class ScoreDisplayView: UIView {

    // MARK: - Properties

    private var hasConfiguredLayout: Bool = false

    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()

    // Current score section
    private let scoreContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.slateCardBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let scoreTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "SCORE"
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = ChromaticPalette.pearlSecondaryText
        label.textAlignment = .center
        return label
    }()

    private let scoreValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = ChromaticPalette.aurelianAccent
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()

    // High score section
    private let highScoreContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.slateCardBackground.withOpacityLevel(0.6)
        view.layer.cornerRadius = 10
        return view
    }()

    private let highScoreTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "BEST"
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textColor = ChromaticPalette.pearlSecondaryText
        label.textAlignment = .center
        return label
    }()

    private let highScoreValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = ChromaticPalette.alabasterText
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        return label
    }()

    private let trophyIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "trophy.fill")
        imageView.tintColor = ChromaticPalette.aurelianAccent
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Layout

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil && !hasConfiguredLayout {
            hasConfiguredLayout = true
            configureVisualHierarchy()
        }
    }

    // MARK: - Configuration

    private func configureVisualHierarchy() {
        addSubview(containerStack)
        containerStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Build current score section
        let scoreSection = buildScoreSection()
        containerStack.addArrangedSubview(scoreSection)

        // Build high score section
        let highScoreSection = buildHighScoreSection()
        containerStack.addArrangedSubview(highScoreSection)
    }

    private func buildScoreSection() -> UIView {
        let section = UIView()
        section.translatesAutoresizingMaskIntoConstraints = false

        section.addSubview(scoreContainer)
        scoreContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scoreContainer.topAnchor.constraint(equalTo: section.topAnchor),
            scoreContainer.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            scoreContainer.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            scoreContainer.bottomAnchor.constraint(equalTo: section.bottomAnchor)
        ])

        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.alignment = .center
        innerStack.spacing = 2
        innerStack.translatesAutoresizingMaskIntoConstraints = false

        scoreContainer.addSubview(innerStack)

        NSLayoutConstraint.activate([
            innerStack.centerXAnchor.constraint(equalTo: scoreContainer.centerXAnchor),
            innerStack.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor),
            innerStack.leadingAnchor.constraint(equalTo: scoreContainer.leadingAnchor, constant: 12),
            innerStack.trailingAnchor.constraint(equalTo: scoreContainer.trailingAnchor, constant: -12)
        ])

        innerStack.addArrangedSubview(scoreTitleLabel)
        innerStack.addArrangedSubview(scoreValueLabel)

        NSLayoutConstraint.activate([
            section.widthAnchor.constraint(equalToConstant: 120),
            section.heightAnchor.constraint(equalToConstant: 70)
        ])

        return section
    }

    private func buildHighScoreSection() -> UIView {
        let section = UIView()
        section.translatesAutoresizingMaskIntoConstraints = false

        section.addSubview(highScoreContainer)
        highScoreContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            highScoreContainer.topAnchor.constraint(equalTo: section.topAnchor),
            highScoreContainer.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            highScoreContainer.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            highScoreContainer.bottomAnchor.constraint(equalTo: section.bottomAnchor)
        ])

        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.alignment = .center
        innerStack.spacing = 2
        innerStack.translatesAutoresizingMaskIntoConstraints = false

        highScoreContainer.addSubview(innerStack)

        NSLayoutConstraint.activate([
            innerStack.centerXAnchor.constraint(equalTo: highScoreContainer.centerXAnchor),
            innerStack.centerYAnchor.constraint(equalTo: highScoreContainer.centerYAnchor),
            innerStack.leadingAnchor.constraint(equalTo: highScoreContainer.leadingAnchor, constant: 12),
            innerStack.trailingAnchor.constraint(equalTo: highScoreContainer.trailingAnchor, constant: -12)
        ])

        // Trophy row
        let trophyRow = UIStackView()
        trophyRow.axis = .horizontal
        trophyRow.alignment = .center
        trophyRow.spacing = 4

        trophyIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trophyIcon.widthAnchor.constraint(equalToConstant: 14),
            trophyIcon.heightAnchor.constraint(equalToConstant: 14)
        ])

        trophyRow.addArrangedSubview(trophyIcon)
        trophyRow.addArrangedSubview(highScoreTitleLabel)

        innerStack.addArrangedSubview(trophyRow)
        innerStack.addArrangedSubview(highScoreValueLabel)

        NSLayoutConstraint.activate([
            section.widthAnchor.constraint(equalToConstant: 100),
            section.heightAnchor.constraint(equalToConstant: 60)
        ])

        return section
    }

    // MARK: - Public Methods

    /// Updates the current score
    func updateScore(_ score: Int, animated: Bool = true) {
        if animated {
            MotionEffectsLibrary.animateNumberChange(in: scoreValueLabel, to: score)

            // Pulse effect on score change
            UIView.animate(withDuration: 0.1) {
                self.scoreValueLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.scoreValueLabel.transform = .identity
                }
            }
        } else {
            scoreValueLabel.text = NumberFormatter.localizedString(from: NSNumber(value: score), number: .decimal)
        }
    }

    /// Updates the high score
    func updateHighScore(_ score: Int) {
        highScoreValueLabel.text = NumberFormatter.localizedString(from: NSNumber(value: score), number: .decimal)
    }

    /// Shows new high score celebration
    func celebrateNewHighScore() {
        // Flash trophy
        UIView.animate(withDuration: 0.3, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.trophyIcon.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.highScoreContainer.backgroundColor = ChromaticPalette.aurelianAccent.withOpacityLevel(0.3)
        }) { _ in
            self.trophyIcon.transform = .identity
            self.highScoreContainer.backgroundColor = ChromaticPalette.slateCardBackground.withOpacityLevel(0.6)
        }

        // Stop animation after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.trophyIcon.layer.removeAllAnimations()
            self.highScoreContainer.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.2) {
                self.trophyIcon.transform = .identity
                self.highScoreContainer.backgroundColor = ChromaticPalette.slateCardBackground.withOpacityLevel(0.6)
            }
        }
    }
}
