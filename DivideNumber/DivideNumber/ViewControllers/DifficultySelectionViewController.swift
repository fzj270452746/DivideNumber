//
//  DifficultySelectionViewController.swift
//  DivideNumber
//
//  Difficulty selection screen
//

import UIKit

/// View controller for selecting game difficulty
class DifficultySelectionViewController: UIViewController {

    // MARK: - Properties

    private let gradientLayer = CAGradientLayer()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Difficulty"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = ChromaticPalette.alabasterText
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose your challenge level"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = ChromaticPalette.pearlSecondaryText
        label.textAlignment = .center
        return label
    }()

    private let cardsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()

    private let backButton: IconButton = {
        let button = IconButton(iconName: "chevron.left")
        return button
    }()

    private var difficultyCards: [DifficultyCardView] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGradientBackground()
        configureVisualHierarchy()
        configureInteractions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        animateCardsEntrance()
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
            topConstant: 60,
            leadingConstant: 20,
            trailingConstant: 20
        )

        view.embedSubview(subtitleLabel)
        subtitleLabel.anchorRelative(
            top: headerLabel.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            topConstant: 8,
            leadingConstant: 20,
            trailingConstant: 20
        )

        // Cards stack
        view.embedSubview(cardsStackView)
        cardsStackView.anchorRelative(
            top: subtitleLabel.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            topConstant: 40,
            leadingConstant: 24,
            trailingConstant: 24
        )

        // Create difficulty cards
        for difficulty in LabyrinthDifficulty.allCases {
            let card = DifficultyCardView(difficulty: difficulty)
            card.selectionDelegate = self
            cardsStackView.addArrangedSubview(card)
            card.anchorToFixedHeight(120)
            difficultyCards.append(card)
        }
    }

    private func configureInteractions() {
        backButton.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
    }

    // MARK: - Animations

    private func animateCardsEntrance() {
        for (index, card) in difficultyCards.enumerated() {
            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 50, y: 0)

            UIView.animate(
                withDuration: 0.4,
                delay: Double(index) * 0.1,
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

    // MARK: - Actions

    @objc private func handleBackTapped() {
        AuralFeedbackManager.shared.emitButtonTapFeedback()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - DifficultyCardViewDelegate

extension DifficultySelectionViewController: DifficultyCardViewDelegate {
    func cardDidSelect(difficulty: LabyrinthDifficulty) {
        AuralFeedbackManager.shared.emitButtonTapFeedback()

        let gameVC = ArenaGameViewController(difficulty: difficulty)
        navigationController?.pushViewController(gameVC, animated: true)
    }
}

// MARK: - DifficultyCardView

protocol DifficultyCardViewDelegate: AnyObject {
    func cardDidSelect(difficulty: LabyrinthDifficulty)
}

/// Card view for displaying a difficulty option
class DifficultyCardView: UIView {

    // MARK: - Properties

    weak var selectionDelegate: DifficultyCardViewDelegate?

    let difficulty: LabyrinthDifficulty

    private var hasConfiguredLayout: Bool = false

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.slateCardBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        return view
    }()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 25
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ChromaticPalette.alabasterText
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = ChromaticPalette.pearlSecondaryText
        return label
    }()

    private let highScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = ChromaticPalette.aurelianAccent
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = ChromaticPalette.pearlSecondaryText
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let gridPreviewView: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.obsidianBackground.withOpacityLevel(0.5)
        view.layer.cornerRadius = 8
        return view
    }()

    private let labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    // MARK: - Initialization

    init(difficulty: LabyrinthDifficulty) {
        self.difficulty = difficulty
        super.init(frame: .zero)
        configureGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil && !hasConfiguredLayout {
            hasConfiguredLayout = true
            configureVisualHierarchy()
            configureContent()
        }
    }

    // MARK: - Configuration

    private func configureVisualHierarchy() {
        // Container
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Arrow first (so we can reference it)
        containerView.addSubview(arrowImageView)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arrowImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])

        // Grid preview
        containerView.addSubview(gridPreviewView)
        gridPreviewView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gridPreviewView.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -12),
            gridPreviewView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            gridPreviewView.widthAnchor.constraint(equalToConstant: 40),
            gridPreviewView.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Icon container
        containerView.addSubview(iconContainerView)
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 50),
            iconContainerView.heightAnchor.constraint(equalToConstant: 50)
        ])

        iconContainerView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])

        // Labels stack
        containerView.addSubview(labelsStack)
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelsStack.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            labelsStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: gridPreviewView.leadingAnchor, constant: -12)
        ])

        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(subtitleLabel)
        labelsStack.addArrangedSubview(highScoreLabel)

        configureGridPreview()
    }

    private func configureGridPreview() {
        let dimension = difficulty.matrixDimension
        let cellSize: CGFloat = 8
        let spacing: CGFloat = 2
        let totalSize = CGFloat(dimension) * cellSize + CGFloat(dimension - 1) * spacing
        let startOffset = (40 - totalSize) / 2

        for row in 0..<dimension {
            for col in 0..<dimension {
                let cell = UIView()
                cell.backgroundColor = ChromaticPalette.colorForDifficulty(difficulty).withOpacityLevel(0.6)
                cell.layer.cornerRadius = 2

                gridPreviewView.addSubview(cell)
                cell.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    cell.widthAnchor.constraint(equalToConstant: cellSize),
                    cell.heightAnchor.constraint(equalToConstant: cellSize),
                    cell.leadingAnchor.constraint(equalTo: gridPreviewView.leadingAnchor, constant: startOffset + CGFloat(col) * (cellSize + spacing)),
                    cell.topAnchor.constraint(equalTo: gridPreviewView.topAnchor, constant: startOffset + CGFloat(row) * (cellSize + spacing))
                ])
            }
        }
    }

    private func configureContent() {
        let color = ChromaticPalette.colorForDifficulty(difficulty)

        containerView.layer.borderColor = color.withOpacityLevel(0.5).cgColor
        iconContainerView.backgroundColor = color

        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        iconImageView.image = UIImage(systemName: difficulty.emblemGlyphName, withConfiguration: config)

        titleLabel.text = difficulty.epithetLabel
        subtitleLabel.text = difficulty.subsidiaryDescription + " Grid"

        let highScore = ArchivalVaultManager.shared.retrieveZenithScore(for: difficulty)
        highScoreLabel.text = highScore > 0 ? "Best: \(highScore)" : "No score yet"
    }

    private func configureGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        MotionEffectsLibrary.applyBounceEffect(to: containerView) { [weak self] in
            guard let self = self else { return }
            self.selectionDelegate?.cardDidSelect(difficulty: self.difficulty)
        }
    }
}
