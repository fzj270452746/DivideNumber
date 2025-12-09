//
//  CeramicTileView.swift
//  DivideNumber
//
//  Visual representation of a mahjong tile
//

import UIKit

/// View representing a single mahjong tile
class CeramicTileView: UIView {

    // MARK: - Properties

    private(set) var tilePiece: CeramicTilePiece?

    private var hasConfiguredLayout: Bool = false

    private let pictogramImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let glossOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        view.isUserInteractionEnabled = false
        return view
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureBaseAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureBaseAppearance()
    }

    // MARK: - Layout

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil && !hasConfiguredLayout {
            hasConfiguredLayout = true
            configureVisualHierarchy()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Configure rounded corners
        layer.cornerRadius = bounds.width * 0.12
        glossOverlay.layer.cornerRadius = bounds.width * 0.12

        // Configure gloss overlay gradient mask
        let maskLayer = CAGradientLayer()
        maskLayer.frame = glossOverlay.bounds
        maskLayer.colors = [
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        maskLayer.startPoint = CGPoint(x: 0.5, y: 0)
        maskLayer.endPoint = CGPoint(x: 0.5, y: 0.6)
        glossOverlay.layer.mask = maskLayer
    }

    // MARK: - Configuration

    private func configureBaseAppearance() {
        backgroundColor = ChromaticPalette.ivoryCell
        layer.borderWidth = 2
        layer.borderColor = ChromaticPalette.bronzeCellBorder.cgColor
        clipsToBounds = false

        // Shadow for 3D effect
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2, height: 3)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.4
    }

    private func configureVisualHierarchy() {
        // Add image view
        addSubview(pictogramImageView)
        pictogramImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pictogramImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            pictogramImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            pictogramImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            pictogramImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])

        // Add gloss overlay
        addSubview(glossOverlay)
        glossOverlay.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            glossOverlay.topAnchor.constraint(equalTo: topAnchor),
            glossOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            glossOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            glossOverlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    /// Configures the view with a tile piece
    func configureTile(_ piece: CeramicTilePiece) {
        self.tilePiece = piece
        pictogramImageView.image = UIImage(named: piece.pictogramAssetDesignation)

        // Reset any animations
        transform = .identity
        alpha = 1
    }

    /// Clears the tile view
    func clearTile() {
        self.tilePiece = nil
        pictogramImageView.image = nil
    }

    /// Updates tile to show a new value (for division transformation)
    func transmutateTo(_ newPiece: CeramicTilePiece, animated: Bool = true) {
        if animated {
            // Flash effect
            UIView.animate(withDuration: 0.15, animations: {
                self.backgroundColor = ChromaticPalette.luminousGlow
                self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }) { _ in
                self.configureTile(newPiece)
                UIView.animate(withDuration: 0.15) {
                    self.backgroundColor = ChromaticPalette.ivoryCell
                    self.transform = .identity
                }
            }
        } else {
            configureTile(newPiece)
        }
    }

    // MARK: - Animation Methods

    /// Plays the elimination animation
    func playEliminationAnimation(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.alpha = 0
            },
            completion: { _ in
                self.clearTile()
                self.transform = .identity
                completion?()
            }
        )
    }

    /// Plays the placement animation
    func playPlacementAnimation() {
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        alpha = 0

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: [],
            animations: {
                self.transform = .identity
                self.alpha = 1
            },
            completion: nil
        )
    }

    /// Highlights the tile (for preview/selection)
    func applyHighlight(_ highlighted: Bool) {
        if highlighted {
            layer.borderColor = ChromaticPalette.aurelianAccent.cgColor
            layer.borderWidth = 3
            MotionEffectsLibrary.applyPulsingGlow(to: self, color: ChromaticPalette.aurelianAccent)
        } else {
            layer.borderColor = ChromaticPalette.bronzeCellBorder.cgColor
            layer.borderWidth = 2
            MotionEffectsLibrary.removeGlowEffect(from: self)
        }
    }
}
