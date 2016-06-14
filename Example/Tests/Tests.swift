import UIKit
import XCTest
import JJ

class Tests: XCTestCase {
    
    func testObject() {
        
        let j = ["firstName": "Yury", "lastName": "Korolev"]
        
        let o = try! jj(j).obj()
        
        XCTAssertEqual("[\"firstName\": Yury, \"lastName\": Korolev]", o.raw.debugDescription)
        XCTAssertEqual("{\n  \"firstName\": \"Yury\",\n  \"lastName\": \"Korolev\"\n}", o.debugDescription)
        XCTAssertEqual("{\n  \"firstName\": \"Yury\",\n  \"lastName\": \"Korolev\"\n}", o.prettyPrint())
        XCTAssertEqual("{\n  \"firstName\": \"Yury\",\n  \"lastName\": \"Korolev\"\n}", o.prettyPrint(space: "", spacer: "  "))
        
        let json = [
            "firstName": "Yury",
            "lastName": "Korolev",
            "trueFlag": true,
            "falseFlag": false,
            "intValue" : 13,
            "doubleValue" : 12.1,
            "date" : "2016-06-10T00:00:00.000Z",
            "url" : "http://anjlab.com",
            "zone" : "Europe/Moscow",
            "arr" : [1, 2, 3],
            "obj" : ["value" : 1]
            ] as [String: AnyObject]
        
        let obj = try! jj(json).obj()
        
        XCTAssertEqual("Yury",    try! obj["firstName"].string())
        XCTAssertEqual("Korolev", try! obj["lastName"].string())
        XCTAssertEqual("Korolev", obj["lastName"].toString())
        XCTAssertEqual("Korolev", obj["lastName"].asString)
        XCTAssertEqual(true, try! obj["trueFlag"].bool())
        XCTAssertEqual(false, try! obj["falseFlag"].bool())
        XCTAssertEqual(true, obj["trueFlag"].toBool())
        XCTAssertEqual(false, obj["falseFlag"].toBool())
        XCTAssertEqual(true, obj["trueFlag"].asBool)
        XCTAssertEqual(false, obj["falseFlag"].asBool)
        XCTAssertEqual(false, obj["unknown"].toBool())
        XCTAssertEqual(13, try! obj["intValue"].int())
        XCTAssertEqual(13, obj["intValue"].toInt())
        XCTAssertEqual(13, obj["intValue"].asInt)
        XCTAssertEqual(11, obj["integerValue"].toInt(11))
        XCTAssertEqual(nil, obj["integerValue"].asInt)
        XCTAssertEqual(13, try! obj["intValue"].uInt())
        XCTAssertEqual(13, obj["intValue"].toUInt())
        XCTAssertEqual(13, obj["intValue"].asUInt)
        XCTAssertEqual(12.1, try! obj["doubleValue"].float())
        XCTAssertEqual(12.1, obj["doubleValue"].toFloat())
        XCTAssertEqual(12.1, obj["doubleValue"].asFloat)
        XCTAssertEqual(12.1, obj["doubleValue"].toDouble())
        XCTAssertEqual(12.1, obj["doubleValue"].toDouble(11.1))
        XCTAssertEqual(12.1, obj["doubleValue"].asDouble)
        XCTAssertEqual(nil, obj["floatValue"].asDouble)
        XCTAssertEqual(11.1, obj["floatValue"].toDouble(11.1))
        XCTAssertEqual(12.1, try! obj["doubleValue"].number())
        XCTAssertEqual(12.1, obj["doubleValue"].toNumber())
        XCTAssertEqual(12.1, obj["doubleValue"].asNumber)
        XCTAssertEqual(String.asRFC3339Date("2016-06-10T00:00:00.000Z")(), obj["date"].asDate)
        XCTAssertEqual("2016-06-10T00:00:00.000Z", String.asRFC3339Date("2016-06-10T00:00:00.000Z")()?.toRFC3339String())
        XCTAssertEqual(NSURL(string: "http://anjlab.com"), try! obj["url"].url())
        XCTAssertEqual(nil, try? obj["unknownKey"].url())
        XCTAssertEqual(NSURL(string: "http://anjlab.com"), obj["url"].toURL())
        XCTAssertEqual(NSURL(string: "http://anjlab.com"), obj["url"].asURL)
        XCTAssertEqual(NSTimeZone(name: "Europe/Moscow"), obj["zone"].asTimeZone)
        XCTAssertEqual(nil, obj["unknownKey"].asTimeZone)
        XCTAssertEqual(nil, obj["unknownKey"].asURL)
        XCTAssertEqual(true, obj["obj"].toObj().exists)
        XCTAssertEqual("Optional([\"value\": 1])", obj["obj"].toObj().raw.debugDescription)
        XCTAssertEqual("<root>.obj", obj["obj"].toObj().path)
        XCTAssertEqual(true, obj["arr"].toArr().exists)
        XCTAssertEqual("[1, 2, 3]", obj["arr"].toArr().raw?.debugDescription)
        XCTAssertEqual("<root>.arr", obj["arr"].toArr().path)
        XCTAssertEqual(11, obj.count)
        XCTAssertEqual(true, obj.exists)
        XCTAssertEqual("<root>", obj.path)
        XCTAssertEqual("<root>.url", obj["url"].path)
        XCTAssertEqual(json["firstName"].debugDescription, obj["firstName"].raw.debugDescription)
        XCTAssertEqual("\"Yury\"", obj["firstName"].debugDescription)
    }
    
