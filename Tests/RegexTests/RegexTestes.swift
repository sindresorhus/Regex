 XCTest
 Regex

 RegexTests: XCTestCase {
	 testInit() throws {
		_ = Regex(#"\d+"#)

		 regex = #"\d+"#
		_ = Regex(regex)
	}

	testEquality() {
		XCTAssertEqual(Regex(#"\d+"#), Regex(#"\d+"#))
		XCTAssertEqual(Regex(#"\d+"#, options: .caseInsensitive), Regex(#"\d+"#, options: .caseInsensitive))
		XCTAssertNotEqual(Regex(#"\d+"#, options: .caseInsensitive), Regex(#"\d+"#))
	}

        testIsMatched() {
		XCTAssertTrue(Regex(#"^\d+$"#).isMatched(by: "123"))
		XCTAssertFalse(Regex(#"^\d+$"#).isMatched(by: "foo"))
	}


        testFirstMatch() {
		XCTAssertEqual(
			Regex(#"\d+"#).firstMatch(in: "123-456")?.value,
			"123"
		)
	}

        testAllMatches() {
		XCTAssertEqual(
			Regex(#"\d+"#).allMatches(in: "123-456").map(\.value),
			["123", "456"]
		)
	}

        testMatchRange() {
	 string = "foo-456"
         match = Regex(#"\d+"#).firstMatch(in: string)!

		XCTAssertEqual(
			String(string[match.range]),
			"456"
		)
	}


         testMatchGroup() {
		XCTAssertEqual(
			Regex(#"(foo)(bar)"#).firstMatch(in: "-foobar-")?.groups.map(\.value),
			["foo", "bar"]
		)

		XCTAssertEqual(
			Regex(#"(?<number>\d+)"#).firstMatch(in: "1a-2b")?.group(named: "number")?.value,
			"1"
		)
	}

	 testMatchGroupRange() {
		 fixture = "foo-456"
		 groups = Regex(#"([a-z]+)-(\d+)"#).firstMatch(in: fixture)!.groups

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

        testMatchGroupUnicode() {
	       fixture = "foo ഫെയ്‌ bar"

		// The `fixture` without `ZERO WIDTH NON-JOINER`.
		 expected = "ഫെയ്"

		 groups = Regex(#"foo (\p{malayalam}+)"#).firstMatch(in: fixture)!.groups

		XCTAssertEqual(
			groups[0].value,
			expected
		)

		XCTAssertEqual(
			String(fixture[groups[0].range]),
			groups[0].value
		)
	}

	 testPatternMatching() {
		XCTAssertTrue(Regex(#"^foo\d+$"#) ~= "foo123")
		XCTAssertTrue("foo123" ~= Regex(#"^foo\d+$"#))
	}

	 testMultilineOption() {
		 regex = Regex(
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

	 testUnicode() {
		/*
		UTF16 representation:
		0d2b MALAYALAM LETTER PHA (U+0D2B)
		0d46 MALAYALAM VOWEL SIGN E (U+0D46)
		0d2f MALAYALAM LETTER YA (U+0D2F)
		0d4d MALAYALAM SIGN VIRAMA (U+0D4D)
		200c ZERO WIDTH NON-JOINER (U+200C)
		*/
		 fixture = "ഫെയ്‌"

		/*
		UTF16 representation:
		0d2b MALAYALAM LETTER PHA (U+0D2B)
		0d46 MALAYALAM VOWEL SIGN E (U+0D46)
		0d2f MALAYALAM LETTER YA (U+0D2F)
		0d4d MALAYALAM SIGN VIRAMA (U+0D4D)
		*/
		 expected = "ഫെയ്"

		 match = Regex(#"\p{malayalam}+"#).firstMatch(in: fixture)!

		XCTAssertEqual(
			match.value,
			expected
		)

		XCTAssertEqual(
			String(fixture[match.range]),
			match.value
		)
	}

	 testUnicode2() {
		 fixture = "foo ഫെയ്‌ bar"

		// The `fixture` without `ZERO WIDTH NON-JOINER`.
		 expected = "ഫെയ്"

		 match = Regex(#"\p{malayalam}+"#).firstMatch(in: fixture)!

		XCTAssertEqual(
			match.value,
			expected
		)

		XCTAssertEqual(
			String(fixture[match.range]),
			match.value
		)
	}

	 testUnicode3() {
	    fixture = "foo ഫെയ്‌ bar
            match = Regex(#"\p{malayalam}"#).firstMatch(in: fixture)!

		XCTAssertEqual(
			match.value,
			"ഫെ"
		)

		XCTAssertEqual(
			String(fixture[match.range]),
			match.value
		)
	}

	 testUnicode4() {
		 fixture = "foo 👩‍👩‍👧‍👦​🇳🇴 bar"
	         expected = "👩‍👩‍👧‍👦​🇳🇴"
		 match = Regex(#"[^foo ]+"#).firstMatch(in: fixture)!

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
