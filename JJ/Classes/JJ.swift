//
//  JJ.swift
//  Pods
//
//  Created by Yury Korolev on 5/27/16.
//
//

import Foundation

private let _rfc3339DateFormatter: NSDateFormatter = _buildRfc3339DateFormatter()

private func _buildRfc3339DateFormatter() -> NSDateFormatter {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    return formatter
}

public extension String {
    func asRFC3339Date() -> NSDate? {
        return _rfc3339DateFormatter.dateFromString(self)
    }
}

public extension NSDate {
    func toRFC3339String() -> String {
        return _rfc3339DateFormatter.stringFromDate(self)
    }
}

public enum JJError: ErrorType, CustomStringConvertible {
    case WrongType(v: AnyObject?, path: String, toType: String)
    case NotFound(path: String)

    public var description: String {
        switch self {
        case let .WrongType(v: v, path: path, toType: type):
            return "JJError.WrongType: Can't convert \(v) at path: '\(path)' to type '\(type)'"
        case let .NotFound(path: path):
            return "JJError.NotFound: No object at path: '\(path)'"
        }
    }
}

public func jj(v: AnyObject?) -> JJVal { return JJVal(v) }

public func jj(decoder decoder: NSCoder) -> JJDec { return JJDec(decoder) }

public func jj(encoder encoder: NSCoder) -> JJEnc { return JJEnc(encoder) }

public struct JJArr: CustomDebugStringConvertible {
    private let _path: String
    private let _v: [AnyObject]

    public init(_ v: [AnyObject], path: String) {
        _v = v
        _path = path
    }

    public subscript (index: Int) -> JJVal {
        return at(index)
    }

    public func at(index: Int) -> JJVal {
        let newPath = _path + "[\(index)]"

        if index >= 0 && index < _v.count {
            return JJVal(_v[index], path: newPath)
        }
        return JJVal(nil, path: newPath)
    }

    // MARK: extension point
    public var raw: [AnyObject] { return _v }
    public var path: String { return _path }

    // MARK: Shortcusts

    public var exists: Bool { return true }
    public var count:Int { return _v.count }

    public func prettyPrint(space space: String = "", spacer: String = "  ") -> String {
        if _v.count == 0 {
            return "[]"
        }
        var str = "[\n"
        let nextSpace = space + spacer
        for v in _v {
            str += "\(nextSpace)" + jj(v).prettyPrint(space: nextSpace, spacer: spacer) + ",\n"
        }
        str.removeAtIndex(str.endIndex.advancedBy(-2))
        return str + "\(space)}"
    }

    public var debugDescription: String { return prettyPrint() }
}

public struct JJMaybeArr {
    private let _path: String
    private let _v: JJArr?

    public init(_ v: JJArr?, path: String) {
        _v = v
        _path = path
    }

    public func at(index: Int) -> JJVal {
        return _v?.at(index) ?? JJVal(nil, path: _path + "<nil>[\(index)]")
    }

    public subscript (index: Int) -> JJVal { return at(index) }

    public var exists: Bool { return _v != nil }

    // MARK: extension point
    public var raw: [AnyObject]? { return _v?.raw }
    public var path: String { return _path }

}

public struct JJObj: CustomDebugStringConvertible {
    private let _path: String
    private let _v: [String: AnyObject]

    public init(_ v: [String: AnyObject], path: String) {
        _v = v
        _path = path
    }

    public func at(key: String) -> JJVal {
        let newPath = _path + ".\(key)"
        #if DEBUG
            if let msg = _v["$\(key)__depricated"] {
                debugPrint("WARNING:!!!!. Using depricated field \(newPath): \(msg)")
            }
        #endif
        return JJVal(_v[key], path: newPath)
    }

    public subscript (key: String) -> JJVal { return at(key) }

    // MARK: extension point
    public var raw: [String: AnyObject] { return _v }
    public var path: String { return _path }

    // Shortcusts

    public var exists: Bool { return true }
    public var count:Int { return _v.count }

    public func prettyPrint(space space: String = "", spacer: String = "  ") -> String {
        if _v.count == 0 {
            return "{}"
        }
        var str = "{\n"
        for (k, v) in _v {
            let nextSpace = space + spacer
            str += "\(nextSpace)\"\(k)\": \(jj(v).prettyPrint(space: nextSpace, spacer: spacer)),\n"
        }
        str.removeAtIndex(str.endIndex.advancedBy(-2))
        return str + "\(space)}"
    }

