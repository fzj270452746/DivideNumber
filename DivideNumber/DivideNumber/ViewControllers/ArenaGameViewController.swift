//
//  ArenaGameViewController.swift
//  DivideNumber
//
//  Main game screen view controller
//

import UIKit

/// Main game view controller
class ArenaGameViewController: UIViewController {

    // MARK: - Properties

    private let difficulty: LabyrinthDifficulty
    private var sessionOrchestrator: SessionOrchestrator!

    private let gradientLayer = CAGradientLayer()

    // Header section
    private let headerContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private let pauseButton: IconButton = {
        let button = IconButton(iconName: "pause.fill")
        return button
    }()

    private let difficultyBadge: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()

    private let scoreDisplayView = ScoreDisplayView()

    // Board section
    private var mosaicBoardView: MosaicBoardView!

    // Dispensary section
    private let dispensaryContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.slateCardBackground.withOpacityLevel(0.5)
        view.layer.cornerRadius = 16
        return view
    }()

    private let tileDispensaryView = TileDispensaryView()

    // Control buttons
    private let controlsContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private let restartButton: IconButton = {
        let button = IconButton(iconName: "arrow.counterclockwise", iconColor: ChromaticPalette.alabasterText, backgroundTint: ChromaticPalette.slateCardBackground)
        return button
    }()

    // State tracking
    private var isUsingHeldTile: Bool = false

    // MARK: - Initialization

    init(difficulty: LabyrinthDifficulty) {
        self.difficulty = difficulty
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSession()
        configureGradientBackground()
        configureVisualHierarchy()
        configureInteractions()
        synchronizeUI()
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

    private func initializeSession() {
        sessionOrchestrator = SessionOrchestrator(difficultyTier: difficulty)
        sessionOrchestrator.sessionDelegate = self
    }

    private func configureGradientBackground() {
        gradientLayer.colors = ChromaticPalette.homeGradientColors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func configureVisualHierarchy() {
        configureHeader()
        configureBoard()
        configureDispensary()
        configureControls()
    }

    private func configureHeader() {
        view.embedSubview(headerContainerView)
        headerContainerView.anchorRelative(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            topConstant: 8,
            leadingConstant: 16,
            trailingConstant: 16
        )
        headerContainerView.anchorToFixedHeight(70)

        // Pause button
        headerContainerView.embedSubview(pauseButton)
        pauseButton.anchorRelative(
            top: headerContainerView.topAnchor,
            leading: headerContainerView.leadingAnchor
        )
        pauseButton.anchorToFixedSize(width: 44, height: 44)

        // Difficulty badge
        headerContainerView.embedSubview(difficultyBadge)
        difficultyBadge.anchorRelative(
            top: headerContainerView.topAnchor,
            leading: pauseButton.trailingAnchor,
            leadingConstant: 8
        )
        difficultyBadge.anchorToFixedHeight(24)
        difficultyBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true

        let difficultyColor = ChromaticPalette.colorForDifficulty(difficulty)
        difficultyBadge.backgroundColor = difficultyColor.withOpacityLevel(0.3)
        difficultyBadge.textColor = difficultyColor
        difficultyBadge.text = "  \(difficulty.epithetLabel)  "

        // Score display
        headerContainerView.embedSubview(scoreDisplayView)
        scoreDisplayView.anchorRelative(
            top: headerContainerView.topAnchor,
            trailing: headerContainerView.trailingAnchor
        )
        scoreDisplayView.anchorToFixedHeight(70)

        // Set high score
        let highScore = ArchivalVaultManager.shared.retrieveZenithScore(for: difficulty)
        scoreDisplayView.updateHighScore(highScore)
    }

    private func configureBoard() {
        mosaicBoardView = MosaicBoardView(difficultyTier: difficulty)
        mosaicBoardView.boardDelegate = self

        view.embedSubview(mosaicBoardView)
        mosaicBoardView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mosaicBoardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true

        // Calculate board size based on screen
        let padding: CGFloat = 32
        let maxWidth = view.bounds.width - padding
        let maxHeight = view.bounds.height * 0.45

        let dimension = CGFloat(difficulty.matrixDimension)
        let cellSize = min(maxWidth / dimension, maxHeight / dimension)
        let boardSize = cellSize * dimension + 24 // Adding padding

        mosaicBoardView.anchorToFixedSize(width: min(boardSize, maxWidth), height: min(boardSize, maxWidth))
    }

    private func configureDispensary() {
        view.embedSubview(dispensaryContainerView)
        dispensaryContainerView.anchorRelative(
            top: mosaicBoardView.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            topConstant: 30,
            leadingConstant: 24,
            trailingConstant: 24
        )
        dispensaryContainerView.anchorToFixedHeight(120)

        dispensaryContainerView.embedSubview(tileDispensaryView)
        tileDispensaryView.anchorToCenterOfSuperview()
        tileDispensaryView.dispensaryDelegate = self
    }

    private func configureControls() {
        view.embedSubview(controlsContainerView)
        controlsContainerView.anchorRelative(
            top: dispensaryContainerView.bottomAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            topConstant: 16,
            bottomConstant: 16
        )
        controlsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        controlsContainerView.embedSubview(restartButton)
        restartButton.anchorToCenterOfSuperview()
        restartButton.anchorToFixedSize(width: 50, height: 50)
    }

    private func configureInteractions() {
        pauseButton.addTarget(self, action: #selector(handlePauseTapped), for: .touchUpInside)
        restartButton.addTarget(self, action: #selector(handleRestartTapped), for: .touchUpInside)
    }

    // MARK: - UI Synchronization

    private func synchronizeUI() {
        updateDispensaryDisplay()
        mosaicBoardView.synchronizeWithState(sessionOrchestrator.boardState)
    }

    private func updateDispensaryDisplay() {
        tileDispensaryView.updateCurrentTile(sessionOrchestrator.currentTile)
        tileDispensaryView.updateNextTile(sessionOrchestrator.nextTile)
        tileDispensaryView.updateHoldSlot(sessionOrchestrator.heldTile)
    }

    // MARK: - Actions

    @objc private func handlePauseTapped() {
        AuralFeedbackManager.shared.emitButtonTapFeedback()

        OverlayDialogPresenter.showPauseDialog(
            in: self,
            onResume: { },
            onRestart: { [weak self] in
                self?.restartGame()
            },
            onMainMenu: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        )
    }

    @objc private func handleRestartTapped() {
        AuralFeedbackManager.shared.emitButtonTapFeedback()

        OverlayDialogPresenter.showConfirmationDialog(
            in: self,
            title: "Restart Game?",
            message: "Your current progress will be lost.",
            confirmTitle: "Restart",
            cancelTitle: "Cancel"
        ) { [weak self] in
            self?.restartGame()
        }
    }

    private func restartGame() {
        sessionOrchestrator.resetSession()
        mosaicBoardView.resetBoard()
        synchronizeUI()
        isUsingHeldTile = false
    }

    private func handleGameOver(finalScore: Int) {
        let highScore = ArchivalVaultManager.shared.retrieveZenithScore(for: difficulty)
        let isNewHighScore = finalScore > highScore

        if isNewHighScore {
            scoreDisplayView.celebrateNewHighScore()
        }

        AuralFeedbackManager.shared.emitGameOverFeedback()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            OverlayDialogPresenter.showGameOverDialog(
                in: self,
                score: finalScore,
                highScore: max(highScore, finalScore),
                isNewHighScore: isNewHighScore,
                onRestart: { [weak self] in
                    self?.restartGame()
                },
                onMainMenu: { [weak self] in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            )
        }
    }
}

// MARK: - MosaicBoardViewDelegate

extension ArenaGameViewController: MosaicBoardViewDelegate {
    func boardDidReceiveTilePlacement(at coordinate: GridCoordinate) {
        var success: Bool

        if isUsingHeldTile {
            success = sessionOrchestrator.attemptHeldTilePlacement(at: coordinate)
            isUsingHeldTile = false
        } else {
            success = sessionOrchestrator.attemptPlacement(at: coordinate)
        }

        if success {
            AuralFeedbackManager.shared.emitPlacementFeedback()
        } else {
            AuralFeedbackManager.shared.emitInvalidActionFeedback()
            mosaicBoardView.cellAt(coordinate: coordinate)?.showValidationState(false)
        }
    }
}

// MARK: - TileDispensaryViewDelegate

extension ArenaGameViewController: TileDispensaryViewDelegate {
    func dispensaryDidRequestHoldToggle() {
        let success = sessionOrchestrator.toggleHold()
        if !success {
            AuralFeedbackManager.shared.emitInvalidActionFeedback()
        }
    }

    func dispensaryDidSelectHeldTile() {
        if sessionOrchestrator.heldTile != nil {
            isUsingHeldTile = true
            // Highlight empty cells to indicate placement mode
            let emptyCoords = sessionOrchestrator.boardState.vacantCoordinates()
            mosaicBoardView.highlightValidCells(emptyCoords)

            // Clear highlight after a delay if no action taken
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.mosaicBoardView.clearAllHighlights()
            }
        }
    }
}

// MARK: - SessionOrchestratorDelegate

extension ArenaGameViewController: SessionOrchestratorDelegate {
    func orchestratorDidUpdateScore(_ newScore: Int) {
        scoreDisplayView.updateScore(newScore)
    }

    func orchestratorDidChangePhase(_ phase: SessionPhase) {
        // Handle phase changes if needed
    }

    func orchestratorDidPlaceTile(_ tile: CeramicTilePiece, at coordinate: GridCoordinate) {
        mosaicBoardView.installTile(tile, at: coordinate)
    }

    func orchestratorDidProcessElimination(_ outcome: EliminationOutcome) {
        AuralFeedbackManager.shared.emitEliminationFeedback()

        switch outcome.category {
        case .identical:
            // Remove all identical tiles with animation
            for coord in outcome.involvedCoordinates {
                mosaicBoardView.expungeTile(at: coord, animated: true)

                // Show floating score
                if let center = mosaicBoardView.centerPointForCell(at: coord) {
                    let globalCenter = mosaicBoardView.convert(center, to: view)
                    MotionEffectsLibrary.showFloatingScore(outcome.earnedPoints / outcome.involvedCoordinates.count, at: globalCenter, in: view)
                    MotionEffectsLibrary.createEliminationBurst(at: globalCenter, in: view, color: ChromaticPalette.aurelianAccent)
                }
            }

        case .quotient:
            // Remove the smaller tile
            for coord in outcome.involvedCoordinates {
                if coord != outcome.transformedCoordinate {
                    mosaicBoardView.expungeTile(at: coord, animated: true)

                    if let center = mosaicBoardView.centerPointForCell(at: coord) {
                        let globalCenter = mosaicBoardView.convert(center, to: view)
                        MotionEffectsLibrary.createEliminationBurst(at: globalCenter, in: view, color: ChromaticPalette.cascadePurple)
                    }
                }
            }

            // Transform the larger tile
            if let transformedCoord = outcome.transformedCoordinate,
               let resultMagnitude = outcome.resultantMagnitude,
               let originalTile = sessionOrchestrator.boardState.retrieveTile(at: transformedCoord) {
                let newPiece = originalTile.metamorphosedPiece(withMagnitude: resultMagnitude)
                mosaicBoardView.transmutateTile(at: transformedCoord, to: newPiece)

                if let center = mosaicBoardView.centerPointForCell(at: transformedCoord) {
                    let globalCenter = mosaicBoardView.convert(center, to: view)
                    MotionEffectsLibrary.showFloatingScore(outcome.earnedPoints, at: globalCenter, in: view, color: ChromaticPalette.cascadePurple)
                }
            }
        }

        // Chain reaction feedback
        if outcome.chainDepth > 0 {
            AuralFeedbackManager.shared.emitChainReactionFeedback()
        }
    }

    func orchestratorDidCompleteEliminations(_ resolution: PlacementResolution) {
        // Sync board state after all eliminations complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.mosaicBoardView.synchronizeWithState(self.sessionOrchestrator.boardState)
        }
    }

    func orchestratorDidEndGame(finalScore: Int) {
        handleGameOver(finalScore: finalScore)
    }

    func orchestratorDidUpdateDispensary() {
        updateDispensaryDisplay()
    }

    func orchestratorDidUpdateHoldSlot(_ tile: CeramicTilePiece?) {
        tileDispensaryView.updateHoldSlot(tile)
    }
}
