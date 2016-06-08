import UIKit
import XCTest
import JJ

class Tests: XCTestCase {

    func testObject() {
        let json = ["firstName": "Yury", "lastName": "Korolev", "trueFlag": true, "falseFlag": false] as [String: AnyObject]

        let obj = try! jj(json).obj()

        XCTAssertEqual("Yury",    try! obj["firstName"].string())
        XCTAssertEqual("Korolev", try! obj["lastName"].string())
        XCTAssertEqual(true, try! obj["trueFlag"].bool())
        XCTAssertEqual(false, try! obj["falseFlag"].bool())
        XCTAssertEqual(true, obj["trueFlag"].toBool())
        XCTAssertEqual(false, obj["falseFlag"].toBool())
        XCTAssertEqual(false, obj["unknown"].toBool())
        XCTAssertEqual(4, obj.count)
        XCTAssertEqual(true, obj.exists)
        XCTAssertEqual("<root>", obj.path)
        XCTAssertEqual(json.debugDescription, obj.raw.debugDescription)
    }

    func testArray() {
        let json = [1, "Nice", 5.5, NSNull(), "http://anjlab.com"] as [AnyObject]

        let arr = try! jj(json).arr()

        XCTAssertEqual(1, try! arr[0].int())
        XCTAssertEqual("Nice", try! arr[1].string())
        XCTAssertEqual(5.5, try! arr[2].double())
        XCTAssertEqual(true, arr[3].isNull)
        XCTAssertEqual(NSURL(string: "http://anjlab.com"), try! arr[4].url())
    }

    func testErrors() {
        let json = ["firstName": "Yury", "lastName": "Korolev"]
        let obj = try! jj(json).obj()

        XCTAssertEqual(false, obj["unknownKey"].exists)

        do {
            let _ = try obj["unknownKey"].string()
            XCTFail()
        } catch {
            let err = "\(error)"
            XCTAssertEqual("JJError.WrongType: Can't convert nil at path: '<root>.unknownKey' to type 'String'", err)
        }

        do {
            let _ = try obj["unknownKey"].date()
            XCTFail()
        } catch {
            let err = "\(error)"
            XCTAssertEqual("JJError.WrongType: Can't convert nil at path: '<root>.unknownKey' to type 'NSDate'", err)
        }

        do {
            let _ = try obj["unknownKey"].url()
            XCTFail()
        } catch {
            let err = "\(error)"
            XCTAssertEqual("JJError.WrongType: Can't convert nil at path: '<root>.unknownKey' to type 'NSURL'", err)
        }

        do {
            let _ = try obj["nested"]["unknown"][0].url()
            XCTFail()
        } catch {
            let err = "\(error)"
            XCTAssertEqual("JJError.WrongType: Can't convert nil at path: '<root>.nested<nil>.unknown<nil>[0]' to type 'NSURL'", err)
        }

        do {
            let _ = try jj(json).arr()
            XCTFail()
        } catch {
            let err = "\(error)"
            XCTAssertEqual("JJError.WrongType: Can't convert Optional({\n    firstName = Yury;\n    lastName = Korolev;\n}) at path: '<root>' to type '[AnyObject]'", err)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
