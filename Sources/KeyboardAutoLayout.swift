import UIKit
#if SWIFT_PACKAGE
import KeyboardAutoLayout_ObjC
#endif

// MARK: - Public

extension UIView {
    @objc
    open var keyboardLayoutGuide: KeyboardLayoutGuide {
        if let guide = objc_getAssociatedObject(self, &keyboardLayoutGuideKey)
            as? KeyboardLayoutGuide
        {
            return guide
        }
        
        let guide = buildKeyboardLayoutGuide()
        objc_setAssociatedObject(
            self, &keyboardLayoutGuideKey,
            guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        updateWindowRelation()
        return guide
    }
}

extension UIWindow {
    @objc
    open var keyboardInteractiveGestureRecognizer: UIPanGestureRecognizer {
        if let gesture = objc_getAssociatedObject(self, &interactiveGestureKey)
            as? UIPanGestureRecognizer
        {
            return gesture
        }
        
        let gesture = UIPanGestureRecognizer()
        objc_setAssociatedObject(
            self, &interactiveGestureKey,
            gesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        return gesture
    }
}

// MARK: - UIView

private var keyboardLayoutGuideKey: UInt8 = 0

extension UIView {
    private var keyboardLayoutGuideIfLoaded: UILayoutGuide? {
        objc_getAssociatedObject(self, &keyboardLayoutGuideKey)
            as? UILayoutGuide
    }
    
    @objc
    fileprivate func buildKeyboardLayoutGuide() -> KeyboardLayoutGuide {
        let guide = KeyboardLayoutGuide()
        guide.identifier = "UIViewKeyboardLayoutGuide"
        addLayoutGuide(guide)
        
        let topConstraint = guide.topAnchor.constraint(equalTo: bottomAnchor)
        topConstraint.priority = .init(998)
        
        NSLayoutConstraint.activate([
            topConstraint,
            guide.topAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            guide.bottomAnchor.constraint(equalTo: bottomAnchor),
            guide.leftAnchor.constraint(equalTo: leftAnchor),
            guide.rightAnchor.constraint(equalTo: rightAnchor),
        ])
        
        return guide
    }
    
    @nonobjc
    func updateWindowRelation() {
        if self is UIWindow { return }
        guard let window = window else { return }
        guard let guide = keyboardLayoutGuideIfLoaded else { return }
        
        let windowAnchor = window.keyboardLayoutGuide.topAnchor
        if guide.constraintsAffectingLayout(for: .vertical)
            .contains(where: { $0.secondAnchor === windowAnchor })
        {
            return
        }
        
        let constraint = guide.topAnchor
            .constraint(equalTo: windowAnchor)
        constraint.priority = .init(999)
        constraint.isActive = true
    }
}

// MARK: - UIWindow

private var heightConstraintKey: UInt8 = 0
private var interactiveGestureKey: UInt8 = 0

extension UIWindow {
    private var heightConstraint: NSLayoutConstraint {
        get {
            objc_getAssociatedObject(self, &heightConstraintKey)
                as! NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(
                self, &heightConstraintKey,
                newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    @objc
    fileprivate override func buildKeyboardLayoutGuide() -> KeyboardLayoutGuide {
        let guide = KeyboardLayoutGuide()
        guide.identifier = "UIWindowKeyboardLayoutGuide"
        addLayoutGuide(guide)
        
        let keyboardHeight = KeyboardManager.shared.latestKeyboardHeight
            .map(keyboardVisibleHeight) ?? 0
        let height = guide.heightAnchor.constraint(
            equalToConstant: keyboardHeight
        )
        heightConstraint = height
        
        NSLayoutConstraint.activate([
            height,
            guide.bottomAnchor.constraint(equalTo: bottomAnchor),
            guide.leftAnchor.constraint(equalTo: leftAnchor),
            guide.rightAnchor.constraint(equalTo: rightAnchor),
        ])
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(klg_keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(klg_keyboardInteractiveDismissalDidBegin),
            name: UIResponder.keyboardInteractiveDismissalNotification,
            object: nil
        )
        
        keyboardInteractiveGestureRecognizer.delegate
            = GestureDelegate.shared
        addGestureRecognizer(keyboardInteractiveGestureRecognizer)
        
        return guide
    }
    
    @objc
    private func klg_keyboardWillChangeFrame(_ notification: Notification) {
        guard let endFrame = notification.keyboardEndFrame else {
            return
        }
        
        var keyboardHeight = keyboardVisibleHeight(with: endFrame)
        if KeyboardManager.shared.latestKeyboardHeight == 0 {
            keyboardHeight = 0
        }
        if keyboardHeight == heightConstraint.constant {
            return
        }
        
        heightConstraint.constant = keyboardHeight
        
        if UIView.inheritedAnimationDuration > 0 {
            layoutIfNeeded()
        } else if let animator = notification.keyboardPropertyAnimator {
            animator.addAnimations {
                self.layoutIfNeeded()
            }
            animator.startAnimation()
        }
    }
    
    @objc
    private func klg_keyboardInteractiveDismissalDidBegin() {
        let gesture = keyboardInteractiveGestureRecognizer
        let heightConstraint = self.heightConstraint
        
        guard
            gesture.state == .changed,
            var latestHeight = KeyboardManager.shared.latestKeyboardHeight else
        {
            return
        }
        
        latestHeight = keyboardVisibleHeight(with: latestHeight)
        var keyboardHeight = bounds.height
            - gesture.location(in: self).y
        keyboardHeight = min(latestHeight, keyboardHeight)
        
        if heightConstraint.constant != keyboardHeight {
            heightConstraint.constant = keyboardHeight
        }
    }
    
    private func keyboardVisibleHeight(with heightInScreen: CGFloat) -> CGFloat {
        keyboardVisibleHeight(with: CGRect(
            x: 0,
            y: UIScreen.main.bounds.height - heightInScreen,
            width: 0,
            height: heightInScreen
        ))
    }
    
    private func keyboardVisibleHeight(with keyboardFrame: CGRect) -> CGFloat {
        // considering that keyboard cannot be displayed on external screen
        if screen != .main {
            return 0
        }
        
        let keyboardFrameInWindow = UIScreen.main.coordinateSpace
            .convert(keyboardFrame, to: self)
        return keyboardFrameInWindow.intersection(bounds).height
    }
}

// MARK: - GestureDelegate

private class GestureDelegate: NSObject, UIGestureRecognizerDelegate {
    static let shared = GestureDelegate()

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
