import UIKit

extension NSNotification {
    @objc
    open var keyboardPropertyAnimator: UIViewPropertyAnimator? {
        (self as Notification).keyboardPropertyAnimator
    }
}

extension Notification {
    public var keyboardPropertyAnimator: UIViewPropertyAnimator? {
        guard
            let animationDuration = keyboardAnimationDuration,
            let animationCurve = keyboardAnimationCurve else
        {
            return nil
        }
        
        return UIViewPropertyAnimator(
            duration: animationDuration,
            curve: animationCurve
        )
    }
}

extension Notification {
    var keyboardEndFrame: CGRect? {
        (userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
            as AnyObject?)?.cgRectValue
    }
    
    var keyboardAnimationDuration: TimeInterval? {
        (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
            as? NSNumber)?.doubleValue
    }
    
    var keyboardAnimationCurve: UIView.AnimationCurve? {
        (userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey]
            as? NSNumber).flatMap({
                UIView.AnimationCurve(rawValue: $0.intValue)
            })
    }
}

extension UIResponder {
    static let keyboardInteractiveDismissalNotification: Notification.Name = {
        if #available(iOS 12.0, *) {
            return .init(
                // UIKeyboardPrivateInteractiveDismissalDidBeginNotification
                "VUlLZXlib2FyZFByaXZhdGVJbnRlcmFjdGl2ZURpc21pc3NhbERpZEJlZ2luTm90aWZpY2F0aW9u"
                    .base64Decoded
            )
        } else {
            return .init(
                // UITextEffectsWindowDidRotateNotification
                "VUlUZXh0RWZmZWN0c1dpbmRvd0RpZFJvdGF0ZU5vdGlmaWNhdGlvbg=="
                    .base64Decoded
            )
        }
    }()
}
