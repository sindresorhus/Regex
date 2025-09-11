import Testing
import Foundation
@testable import Regex

struct RegexTests {
	// MARK: - Initialization
	
	@Test 
	func initialization() throws {
		// StaticString init (doesn't throw)
		let staticRegex = Regex(#"\d+"#)
		#expect(staticRegex.pattern == #"\d+"#)
		#expect(staticRegex.options.isEmpty)
		
		// String init (can throw)
		let pattern = #"\d+"#
		let stringRegex = try Regex(pattern)
		#expect(stringRegex.pattern == pattern)
		
		// With options
		let optionsRegex = Regex(#"[a-z]+"#, options: [.caseInsensitive, .anchorsMatchLines])
		#expect(optionsRegex.options.contains(.caseInsensitive))
		#expect(optionsRegex.options.contains(.anchorsMatchLines))
		
		// NSRegularExpression init
		let nsRegex = try NSRegularExpression(pattern: #"\w+"#, options: .caseInsensitive)
		let wrappedRegex = Regex(nsRegex)
		#expect(wrappedRegex.pattern == #"\w+"#)
		#expect(wrappedRegex.options.contains(.caseInsensitive))
		
		// Invalid pattern
		#expect(throws: (any Error).self) {
			let invalid = "["
			_ = try Regex(invalid)
		}
	}
	
	// MARK: - Equality & Hashable
	
	@Test 
	func equalityAndHashable() {
		let regex1 = Regex(#"\d+"#)
		let regex2 = Regex(#"\d+"#)
		let regex3 = Regex(#"\d+"#, options: .caseInsensitive)
		let regex4 = Regex(#"[a-z]+"#)
		
		// Equality
		#expect(regex1 == regex2)
		#expect(regex1 != regex3) // Different options
		#expect(regex1 != regex4) // Different pattern
		
		// Hashable - test Set deduplication
		let set: Set = [regex1, regex2, regex3]
		#expect(set.count == 2) // regex1 and regex2 should deduplicate
		
		// Options order shouldn't matter
		let multiOption1 = Regex(#"test"#, options: [.caseInsensitive, .anchorsMatchLines])
		let multiOption2 = Regex(#"test"#, options: [.anchorsMatchLines, .caseInsensitive])
		#expect(multiOption1 == multiOption2)
	}
	
	// MARK: - Basic Matching
	
	@Test 
	func basicMatching() {
		let digitRegex = Regex(#"^\d+$"#)
		
		// Matches
		#expect(digitRegex.isMatched(by: "123"))
		#expect(digitRegex.isMatched(by: "0"))
		
		// Non-matches
		#expect(!digitRegex.isMatched(by: "foo"))
		#expect(!digitRegex.isMatched(by: "123a"))
		#expect(!digitRegex.isMatched(by: "a123"))
		#expect(!digitRegex.isMatched(by: ""))
		
		// Empty pattern edge case
		let emptyRegex = Regex("^$")
		#expect(emptyRegex.isMatched(by: ""))
		#expect(!emptyRegex.isMatched(by: "a"))
	}
	
	@Test 
	func firstMatch() {
		let regex = Regex(#"\d+"#)
		
		// Found match
		let match = regex.firstMatch(in: "abc123def456")
		#expect(match?.value == "123") // Gets first match
		
		// No match
		let noMatch = regex.firstMatch(in: "abcdef")
		#expect(noMatch == nil)
		
		// Match range validation
		let string = "foo-456-bar"
		let rangeMatch = regex.firstMatch(in: string)!
		#expect(String(string[rangeMatch.range]) == "456")
	}
	
	@Test 
	func allMatches() {
		let regex = Regex(#"\d+"#)
		
		// Multiple matches
		let matches = regex.allMatches(in: "123-456-789")
		#expect(matches.count == 3)
		#expect(matches.map(\.value) == ["123", "456", "789"])
		
		// No matches
		let noMatches = regex.allMatches(in: "abcdef")
		#expect(noMatches.isEmpty)
		
		// Non-overlapping matches
		let letterRegex = Regex(#"a+"#)
		let letterMatches = letterRegex.allMatches(in: "aaabaaaa")
		#expect(letterMatches.map(\.value) == ["aaa", "aaaa"])
	}
	
	// MARK: - Capture Groups
	
	@Test 
	func captureGroups() {
		// Basic groups
		let dateRegex = Regex(#"(\d{4})-(\d{2})-(\d{2})"#)
		let dateMatch = dateRegex.firstMatch(in: "Today is 2024-03-15")!
		#expect(dateMatch.groups.count == 3)
		#expect(dateMatch.groups[0].value == "2024")
		#expect(dateMatch.groups[1].value == "03")
		#expect(dateMatch.groups[2].value == "15")
		
		// Named groups
		let namedRegex = Regex(#"(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})"#)
		let namedMatch = namedRegex.firstMatch(in: "Date: 2024-03-15")!
		#expect(namedMatch.group(named: "year")?.value == "2024")
		#expect(namedMatch.group(named: "month")?.value == "03")
		#expect(namedMatch.group(named: "day")?.value == "15")
		#expect(namedMatch.group(named: "hour") == nil)
		
		// Mixed named and unnamed groups
		let urlRegex = Regex(#"(?<protocol>https?)://([^/]+)(?<path>/.*)"#)
		let urlMatch = urlRegex.firstMatch(in: "Visit https://example.com/path")!
		#expect(urlMatch.group(named: "protocol")?.value == "https")
		#expect(urlMatch.groups[1].value == "example.com") // Unnamed group
		#expect(urlMatch.group(named: "path")?.value == "/path")
	}
	
	@Test 
	func optionalAndNestedGroups() {
		// Optional groups
		let optionalRegex = Regex(#"(\d+)(?:-(\d+))?"#)
		
		let withOptional = optionalRegex.firstMatch(in: "123-456")!
		#expect(withOptional.groups.count == 2)
		#expect(withOptional.groups[0].value == "123")
		#expect(withOptional.groups[1].value == "456")
		
		let withoutOptional = optionalRegex.firstMatch(in: "123")!
		#expect(withoutOptional.groups.count == 1)
		#expect(withoutOptional.groups[0].value == "123")
		
		// Nested groups
		let nestedRegex = Regex(#"((a+)(b+))"#)
		let nestedMatch = nestedRegex.firstMatch(in: "aaabbb")!
		#expect(nestedMatch.groups.count == 3)
		#expect(nestedMatch.groups[0].value == "aaabbb") // Outer group
		#expect(nestedMatch.groups[1].value == "aaa")    // First inner
		#expect(nestedMatch.groups[2].value == "bbb")    // Second inner
	}
	
	@Test 
	func captureGroupRanges() {
		let email = "user@domain.com"
		let emailRegex = Regex(#"([^@]+)@([^.]+)\.(.+)"#)
		let match = emailRegex.firstMatch(in: email)!
		
		// Verify ranges extract correct substrings
		#expect(String(email[match.groups[0].range]) == "user")
		#expect(String(email[match.groups[1].range]) == "domain")
		#expect(String(email[match.groups[2].range]) == "com")
		
		// Verify consistency between value and range
		for group in match.groups {
			#expect(String(email[group.range]) == group.value)
		}
	}
	
	// MARK: - Pattern Matching Operator
	
	@Test 
	func patternMatchingOperator() {
		let regex = Regex(#"^foo\d+$"#)
		
		// Test ~= operator both directions
		#expect(regex ~= "foo123")
		#expect("foo123" ~= regex)
		#expect(!(regex ~= "bar123"))
		#expect(!("bar123" ~= regex))
		
		// Use in switch statements
		switch "foo456" {
		case regex:
			break // Expected to match
		default:
			#expect(Bool(false), "Should have matched")
		}
		
		// Practical use in filter
		let strings = ["foo1", "bar2", "foo3", "baz4", "foo5"]
		let matches = strings.filter { regex ~= $0 }
		#expect(matches == ["foo1", "foo3", "foo5"])
	}
	
	// MARK: - Regex Options
	
	@Test 
	func caseInsensitiveOption() {
		let regex = Regex(#"^[a-z]+$"#, options: .caseInsensitive)
		
		#expect(regex.isMatched(by: "abc"))
		#expect(regex.isMatched(by: "ABC"))
		#expect(regex.isMatched(by: "AbC"))
		#expect(!regex.isMatched(by: "123"))
	}
	
	@Test 
	func multilineOptions() {
		let text = """
		first line
		123 second
		third line
		"""
		
		// anchorsMatchLines allows ^ to match at line starts
		let anchorRegex = Regex(#"^\d+"#, options: .anchorsMatchLines)
		#expect(anchorRegex.firstMatch(in: text)?.value == "123")
		
		let noAnchorRegex = Regex(#"^\d+"#)
		#expect(noAnchorRegex.firstMatch(in: text) == nil)
		
		// dotMatchesLineSeparators allows . to match newlines
		let dotRegex = Regex(#"first.second"#, options: .dotMatchesLineSeparators)
		#expect(dotRegex.isMatched(by: "first\nsecond"))
		
		let noDotRegex = Regex(#"first.second"#)
		#expect(!noDotRegex.isMatched(by: "first\nsecond"))
	}
	
	@Test 
	func extendedSyntaxOption() {
		// allowCommentsAndWhitespace enables extended syntax
		let regex = Regex(
			#"""
			^           # Start of string
			[a-z]+      # One or more letters
			\s+         # One or more whitespace
			\d+         # One or more digits
			$           # End of string
			"""#,
			options: .allowCommentsAndWhitespace
		)
		
		#expect(regex.isMatched(by: "hello 123"))
		#expect(!regex.isMatched(by: "hello123"))
	}
	
	// MARK: - Unicode Support
	
	@Test 
	func unicodeMatching() {
		// Malayalam text with zero-width non-joiner
		let malayalam = "ഫെയ്‌"
		let malayalamMatch = Regex(#"\p{malayalam}+"#).firstMatch(in: malayalam)!
		#expect(malayalamMatch.value == "ഫെയ്")
		
		// Complex emoji sequences
		let emojiText = "Family: 👩‍👩‍👧‍👦 Flag: 🇳🇴"
		let emojiMatch = Regex(#"👩‍👩‍👧‍👦"#).firstMatch(in: emojiText)!
		#expect(emojiMatch.value == "👩‍👩‍👧‍👦")
		
		// Unicode properties
		let mixed = "Hello 世界 123"
		let letters = Regex(#"\p{Letter}+"#).allMatches(in: mixed).map(\.value)
		#expect(letters == ["Hello", "世界"])
		
		let numbers = Regex(#"\p{Number}+"#).firstMatch(in: mixed)?.value
		#expect(numbers == "123")
	}
	
	// MARK: - Codable
	
	@Test 
	func codableSupport() throws {
		// Basic encoding/decoding
		let original = Regex(#"\d+"#, options: [.caseInsensitive, .anchorsMatchLines])
		
		let encoder = JSONEncoder()
		let data = try encoder.encode(original)
		
		let decoder = JSONDecoder()
		let decoded = try decoder.decode(Regex.self, from: data)
		
		// Verify equality
		#expect(original == decoded)
		#expect(original.pattern == decoded.pattern)
		#expect(original.options == decoded.options)
		
		// Verify functionality preserved
		#expect(decoded.isMatched(by: "123"))
		
		// Complex pattern with named groups
		let complexPattern = #"(?<year>\d{4})-(?<month>\d{2})"#
		let complexRegex = try Regex(complexPattern, options: .caseInsensitive)
		
		let complexData = try encoder.encode(complexRegex)
		let complexDecoded = try decoder.decode(Regex.self, from: complexData)
		
		let match = complexDecoded.firstMatch(in: "Date: 2024-03")!
		#expect(match.group(named: "year")?.value == "2024")
		#expect(match.group(named: "month")?.value == "03")
	}
	
	// MARK: - Special Features
	
	@Test 
	func escapingUtility() {
		// Test the escapingPattern utility
		let userInput = "Price: $19.99 [on sale]"
		let escaped = Regex.escapingPattern(for: userInput)
		let literalRegex = try! Regex(escaped)
		
		#expect(literalRegex.isMatched(by: userInput))
		#expect(!literalRegex.isMatched(by: "Price: 19.99 on sale"))
	}
	
	@Test 
	func quantifiersAndBoundaries() {
		// Quantifiers
		let quantifierRegex = Regex(#"a{2,4}"#)
		#expect(!quantifierRegex.isMatched(by: "a"))
		#expect(quantifierRegex.firstMatch(in: "aa")?.value == "aa")
		#expect(quantifierRegex.firstMatch(in: "aaaaa")?.value == "aaaa") // Matches first 4
		
		// Word boundaries
		let wordRegex = Regex(#"\btest\b"#)
		#expect(wordRegex.isMatched(by: "test"))
		#expect(wordRegex.isMatched(by: "a test b"))
		#expect(!wordRegex.isMatched(by: "testing"))
		#expect(!wordRegex.isMatched(by: "contest"))
	}
	
	@Test 
	func performanceWithLargeStrings() {
		// Test with very long string
		let longString = String(repeating: "a", count: 10000) + "123" + String(repeating: "b", count: 10000)
		let regex = Regex(#"\d+"#)
		
		let match = regex.firstMatch(in: longString)
		#expect(match?.value == "123")
	}
}