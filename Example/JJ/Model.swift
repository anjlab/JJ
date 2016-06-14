import Foundation
import JJ

class Model: NSObject, NSCoding {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObjectForKey("title") as? String else { return nil }
        
        self.init(title: title)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.title, forKey: "title")
    }
}