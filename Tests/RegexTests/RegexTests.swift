import XCTest
@testable import Regex

final class RegexTests: XCTestCase {
	func testInit() throws {
		_ = Regex(#"\d+"#)

		let regex = #"\d+"#
		_ = try Regex(regex)
	}

	func testEquality() {
		XCTAssertEqual(Regex(#"\d+"#), Regex(#"\d+"#))
		XCTAssertEqual(Regex(#"\d+"#, options: .caseInsensitive), Regex(#"\d+"#, options: .caseInsensitive))
		XCTAssertNotEqual(Regex(#"\d+"#, options: .caseInsensitive), Regex(#"\d+"#))
	}

	func testIsMatched() {
		XCTAssertTrue(Regex(#"^\d+$"#).isMatched(by: "123"))
		XCTAssertFalse(Regex(#"^\d+$"#).isMatched(by: "foo"))
	}

	func testFirstMatch() {
		XCTAssertEqual(
			Regex(#"\d+"#).firstMatch(in: "123-456")?.value,
			"123"
		)
	}

	func testAllMatches() {
		XCTAssertEqual(
			Regex(#"\d+"#).allMatches(in: "123-456").map(\.value),
			["123", "456"]
		)
	}

	func testMatchRange() {
		let string = "foo-456"
		let match = Regex(#"\d+"#).firstMatch(in: string)!

		XCTAssertEqual(
			String(string[match.range]),
			"456"
		)
	}


	func testMatchGroup() {
		XCTAssertEqual(
			Regex(#"(foo)(bar)"#).firstMatch(in: "-foobar-")?.groups.map(\.value),
			["foo", "bar"]
		)

		XCTAssertEqual(
			Regex(#"(?<number>\d+)"#).firstMatch(in: "1a-2b")?.group(named: "number")?.value,
			"1"
		)
	}

	func testMatchGroupRange() {
		let fixture = "foo-456"
		let groups = Regex(#"([a-z]+)-(\d+)"#).firstMatch(in: fixture)!.groups

		XCTAssertEqual(
			fixture[groups[0].range],
			"foo"
		)

		XCTAssertEqual(
			fixture[groups[1].range],
			"456"
		)

		XCTAssertEqual(
			String(fixture[groups[0].range]),
			groups[0].value
		)

		XCTAssertEqual(
			String(fixture[groups[1].range]),
			groups[1].value
		)
	}

	func testMatchGroupUnicode() {
		let fixture = "foo ഫെയ്‌ bar"

		// The `fixture` without `ZERO WIDTH NON-JOINER`.
		let expected = "ഫെയ്"

		let groups = Regex(#"foo (\p{malayalam}+)"#).firstMatch(in: fixture)!.groups

		XCTAssertEqual(
			groups[0].value,
			expected
		)

		XCTAssertEqual(
			String(fixture[groups[0].range]),
			groups[0].value
		)
	}

	func testPatternMatching() {
		XCTAssertTrue(Regex(#"^foo\d+$"#) ~= "foo123")
		XCTAssertTrue("foo123" ~= Regex(#"^foo\d+$"#))
	}

	func testMultilineOption() {
		let regex = Regex(
			#"""
			^
			[a-z]+  # Match the word
			\d+     # Match the number
			$
			"""#,
			options: .allowCommentsAndWhitespace
		)

		XCTAssertTrue(regex.isMatched(by: "foo123"))
	}

	func testUnicode() {
		/*
		UTF16 representation:
		0d2b MALAYALAM LETTER PHA (U+0D2B)
		0d46 MALAYALAM VOWEL SIGN E (U+0D46)
		0d2f MALAYALAM LETTER YA (U+0D2F)
		0d4d MALAYALAM SIGN VIRAMA (U+0D4D)
		200c ZERO WIDTH NON-JOINER (U+200C)
		*/
		let fixture = "ഫെയ്‌"

		/*
		UTF16 representation:
		0d2b MALAYALAM LETTER PHA (U+0D2B)
		0d46 MALAYALAM VOWEL SIGN E (U+0D46)
		0d2f MALAYALAM LETTER YA (U+0D2F)
		0d4d MALAYALAM SIGN VIRAMA (U+0D4D)
		*/
		let expected = "ഫെയ്"

		let match = Regex(#"\p{malayalam}+"#).firstMatch(in: fixture)!

		XCTAssertEqual(
			match.value,
			expected
		)

		XCTAssertEqual(
			String(fixture[match.range]),
			match.value
		)
	}

	func testUnicode2() {
		let fixture = "foo ഫെയ്‌ bar"

		// The `fixture` without `ZERO WIDTH NON-JOINER`.
		let expected = "ഫെയ്"

		let match = Regex(#"\p{malayalam}+"#).firstMatch(in: fixture)!

		XCTAssertEqual(
			match.value,
			expected
		)

		XCTAssertEqual(
			String(fixture[match.range]),
			match.value
		)
	}

	func testUnicode3() {
		let fixture = "foo ഫെയ്‌ bar"
		let match = Regex(#"\p{malayalam}"#).firstMatch(in: fixture)!

		XCTAssertEqual(
			match.value,
			"ഫെ"
		)

		XCTAssertEqual(
			String(fixture[match.range]),
			match.value
		)
	}

	func testUnicode4() {
		let fixture = "foo 👩‍👩‍👧‍👦​🇳🇴 bar"
		let expected = "👩‍👩‍👧‍👦​🇳🇴"
		let match = Regex(#"[^foo ]+"#).firstMatch(in: fixture)!

		XCTAssertEqual(
			match.value,
			expected
		)

		XCTAssertEqual(
			String(fixture[match.range]),
			match.value
		)
	}
}
