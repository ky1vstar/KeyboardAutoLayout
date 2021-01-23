import UIKit

@objc(__KeyboardManager__)
class KeyboardManager: NSObject {
    @objc(shared)
    static let shared = KeyboardManager()
    
    var latestKeyboardHeight: CGFloat?
    
    private override init() {
        UIView.swizzleDidMoveToWindow()
        UIView.swizzleDidMoveFromWindow()
        
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc
    private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let endFrame = notification.keyboardEndFrame else {
            return
        }
        
        var screenBounds = UIScreen.main.bounds
        // when we dismiss keyboard inside interface rotation
        // keyboard frame in old screen coordinate space is reported
        if endFrame.width == screenBounds.height {
            swap(
                &screenBounds.size.width,
                &screenBounds.size.height
            )
        }
        
        latestKeyboardHeight = screenBounds
            .intersection(endFrame).height
    }
}
