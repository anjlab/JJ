//
//  JJ.swift
//  Pods
//
//  Created by Yury Korolev on 5/27/16.
//
//

import Foundation

private let _rfc3339DateFormatter: DateFormatter = _buildRfc3339DateFormatter()
/** - Returns: **RFC 3339** date formatter */
private func _buildRfc3339DateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale(localeIdentifier: "en_US")
    formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
    formatter.timeZone = TimeZone(forSecondsFromGMT: 0)
    return formatter
}

public extension String {
    /**
     Returns a date representation of a given **RFC 3339** string. If dateFromString: can not parse the string, returns `nil`.
     - Returns: A date representation of string.
     */
    func asRFC3339Date() -> Date? {
        return _rfc3339DateFormatter.date(from: self)
    }
}

public extension Date {
    /**
     Returns a **RFC 3339** string representation of a given date formatted.
     - Returns: A **RFC 3339** string representation.
     */
    func toRFC3339String() -> String {
        return _rfc3339DateFormatter.string(from: self)
    }
}

public enum JJError: ErrorProtocol, CustomStringConvertible {
    /** Throws on can't convert value on path */
    case wrongType(v: AnyObject?, path: String, toType: String)
    /** Throws on can't find object on path */
    case notFound(path: String)

    public var description: String {
        switch self {
        case let .wrongType(v: v, path: path, toType: type):
            return "JJError.WrongType: Can't convert \(v) at path: '\(path)' to type '\(type)'"
        case let .notFound(path: path):
            return "JJError.NotFound: No object at path: '\(path)'"
        }
    }
}
/**
 - Parameter v: `AnyObject` to parse
 - Returns: `JJVal`
 */
public func jj(_ v: AnyObject?) -> JJVal { return JJVal(v) }
/**
 - Parameter decoder: `NSCoder` to decode
 - Returns: `JJDec`
 */
public func jj(decoder: NSCoder) -> JJDec { return JJDec(decoder) }
/**
 - Parameter encoder: `NSCoder` to encode
 - Returns: `JJEnc`
 */
public func jj(encoder: NSCoder) -> JJEnc { return JJEnc(encoder) }
/**
 Struct for store parsing `Array`
 */
public struct JJArr: CustomDebugStringConvertible {
    private let _path: String
    private let _v: [AnyObject]
    /**
     - Parameters:
        - v: [`AnyObject`]
        - path: `String` value of the path in original object
     - Returns: `JJArr`
     */
    public init(_ v: [AnyObject], path: String) {
        _v = v
        _path = path
    }
    /**
     - Parameter index: Index of element
     - Returns: `JJVal` or `JJVal(nil, path: newPath)` if `index` is out of `Array`
     */
    public subscript (index: Int) -> JJVal {
        return at(index)
    }
    /**
     - Parameter index: Index of element
     - Returns: `JJVal` or `JJVal(nil, path: newPath)` if `index` is out of `Array`
     */
    public func at(_ index: Int) -> JJVal {
        let newPath = _path + "[\(index)]"

        if index >= 0 && index < _v.count {
            return JJVal(_v[index], path: newPath)
        }
        return JJVal(nil, path: newPath)
    }

    // MARK: extension point
    /** Raw value of stored `Array` */
    public var raw: [AnyObject] { return _v }
    /** `String` value of the path in original object */
    public var path: String { return _path }

    // MARK: Shortcusts
    /** `True` if raw value isn't equal `nil` */
    public var exists: Bool { return true }
    /** The number of elements the `Array` stores */
    public var count:Int { return _v.count }
    /**
     - Parameters:
        - space: space between parent elements of `Array`
        - spacer: space to embedded values
     - Returns: A textual representation of `Array`
     */
    public func prettyPrint(space: String = "", spacer: String = "  ") -> String {
        if _v.count == 0 {
            return "[]"
        }
        var str = "[\n"
        let nextSpace = space + spacer
        for v in _v {
            str += "\(nextSpace)" + jj(v).prettyPrint(space: nextSpace, spacer: spacer) + ",\n"
        }
        str.remove(at: str.index(str.endIndex, offsetBy: -2))
        
        return str + "\(space)]"
    }
    /** A Textual representation of stored `Array` */
    public var debugDescription: String { return prettyPrint() }
}
/** 
 Struct with optional raw value of `Array`
 */
