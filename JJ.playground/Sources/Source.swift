import UIKit
/** The helper class conforming CustomPlaygroundQuickLookable */
public class QuickLookable: NSObject, CustomPlaygroundQuickLookable {
    public var quickLookString: String = ""
    
    public func customPlaygroundQuickLook() -> PlaygroundQuickLook {
        let textView = UITextView()
        textView.font = UIFont.systemFontOfSize(10)
        textView.text = quickLookString
        textView.sizeToFit()
        textView.scrollEnabled = true
        return .View(textView)
    }
}