    public var debugDescription: String { return prettyPrint() }
}

public struct JJMaybeObj {
    private let _path: String
    private let _v: JJObj?

    public init(_ v: JJObj?, path: String) {
        _v = v
        _path = path
    }

    public func at(key: String) -> JJVal {
        return _v?.at(key) ?? JJVal(nil, path: _path + "<nil>.\(key)")
    }

    public subscript (key: String) -> JJVal { return at(key) }


    // MARK: extension point
    public var raw: [String: AnyObject]? { return _v?.raw }
    public var path: String { return _path }

    // MARK: shortcusts

    public var exists: Bool { return _v != nil }
}

public struct JJVal: CustomDebugStringConvertible {
    private let _path: String
    private let _v: AnyObject?

    public init(_ v: AnyObject?, path: String = "<root>") {
        _v = v
        _path = path
    }

    // MARK: Bool

    public var asBool: Bool? { return _v as? Bool }

    public func toBool(@autoclosure defaultValue:  () -> Bool = true) -> Bool {
        return asBool ?? defaultValue()
    }


    public func bool() throws -> Bool {
        if let x = _v as? Bool {
            return x
        }
        throw JJError.WrongType(v: _v, path: _path, toType: "Bool")
    }

    // MARK: Int

    public var asInt: Int? { return _v as? Int }

    public func toInt(@autoclosure defaultValue:  () -> Int = 0) -> Int {
        return asInt ?? defaultValue()
    }

    public func int() throws -> Int {
        if let x = asInt {
            return x
        }
        throw JJError.WrongType(v: _v, path: _path, toType: "Int")
    }

    // MARK: UInt

    public var asUInt: UInt? { return _v as? UInt }

    public func toUInt(@autoclosure defaultValue:  () -> UInt = 0) -> UInt {
        return asUInt ?? defaultValue()
    }

    public func uInt() throws -> UInt {
        if let x = asUInt {
            return x
        }
        throw JJError.WrongType(v: _v, path: _path, toType: "UInt")
    }

    // MARK: NSNumber

    public var asNumber: NSNumber? { return _v as? NSNumber }

    public func toNumber(@autoclosure defaultValue:  () -> NSNumber = 0) -> NSNumber {
        return asNumber ?? defaultValue()
    }

    public func number() throws -> NSNumber {
        if let x = asNumber {
            return x
        }
        throw JJError.WrongType(v: _v, path: _path, toType: "NSNumber")
    }

    // MARK: Float

    public var asFloat: Float? { return _v as? Float }

    public func toFloat(@autoclosure defaultValue:  () -> Float = 0) -> Float {
        return asFloat ?? defaultValue()
    }

    public func float() throws -> Float {
        if let x = asFloat {
            return x
        }
        throw JJError.WrongType(v: _v, path: _path,toType: "Float")
    }

    // MARK: Double

    public var asDouble: Double? { return _v as? Double }

    public func toDouble(@autoclosure defaultValue:  () -> Double = 0) -> Double {
        return asDouble ?? defaultValue()
    }

    public func double() throws -> Double {
        if let x = asDouble {
            return x
        }
        throw JJError.WrongType(v: _v, path: _path,toType: "Double")
    }


    // MARK: Object

    public var asObj: JJObj? {
        if let obj = _v as? [String: AnyObject] {
            return JJObj(obj, path: _path)
        }

        return nil
    }

    public func toObj() -> JJMaybeObj {
        return JJMaybeObj(asObj, path: _path)
    }

    public func obj() throws -> JJObj {
        if let obj = _v as? [String: AnyObject] {
            return JJObj(obj, path: _path)
        }

        throw JJError.WrongType( v: _v, path: _path, toType: "[String: AnyObject]")
    }

    // MARK: Array

    public var asArr: JJArr? {
        if let arr = _v as? [AnyObject] {
            return JJArr(arr, path: _path)
        }
        return nil
    }

    public func toArr() -> JJMaybeArr {
        return JJMaybeArr(asArr, path: _path)
    }

    public func arr() throws -> JJArr {
        guard let arr = _v as? [AnyObject] else {
            throw JJError.WrongType( v: _v, path: _path, toType: "[AnyObject]")
        }
        return JJArr(arr, path: _path)
    }

    // MARK: String

    public var asString: String? { return _v as? String }

    public func toString(@autoclosure defaultValue:  () -> String = "") -> String {
        return asString ?? defaultValue()
    }

