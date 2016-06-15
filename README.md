# JJ

[![CI Status](http://img.shields.io/travis/anjlab/JJ.svg?style=flat)](https://travis-ci.org/anjlab/JJ)
[![Version](https://img.shields.io/cocoapods/v/JJ.svg?style=flat)](http://cocoapods.org/pods/JJ)
[![License](https://img.shields.io/cocoapods/l/JJ.svg?style=flat)](http://cocoapods.org/pods/JJ)
[![Platform](https://img.shields.io/cocoapods/p/JJ.svg?style=flat)](http://cocoapods.org/pods/JJ)

Super simple json parser for Swift

## Requirements

Do depencies. You can copy JJ.swift into your project if you want.

## Installation

JJ is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JJ"
```

## Example

```swift
import JJ

...

do {
let obj = try jj(json).obj()
} catch {
print(error)
}
```

## Author

Yury Korolev, yury.korolev@gmail.com

## License

JJ is available under the MIT license. See the LICENSE file for more info.
