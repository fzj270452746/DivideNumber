//
//  ChronicleLeaderboardViewController.swift
//  DivideNumber
//
//  Leaderboard display screen
//

import UIKit

/// View controller for displaying leaderboard
class ChronicleLeaderboardViewController: UIViewController {

    // MARK: - Properties

    private let gradientLayer = CAGradientLayer()

    private var selectedDifficulty: LabyrinthDifficulty = .novice
    private var leaderboardRecords: [LeaderboardRecord] = []

    private let backButton: IconButton = {
        let button = IconButton(iconName: "chevron.left")
        return button
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Leaderboard"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = ChromaticPalette.alabasterText
        label.textAlignment = .center
        return label
    }()

    private let segmentedControl: UISegmentedControl = {
        let items = LabyrinthDifficulty.allCases.map { $0.epithetLabel }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.backgroundColor = ChromaticPalette.slateCardBackground
        control.selectedSegmentTintColor = ChromaticPalette.aurelianAccent
        control.setTitleTextAttributes([.foregroundColor: ChromaticPalette.ebonyText], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: ChromaticPalette.alabasterText], for: .normal)
        return control
    }()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        return table
    }()

    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No scores yet!\nPlay a game to get on the board."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = ChromaticPalette.pearlSecondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let emptyStateIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "trophy")
        imageView.tintColor = ChromaticPalette.pearlSecondaryText.withOpacityLevel(0.5)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGradientBackground()
        configureVisualHierarchy()
        configureTableView()
        configureInteractions()
        loadLeaderboardData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadLeaderboardData()
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

        // Segmented control
        view.embedSubview(segmentedControl)
        segmentedControl.anchorRelative(
            top: headerLabel.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            topConstant: 24,
            leadingConstant: 20,
            trailingConstant: 20
        )
        segmentedControl.anchorToFixedHeight(36)

        // Table view
        view.embedSubview(tableView)
        tableView.anchorRelative(
            top: segmentedControl.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            topConstant: 20,
            leadingConstant: 20,
            trailingConstant: 20
        )

        // Empty state
        view.embedSubview(emptyStateView)
        emptyStateView.anchorToCenterOfSuperview()
        emptyStateView.anchorToFixedSize(width: 200, height: 150)

        emptyStateView.embedSubview(emptyStateIcon)
        emptyStateIcon.anchorRelative(
            top: emptyStateView.topAnchor,
            leading: emptyStateView.leadingAnchor,
            trailing: emptyStateView.trailingAnchor
        )
        emptyStateIcon.anchorToFixedHeight(60)

        emptyStateView.embedSubview(emptyStateLabel)
        emptyStateLabel.anchorRelative(
            top: emptyStateIcon.bottomAnchor,
            leading: emptyStateView.leadingAnchor,
            trailing: emptyStateView.trailingAnchor,
            bottom: emptyStateView.bottomAnchor,
            topConstant: 16
        )
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LeaderboardEntryCell.self, forCellReuseIdentifier: LeaderboardEntryCell.reuseIdentifier)
    }

    private func configureInteractions() {
        backButton.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(handleSegmentChanged), for: .valueChanged)
    }

    // MARK: - Data

    private func loadLeaderboardData() {
        leaderboardRecords = ArchivalVaultManager.shared.retrieveChronicle(for: selectedDifficulty)
        tableView.reloadData()

        emptyStateView.isHidden = !leaderboardRecords.isEmpty
        tableView.isHidden = leaderboardRecords.isEmpty
    }

    // MARK: - Actions

    @objc private func handleBackTapped() {
        AuralFeedbackManager.shared.emitButtonTapFeedback()
        navigationController?.popViewController(animated: true)
    }

    @objc private func handleSegmentChanged() {
        AuralFeedbackManager.shared.emitSelectionChange()
        selectedDifficulty = LabyrinthDifficulty.allCases[segmentedControl.selectedSegmentIndex]
        loadLeaderboardData()
    }
}

// MARK: - UITableViewDelegate & DataSource

extension ChronicleLeaderboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardEntryCell.reuseIdentifier, for: indexPath) as? LeaderboardEntryCell else {
            return UITableViewCell()
        }

        let record = leaderboardRecords[indexPath.row]
        cell.configureCell(rank: indexPath.row + 1, record: record)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - LeaderboardEntryCell

class LeaderboardEntryCell: UITableViewCell {

    static let reuseIdentifier = "LeaderboardEntryCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.slateCardBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let rankBadgeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        return view
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = ChromaticPalette.aurelianAccent
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = ChromaticPalette.pearlSecondaryText
        return label
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureVisualHierarchy()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configureVisualHierarchy() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.embedSubview(containerView)
        containerView.anchorToSuperviewEdges(insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))

        containerView.embedSubview(rankBadgeView)
        rankBadgeView.anchorRelative(
            leading: containerView.leadingAnchor,
            leadingConstant: 12
        )
        rankBadgeView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        rankBadgeView.anchorToFixedSize(width: 36, height: 36)

        rankBadgeView.embedSubview(rankLabel)
        rankLabel.anchorToCenterOfSuperview()

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 4

        containerView.embedSubview(textStack)
        textStack.anchorRelative(
            trailing: containerView.trailingAnchor,
            trailingConstant: 16
        )
        textStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        textStack.addArrangedSubview(scoreLabel)
        textStack.addArrangedSubview(dateLabel)
    }

    func configureCell(rank: Int, record: LeaderboardRecord) {
        rankLabel.text = "\(rank)"

        // Rank styling
        switch rank {
        case 1:
            rankBadgeView.backgroundColor = ChromaticPalette.aurelianAccent
            rankLabel.textColor = ChromaticPalette.ebonyText
        case 2:
            rankBadgeView.backgroundColor = UIColor(hex: "#C0C0C0")
            rankLabel.textColor = ChromaticPalette.ebonyText
        case 3:
            rankBadgeView.backgroundColor = UIColor(hex: "#CD7F32")
            rankLabel.textColor = ChromaticPalette.alabasterText
        default:
            rankBadgeView.backgroundColor = ChromaticPalette.obsidianBackground
            rankLabel.textColor = ChromaticPalette.alabasterText
        }

        scoreLabel.text = NumberFormatter.localizedString(from: NSNumber(value: record.achievedScore), number: .decimal)
        dateLabel.text = record.formattedChronology
    }
}
