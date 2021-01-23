import UIKit
extension UIView {
    typealias DidMoveToWindowType = @convention(c) (UIView, Selector) -> ()
    typealias DidMoveFromWindowType = @convention(c) (
        UIView, Selector, AnyObject?, AnyObject?
    ) -> ()
    
    private static var originalDidMoveToWindow: DidMoveToWindowType!
    private static let swizzledDidMoveToWindow: DidMoveToWindowType
        = { view, sel in
            originalDidMoveToWindow(view, sel)
            view.updateWindowRelation()
        }
    
    private static var originalDidMoveFromWindow: DidMoveFromWindowType!
    private static let swizzledDidMoveFromWindow: DidMoveFromWindowType
        = { view, sel, arg2, arg3 in
            originalDidMoveFromWindow(view, sel, arg2, arg3)
            view.updateWindowRelation()
        }
    
    @nonobjc
    static func swizzleDidMoveToWindow() {
        let type = UIView.self
        let selector = #selector(UIView.didMoveToWindow)
        
        guard let originalMethod = class_getInstanceMethod(type, selector) else {
            return
        }
        
        originalDidMoveToWindow = unsafeBitCast(
            method_getImplementation(originalMethod),
            to: DidMoveToWindowType.self
        )
        let swizzledImp = unsafeBitCast(swizzledDidMoveToWindow, to: IMP.self)
        
        let didAddMethod = class_addMethod(
            type, selector, swizzledImp,
            method_getTypeEncoding(originalMethod)
        )
        
        if !didAddMethod {
            method_setImplementation(originalMethod, swizzledImp)
        }
    }
    
    // i.e. -[UICollectionView didMoveToWindow] doesn't calls super...
    @nonobjc
    static func swizzleDidMoveFromWindow() {
        let type = UIView.self
        // _didMoveFromWindow:toWindow:
        let selector = NSSelectorFromString(
            "X2RpZE1vdmVGcm9tV2luZG93OnRvV2luZG93Og==".base64Decoded
        )
        
        guard let originalMethod = class_getInstanceMethod(type, selector) else {
            return
        }
        
        originalDidMoveFromWindow = unsafeBitCast(
            method_getImplementation(originalMethod),
            to: DidMoveFromWindowType.self
        )
        let swizzledImp = unsafeBitCast(
            swizzledDidMoveFromWindow, to: IMP.self
        )
        
        let didAddMethod = class_addMethod(
            type, selector, swizzledImp,
            method_getTypeEncoding(originalMethod)
        )
        
        if !didAddMethod {
            method_setImplementation(originalMethod, swizzledImp)
        }
    }
}
