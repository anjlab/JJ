import UIKit
/** The helper class conforming CustomPlaygroundQuickLookable */
public class QuickLookable: NSObject, CustomPlaygroundQuickLookable {
    public var quickLookString: String = ""
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 10)
        textView.text = quickLookString
        textView.sizeToFit()
        textView.isScrollEnabled = true
        return .view(textView)
    }
}
