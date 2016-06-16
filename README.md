# JJ

[![CI Status](http://img.shields.io/travis/anjlab/JJ.svg?style=flat)](https://travis-ci.org/anjlab/JJ)
[![Version](https://img.shields.io/cocoapods/v/JJ.svg?style=flat)](http://cocoapods.org/pods/JJ)
[![License](https://img.shields.io/cocoapods/l/JJ.svg?style=flat)](http://cocoapods.org/pods/JJ)
[![Platform](https://img.shields.io/cocoapods/p/JJ.svg?style=flat)](http://cocoapods.org/pods/JJ)

Super simple json parser for Swift

### Requirements

Do depencies. You can copy JJ.swift into your project if you want.

### Installation

JJ is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JJ"
```

### Example

```swift
struct Repository {
let name: String
let description: String
let stargazersCount: Int
let language: String?
let sometimesMissingKey: String?

let owner: User //Struct conforming NSCoding
let defaultBranch: Branch // Struct NOT conforming to NSCoding

var fullName: String { return "\(owner.login) \(name)" }

init(anyObject: AnyObject?) throws {
let obj = try jj(anyObject).obj()
self.name = obj["name"].toString()
self.description = obj["description"].toString()
self.stargazersCount = obj["stargazersCount"].toInt()
self.language = obj["language"].asString
self.sometimesMissingKey = obj["sometimesMissingKey"].asString

self.owner = obj["owner"].decode() as User
self.defaultBranch = Branch(name: obj["branch"].toString())
}
}

let json = [
"name" : "JJ",
"description" : "Super simple json parser for Swift",
"stargazersCount" : 999999,
"language" : "RU",
"sometimesMissingKey" : NSNull(),
"owner" : [
"name" : "Yury",
"headquarters" : "AnjLab" 
],
"branch" : "master"
]

do {
let repository = try Repostory(anyObject: json)
} catch {
debugPrint(error)
}
```

### Features
- Informative errors
- Decoding depends on inferred type
- Leverages Swift 2's error handling
- Support classes conforming ```NSCoding```

### Parsing Formats
- `Bool`
- `Int` & `UInt`
- `Float`
- `Double`
- `NSNumber`
- `String`
- `NSDate`
- `NSURL`
- `NSTimeZone`
- [`AnyObject`]
- [`String` : `AnyObject`]

### Errors
`JJError` conforming `ErrorType` and there are currently two error-structs conforming to it
- `WrongType` throws when it is impossible to convert the element
- `NotFound` throws if the element is missing

```swift
let json = ["element"]

do {
let _ = try jj(json).obj()
} catch {
print(error)
}

//  JJError.WrongType: Can't convert Optional(<_TtCs21_SwiftDeferredNSArray 0x7fa3be4acb40>(
//  element
//  )
//  ) at path: '<root>' to type '[String: AnyObject]'
```

### Handling Errors

| Method | Examples | Null Behaviour | Missing Key Behaviour | Type Mismatch Behaviour |
| --- | :---: | :---: | :---: | :---: |
| `.<Type>()` | `.int()` | `throws` | `throws` | `throws` |
| `.to<Type>(defaultValue)` | `.toString()` or `.toString("Default")` | `defaultValue` | `defaultValue` | `defaultValue` |
| `.as<Type>` | `.asObj` | `nil` | `nil` | `nil` |
| `.decode()` | `.decode() as NSNumber` | `nil` | `nil` | `nil` |
| `.decodeAs()` | `.decodeAs()` | ```nil``` | `nil` | `nil` |


### Requirements
- iOS 8.0+ / Mac OS X 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 7.3
- Swift 2.2

### Author

Yury Korolev, yury.korolev@gmail.com

### License

JJ is available under the MIT license. See the LICENSE file for more info.