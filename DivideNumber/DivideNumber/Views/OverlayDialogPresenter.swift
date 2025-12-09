//
//  OverlayDialogPresenter.swift
//  DivideNumber
//
//  Custom dialog/popup system
//

import UIKit

/// Configuration for dialog appearance
struct DialogConfiguration {
    let title: String
    let message: String?
    let primaryAction: DialogAction?
    let secondaryAction: DialogAction?
    let dismissOnBackgroundTap: Bool

    init(
        title: String,
        message: String? = nil,
        primaryAction: DialogAction? = nil,
        secondaryAction: DialogAction? = nil,
        dismissOnBackgroundTap: Bool = true
    ) {
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
    }
}

/// Dialog action button configuration
struct DialogAction {
    let title: String
    let style: ActionStyle
    let handler: (() -> Void)?

    enum ActionStyle {
        case primary
        case secondary
        case destructive
    }

    init(title: String, style: ActionStyle = .primary, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

/// Custom dialog presenter
class OverlayDialogPresenter: UIView {

    // MARK: - Properties

    private var configuration: DialogConfiguration?
    private var dismissCompletion: (() -> Void)?

    private let backdropView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return view
    }()

    private let dialogContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.slateCardBackground
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 2
        view.layer.borderColor = ChromaticPalette.aurelianAccent.withOpacityLevel(0.3).cgColor
        return view
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = ChromaticPalette.alabasterText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = ChromaticPalette.pearlSecondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    private let decorativeTopBar: UIView = {
        let view = UIView()
        view.backgroundColor = ChromaticPalette.aurelianAccent
        view.layer.cornerRadius = 2
        return view
    }()

    // MARK: - Singleton Presentation

    private static var currentDialog: OverlayDialogPresenter?

    /// Presents a dialog
    static func presentDialog(
        in viewController: UIViewController,
        configuration: DialogConfiguration,
        completion: (() -> Void)? = nil
    ) {
        // Dismiss existing dialog if any
        currentDialog?.dismissDialog(animated: false)

        let dialog = OverlayDialogPresenter()
        dialog.configuration = configuration
        dialog.dismissCompletion = completion

        dialog.configureWithConfiguration(configuration)

        guard let window = viewController.view.window else { return }

        dialog.frame = window.bounds
        window.addSubview(dialog)

        currentDialog = dialog
        dialog.presentAnimated()
    }

    /// Dismisses the current dialog
    static func dismissCurrentDialog(animated: Bool = true) {
        currentDialog?.dismissDialog(animated: animated)
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureVisualHierarchy()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureVisualHierarchy()
    }

    // MARK: - Configuration

    private func configureVisualHierarchy() {
        // Backdrop
        addSubview(backdropView)
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(equalTo: topAnchor),
            backdropView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdropView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Dialog container
        addSubview(dialogContainer)
        dialogContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dialogContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            dialogContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            dialogContainer.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.85),
            dialogContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 280)
        ])

        // Shadow for dialog
        dialogContainer.layer.shadowColor = UIColor.black.cgColor
        dialogContainer.layer.shadowOffset = CGSize(width: 0, height: 10)
        dialogContainer.layer.shadowRadius = 30
        dialogContainer.layer.shadowOpacity = 0.5

        // Decorative bar
        dialogContainer.addSubview(decorativeTopBar)
        decorativeTopBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            decorativeTopBar.topAnchor.constraint(equalTo: dialogContainer.topAnchor, constant: 12),
            decorativeTopBar.centerXAnchor.constraint(equalTo: dialogContainer.centerXAnchor),
            decorativeTopBar.widthAnchor.constraint(equalToConstant: 40),
            decorativeTopBar.heightAnchor.constraint(equalToConstant: 4)
        ])

        // Content stack
        dialogContainer.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: decorativeTopBar.bottomAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: dialogContainer.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: dialogContainer.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: dialogContainer.bottomAnchor, constant: -24)
        ])
    }

    private func configureWithConfiguration(_ config: DialogConfiguration) {
        // Title
        titleLabel.text = config.title
        contentStack.addArrangedSubview(titleLabel)

        // Message
        if let message = config.message {
            messageLabel.text = message
            contentStack.addArrangedSubview(messageLabel)
        }

        // Buttons
        if config.primaryAction != nil || config.secondaryAction != nil {
            contentStack.addArrangedSubview(buttonStack)
            buttonStack.widthAnchor.constraint(equalTo: contentStack.widthAnchor).isActive = true

            if let secondary = config.secondaryAction {
                let button = createButton(for: secondary)
                buttonStack.addArrangedSubview(button)
            }

            if let primary = config.primaryAction {
                let button = createButton(for: primary)
                buttonStack.addArrangedSubview(button)
            }
        }

        // Background tap
        if config.dismissOnBackgroundTap {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackdropTap))
            backdropView.addGestureRecognizer(tapGesture)
        }
    }

    private func createButton(for action: DialogAction) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(action.title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true

        switch action.style {
        case .primary:
            button.backgroundColor = ChromaticPalette.aurelianAccent
            button.setTitleColor(ChromaticPalette.ebonyText, for: .normal)
        case .secondary:
            button.backgroundColor = ChromaticPalette.obsidianBackground
            button.setTitleColor(ChromaticPalette.alabasterText, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = ChromaticPalette.pearlSecondaryText.cgColor
        case .destructive:
            button.backgroundColor = ChromaticPalette.vermilionAlert
            button.setTitleColor(ChromaticPalette.alabasterText, for: .normal)
        }

        button.addAction(UIAction { [weak self] _ in
            AuralFeedbackManager.shared.emitButtonTapFeedback()
            self?.dismissDialog(animated: true) {
                action.handler?()
            }
        }, for: .touchUpInside)

        return button
    }

    @objc private func handleBackdropTap() {
        dismissDialog(animated: true)
    }

    // MARK: - Animation

    private func presentAnimated() {
        backdropView.alpha = 0
        dialogContainer.alpha = 0
        dialogContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                self.backdropView.alpha = 1
                self.dialogContainer.alpha = 1
                self.dialogContainer.transform = .identity
            },
            completion: nil
        )
    }

    private func dismissDialog(animated: Bool, completion: (() -> Void)? = nil) {
        let dismissAction = { [weak self] in
            self?.removeFromSuperview()
            OverlayDialogPresenter.currentDialog = nil
            completion?()
            self?.dismissCompletion?()
        }

        if animated {
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self.backdropView.alpha = 0
                    self.dialogContainer.alpha = 0
                    self.dialogContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                },
                completion: { _ in
                    dismissAction()
                }
            )
        } else {
            dismissAction()
        }
    }
}

