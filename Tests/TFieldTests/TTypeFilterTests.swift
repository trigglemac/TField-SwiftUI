//
//  TTypeFilterTests.swift
//  TFieldTests
//
//  Created by Timothy Riggle on 9/20/25.
//

import XCTest
@testable import TField

final class TTypeFilterTests: XCTestCase {
    
    // MARK: - Helper Function for Array Testing
    
    func testFilterWithArray(
        _ type: TType,
        testCases: [(input: String, expected: String)]
    ) {
        for testCase in testCases {
            let result = type.filter(testCase.input)
            XCTAssertEqual(
                result,
                testCase.expected,
                "Filter failed for \(type) with input '\(testCase.input)': expected '\(testCase.expected)', got '\(result)'"
            )
        }
    }
    
    // MARK: - Data Type Tests
    
    func testDataFilter() {
        let type = TType.data
        
        // Individual tests
        XCTAssertEqual(type.filter("hello world"), "helloworld")
        XCTAssertEqual(type.filter("  spaces  everywhere  "), "spaceseverywhere")
        XCTAssertEqual(type.filter(""), "")
        XCTAssertEqual(type.filter("single"), "single")
        
        // Array test
        let testCases: [(String, String)] = [
            ("hello world", "helloworld"),
            ("test 123", "test123"),
            ("   leading spaces", "leadingspaces"),
            ("trailing spaces   ", "trailingspaces"),
            ("multiple   spaces   between", "multiplespacesbetween"),
            ("tab there", "tabthere"),
            ("newline\nhere", "newlinehere"),
            ("mixed\t\n spaces", "mixedspaces"),
            ("", ""),
            ("nospaces", "nospaces")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    func testDataLengthFilter() {
        let type = TType.dataLength(length: 5)
        
        // Individual tests
        XCTAssertEqual(type.filter("123456789"), "12345")
        XCTAssertEqual(type.filter("hello world"), "hello")
        XCTAssertEqual(type.filter("hi"), "hi")
        XCTAssertEqual(type.filter(""), "")
        
        // Array test
        let testCases: [(String, String)] = [
            ("123456789", "12345"),
            ("hello world", "hello"),
            ("a b c d e f g", "abcde"),
            ("short", "short"),
            ("exact", "exact"),
            ("", ""),
            ("  spaced  out  ", "space"),
            ("tab\ttab", "tabta")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - Name Filter Tests
    
    func testNameFilter() {
        let type = TType.name
        
        // Individual tests
        XCTAssertEqual(type.filter("john doe"), "John Doe")
        XCTAssertEqual(type.filter("o'connor"), "O'Connor")
        XCTAssertEqual(type.filter("  john"), "John")
        XCTAssertEqual(type.filter("mary-jane"), "Mary-Jane")
        
        // Array test
        let testCases: [(String, String)] = [
            ("john doe", "John Doe"),
            ("mary jane smith", "Mary Jane Smith"),
            ("  john", "John"),
            ("o'connor", "O'Connor"),
            ("d'angelo", "D'Angelo"),
            ("mary-jane", "Mary-Jane"),
            ("jr.", "Jr."),
            ("john123doe", "Johndoe"),
            ("mary@jane", "Maryjane"),
            ("josé", "José"),
            ("mc'donald", "Mc'Donald"),
            ("van der berg", "Van Der Berg"),
            ("", ""),
            ("a", "A"),
            ("anne-marie o'brien-smith", "Anne-Marie O'Brien-Smith")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - Phrase Filter Tests
    
    func testPhraseFilter() {
        let type = TType.phrase
        
        // Individual tests - phrase has no filtering
        XCTAssertEqual(type.filter("anything goes"), "anything goes")
        XCTAssertEqual(type.filter("123!@#$%^&*()"), "123!@#$%^&*()")
        XCTAssertEqual(type.filter(""), "")
        
        // Array test
        let testCases: [(String, String)] = [
            ("anything goes", "anything goes"),
            ("Numbers 123 and symbols !@#", "Numbers 123 and symbols !@#"),
            ("", ""),
            ("   spaces preserved   ", "   spaces preserved   "),
            ("new\nlines\npreserved", "new\nlines\npreserved"),
            ("unicode: 🎉 emoji", "unicode: 🎉 emoji")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - Credit Card Filter Tests
    
    func testCreditFilter() {
        let type = TType.credit
        
        // Individual tests
        XCTAssertEqual(type.filter("4111111111111111"), "4111111111111111")
        XCTAssertEqual(type.filter("4111 1111 1111 1111"), "4111111111111111")
        XCTAssertEqual(type.filter("4111-1111-1111-1111"), "4111111111111111")
        XCTAssertEqual(type.filter("41111111111111119999"), "4111111111111111")
        
        // Array test
        let testCases: [(String, String)] = [
            ("4111111111111111", "4111111111111111"),
            ("4111 1111 1111 1111", "4111111111111111"),
            ("4111-1111-1111-1111", "4111111111111111"),
            ("4111.1111.1111.1111", "4111111111111111"),
            ("4111abc1111def1111ghi1111", "4111111111111111"),
            ("41111111111111119999", "4111111111111111"),
            ("4111", "4111"),
            ("", ""),
            ("abcdef", ""),
            ("411 111 111 111 111 1", "4111111111111111"),
            ("4 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1", "4111111111111111"),
            ("5555 5555 5555 4444", "5555555555554444"),
            ("378282246310005", "378282246310005")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - Expiration Date Filter Tests
    
    func testExpDateFilter() {
        let type = TType.expDate
        
        // Individual tests
        XCTAssertEqual(type.filter("1225"), "1225")
        XCTAssertEqual(type.filter("12/25"), "1225")
        XCTAssertEqual(type.filter("12-25"), "1225")
        XCTAssertEqual(type.filter("122599"), "1225")
        
        // Array test
        let testCases: [(String, String)] = [
            ("1225", "1225"),
            ("12/25", "1225"),
            ("12-25", "1225"),
            ("12.25", "1225"),
            ("12 25", "1225"),
            ("12abc25", "1225"),
            ("122599", "1225"),
            ("1", "1"),
            ("12", "12"),
            ("123", "123"),
            ("", ""),
            ("abcd", ""),
            ("1a2b3c4d", "1234"),
            ("01/29", "0129")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - CVV Filter Tests
    
    func testCVVFilter() {
        let type = TType.cvv
        
        // Individual tests
        XCTAssertEqual(type.filter("123"), "123")
        XCTAssertEqual(type.filter("1a2b3c"), "123")
        XCTAssertEqual(type.filter("12345"), "123")
        XCTAssertEqual(type.filter(""), "")
        
        // Array test
        let testCases: [(String, String)] = [
            ("123", "123"),
            ("1a2b3c", "123"),
            ("12345", "123"),
            ("1", "1"),
            ("12", "12"),
            ("", ""),
            ("abc", ""),
            ("1!2@3#4$", "123"),
            ("   1 2 3   ", "123"),
            ("999", "999"),
            ("000", "000")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - Age Filter Tests
    
    func testAgeFilter() {
        let ageType2Digit = TType.age(min: 18, max: 99)
        let ageType3Digit = TType.age(min: 0, max: 120)
        
        // Individual tests for 2-digit
        XCTAssertEqual(ageType2Digit.filter("25"), "25")
        XCTAssertEqual(ageType2Digit.filter("999"), "99")
        XCTAssertEqual(ageType2Digit.filter("2a5b"), "25")
        
        // Individual tests for 3-digit
        XCTAssertEqual(ageType3Digit.filter("105"), "105")
        XCTAssertEqual(ageType3Digit.filter("1059"), "105")
        XCTAssertEqual(ageType3Digit.filter("1a0b5c"), "105")
        
        // Array test for 2-digit age
        let testCases2Digit: [(String, String)] = [
            ("25", "25"),
            ("999", "99"),
            ("2a5b", "25"),
            ("18", "18"),
            ("99", "99"),
            ("1", "1"),
            ("", ""),
            ("abc", ""),
            ("1!2@3#", "12"),
            ("100", "10")
        ]
        
        testFilterWithArray(ageType2Digit, testCases: testCases2Digit)
        
        // Array test for 3-digit age
        let testCases3Digit: [(String, String)] = [
            ("105", "105"),
            ("1059", "105"),
            ("1a0b5c", "105"),
            ("120", "120"),
            ("0", "0"),
            ("", ""),
            ("abc", ""),
            ("1!2@3#4$", "123"),
            ("1000", "100")
        ]
        
        testFilterWithArray(ageType3Digit, testCases: testCases3Digit)
    }
    
    // MARK: - Date Filter Tests
    
    func testDateFilter() {
        let type = TType.date
        
        // Individual tests
        XCTAssertEqual(type.filter("12252023"), "12252023")
        XCTAssertEqual(type.filter("12/25/2023"), "12252023")
        XCTAssertEqual(type.filter("12-25-2023"), "12252023")
        XCTAssertEqual(type.filter("1225202399"), "12252023")
        
        // Array test
        let testCases: [(String, String)] = [
            ("12252023", "12252023"),
            ("12/25/2023", "12252023"),
            ("12-25-2023", "12252023"),
            ("12.25.2023", "12252023"),
            ("12 25 2023", "12252023"),
            ("12abc25def2023", "12252023"),
            ("1225202399", "12252023"),
            ("1", "1"),
            ("12", "12"),
            ("1225", "1225"),
            ("", ""),
            ("abcd", ""),
            ("01/01/1999", "01011999"),
            ("12/31/2024", "12312024")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - Street Number Filter Tests
    
    func testStreetNumberFilter() {
        let type = TType.streetnumber
        
        // Individual tests
        XCTAssertEqual(type.filter("123"), "123")
        XCTAssertEqual(type.filter("1a2b3c"), "123")
        XCTAssertEqual(type.filter("1234567"), "123456")
        XCTAssertEqual(type.filter(""), "")
        
        // Array test
        let testCases: [(String, String)] = [
            ("123", "123"),
            ("1a2b3c", "123"),
            ("1234567", "123456"),
            ("", ""),
            ("abc", ""),
            ("12345", "12345"),
            ("123456", "123456"),
            ("1234567890", "123456"),
            ("1!2@3#", "123"),
            ("0", "0"),
            ("000123", "000123")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - Street Filter Tests
    
    func testStreetFilter() {
        let type = TType.street
        
        // Individual tests
        XCTAssertEqual(type.filter("main street"), "Main Street")
        XCTAssertEqual(type.filter("elm ave"), "Elm Ave")
        XCTAssertEqual(type.filter(""), "")
        
        // Array test
        let testCases: [(String, String)] = [
            ("main street", "Main Street"),
            ("elm ave", "Elm Ave"),
            ("", ""),
            ("123 main st", "123 Main St"),
            ("oak tree lane", "Oak Tree Lane"),
            ("first avenue", "First Avenue"),
            ("martin luther king jr blvd", "Martin Luther King Jr Blvd"),
            ("n. main street", "N. Main Street"),
            ("south elm ave.", "South Elm Ave.")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - ZIP Code Filter Tests
    
    func testZipFilter() {
        let type = TType.zip
        
        // Individual tests
        XCTAssertEqual(type.filter("12345"), "12345")
        XCTAssertEqual(type.filter("12345-6789"), "12345")
        XCTAssertEqual(type.filter("123456789"), "12345")
        XCTAssertEqual(type.filter(""), "")
        
        // Array test
        let testCases: [(String, String)] = [
            ("12345", "12345"),
            ("12345-6789", "12345"),
            ("123456789", "12345"),
            ("1a2b3c4d5e", "12345"),
            ("", ""),
            ("abc", ""),
            ("12345-1234", "12345"),
            ("90210", "90210"),
            ("1!2@3#4$5%6^", "12345"),
            ("123", "123"),
            ("1234", "1234")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - Phone Filter Tests
    
    func testPhoneFilter() {
        let type = TType.phone
        
        // Individual tests
        XCTAssertEqual(type.filter("5551234567"), "5551234567")
        XCTAssertEqual(type.filter("(555) 123-4567"), "5551234567")
        XCTAssertEqual(type.filter("555.123.4567"), "5551234567")
        XCTAssertEqual(type.filter("555123456789"), "5551234567")
        
        // Array test
        let testCases: [(String, String)] = [
            ("5551234567", "5551234567"),
            ("(555) 123-4567", "5551234567"),
            ("555.123.4567", "5551234567"),
            ("555-123-4567", "5551234567"),
            ("555 123 4567", "5551234567"),
            ("555abc123def4567", "5551234567"),
            ("555123456789", "5551234567"),
            ("", ""),
            ("555", "555"),
            ("5551234", "5551234"),
            ("800-555-1234", "8005551234"),
            (" 555 123 4567", "5551234567")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - SSN Filter Tests
    
    func testSSNFilter() {
        let type = TType.ssn
        
        // Individual tests
        XCTAssertEqual(type.filter("123456789"), "123456789")
        XCTAssertEqual(type.filter("123-45-6789"), "123456789")
        XCTAssertEqual(type.filter("1234567890"), "123456789")
        XCTAssertEqual(type.filter(""), "")
        
        // Array test
        let testCases: [(String, String)] = [
            ("123456789", "123456789"),
            ("123-45-6789", "123456789"),
            ("123 45 6789", "123456789"),
            ("123.45.6789", "123456789"),
            ("123abc456def789", "123456789"),
            ("1234567890", "123456789"),
            ("", ""),
            ("123", "123"),
            ("12345", "12345"),
            ("1!2@3#4$5%6^7&8*9(", "123456789"),
            ("000-00-0000", "000000000")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - City Filter Tests
    
    func testCityFilter() {
        let type = TType.city
        
        // Individual tests
        XCTAssertEqual(type.filter("new york"), "New York")
        XCTAssertEqual(type.filter("los angeles"), "Los Angeles")
        XCTAssertEqual(type.filter("  chicago"), "Chicago")
        XCTAssertEqual(type.filter("st. louis"), "St. Louis")
        
        // Array test
        let testCases: [(String, String)] = [
            ("new york", "New York"),
            ("los angeles", "Los Angeles"),
            ("  chicago", "Chicago"),
            ("st. louis", "St. Louis"),
            ("winston-salem", "Winston-Salem"),
            ("city123name", "Cityname"),
            ("", ""),
            ("portland", "Portland"),
            ("san francisco", "San Francisco"),
            ("st. petersburg", "St. Petersburg"),
            ("fort worth", "Fort Worth"),
            ("lake charles", "Lake Charles"),
            ("new orleans", "New Orleans")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - International City Filter Tests
    
    func testIntCityFilter() {
        let type = TType.intcity
        
        // Individual tests
        XCTAssertEqual(type.filter("london"), "London")
        XCTAssertEqual(type.filter("  paris"), "Paris")
        XCTAssertEqual(type.filter("new delhi"), "New Delhi")
        
        // Array test
        let testCases: [(String, String)] = [
            ("london", "London"),
            ("  paris", "Paris"),
            ("new delhi", "New Delhi"),
            ("são paulo", "São Paulo"),
            ("mexico city", "Mexico City"),
            ("rio de janeiro", "Rio De Janeiro"),
            ("buenos aires", "Buenos Aires"),
            ("hong kong", "Hong Kong"),
            ("tel aviv", "Tel Aviv"),
            ("québec city", "Québec City"),
            ("city123name", "Cityname"),
            ("", ""),
            ("montréal", "Montréal"),
            ("zürich", "Zürich")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - State Filter Tests
    
    func testStateFilter() {
        let type = TType.state
        
        // Individual tests
        XCTAssertEqual(type.filter("ca"), "CA")
        XCTAssertEqual(type.filter("ny"), "NY")
        XCTAssertEqual(type.filter("california"), "California")
        XCTAssertEqual(type.filter("new york"), "New York")
        
        // Array test
        let testCases: [(String, String)] = [
            ("ca", "CA"),
            ("ny", "NY"),
            ("tx", "TX"),
            ("california", "California"),
            ("new york", "New York"),
            ("  texas", "Texas"),
            ("calif123ornia", "California"),
            ("", ""),
            ("zz", "Zz"), // Invalid 2-letter, gets normal capitalization
            ("florida", "Florida"),
            ("n. carolina", "N. Carolina"),
            ("north dakota", "North Dakota")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
    
    // MARK: - State Code (ST) Filter Tests
    
    func testSTFilter() {
        let type = TType.st
        
        // Individual tests
        XCTAssertEqual(type.filter("ca"), "CA")
        XCTAssertEqual(type.filter("ny"), "NY")
        XCTAssertEqual(type.filter("california"), "CA")
        XCTAssertEqual(type.filter("c1a2"), "CA")
        
        // Array test
        let testCases: [(String, String)] = [
            ("ca", "CA"),
            ("ny", "NY"),
            ("CA", "CA"),
            ("california", "CA"),
            ("c1a2", "CA"),
            ("c@a", "CA"),
            ("", ""),
            ("c", "C"),
            ("tx", "TX"),
            ("florida", "FL"),
            ("123", ""),
            ("!@#", ""),
            ("ab", "AB"),
            ("xyz", "XY")
        ]
        
        testFilterWithArray(type, testCases: testCases)
    }
}
