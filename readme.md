# Regex

> Swifty [regular expressions](https://en.wikipedia.org/wiki/Regular_expression)

This is a wrapper for [`NSRegularExpression`](https://developer.apple.com/documentation/foundation/nsregularexpression) that makes it more convenient and type-safe to use regular expressions in Swift.

## Install

Add the following to `Package.swift`:

```swift
.package(url: "https://github.com/sindresorhus/Regex", from: "0.0.0")
```

[Or add the package in Xcode.](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

## Usage

First, import the package:

```swift
import Regex
```

[Supported regex syntax.](https://developer.apple.com/documentation/foundation/nsregularexpression#1661061)

### Examples

Check if it matches:

```swift
Regex(#"\d+"#).isMatched(by: "123")
//=> true
```

Get first match:

```swift
Regex(#"\d+"#).firstMatch(in: "123-456")?.value
//=> "123"
```

Get all matches:

```swift
Regex(#"\d+"#).allMatches(in: "123-456").map(\.value)
//=> ["123", "456"]
```

Replacing first match:

```swift
"123🦄456".replacingFirstMatch(of: #"\d+"#, with: "")
//=> "🦄456"
```

Replacing all matches:

```swift
"123🦄456".replacingAllMatches(of: #"\d+"#, with: "")
//=> "🦄"
```

Named capture groups:

```swift
let regex = Regex(#"\d+(?<word>[a-z]+)\d+"#)

regex.firstMatch(in: "123unicorn456")?.group(named: "word")?.value
//=> "unicorn"
```

[Pattern matching:](https://docs.swift.org/swift-book/ReferenceManual/Patterns.html)

```swift
switch "foo123" {
case Regex(#"^foo\d+$"#):
	print("Match!")
default:
	break
}

switch Regex(#"^foo\d+$"#) {
case "foo123":
	print("Match!")
default:
	break
}
```

## API

[See the API docs.](https://sindresorhus.com/Regex/Structs/Regex.html)

## FAQ

### Why are pattern strings wrapped in `#`?

Those are [raw strings](https://www.hackingwithswift.com/articles/162/how-to-use-raw-strings-in-swift) and they make it possible to, for example, use `\d` without having to escape the backslash.

## Related

- [Defaults](https://github.com/sindresorhus/Defaults) - Swifty and modern UserDefaults
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Add user-customizable global keyboard shortcuts to your macOS app
- [LaunchAtLogin](https://github.com/sindresorhus/LaunchAtLogin) - Add “Launch at Login” functionality to your macOS app
- [More…](https://github.com/search?q=user%3Asindresorhus+language%3Aswift)
