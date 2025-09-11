import Testing
@testable import Regex

struct StringExtensionTests {
	// MARK: - Replace First Match
	
	@Test 
	func replacingFirstMatch() {
		// Basic replacement
		#expect(
			"123foo456bar".replacingFirstMatch(of: Regex(#"[a-z]+"#), with: "🦄") == "123🦄456bar"
		)
		
		// No match returns original
		#expect(
			"12345".replacingFirstMatch(of: Regex(#"[a-z]+"#), with: "🦄") == "12345"
		)
		
		// Empty replacement removes match
		#expect(
			"123foo456bar".replacingFirstMatch(of: Regex(#"[a-z]+"#), with: "") == "123456bar"
		)
		
		// String pattern overload
		#expect(
			"123foo456bar".replacingFirstMatch(of: #"[a-z]+"#, with: "🦄") == "123🦄456bar"
		)
		
		// Only first of multiple matches
		#expect(
			"foo123bar456baz".replacingFirstMatch(of: Regex(#"\d+"#), with: "XXX") == "fooXXXbar456baz"
		)
	}
	
	@Test 
	func replacingFirstMatchWithCaptureGroups() {
		let result = "Name: John Doe".replacingFirstMatch(
			of: Regex(#"Name: ([A-Z][a-z]+) ([A-Z][a-z]+)"#),
			with: "Hello $2, $1"
		)
		#expect(result == "Hello Doe, John")
	}
	
	// MARK: - Replace All Matches
	
	@Test 
	func replacingAllMatches() {
		// Basic replacement
		#expect(
			"123foo456bar".replacingAllMatches(of: Regex(#"[a-z]+"#), with: "🦄") == "123🦄456🦄"
		)
		
		// No match returns original
		#expect(
			"12345".replacingAllMatches(of: Regex(#"[a-z]+"#), with: "🦄") == "12345"
		)
		
		// Empty replacement removes all matches
		#expect(
			"123foo456bar789".replacingAllMatches(of: Regex(#"[a-z]+"#), with: "") == "123456789"
		)
		
		// String pattern overload
		#expect(
			"123foo456bar".replacingAllMatches(of: #"[a-z]+"#, with: "🦄") == "123🦄456🦄"
		)
		
		// Multiple distinct matches
		#expect(
			"foo123bar456baz789".replacingAllMatches(of: Regex(#"\d+"#), with: "NUM") == "fooNUMbarNUMbazNUM"
		)
		
		// Single character matches
		#expect(
			"a1b2c3d".replacingAllMatches(of: Regex(#"[a-z]"#), with: "X") == "X1X2X3X"
		)
	}
	
	@Test 
	func replacingAllMatchesWithCaptureGroups() {
		let result = "First: John, Last: Doe, Age: 30".replacingAllMatches(
			of: Regex(#"(\w+): (\w+)"#),
			with: "[$1=$2]"
		)
		#expect(result == "[First=John], [Last=Doe], [Age=30]")
	}
	
	// MARK: - Special Cases
	
	@Test 
	func replacingWithUnicode() {
		// Unicode property matching
		#expect(
			"Hello 世界".replacingFirstMatch(of: Regex(#"\p{Han}+"#), with: "World") == "Hello World"
		)
		
		// Emoji replacement
		#expect(
			"I love 🐱 and 🐶".replacingAllMatches(of: Regex(#"🐱|🐶"#), with: "❤️") == "I love ❤️ and ❤️"
		)
	}
	
	@Test 
	func replacingZeroWidthMatches() {
		// Word boundaries are zero-width assertions
		let result = "hello world".replacingAllMatches(of: Regex(#"\b"#), with: "|")
		#expect(result == "|hello| |world|")
	}
	
	@Test 
	func replacingWithOptions() {
		// Case insensitive option is preserved
		let caseInsensitive = "ABC def GHI".replacingAllMatches(
			of: Regex(#"[a-z]+"#, options: .caseInsensitive),
			with: "X"
		)
		#expect(caseInsensitive == "X X X")
		
		// Without option, only lowercase matches
		let caseSensitive = "ABC def GHI".replacingAllMatches(
			of: Regex(#"[a-z]+"#),
			with: "X"
		)
		#expect(caseSensitive == "ABC X GHI")
	}
}