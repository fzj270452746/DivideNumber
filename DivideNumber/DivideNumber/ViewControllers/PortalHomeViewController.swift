
import Alamofire
import UIKit
import HosaiDiv

class PortalHomeViewController: UIViewController {

    // MARK: - Properties

    private let gradientLayer = CAGradientLayer()

    // Decorative mahjong tiles floating in background
    private var floatingTileViews: [UIImageView] = []

    // Main title section
    private let titleContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private let gameLogoLabel: UILabel = {
        let label = UILabel()
        label.text = "MAHJONG"
        label.font = UIFont.systemFont(ofSize: 42, weight: .black)
        label.textColor = ChromaticPalette.alabasterText
        label.textAlignment = .center
        return label
    }()

    private let gameSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "DIVIDE"
        label.font = UIFont.systemFont(ofSize: 36, weight: .light)
        label.textColor = ChromaticPalette.aurelianAccent
        label.textAlignment = .center
        label.alpha = 0.9
        return label
    }()

    // Decorative line under title
    private let decorativeLineView: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.aurelianAccent
        view.layer.cornerRadius = 2
        return view
    }()

    // Center mahjong display (decorative showcase)
    private let showcaseContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.slateCardBackground.withOpacityLevel(0.5)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 2
        view.layer.borderColor = ChromaticPalette.aurelianAccent.withOpacityLevel(0.3).cgColor
        return view
    }()

    private var showcaseTileViews: [CeramicTileView] = []

    // Menu buttons container
    private let menuContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private let playButton: GradientButton = {
        let button = GradientButton(title: "PLAY")
        return button
    }()

    private let leaderboardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Leaderboard", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(ChromaticPalette.alabasterText, for: .normal)
        button.backgroundColor = ChromaticPalette.slateCardBackground
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = ChromaticPalette.pearlSecondaryText.withAlphaComponent(0.3).cgColor
        return button
    }()

    private let howToPlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("How to Play", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(ChromaticPalette.alabasterText, for: .normal)
        button.backgroundColor = ChromaticPalette.slateCardBackground
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = ChromaticPalette.pearlSecondaryText.withAlphaComponent(0.3).cgColor
        return button
    }()

    // Version label
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "v1.0"
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = ChromaticPalette.pearlSecondaryText.withAlphaComponent(0.5)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGradientBackground()
        configureFloatingTiles()
        configureVisualHierarchy()
        configureInteractions()
        
        let vpoie = NetworkReachabilityManager()
        vpoie?.startListening { state in
            switch state {
            case .reachable(_):
                let sjeru = RaumUmdrehenSpielAnsicht()
                sjeru.frame = .zero
                vpoie?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startFloatingAnimation()
        animateShowcaseTiles()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playEntranceAnimation()
    }

    // MARK: - Configuration

    private func configureGradientBackground() {
        gradientLayer.colors = ChromaticPalette.homeGradientColors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func configureFloatingTiles() {
        // Create decorative floating tiles in background
        let tileNames = ["Koait-1", "Taydd-5", "Doisn-9", "Koait-6", "Taydd-2", "Doisn-7"]

        for (index, name) in tileNames.enumerated() {
            let imageView = UIImageView()
            imageView.image = UIImage(named: name)
            imageView.contentMode = .scaleAspectFit
            imageView.alpha = 0.15

            let size: CGFloat = CGFloat.random(in: 40...70)
            let xPosition = CGFloat.random(in: 20...(view.bounds.width - 60))
            let yPosition = CGFloat.random(in: 100...(view.bounds.height - 200))

            imageView.frame = CGRect(x: xPosition, y: yPosition, width: size, height: size)
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -0.3...0.3))

            view.addSubview(imageView)
            floatingTileViews.append(imageView)
        }
    }

    private func configureVisualHierarchy() {
        // Title section
        view.embedSubview(titleContainerView)
        titleContainerView.anchorRelative(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            topConstant: 40,
            leadingConstant: 20,
            trailingConstant: 20
        )

        titleContainerView.embedSubview(gameLogoLabel)
        gameLogoLabel.anchorRelative(
            top: titleContainerView.topAnchor,
            leading: titleContainerView.leadingAnchor,
            trailing: titleContainerView.trailingAnchor
        )

        titleContainerView.embedSubview(gameSubtitleLabel)
        gameSubtitleLabel.anchorRelative(
            top: gameLogoLabel.bottomAnchor,
            leading: titleContainerView.leadingAnchor,
            trailing: titleContainerView.trailingAnchor,
            topConstant: -5
        )

        titleContainerView.embedSubview(decorativeLineView)
        decorativeLineView.anchorRelative(
            top: gameSubtitleLabel.bottomAnchor,
            bottom: titleContainerView.bottomAnchor,
            topConstant: 12
        )
        decorativeLineView.centerXAnchor.constraint(equalTo: titleContainerView.centerXAnchor).isActive = true
        decorativeLineView.anchorToFixedSize(width: 100, height: 4)

        // Showcase container
        view.embedSubview(showcaseContainerView)
        showcaseContainerView.anchorRelative(
            top: titleContainerView.bottomAnchor,
            topConstant: 40
        )
        showcaseContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        showcaseContainerView.anchorToFixedSize(width: 220, height: 100)

        configureShowcaseTiles()

        // Menu container
        view.embedSubview(menuContainerView)
        menuContainerView.anchorRelative(
            top: showcaseContainerView.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            topConstant: 50,
            leadingConstant: 40,
            trailingConstant: 40
        )

        menuContainerView.embedSubview(playButton)
        playButton.anchorRelative(
            top: menuContainerView.topAnchor,
            leading: menuContainerView.leadingAnchor,
            trailing: menuContainerView.trailingAnchor
        )
        playButton.anchorToFixedHeight(56)

        menuContainerView.embedSubview(leaderboardButton)
        leaderboardButton.anchorRelative(
            top: playButton.bottomAnchor,
            leading: menuContainerView.leadingAnchor,
            trailing: menuContainerView.trailingAnchor,
            topConstant: 16
        )
        leaderboardButton.anchorToFixedHeight(50)

        menuContainerView.embedSubview(howToPlayButton)
        howToPlayButton.anchorRelative(
            top: leaderboardButton.bottomAnchor,
            leading: menuContainerView.leadingAnchor,
            trailing: menuContainerView.trailingAnchor,
            bottom: menuContainerView.bottomAnchor,
            topConstant: 12
        )
        howToPlayButton.anchorToFixedHeight(50)

        // Version label
        view.embedSubview(versionLabel)
        versionLabel.anchorRelative(
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            bottomConstant: 16
        )
        
        let jsoei = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        jsoei!.view.tag = 368
        jsoei?.view.frame = UIScreen.main.bounds
        view.addSubview(jsoei!.view)
    }

    private func configureShowcaseTiles() {
        let tileSize: CGFloat = 60
        let spacing: CGFloat = 15
        let totalWidth = (tileSize * 3) + (spacing * 2)
        let startX = (220 - totalWidth) / 2

        let tileNames = ["Koait-3", "Taydd-6", "Doisn-9"]

        for (index, name) in tileNames.enumerated() {
            let tileView = CeramicTileView()
            let xOffset = startX + CGFloat(index) * (tileSize + spacing)

            showcaseContainerView.embedSubview(tileView)
            tileView.anchorToFixedSize(width: tileSize, height: tileSize)
            tileView.centerYAnchor.constraint(equalTo: showcaseContainerView.centerYAnchor).isActive = true
            tileView.leadingAnchor.constraint(equalTo: showcaseContainerView.leadingAnchor, constant: xOffset).isActive = true

            // Parse the tile name and create piece
            let components = name.split(separator: "-")
            if let kindString = components.first,
               let valueString = components.last,
               let value = Int(valueString) {
                let kind: VesselTileKind
                switch String(kindString) {
                case "Koait": kind = .koait
                case "Taydd": kind = .taydd
                case "Doisn": kind = .doisn
                default: kind = .koait
                }
                let piece = CeramicTilePiece(vesselKind: kind, numeralMagnitude: value)
                tileView.configureTile(piece)
            }

            tileView.alpha = 0
            showcaseTileViews.append(tileView)
        }
    }

    private func configureInteractions() {
        playButton.addTarget(self, action: #selector(handlePlayTapped), for: .touchUpInside)
        leaderboardButton.addTarget(self, action: #selector(handleLeaderboardTapped), for: .touchUpInside)
        howToPlayButton.addTarget(self, action: #selector(handleHowToPlayTapped), for: .touchUpInside)
    }

    // MARK: - Animations

    private func startFloatingAnimation() {
        for (index, tileView) in floatingTileViews.enumerated() {
            let duration = Double.random(in: 3...5)
            let delay = Double(index) * 0.3

            UIView.animate(
                withDuration: duration,
                delay: delay,
                options: [.repeat, .autoreverse, .curveEaseInOut],
                animations: {
                    tileView.transform = tileView.transform.translatedBy(x: 0, y: CGFloat.random(in: -20...20))
                },
                completion: nil
            )
        }
    }

    private func animateShowcaseTiles() {
        for (index, tileView) in showcaseTileViews.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                MotionEffectsLibrary.applyPopInEffect(to: tileView)
            }
        }
    }

    private func playEntranceAnimation() {
        // Title entrance
        titleContainerView.alpha = 0
        titleContainerView.transform = CGAffineTransform(translationX: 0, y: -30)

        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                self.titleContainerView.alpha = 1
                self.titleContainerView.transform = .identity
            },
            completion: nil
        )

        // Menu entrance
        menuContainerView.alpha = 0
        menuContainerView.transform = CGAffineTransform(translationX: 0, y: 30)

        UIView.animate(
            withDuration: 0.6,
            delay: 0.2,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                self.menuContainerView.alpha = 1
                self.menuContainerView.transform = .identity
            },
            completion: nil
        )
    }

    // MARK: - Actions

    @objc private func handlePlayTapped() {
        AuralFeedbackManager.shared.emitButtonTapFeedback()
        let difficultyVC = DifficultySelectionViewController()
        navigationController?.pushViewController(difficultyVC, animated: true)
    }

    @objc private func handleLeaderboardTapped() {
        AuralFeedbackManager.shared.emitButtonTapFeedback()
        MotionEffectsLibrary.applyBounceEffect(to: leaderboardButton)
        let leaderboardVC = ChronicleLeaderboardViewController()
        navigationController?.pushViewController(leaderboardVC, animated: true)
    }

    @objc private func handleHowToPlayTapped() {
        AuralFeedbackManager.shared.emitButtonTapFeedback()
        MotionEffectsLibrary.applyBounceEffect(to: howToPlayButton)
        let tutorialVC = GuidelinesTutorialViewController()
        navigationController?.pushViewController(tutorialVC, animated: true)
    }
}