public struct JJMaybeArr {
    private let _path: String
    private let _v: JJArr?

    public init(_ v: JJArr?, path: String) {
        _v = v
        _path = path
    }

    public func at(_ index: Int) -> JJVal {
        return _v?.at(index) ?? JJVal(nil, path: _path + "<nil>[\(index)]")
    }

    public subscript (index: Int) -> JJVal { return at(index) }

    public var exists: Bool { return _v != nil }

    // MARK: extension point
    public var raw: [AnyObject]? { return _v?.raw }
    public var path: String { return _path }

}
/**
 Struct for store parsing `Dictionary`
 */
public struct JJObj: CustomDebugStringConvertible {
    private let _path: String
    private let _v: [String: AnyObject]
    /**
     - Parameters:
        - v: [`String` : `AnyObject`]
        - path: `String` value of the path in original object
     - Returns: `JJObj`
     */
    public init(_ v: [String: AnyObject], path: String) {
        _v = v
        _path = path
    }
    /**
     - Parameter key: Key of element of `Dictionary`
     - Returns: `JJVal`
     */
    public func at(_ key: String) -> JJVal {
        let newPath = _path + ".\(key)"
        #if DEBUG
            if let msg = _v["$\(key)__depricated"] {
                debugPrint("WARNING:!!!!. Using depricated field \(newPath): \(msg)")
            }
        #endif
        return JJVal(_v[key], path: newPath)
    }
    /**
     - Parameter key: Key of element of `Dictionary`
     - Returns: `JJVal`
     */
    public subscript (key: String) -> JJVal { return at(key) }

    // MARK: extension point
    /** Raw value of stored `Dictionary` */
    public var raw: [String: AnyObject] { return _v }
    /** `String` value of the path in original object */
    public var path: String { return _path }

    // Shortcusts
    /** `True` if raw value isn't equal `nil` */
    public var exists: Bool { return true }
    /** The number of elements the `Dictionary` stores */
    public var count:Int { return _v.count }
    /**
     - Parameters:
        - space: space between parent elements of `Dictionary`
        - spacer: space to embedded values
     - Returns: A textual representation of `Dictionary`
     */
    public func prettyPrint(space: String = "", spacer: String = "  ") -> String {
        if _v.count == 0 {
            return "{}"
        }
        var str = "{\n"
        for (k, v) in _v {
            let nextSpace = space + spacer
            str += "\(nextSpace)\"\(k)\": \(jj(v).prettyPrint(space: nextSpace, spacer: spacer)),\n"
        }
        str.remove(at: str.index(str.endIndex, offsetBy: -2))
        return str + "\(space)}"
    }
    /** A Textual representation of stored `Dictionary` */
    public var debugDescription: String { return prettyPrint() }
}
/**
 Struct with optional raw value of `Dictionary`
 */
public struct JJMaybeObj {
    private let _path: String
    private let _v: JJObj?

    public init(_ v: JJObj?, path: String) {
        _v = v
        _path = path
    }

    public func at(_ key: String) -> JJVal {
        return _v?.at(key) ?? JJVal(nil, path: _path + "<nil>.\(key)")
    }

    public subscript (key: String) -> JJVal { return at(key) }


    // MARK: extension point
    public var raw: [String: AnyObject]? { return _v?.raw }
    public var path: String { return _path }

    // MARK: shortcusts

    public var exists: Bool { return _v != nil }
}
/**
 Struct for store parsed value
 
 Stored types:
 - `Bool`
 - `Int`
 - `UInt`
 - `Number`
 - `Float`
 - `Double`
 - `Dictionary`
 - `Array`
 - `String`
 - `Date`
 - `URL`
 - `Null`
 - `TimeZone`
 
 To get access to stored value use `raw`
 */
