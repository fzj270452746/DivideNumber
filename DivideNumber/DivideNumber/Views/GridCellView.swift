//
//  GridCellView.swift
//  DivideNumber
//
//  Represents a single cell on the game board
//

import UIKit

/// Delegate for cell interaction events
protocol GridCellViewDelegate: AnyObject {
    func cellDidReceiveTap(_ cell: GridCellView)
    func cellDidReceiveDrop(_ cell: GridCellView, tile: CeramicTilePiece)
}

/// View representing a single cell on the game board
class GridCellView: UIView {

    // MARK: - Properties

    weak var interactionDelegate: GridCellViewDelegate?

    let coordinate: GridCoordinate

    private(set) var tileView: CeramicTileView?

    private var hasConfiguredLayout: Bool = false

    private let baseLayer: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.ivoryCell.withOpacityLevel(0.3)
        view.layer.borderWidth = 1
        view.layer.borderColor = ChromaticPalette.bronzeCellBorder.withOpacityLevel(0.5).cgColor
        return view
    }()

    private let highlightOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.aurelianAccent.withOpacityLevel(0.3)
        view.alpha = 0
        view.isUserInteractionEnabled = false
        return view
    }()

    var isOccupied: Bool {
        return tileView?.tilePiece != nil
    }

    // MARK: - Initialization

    init(coordinate: GridCoordinate) {
        self.coordinate = coordinate
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
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        baseLayer.layer.cornerRadius = bounds.width * 0.1
        highlightOverlay.layer.cornerRadius = bounds.width * 0.1
    }

    // MARK: - Configuration

    private func configureVisualHierarchy() {
        // Base layer
        addSubview(baseLayer)
        baseLayer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            baseLayer.topAnchor.constraint(equalTo: topAnchor),
            baseLayer.leadingAnchor.constraint(equalTo: leadingAnchor),
            baseLayer.trailingAnchor.constraint(equalTo: trailingAnchor),
            baseLayer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Highlight overlay
        addSubview(highlightOverlay)
        highlightOverlay.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            highlightOverlay.topAnchor.constraint(equalTo: topAnchor),
            highlightOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            highlightOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            highlightOverlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func configureGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        addGestureRecognizer(tapGesture)

        isUserInteractionEnabled = true
    }

    @objc private func handleTapGesture() {
        interactionDelegate?.cellDidReceiveTap(self)
    }

    // MARK: - Tile Management

    /// Places a tile in this cell
    func installTile(_ piece: CeramicTilePiece, animated: Bool = true) {
        // Remove existing tile if any
        tileView?.removeFromSuperview()

        // Create new tile view
        let newTileView = CeramicTileView()

        addSubview(newTileView)
        newTileView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            newTileView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            newTileView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            newTileView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            newTileView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])

        self.tileView = newTileView

        // Configure after adding to view hierarchy
        newTileView.configureTile(piece)

        if animated {
            newTileView.playPlacementAnimation()
        }
    }

    /// Removes the tile from this cell
    func expungeTile(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let existingTileView = tileView else {
            completion?()
            return
        }

        if animated {
            existingTileView.playEliminationAnimation { [weak self] in
                existingTileView.removeFromSuperview()
                self?.tileView = nil
                completion?()
            }
        } else {
            existingTileView.removeFromSuperview()
            tileView = nil
            completion?()
        }
    }

    /// Transforms the tile to a new value
    func transmutateTile(to newPiece: CeramicTilePiece, animated: Bool = true) {
        tileView?.transmutateTo(newPiece, animated: animated)
    }

    // MARK: - Highlight

    /// Shows placement highlight
    func showPlacementHighlight(_ show: Bool) {
        UIView.animate(withDuration: 0.15) {
            self.highlightOverlay.alpha = show ? 1 : 0
        }
    }

    /// Shows valid/invalid state
    func showValidationState(_ isValid: Bool) {
        let color = isValid ? ChromaticPalette.triumphantGreen : ChromaticPalette.vermilionAlert
        highlightOverlay.backgroundColor = color.withOpacityLevel(0.4)
        showPlacementHighlight(true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.highlightOverlay.backgroundColor = ChromaticPalette.aurelianAccent.withOpacityLevel(0.3)
            self?.showPlacementHighlight(false)
        }
    }
}
