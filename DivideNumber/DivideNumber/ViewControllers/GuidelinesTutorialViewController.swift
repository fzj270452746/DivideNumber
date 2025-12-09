//
//  GuidelinesTutorialViewController.swift
//  DivideNumber
//
//  Tutorial and rules explanation screen
//

import UIKit

/// View controller for game tutorial/rules
class GuidelinesTutorialViewController: UIViewController {

    // MARK: - Properties

    private let gradientLayer = CAGradientLayer()

    private let backButton: IconButton = {
        let button = IconButton(iconName: "chevron.left")
        return button
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "How to Play"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = ChromaticPalette.alabasterText
        label.textAlignment = .center
        return label
    }()

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        return stack
    }()

    // Tutorial sections
    private let tutorialSections: [(icon: String, title: String, content: String)] = [
        (
            icon: "square.grid.3x3",
            title: "Objective",
            content: "Place mahjong tiles (1-9) on the board. Score points by eliminating tiles through matching or division. The game ends when the board is full."
        ),
        (
            icon: "equal.circle",
            title: "Same Number Rule",
            content: "When you place a tile next to another tile with the SAME number, both tiles are eliminated!\n\nExample: Place a 6 next to another 6 → Both are removed.\n\nScore: Sum of eliminated values × 10"
        ),
        (
            icon: "divide.circle",
            title: "Division Rule",
            content: "When you place a tile next to another tile where one divides the other evenly, the smaller number is eliminated and the larger becomes the quotient.\n\nExample: Place 6 next to 3 → 3 is removed, 6 becomes 2.\n\nScore: Eliminated value × 10\n\nNote: The number 1 only eliminates with another 1, it doesn't participate in division."
        ),
        (
            icon: "link",
            title: "Chain Reactions",
            content: "After an elimination, if the result triggers another valid elimination, it chains! Chain reactions multiply your score.\n\nChain bonus: ×1.2 for each chain level"
        ),
        (
            icon: "hand.raised",
            title: "Hold Position",
            content: "You can save one tile in the Hold slot for later use.\n\n• Tap the current tile or Hold slot to swap\n• Use the held tile by tapping on it, then selecting an empty cell\n• Strategic holding helps you plan better moves!"
        ),
        (
            icon: "star",
            title: "Scoring Tips",
            content: "• Same number eliminations score higher (sum of both tiles)\n• Set up chain reactions for bonus multipliers\n• Use the Hold slot to save high-value tiles for combos\n• Plan ahead to keep the board clear"
        ),
        (
            icon: "speedometer",
            title: "Difficulty Levels",
            content: "• Easy (3×3): 9 cells, great for learning\n• Medium (4×4): 16 cells, balanced challenge\n• Hard (5×5): 25 cells, maximum strategy"
        )
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGradientBackground()
        configureVisualHierarchy()
        buildTutorialContent()
        configureInteractions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Configuration

    private func configureGradientBackground() {
        gradientLayer.colors = ChromaticPalette.homeGradientColors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func configureVisualHierarchy() {
        // Back button
        view.embedSubview(backButton)
        backButton.anchorRelative(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            topConstant: 16,
            leadingConstant: 20
        )
        backButton.anchorToFixedSize(width: 44, height: 44)

        // Header
        view.embedSubview(headerLabel)
        headerLabel.anchorRelative(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            topConstant: 16,
            leadingConstant: 60,
            trailingConstant: 60
        )

        // Scroll view
        view.embedSubview(scrollView)
        scrollView.anchorRelative(
            top: headerLabel.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            topConstant: 24
        )

        scrollView.embedSubview(contentStackView)
        contentStackView.anchorToSuperviewEdges(insets: UIEdgeInsets(top: 0, left: 20, bottom: 40, right: 20))
        contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40).isActive = true
    }

    private func buildTutorialContent() {
        for (index, section) in tutorialSections.enumerated() {
            let card = createTutorialCard(icon: section.icon, title: section.title, content: section.content)

            // Animate entrance
            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 0, y: 20)

            contentStackView.addArrangedSubview(card)

            UIView.animate(
                withDuration: 0.4,
                delay: Double(index) * 0.08,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [],
                animations: {
                    card.alpha = 1
                    card.transform = .identity
                },
                completion: nil
            )
        }
    }

    private func createTutorialCard(icon: String, title: String, content: String) -> UIView {
        let card = UIView()
        card.backgroundColor = ChromaticPalette.slateCardBackground
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = ChromaticPalette.aurelianAccent.withOpacityLevel(0.2).cgColor

        // Icon container
        let iconContainer = UIView()
        iconContainer.backgroundColor = ChromaticPalette.aurelianAccent.withOpacityLevel(0.2)
        iconContainer.layer.cornerRadius = 20

        card.embedSubview(iconContainer)
        iconContainer.anchorRelative(
            top: card.topAnchor,
            leading: card.leadingAnchor,
            topConstant: 16,
            leadingConstant: 16
        )
        iconContainer.anchorToFixedSize(width: 40, height: 40)

        let iconImageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        iconImageView.image = UIImage(systemName: icon, withConfiguration: config)
        iconImageView.tintColor = ChromaticPalette.aurelianAccent
        iconImageView.contentMode = .scaleAspectFit

        iconContainer.embedSubview(iconImageView)
        iconImageView.anchorToCenterOfSuperview()
        iconImageView.anchorToFixedSize(width: 20, height: 20)

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = ChromaticPalette.alabasterText

        card.embedSubview(titleLabel)
        titleLabel.anchorRelative(
            leading: iconContainer.trailingAnchor,
            trailing: card.trailingAnchor,
            leadingConstant: 12,
            trailingConstant: 16
        )
        titleLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor).isActive = true

        // Content label
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLabel.textColor = ChromaticPalette.pearlSecondaryText
        contentLabel.numberOfLines = 0

        card.embedSubview(contentLabel)
        contentLabel.anchorRelative(
            top: iconContainer.bottomAnchor,
            leading: card.leadingAnchor,
            trailing: card.trailingAnchor,
            bottom: card.bottomAnchor,
            topConstant: 12,
            leadingConstant: 16,
            trailingConstant: 16,
            bottomConstant: 16
        )

        return card
    }

    private func configureInteractions() {
        backButton.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func handleBackTapped() {
        AuralFeedbackManager.shared.emitButtonTapFeedback()
        navigationController?.popViewController(animated: true)
    }
}