public struct JJVal: CustomDebugStringConvertible {
    private let _path: String
    private let _v: AnyObject?
    /**
     - Parameters:
        - v: `AnyObject`
        - path: `String` value of the path in original object
     - Returns: `JJVal`
     */
    public init(_ v: AnyObject?, path: String = "<root>") {
        _v = v
        _path = path
    }

    // MARK: Bool
    /**
     Representation the raw value as `Bool`.
     
     If this impossible, it is set to `nil`
     */
    public var asBool: Bool? { return _v as? Bool }
    /**
     Represent raw value as `Bool`
     - Parameter defaultValue: Returned `Bool` value, if impossible represent raw value as `Bool` (`false` by default)
     - Returns: `Bool` value
    */
    public func toBool(_ defaultValue:  @autoclosure() -> Bool = false) -> Bool {
        return asBool ?? defaultValue()
    }
    /**
     - Returns: `Bool` value of raw value
     - Throws: `JJError.wrongType` if the raw value can't represent as `Bool`
     */
    public func bool() throws -> Bool {
        if let x = _v as? Bool {
            return x
        }
        throw JJError.wrongType(v: _v, path: _path, toType: "Bool")
    }

    // MARK: Int
    /**
     Representation the raw value as `Int`.
     
     If this impossible, it is set to `nil`
     */
    public var asInt: Int? { return _v as? Int }
    /**
     Represent raw value as `Int`
     - Parameter defaultValue: Returned `Int` value, if impossible represent raw value as `Int` (`0` by default)
     - Returns: `Int` value
     */
    public func toInt(_ defaultValue:  @autoclosure() -> Int = 0) -> Int {
        return asInt ?? defaultValue()
    }
    /**
     - Returns: `Int` value of raw value
     - Throws: `JJError.wrongType` if the raw value can't represent as `Int`
     */
    public func int() throws -> Int {
        if let x = asInt {
            return x
        }
        throw JJError.wrongType(v: _v, path: _path, toType: "Int")
    }

    // MARK: UInt
    /**
     Representation the raw value as `UInt`.
     
     If this impossible, it is set to `nil`
     */
    public var asUInt: UInt? { return _v as? UInt }
    /**
     Represent raw value as `UInt`
     - Parameter defaultValue: Returned `UInt` value, if impossible represent raw value as `UInt` (`0` by default)
     - Returns: `UInt` value
     */
    public func toUInt(_ defaultValue:  @autoclosure() -> UInt = 0) -> UInt {
        return asUInt ?? defaultValue()
    }
    /**
     - Returns: `UInt` value of raw value
     - Throws: `JJError.wrongType` if the raw value can't represent as `UInt`
     */
    public func uInt() throws -> UInt {
        if let x = asUInt {
            return x
        }
        throw JJError.wrongType(v: _v, path: _path, toType: "UInt")
    }

    // MARK: NSNumber
    /**
     Representation the raw value as `NSNumber`.
     
     If this impossible, it is set to `nil`
     */
    public var asNumber: NSNumber? { return _v as? NSNumber }
    /**
     Represent raw value as `NSNumber`
     - Parameter defaultValue: Returned `NSNumber` value, if impossible represent raw value as `NSNumber` (`0` by default)
     - Returns: `NSNumber` value
     */
    public func toNumber(_ defaultValue:  @autoclosure() -> NSNumber = 0) -> NSNumber {
        return asNumber ?? defaultValue()
    }
    /**
     - Returns: `NSNumber` value of raw value
     - Throws: `JJError.wrongType` if the raw value can't represent as `NSNumber`
     */
    public func number() throws -> NSNumber {
        if let x = asNumber {
            return x
        }
        throw JJError.wrongType(v: _v, path: _path, toType: "Number")
    }