    public func string() throws -> String {
        if let x = asString {
            return x
        }
        throw JJError.WrongType(v: _v, path: _path, toType: "String")
    }

    // MARK: Date

    public var asDate: NSDate? { return asString?.asRFC3339Date() }

    public func date() throws -> NSDate {
        if let d = asString?.asRFC3339Date() {
            return d
        } else {
            throw JJError.WrongType(v: _v, path: _path, toType: "NSDate")
        }
    }

    // MARK: NSURL

    public var asURL: NSURL? {
        if let s = asString, d = NSURL(string: s) {
            return d
        } else {
            return nil
        }
    }

    public func toURL(@autoclosure defaultValue:  () -> NSURL = NSURL()) -> NSURL {
        return asURL ?? defaultValue()
    }

    public func url() throws -> NSURL {
        if let s = asString, d = NSURL(string: s) {
            return d
        } else {
            throw JJError.WrongType(v: _v, path: _path, toType: "NSURL")
        }
    }

    // MARK: Null

    public var isNull: Bool { return _v === NSNull() }


    // MARK: NSTimeZone

    public var asTimeZone: NSTimeZone? {
        if let s = asString, d = NSTimeZone(name: s) {
            return d
        } else {
            return nil
        }
    }

    // MARK: Navigation as Object

    public func at(key: String) -> JJVal {
        return toObj()[key]
    }

    public subscript (key: String) -> JJVal {
        return at(key)
    }

    // MARK: Navigation as Array

    public func at(index: Int) -> JJVal {
        return toArr()[index]
    }

    public subscript (index: Int) -> JJVal {
        return at(index)
    }

    public var exists: Bool { return _v != nil }

    // MARK: extension point

    public var path: String { return _path }
    public var raw: AnyObject? { return _v }

    // MARK: pretty print

    public func prettyPrint(space space: String = "", spacer: String = "  ") -> String {
        if let arr = asArr {
            return arr.prettyPrint(space: space, spacer: spacer)
        } else if let obj = asObj {
            return obj.prettyPrint(space: space, spacer: spacer)
        } else if let s = asString {
            return "\"\(s)\""
        } else if isNull {
            return "null"
        } else if let v = _v {
            return v.description
        } else {
            return "nil"
        }
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return prettyPrint()
    }
}

public struct JJEnc {
    private let _enc: NSCoder

    public init(_ enc: NSCoder) {
        _enc = enc
    }

    public func put(v:Int, at: String) {
        _enc.encodeInt32(Int32(v), forKey: at)
    }

    public func put(v:Bool, at: String) {
        _enc.encodeBool(v, forKey: at)
    }

    public func put(v:AnyObject?, at: String) {
        _enc.encodeObject(v, forKey: at)
    }
}

public struct JJDecVal {
    private let _key: String
    private let _dec: NSCoder

    public init(dec: NSCoder, key: String) {
        _key = key
        _dec = dec
    }

    public func string() throws -> String {
        let v = _dec.decodeObjectForKey(_key)
        if let x = v as? String {
            return x
        }
        throw JJError.WrongType(v: v, path: _key, toType: "String")
    }

    public var asString: String? { return _dec.decodeObjectForKey(_key) as? String }

    public func int() throws -> Int { return Int(_dec.decodeInt32ForKey(_key)) }

    public var asInt: Int? { return _dec.decodeObjectForKey(_key) as? Int }

    public var asDate: NSDate? { return _dec.decodeObjectForKey(_key) as? NSDate }

    public var asURL: NSURL? { return _dec.decodeObjectForKey(_key) as? NSURL }

    public var asTimeZone: NSTimeZone? { return _dec.decodeObjectForKey(_key) as? NSTimeZone }

    public func bool() throws -> Bool { return _dec.decodeBoolForKey(_key) }

    public func toBool() -> Bool { return _dec.decodeBoolForKey(_key) }

    public func decodeAs<T: NSCoding>() -> T? { return _dec.decodeObjectForKey(_key) as? T }

    public func date() throws -> NSDate {
        let v = _dec.decodeObjectForKey(_key)
        if let x = v as? NSDate {
            return x
        }
        throw JJError.WrongType(v: v, path: _key, toType: "NSDate")
    }
}

public struct JJDec {
    private let _dec: NSCoder

    public init(_ dec: NSCoder) {
        _dec = dec
    }

    public subscript (key: String) -> JJDecVal {
        return JJDecVal(dec: _dec, key: key)
    }
}
