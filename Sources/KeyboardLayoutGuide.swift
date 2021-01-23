import UIKit

@objc
open class KeyboardLayoutGuide: UILayoutGuide {
    // KVO-compatible
    open override var layoutFrame: CGRect {
        super.layoutFrame
    }
    
    private typealias MethodSignature =
        @convention(c) (UILayoutGuide, Selector) -> ()
    private static let originalInvalidate: MethodSignature = {
        let imp = UILayoutGuide.instanceMethod(
            for: #selector(invalidateLayoutFrame)
        )
        return unsafeBitCast(imp, to: MethodSignature.self)
    }()
    
    @objc(_invalidateLayoutFrame)
    open func invalidateLayoutFrame() {
        willChangeValue(for: \.layoutFrame)
        Self.originalInvalidate(self, #selector(invalidateLayoutFrame))
        didChangeValue(for: \.layoutFrame)
    }
}