    // MARK: Float
    /**
     Representation the raw value as `Float`.
     
     If this impossible, it is set to `nil`
     */
    public var asFloat: Float? { return _v as? Float }
    /**
     Represent raw value as `Float`
     - Parameter defaultValue: Returned `Float` value, if impossible represent raw value as `Float` (`0` by default)
     - Returns: `Float` value
     */
    public func toFloat(_ defaultValue:  @autoclosure() -> Float = 0) -> Float {
        return asFloat ?? defaultValue()
    }
    /**
     - Returns: `Float` value of raw value
     - Throws: `JJError.wrongType` if the raw value can't represent as `Float`
     */
    public func float() throws -> Float {
        if let x = asFloat {
            return x
        }
        throw JJError.wrongType(v: _v, path: _path,toType: "Float")
    }

    // MARK: Double
    /**
     Representation the raw value as `Double`.
     
     If this impossible, it is set to `nil`
     */
    public var asDouble: Double? { return _v as? Double }
    /**
     Represent raw value as `Double`
     - Parameter defaultValue: Returned `Double` value, if impossible represent raw value as `Double` (`0` by default)
     - Returns: `Double` value
     */
    public func toDouble(_ defaultValue:  @autoclosure() -> Double = 0) -> Double {
        return asDouble ?? defaultValue()
    }
    /**
     - Returns: `Double` value of raw value
     - Throws: `JJError.wrongType` if the raw value can't represent as `Double`
     */
    public func double() throws -> Double {
        if let x = asDouble {
            return x
        }
        throw JJError.wrongType(v: _v, path: _path,toType: "Double")
    }
    
    // MARK: Object
    /**
     Representation the raw value as `JJObj`.
     
     If this impossible, it is set to `nil`
     */
    public var asObj: JJObj? {
        if let obj = _v as? [String: AnyObject] {
            return JJObj(obj, path: _path)
        }

        return nil
    }
    /**
     Represent raw value as `JJObj`
     - Parameter defaultValue: Returned `JJObj` value, if impossible represent raw value as `JJObj` (`JJObj(nil, path: newPath)` by default)
     - Returns: `JJObj`
     */
    public func toObj() -> JJMaybeObj {
        return JJMaybeObj(asObj, path: _path)
    }
    /**
     - Returns: `JJMaybeObj` value with stored optional `JJObj` of raw value
     - Throws: `JJError.wrongType` if the raw value can't represent as `JJObj`
     */
    public func obj() throws -> JJObj {
        if let obj = _v as? [String: AnyObject] {
            return JJObj(obj, path: _path)
        }

        throw JJError.wrongType( v: _v, path: _path, toType: "[String: AnyObject]")
    }

    // MARK: Array
    /**
     Representation the raw value as `JJArr`.
     
     If this impossible, it is set to `nil`
     */
    public var asArr: JJArr? {
        if let arr = _v as? [AnyObject] {
            return JJArr(arr, path: _path)
        }
        return nil
    }
    /**
     Represent raw value as `JJArr`
     - Parameter defaultValue: Returned `JJArr` value, if impossible represent raw value as `JJArr` (`JJArr(nil, path: newPath)` by default)
     - Returns: `JJArr`
     */
    public func toArr() -> JJMaybeArr {
        return JJMaybeArr(asArr, path: _path)
    }
    /**
     - Returns: `JJMaybeArr` value with stored optional `JJArr` of raw value
     - Throws: `JJError.wrongType` if the raw value can't represent as `JJArr`
     */
    public func arr() throws -> JJArr {
        guard let arr = _v as? [AnyObject] else {
            throw JJError.wrongType( v: _v, path: _path, toType: "[AnyObject]")
        }
        return JJArr(arr, path: _path)
    }

    // MARK: String
    /**
     Representation the raw value as `String`.
     
     If this impossible, it is set to `nil`
     */
    public var asString: String? { return _v as? String }
    /**
     Represent raw value as `String`
     - Parameter defaultValue: Returned `String` value, if impossible represent raw value as `String` (Empty string by default)
     - Returns: `String` value
     */
    public func toString(_ defaultValue:  @autoclosure() -> String = "") -> String {
        return asString ?? defaultValue()
    }
    /**
     - Returns: `String` value of raw value
     - Throws: `JJError.wrongType` if the raw value can't represent as `String`
     */
    public func string() throws -> String {
        if let x = asString {
            return x
        }
        throw JJError.wrongType(v: _v, path: _path, toType: "String")
    }

