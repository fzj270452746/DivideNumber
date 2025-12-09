//
//  MosaicBoardView.swift
//  DivideNumber
//
//  Visual representation of the game board
//

import UIKit

/// Delegate for board interaction events
protocol MosaicBoardViewDelegate: AnyObject {
    func boardDidReceiveTilePlacement(at coordinate: GridCoordinate)
}

/// View representing the entire game board
class MosaicBoardView: UIView {

    // MARK: - Properties

    weak var boardDelegate: MosaicBoardViewDelegate?

    private let difficultyTier: LabyrinthDifficulty
    private var cellGrid: [[GridCellView]] = []

    private var hasConfiguredLayout: Bool = false

    private let boardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.mahoganyBoardBase
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 4
        view.layer.borderColor = ChromaticPalette.bronzeCellBorder.cgColor
        view.clipsToBounds = true
        return view
    }()

    private let gridStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 6
        return stack
    }()

    private var cellSize: CGFloat = 60

    // MARK: - Initialization

    init(difficultyTier: LabyrinthDifficulty) {
        self.difficultyTier = difficultyTier
        super.init(frame: .zero)
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
            constructCellGrid()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureBoardShadow()
    }

    // MARK: - Configuration

    private func configureVisualHierarchy() {
        // Add decorative background gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = ChromaticPalette.boardGradientColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        boardContainer.layer.insertSublayer(gradientLayer, at: 0)

        addSubview(boardContainer)
        boardContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            boardContainer.topAnchor.constraint(equalTo: topAnchor),
            boardContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            boardContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            boardContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        boardContainer.addSubview(gridStackView)
        gridStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            gridStackView.topAnchor.constraint(equalTo: boardContainer.topAnchor, constant: 12),
            gridStackView.leadingAnchor.constraint(equalTo: boardContainer.leadingAnchor, constant: 12),
            gridStackView.trailingAnchor.constraint(equalTo: boardContainer.trailingAnchor, constant: -12),
            gridStackView.bottomAnchor.constraint(equalTo: boardContainer.bottomAnchor, constant: -12)
        ])
    }

    private func constructCellGrid() {
        let dimension = difficultyTier.matrixDimension

        for row in 0..<dimension {
            var rowCells: [GridCellView] = []
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 6

            for col in 0..<dimension {
                let coordinate = GridCoordinate(rowIndex: row, columnIndex: col)
                let cell = GridCellView(coordinate: coordinate)
                cell.interactionDelegate = self

                rowCells.append(cell)
                rowStack.addArrangedSubview(cell)
            }

            cellGrid.append(rowCells)
            gridStackView.addArrangedSubview(rowStack)
        }
    }

    private func configureBoardShadow() {
        boardContainer.layer.shadowColor = UIColor.black.cgColor
        boardContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
        boardContainer.layer.shadowRadius = 16
        boardContainer.layer.shadowOpacity = 0.5
        boardContainer.layer.masksToBounds = false

        // Update gradient frame
        if let gradientLayer = boardContainer.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = boardContainer.bounds
        }
    }

    // MARK: - Public Methods

    /// Gets the cell at the specified coordinate
    func cellAt(coordinate: GridCoordinate) -> GridCellView? {
        guard coordinate.rowIndex >= 0 && coordinate.rowIndex < cellGrid.count,
              coordinate.columnIndex >= 0 && coordinate.columnIndex < cellGrid[coordinate.rowIndex].count else {
            return nil
        }
        return cellGrid[coordinate.rowIndex][coordinate.columnIndex]
    }

    /// Places a tile at the specified coordinate
    func installTile(_ piece: CeramicTilePiece, at coordinate: GridCoordinate, animated: Bool = true) {
        guard let cell = cellAt(coordinate: coordinate) else { return }
        cell.installTile(piece, animated: animated)
    }

    /// Removes a tile at the specified coordinate
    func expungeTile(at coordinate: GridCoordinate, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let cell = cellAt(coordinate: coordinate) else {
            completion?()
            return
        }
        cell.expungeTile(animated: animated, completion: completion)
    }

    /// Transforms a tile at the specified coordinate
    func transmutateTile(at coordinate: GridCoordinate, to newPiece: CeramicTilePiece, animated: Bool = true) {
        guard let cell = cellAt(coordinate: coordinate) else { return }
        cell.transmutateTile(to: newPiece, animated: animated)
    }

    /// Highlights valid placement cells
    func highlightValidCells(_ coordinates: [GridCoordinate]) {
        for row in cellGrid {
            for cell in row {
                let shouldHighlight = coordinates.contains(cell.coordinate)
                cell.showPlacementHighlight(shouldHighlight)
            }
        }
    }

    /// Clears all highlights
    func clearAllHighlights() {
        for row in cellGrid {
            for cell in row {
                cell.showPlacementHighlight(false)
            }
        }
    }

    /// Resets the board to empty state
    func resetBoard() {
        for row in cellGrid {
            for cell in row {
                cell.expungeTile(animated: false)
            }
        }
    }

    /// Gets the center point of a cell in the board's coordinate system
    func centerPointForCell(at coordinate: GridCoordinate) -> CGPoint? {
        guard let cell = cellAt(coordinate: coordinate) else { return nil }
        return cell.superview?.convert(cell.center, to: self)
    }

    /// Syncs the view with board state
    func synchronizeWithState(_ boardState: MosaicBoardState) {
        let dimension = difficultyTier.matrixDimension

        for row in 0..<dimension {
            for col in 0..<dimension {
                let coordinate = GridCoordinate(rowIndex: row, columnIndex: col)
                guard let cell = cellAt(coordinate: coordinate) else { continue }

                if let tile = boardState.retrieveTile(at: coordinate) {
                    if cell.tileView?.tilePiece?.fragmentIdentifier != tile.fragmentIdentifier {
                        cell.installTile(tile, animated: false)
                    }
                } else {
                    if cell.isOccupied {
                        cell.expungeTile(animated: false)
                    }
                }
            }
        }
    }
}

// MARK: - GridCellViewDelegate

extension MosaicBoardView: GridCellViewDelegate {
    func cellDidReceiveTap(_ cell: GridCellView) {
        boardDelegate?.boardDidReceiveTilePlacement(at: cell.coordinate)
    }

    func cellDidReceiveDrop(_ cell: GridCellView, tile: CeramicTilePiece) {
        boardDelegate?.boardDidReceiveTilePlacement(at: cell.coordinate)
    }
}
