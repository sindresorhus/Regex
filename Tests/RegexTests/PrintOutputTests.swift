import Testing
import Foundation
@testable import Regex

struct PrintOutputTests {
	// MARK: - Regex Description Tests
	
	@Test 
	func regexDescription() {
		// Without options
		let regex1 = Regex(#"\d+"#)
		#expect(regex1.description == #"/\d+/"#)
		
		// With single option
		let regex2 = Regex(#"[a-z]+"#, options: .caseInsensitive)
		#expect(regex2.description == "/[a-z]+/[caseInsensitive]")
		
		// With multiple options
		let regex3 = Regex(#"^test$"#, options: [.caseInsensitive, .anchorsMatchLines])
		#expect(regex3.description == "/^test$/[caseInsensitive, anchorsMatchLines]")
		
		// With all options
		let regex4 = Regex(#"test"#, options: [
			.caseInsensitive,
			.allowCommentsAndWhitespace,
			.ignoreMetacharacters,
			.dotMatchesLineSeparators,
			.anchorsMatchLines,
			.useUnixLineSeparators,
			.useUnicodeWordBoundaries
		])
		#expect(regex4.description.contains("/test/["))
		#expect(regex4.description.contains("caseInsensitive"))
		#expect(regex4.description.contains("allowCommentsAndWhitespace"))
		#expect(regex4.description.contains("ignoreMetacharacters"))
		#expect(regex4.description.contains("dotMatchesLineSeparators"))
		#expect(regex4.description.contains("anchorsMatchLines"))
		#expect(regex4.description.contains("useUnixLineSeparators"))
		#expect(regex4.description.contains("useUnicodeWordBoundaries"))
	}
	
	// MARK: - Match Description Tests
	
	@Test 
	func matchDescription() {
		let regex = Regex(#"\d+"#)
		
		// Match without groups
		if let match = regex.firstMatch(in: "abc123def") {
			#expect(match.description.starts(with: "\"123\" at "))
			#expect(!match.description.contains("groups"))
		}
		
		// Match with groups
		let groupRegex = Regex(#"(\d+)([a-z]+)"#)
		if let groupMatch = groupRegex.firstMatch(in: "123abc") {
			#expect(groupMatch.description.starts(with: "\"123abc\" at "))
			#expect(groupMatch.description.contains("with groups: [\"123\", \"abc\"]"))
		}
	}
	
	// MARK: - Group Description Tests
	
	@Test 
	func groupDescription() {
		let regex = Regex(#"(\d+)([a-z]+)"#)
		
		if let match = regex.firstMatch(in: "123abc") {
			#expect(match.groups.count == 2)
			#expect(match.groups[0].description == "\"123\"")
			#expect(match.groups[1].description == "\"abc\"")
		}
	}
	
	// MARK: - Complex Pattern Tests
	
	@Test 
	func complexPatternDescription() {
		// Pattern with special characters
		let regex1 = Regex(#"^\w+@\w+\.\w+$"#)
		#expect(regex1.description == #"/^\w+@\w+\.\w+$/"#)
		
		// Pattern with named groups
		let regex2 = Regex(#"(?<year>\d{4})-(?<month>\d{2})"#)
		#expect(regex2.description == #"/(?<year>\d{4})-(?<month>\d{2})/"#)
		
		// Pattern with escapes
		let regex3 = Regex(#"\$\d+\.\d+"#)
		#expect(regex3.description == #"/\$\d+\.\d+/"#)
	}
}