    func testArray() {
        let j = [1, "Nice"]
        
        let a = try! jj(j).arr()
        
        XCTAssertEqual(j.debugDescription, a.raw.debugDescription)
        XCTAssertEqual("[\n  1,\n  \"Nice\"\n]", a.debugDescription)
        
        let json = [1, "Nice", 5.5, NSNull(), "http://anjlab.com"] as [AnyObject]
        
        let arr = try! jj(json).arr()
        
        XCTAssertEqual(1, try! arr[0].int())
        XCTAssertEqual("Nice", try! arr[1].string())
        XCTAssertEqual(5.5, try! arr[2].double())
        XCTAssertEqual(true, arr[3].isNull)
        XCTAssertEqual(NSURL(string: "http://anjlab.com"), try! arr[4].url())
        XCTAssertEqual(5, arr.count)
        XCTAssertEqual(true, arr.exists)
        XCTAssertEqual(true, arr[1].exists)
        XCTAssertEqual("<root>", arr.path)
        XCTAssertEqual("[\n  1,\n  \"Nice\",\n  5.5,\n  null,\n  \"http://anjlab.com\"\n]", arr.prettyPrint())
        XCTAssertEqual("[\n  1,\n  \"Nice\",\n  5.5,\n  null,\n  \"http://anjlab.com\"\n]", arr.prettyPrint(space: "", spacer: "  "))
    }
    
    func testDecEnc() {
        let data = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWithMutableData: data)
        
        let enc = jj(encoder: coder)
        
        enc.put("Title", at: "title")
        enc.put("Nice", at: "text")
        enc.put(String.asRFC3339Date("2016-06-10T00:00:00.000Z")(), at: "date")
        enc.put(false, at: "boolValue")
        enc.put(13, at: "number")
        
        coder.finishEncoding()
        
        let decoder = NSKeyedUnarchiver(forReadingWithData: data)
        
        let dec = jj(decoder: decoder)

        XCTAssertEqual("Nice", try! dec["text"].string())
        XCTAssertEqual(nil, dec["unknownKey"].asString)
        XCTAssertEqual(13, try! dec["number"].int())
        XCTAssertEqual(nil, dec["unknownKey"].asInt)
        XCTAssertEqual(nil, dec["unknownKey"].asDate)
        XCTAssertEqual(nil, dec["unknownKey"].asURL)
        XCTAssertEqual(String.asRFC3339Date("2016-06-10T00:00:00.000Z")(), try! dec["date"].date())
        XCTAssertEqual(String.asRFC3339Date("2016-06-10T00:00:00.000Z")(), dec["date"].asDate)
        XCTAssertEqual(nil, dec["unknownKey"].asTimeZone)
        XCTAssertEqual(false, try! dec["boolValue"].bool())
        XCTAssertEqual(false, dec["boolValue"].toBool())

        //Errors
        
        do {
            let _ = try dec["unknownKey"].date()
            XCTFail()
        } catch {
            let err = "\(error)"
            XCTAssertEqual("JJError.WrongType: Can\'t convert nil at path: \'unknownKey\' to type \'NSDate\'", err)
        }
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
        
        do {
            let _ = try obj["boolValue"].bool()
            XCTFail()
        } catch {
            let err = "\(error)"
            XCTAssertEqual("JJError.WrongType: Can't convert nil at path: '<root>.boolValue' to type 'Bool'", err)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}