    // MARK: Date
    /**
     Representation the raw value as `Date`.
     
     If this impossible, it is set to `nil`
     */
    public var asDate: Date? { return asString?.asRFC3339Date() }
    /**
     - Returns: `Date` value of raw value
     - Throws: `JJError.wrongType` if the raw value can't represent as `Date`
     */
    public func date() throws -> Date {
        if let d = asString?.asRFC3339Date() {
            return d
        } else {
            throw JJError.wrongType(v: _v, path: _path, toType: "Date")
        }
    }

    // MARK: URL
    /**
     Representation the raw value as `URL`.
     
     If this impossible, it is set to `nil`
     */
    public var asURL: URL? {
        if let s = asString, d = URL(string: s) {
            return d
        } else {
            return nil
        }
    }
    /**
     Represent raw value as `URL`
     - Parameter defaultValue: Returned `URL` value, if impossible represent raw value as `URL` (`URL(string: "")` by default)
     - Returns: `URL` value
     */
    public func toURL(_ defaultValue:  @autoclosure() -> URL = URL(string: "")!) -> URL {
        return asURL ?? defaultValue()
    }
    /**
     - Returns: `URL` value of raw value
     - Throws: `JJError.wrongType` if the raw value can't represent as `URL`
     */
    public func url() throws -> URL {
        if let s = asString, d = URL(string: s) {
            return d
        } else {
            throw JJError.wrongType(v: _v, path: _path, toType: "URL")
        }
    }

    // MARK: Null
    /** 'False' if raw value equal nil */
    public var isNull: Bool { return _v === NSNull() }

    // MARK: TimeZone
    /**
     Representation the raw value as `TimeZone`.
     
     If this impossible, it is set to `nil`
     */
    public var asTimeZone: TimeZone? {
        if let s = asString, d = TimeZone(name: s) {
            return d
        } else {
            return nil
        }
    }

    // MARK: Navigation as Object
    /**
     - Returns: JJVal by key if raw value can represent as JJObj
     */
    public func at(_ key: String) -> JJVal {
        return toObj()[key]
    }

    public subscript (key: String) -> JJVal {
        return at(key)
    }

    // MARK: Navigation as Array
    /**
     - Returns: JJVal by index if raw value can represent as JJArr
     */
    public func at(_ index: Int) -> JJVal {
        return toArr()[index]
    }

    public subscript (index: Int) -> JJVal {
        return at(index)
    }
    /** `True` if raw value isn't equal `nil` */
    public var exists: Bool { return _v != nil }

    // MARK: extension point

    /** `String` value of the path in original object */
    public var path: String { return _path }
    /** Raw value of stored object */
    public var raw: AnyObject? { return _v }

