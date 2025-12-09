//
//  LayoutAnchorUtilities.swift
//  DivideNumber
//
//  Auto Layout utilities and extensions
//

import UIKit

/// Extension for easier Auto Layout constraint creation
extension UIView {

    /// Adds subview with translatesAutoresizingMaskIntoConstraints set to false
    func embedSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }

    /// Pins view to all edges of its superview with optional insets
    func anchorToSuperviewEdges(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }

    /// Pins view to safe area of its superview
    func anchorToSafeArea(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom)
        ])
    }

    /// Centers view in its superview
    func anchorToCenterOfSuperview() {
        guard let superview = superview else { return }
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }

    /// Sets fixed size constraints
    func anchorToFixedSize(width: CGFloat, height: CGFloat) {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }

    /// Sets fixed width constraint
    func anchorToFixedWidth(_ width: CGFloat) {
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    /// Sets fixed height constraint
    func anchorToFixedHeight(_ height: CGFloat) {
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    /// Sets aspect ratio constraint
    func anchorToAspectRatio(_ ratio: CGFloat) {
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio).isActive = true
    }

    /// Creates constraints relative to another view
    func anchorRelative(
        top: NSLayoutYAxisAnchor? = nil,
        leading: NSLayoutXAxisAnchor? = nil,
        trailing: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        topConstant: CGFloat = 0,
        leadingConstant: CGFloat = 0,
        trailingConstant: CGFloat = 0,
        bottomConstant: CGFloat = 0
    ) {
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: leadingConstant).isActive = true
        }
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -trailingConstant).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant).isActive = true
        }
    }
}

// MARK: - Screen Utilities

struct ViewportMetrics {

    /// Screen width
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    /// Screen height
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }

    /// Safe area insets
    static var safeAreaInsets: UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }

    /// Usable height (excluding safe areas)
    static var usableHeight: CGFloat {
        return screenHeight - safeAreaInsets.top - safeAreaInsets.bottom
    }

    /// Checks if device is iPad
    static var isTabletDevice: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    /// Returns scaled value based on screen width (base: iPhone 375pt width)
    static func scaledDimension(_ value: CGFloat) -> CGFloat {
        let baseWidth: CGFloat = 375.0
        let scale = min(screenWidth / baseWidth, 1.5) // Cap at 1.5x for iPads
        return value * scale
    }

    /// Returns board cell size based on difficulty and screen
    static func cellDimensionForBoard(difficulty: LabyrinthDifficulty) -> CGFloat {
        let availableWidth = screenWidth - 40 // 20pt padding on each side
        let cellCount = CGFloat(difficulty.matrixDimension)
        let spacing: CGFloat = 8
        let totalSpacing = spacing * (cellCount - 1)
        let cellSize = (availableWidth - totalSpacing) / cellCount
        return min(cellSize, 80) // Max cell size of 80pt
    }
}
