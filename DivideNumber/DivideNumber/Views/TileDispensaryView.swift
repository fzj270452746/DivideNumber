//
//  TileDispensaryView.swift
//  DivideNumber
//
//  Visual component for tile queue and hold slot
//

import UIKit

/// Delegate for dispensary interaction events
protocol TileDispensaryViewDelegate: AnyObject {
    func dispensaryDidRequestHoldToggle()
    func dispensaryDidSelectHeldTile()
}

/// View showing current tile, next tile, and hold slot
class TileDispensaryView: UIView {

    // MARK: - Properties

    weak var dispensaryDelegate: TileDispensaryViewDelegate?

    private var hasConfiguredLayout: Bool = false

    // Current tile section
    private let currentSectionView = UIView()
    private let currentTileContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.slateCardBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.layer.borderColor = ChromaticPalette.aurelianAccent.cgColor
        view.isUserInteractionEnabled = true
        return view
    }()

    private let currentTileView: CeramicTileView = {
        let view = CeramicTileView()
        return view
    }()

    private let currentLabel: UILabel = {
        let label = UILabel()
        label.text = "CURRENT"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = ChromaticPalette.aurelianAccent
        label.textAlignment = .center
        return label
    }()

    // Next tile section
    private let nextSectionView = UIView()
    private let nextTileContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.slateCardBackground.withOpacityLevel(0.6)
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = ChromaticPalette.pearlSecondaryText.cgColor
        return view
    }()

    private let nextTileView: CeramicTileView = {
        let view = CeramicTileView()
        view.alpha = 0.7
        return view
    }()

    private let nextLabel: UILabel = {
        let label = UILabel()
        label.text = "NEXT"
        label.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        label.textColor = ChromaticPalette.pearlSecondaryText
        label.textAlignment = .center
        return label
    }()

    // Hold slot section
    private let holdSectionView = UIView()
    private let holdSlotContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.slateCardBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.layer.borderColor = ChromaticPalette.cascadePurple.withOpacityLevel(0.6).cgColor
        view.isUserInteractionEnabled = true
        return view
    }()

    private let holdTileView: CeramicTileView = {
        let view = CeramicTileView()
        return view
    }()

    private let holdLabel: UILabel = {
        let label = UILabel()
        label.text = "HOLD"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = ChromaticPalette.cascadePurple
        label.textAlignment = .center
        return label
    }()

    private let holdIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "hand.raised.fill")
        imageView.tintColor = ChromaticPalette.cascadePurple.withOpacityLevel(0.4)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let tileSize: CGFloat = 60
    private let smallTileSize: CGFloat = 50

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
            configureGestureRecognizers()
        }
    }

    // MARK: - Configuration

    private func configureVisualHierarchy() {
        // Create horizontal stack
        let containerStack = UIStackView()
        containerStack.axis = .horizontal
        containerStack.distribution = .equalSpacing
        containerStack.alignment = .center
        containerStack.spacing = 16

        embedSubview(containerStack)
        containerStack.anchorToSuperviewEdges()

        // Build sections
        buildCurrentTileSection()
        buildNextTileSection()
        buildHoldSlotSection()

        // Add to stack
        containerStack.addArrangedSubview(currentSectionView)
        containerStack.addArrangedSubview(nextSectionView)
        containerStack.addArrangedSubview(holdSectionView)
    }

    private func buildCurrentTileSection() {
        currentSectionView.translatesAutoresizingMaskIntoConstraints = false

        currentSectionView.addSubview(currentTileContainer)
        currentTileContainer.translatesAutoresizingMaskIntoConstraints = false

        currentTileContainer.addSubview(currentTileView)
        currentTileView.translatesAutoresizingMaskIntoConstraints = false

        currentSectionView.addSubview(currentLabel)
        currentLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            currentSectionView.widthAnchor.constraint(equalToConstant: tileSize + 20),
            currentSectionView.heightAnchor.constraint(equalToConstant: tileSize + 40),

            currentTileContainer.topAnchor.constraint(equalTo: currentSectionView.topAnchor),
            currentTileContainer.leadingAnchor.constraint(equalTo: currentSectionView.leadingAnchor),
            currentTileContainer.trailingAnchor.constraint(equalTo: currentSectionView.trailingAnchor),
            currentTileContainer.widthAnchor.constraint(equalToConstant: tileSize + 20),
            currentTileContainer.heightAnchor.constraint(equalToConstant: tileSize + 20),

            currentTileView.centerXAnchor.constraint(equalTo: currentTileContainer.centerXAnchor),
            currentTileView.centerYAnchor.constraint(equalTo: currentTileContainer.centerYAnchor),
            currentTileView.widthAnchor.constraint(equalToConstant: tileSize),
            currentTileView.heightAnchor.constraint(equalToConstant: tileSize),

            currentLabel.topAnchor.constraint(equalTo: currentTileContainer.bottomAnchor, constant: 4),
            currentLabel.leadingAnchor.constraint(equalTo: currentSectionView.leadingAnchor),
            currentLabel.trailingAnchor.constraint(equalTo: currentSectionView.trailingAnchor),
            currentLabel.bottomAnchor.constraint(equalTo: currentSectionView.bottomAnchor)
        ])
    }

    private func buildNextTileSection() {
        nextSectionView.translatesAutoresizingMaskIntoConstraints = false

        nextSectionView.addSubview(nextTileContainer)
        nextTileContainer.translatesAutoresizingMaskIntoConstraints = false

        nextTileContainer.addSubview(nextTileView)
        nextTileView.translatesAutoresizingMaskIntoConstraints = false

        nextSectionView.addSubview(nextLabel)
        nextLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nextSectionView.widthAnchor.constraint(equalToConstant: smallTileSize + 16),
            nextSectionView.heightAnchor.constraint(equalToConstant: smallTileSize + 36),

            nextTileContainer.topAnchor.constraint(equalTo: nextSectionView.topAnchor),
            nextTileContainer.leadingAnchor.constraint(equalTo: nextSectionView.leadingAnchor),
            nextTileContainer.trailingAnchor.constraint(equalTo: nextSectionView.trailingAnchor),
            nextTileContainer.widthAnchor.constraint(equalToConstant: smallTileSize + 16),
            nextTileContainer.heightAnchor.constraint(equalToConstant: smallTileSize + 16),

            nextTileView.centerXAnchor.constraint(equalTo: nextTileContainer.centerXAnchor),
            nextTileView.centerYAnchor.constraint(equalTo: nextTileContainer.centerYAnchor),
            nextTileView.widthAnchor.constraint(equalToConstant: smallTileSize),
            nextTileView.heightAnchor.constraint(equalToConstant: smallTileSize),

            nextLabel.topAnchor.constraint(equalTo: nextTileContainer.bottomAnchor, constant: 4),
            nextLabel.leadingAnchor.constraint(equalTo: nextSectionView.leadingAnchor),
            nextLabel.trailingAnchor.constraint(equalTo: nextSectionView.trailingAnchor),
            nextLabel.bottomAnchor.constraint(equalTo: nextSectionView.bottomAnchor)
        ])
    }

    private func buildHoldSlotSection() {
        holdSectionView.translatesAutoresizingMaskIntoConstraints = false

        holdSectionView.addSubview(holdSlotContainer)
        holdSlotContainer.translatesAutoresizingMaskIntoConstraints = false

        holdSlotContainer.addSubview(holdIconView)
        holdIconView.translatesAutoresizingMaskIntoConstraints = false

        holdSlotContainer.addSubview(holdTileView)
        holdTileView.translatesAutoresizingMaskIntoConstraints = false
        holdTileView.isHidden = true

        holdSectionView.addSubview(holdLabel)
        holdLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            holdSectionView.widthAnchor.constraint(equalToConstant: tileSize + 20),
            holdSectionView.heightAnchor.constraint(equalToConstant: tileSize + 40),

            holdSlotContainer.topAnchor.constraint(equalTo: holdSectionView.topAnchor),
            holdSlotContainer.leadingAnchor.constraint(equalTo: holdSectionView.leadingAnchor),
            holdSlotContainer.trailingAnchor.constraint(equalTo: holdSectionView.trailingAnchor),
            holdSlotContainer.widthAnchor.constraint(equalToConstant: tileSize + 20),
            holdSlotContainer.heightAnchor.constraint(equalToConstant: tileSize + 20),

            holdIconView.centerXAnchor.constraint(equalTo: holdSlotContainer.centerXAnchor),
            holdIconView.centerYAnchor.constraint(equalTo: holdSlotContainer.centerYAnchor),
            holdIconView.widthAnchor.constraint(equalToConstant: 30),
            holdIconView.heightAnchor.constraint(equalToConstant: 30),

            holdTileView.centerXAnchor.constraint(equalTo: holdSlotContainer.centerXAnchor),
            holdTileView.centerYAnchor.constraint(equalTo: holdSlotContainer.centerYAnchor),
            holdTileView.widthAnchor.constraint(equalToConstant: tileSize),
            holdTileView.heightAnchor.constraint(equalToConstant: tileSize),

            holdLabel.topAnchor.constraint(equalTo: holdSlotContainer.bottomAnchor, constant: 4),
            holdLabel.leadingAnchor.constraint(equalTo: holdSectionView.leadingAnchor),
            holdLabel.trailingAnchor.constraint(equalTo: holdSectionView.trailingAnchor),
            holdLabel.bottomAnchor.constraint(equalTo: holdSectionView.bottomAnchor)
        ])
    }

    private func configureGestureRecognizers() {
        let holdTap = UITapGestureRecognizer(target: self, action: #selector(handleHoldTap))
        holdSlotContainer.addGestureRecognizer(holdTap)

        let currentTap = UITapGestureRecognizer(target: self, action: #selector(handleCurrentTileTap))
        currentTileContainer.addGestureRecognizer(currentTap)
    }

    @objc private func handleHoldTap() {
        AuralFeedbackManager.shared.emitButtonTapFeedback()
        MotionEffectsLibrary.applyBounceEffect(to: holdSlotContainer)

        if holdTileView.tilePiece != nil {
            dispensaryDelegate?.dispensaryDidSelectHeldTile()
        } else {
            dispensaryDelegate?.dispensaryDidRequestHoldToggle()
        }
    }

    @objc private func handleCurrentTileTap() {
        AuralFeedbackManager.shared.emitButtonTapFeedback()
        MotionEffectsLibrary.applyBounceEffect(to: currentTileContainer)
        dispensaryDelegate?.dispensaryDidRequestHoldToggle()
    }

    // MARK: - Public Methods

    /// Updates the current tile display
    func updateCurrentTile(_ tile: CeramicTilePiece?) {
        if let tile = tile {
            currentTileView.configureTile(tile)
            currentTileView.isHidden = false
        } else {
            currentTileView.clearTile()
            currentTileView.isHidden = true
        }
    }

    /// Updates the next tile display
    func updateNextTile(_ tile: CeramicTilePiece?) {
        if let tile = tile {
            nextTileView.configureTile(tile)
            nextTileView.isHidden = false
        } else {
            nextTileView.clearTile()
            nextTileView.isHidden = true
        }
    }

    /// Updates the hold slot display
    func updateHoldSlot(_ tile: CeramicTilePiece?) {
        if let tile = tile {
            holdTileView.configureTile(tile)
            holdTileView.isHidden = false
            holdIconView.isHidden = true
            holdSlotContainer.layer.borderColor = ChromaticPalette.cascadePurple.cgColor
        } else {
            holdTileView.clearTile()
            holdTileView.isHidden = true
            holdIconView.isHidden = false
            holdSlotContainer.layer.borderColor = ChromaticPalette.cascadePurple.withOpacityLevel(0.6).cgColor
        }
    }

    /// Enables or disables hold interaction
    func setHoldEnabled(_ enabled: Bool) {
        holdSlotContainer.alpha = enabled ? 1.0 : 0.5
        holdSlotContainer.isUserInteractionEnabled = enabled
    }
}