// MARK: - Convenience Methods

extension OverlayDialogPresenter {

    /// Shows a game over dialog
    static func showGameOverDialog(
        in viewController: UIViewController,
        score: Int,
        highScore: Int,
        isNewHighScore: Bool,
        onRestart: @escaping () -> Void,
        onMainMenu: @escaping () -> Void
    ) {
        let title = isNewHighScore ? "🎉 New High Score!" : "Game Over"
        let message = isNewHighScore
            ? "Congratulations! You scored \(score) points!"
            : "Your score: \(score)\nBest: \(highScore)"

        let config = DialogConfiguration(
            title: title,
            message: message,
            primaryAction: DialogAction(title: "Play Again", style: .primary, handler: onRestart),
            secondaryAction: DialogAction(title: "Main Menu", style: .secondary, handler: onMainMenu),
            dismissOnBackgroundTap: false
        )

        presentDialog(in: viewController, configuration: config)
    }

    /// Shows a pause dialog
    static func showPauseDialog(
        in viewController: UIViewController,
        onResume: @escaping () -> Void,
        onRestart: @escaping () -> Void,
        onMainMenu: @escaping () -> Void
    ) {
        let config = DialogConfiguration(
            title: "Paused",
            message: nil,
            primaryAction: DialogAction(title: "Resume", style: .primary, handler: onResume),
            secondaryAction: DialogAction(title: "Quit", style: .secondary, handler: onMainMenu),
            dismissOnBackgroundTap: true
        )

        presentDialog(in: viewController, configuration: config)
    }

    /// Shows a confirmation dialog
    static func showConfirmationDialog(
        in viewController: UIViewController,
        title: String,
        message: String,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void
    ) {
        let config = DialogConfiguration(
            title: title,
            message: message,
            primaryAction: DialogAction(title: confirmTitle, style: .primary, handler: onConfirm),
            secondaryAction: DialogAction(title: cancelTitle, style: .secondary),
            dismissOnBackgroundTap: true
        )

        presentDialog(in: viewController, configuration: config)
    }
}