    // MARK: pretty print
    /**
     - Parameters:
        - space: space between parent elements of `Array`
        - spacer: space to embedded values
     - Returns: A textual representation of stored value
     */
    public func prettyPrint(space: String = "", spacer: String = "  ") -> String {
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
    /** A Textual representation of stored value */
    public var debugDescription: String { return prettyPrint() }
}
/** Struct to encode `NSCoder` values */
public struct JJEnc {
    private let _enc: NSCoder
    /**
     - Parameter enc: `NSCoder`
     - Returns: `JJEnc`
    */
    public init(_ enc: NSCoder) {
        _enc = enc
    }
    /**
     Put `Int` value
     - Parameters:
        - v: `Int` value
        - at: `String` value of key
     */
    public func put(int v:Int, at: String) {
        _enc.encode(Int32(v), forKey: at)
    }
    /**
     Put `Bool` value
     - Parameters:
        - v: `Bool` value
        - at: `String` value of key
     */
    public func put(bool v:Bool, at: String) {
        _enc.encode(v, forKey: at)
    }
    /**
     Put `AnyObject` value
     - Parameters:
        - v: `AnyObject` value
        - at: `String` value of key
     */
    public func put(_ v:AnyObject?, at: String) {
        _enc.encode(v, forKey: at)
    }
}
/**
 
 */
public struct JJDecVal {
    private let _key: String
    private let _dec: NSCoder
    /**
     - Parameters:
        - dec: `NSCoder` to decode
        - key: `String` value of key
     */
    public init(dec: NSCoder, key: String) {
        _key = key
        _dec = dec
    }
    /**
     - Returns: `String` value of encoded value
     - Throws: `JJError.wrongType` if the encoded value can't decoded to `String`
     */
    public func string() throws -> String {
        let v = _dec.decodeObject(forKey: _key)
        if let x = v as? String {
            return x
        }
        throw JJError.wrongType(v: v, path: _key, toType: "String")
    }
    /**
     Decode the encoded value as `String`.
     
     If this impossible, it is set to `nil`
     */
    public var asString: String? { return _dec.decodeObject(forKey: _key) as? String }
    /**
     - Returns: `Int` value of encoded value
     - Throws: `JJError.wrongType` if the encoded value can't decoded to `Int`
     */
    public func int() throws -> Int { return Int(_dec.decodeInt32(forKey: _key)) }
    /**
     Decode the encoded value as `Int`.
     
     If this impossible, it is set to `nil`
     */
    public var asInt: Int? { return _dec.decodeObject(forKey: _key) as? Int }
    /**
     Decode the encoded value as `Date`.
     
     If this impossible, it is set to `nil`
     */
    public var asDate: Date? { return _dec.decodeObject(forKey: _key) as? Date }
    /**
     Decode the encoded value as `URL`.
     
     If this impossible, it is set to `nil`
     */
    public var asURL: URL? { return _dec.decodeObject(forKey: _key) as? URL }
    /**
     Decode the encoded value as `TimeZone`.
     
     If this impossible, it is set to `nil`
     */
    public var asTimeZone: TimeZone? { return _dec.decodeObject(forKey: _key) as? TimeZone }
    /**
     - Returns: `String` value of encoded value
     - Throws: `JJError.wrongType` if the encoded value can't decoded to `String`
     */
    public func bool() throws -> Bool { return _dec.decodeBool(forKey: _key) }
    /**
     Decode raw value to `Bool`
     - Returns: `Bool` value
     */
    public func toBool() -> Bool { return _dec.decodeBool(forKey: _key) }
    /**
     Decode the encoded value as generic value.
     
     If this impossible, it is set to `nil`
     */
    public func decodeAs<T: NSCoding>() -> T? { return _dec.decodeObject(forKey: _key) as? T }
    /**
     - Returns: generic value of encoded value
     - Throws: `JJError.wrongType` if the encoded value can't decoded to needed type
     */
    public func decode<T: NSCoding>() throws -> T {
        let obj = _dec.decodeObject(forKey: _key)
        if let v:T = obj as? T {
            return v
        }
       
        // TODO: find a way to get type
        throw JJError.wrongType(v: obj, path: _key, toType: "T")
    }
    /**
     - Returns: `Date` value of encoded value
     - Throws: `JJError.wrongType` if the encoded value can't decoded to `Date`
     */
    public func date() throws -> Date {
        let v = _dec.decodeObject(forKey: _key)
        if let x = v as? Date {
            return x
        }
        throw JJError.wrongType(v: v, path: _key, toType: "Date")
    }
    
    // extension point
    public var decoder: NSCoder { return _dec }
    public var key: String { return _key }
}
/** Struct to decode `NSCoder` values */
public struct JJDec {
    private let _dec: NSCoder
    /**
     - Parameter dec: `NSCoder`
     - Returns: `JJDec`
     */
    public init(_ dec: NSCoder) {
        _dec = dec
    }

    public subscript (key: String) -> JJDecVal {
        return JJDecVal(dec: _dec, key: key)
    }
}
