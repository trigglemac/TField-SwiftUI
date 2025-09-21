//
//  TTypeValidateResultTests.swift
//  TFieldTests
//
//  Created by Timothy Riggle on 9/20/25.
//

import XCTest
@testable import TField

final class TTypeValidateResultTests: XCTestCase {
    
    // MARK: - Helper Function for Array Testing
    
    func testValidateResultWithArray(
        _ type: TType,
        testCases: [(input: String, expectedResult: Bool, expectedError: String?)]
    ) {
        for testCase in testCases {
            var errorMessage = ""
            let result = type.validateResult(testCase.input, &errorMessage)
            
            XCTAssertEqual(
                result,
                testCase.expectedResult,
                "validateResult failed for \(type) with input '\(testCase.input)': expected \(testCase.expectedResult), got \(result)"
            )
            
            if let expectedError = testCase.expectedError {
                XCTAssertEqual(
                    errorMessage,
                    expectedError,
                    "Error message mismatch for \(type) with input '\(testCase.input)': expected '\(expectedError)', got '\(errorMessage)'"
                )
            }
        }
    }
    
    // MARK: - Data Type Tests
    
    func testDataValidateResult() {
        let type = TType.data
        var errorMessage = ""
        
        // Individual tests - data always passes result validation
        XCTAssertTrue(type.validateResult("anything", &errorMessage))
        XCTAssertTrue(type.validateResult("", &errorMessage))
        XCTAssertTrue(type.validateResult("123!@#", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("anything", true, nil),
            ("123!@#", true, nil),
            ("spaces work", true, nil),
            ("unicode 🎉", true, nil)
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    func testDataLengthValidateResult() {
        let type = TType.dataLength(length: 5)
        var errorMessage = ""
        
        // Individual tests
        XCTAssertFalse(type.validateResult("hi", &errorMessage))
        XCTAssertEqual(errorMessage, "Not Long Enough")
        
        errorMessage = ""
        XCTAssertTrue(type.validateResult("hello", &errorMessage))
        XCTAssertTrue(type.validateResult("helloworld", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", false, "Not Long Enough"),
            ("h", false, "Not Long Enough"),
            ("hi", false, "Not Long Enough"),
            ("hello", true, nil),
            ("helloworld", true, nil),
            ("12345", true, nil),
            ("exact", true, nil)
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - Name Validation Tests
    
    func testNameValidateResult() {
        let type = TType.name
        var errorMessage = ""
        
        // Individual tests - name always passes result validation
        XCTAssertTrue(type.validateResult("John Doe", &errorMessage))
        XCTAssertTrue(type.validateResult("", &errorMessage))
        XCTAssertTrue(type.validateResult("O'Connor", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("John Doe", true, nil),
            ("O'Connor", true, nil),
            ("Mary-Jane", true, nil),
            ("José", true, nil),
            ("a", true, nil)
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - Phrase Validation Tests
    
    func testPhraseValidateResult() {
        let type = TType.phrase
        var errorMessage = ""
        
        // Individual tests - phrase always passes result validation
        XCTAssertTrue(type.validateResult("anything goes", &errorMessage))
        XCTAssertTrue(type.validateResult("", &errorMessage))
        XCTAssertTrue(type.validateResult("123!@#", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("anything goes", true, nil),
            ("123!@#$%^&*()", true, nil),
            ("unicode: 🎉", true, nil),
            ("newlines\nallowed", true, nil)
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - Credit Card Validation Tests
    
    func testCreditValidateResult() {
        let type = TType.credit
        var errorMessage = ""
        
        // Individual tests
        XCTAssertFalse(type.validateResult("4111", &errorMessage))
        XCTAssertEqual(errorMessage, "Card Number Incomplete")
        
        errorMessage = ""
        XCTAssertTrue(type.validateResult("4111 1111 1111 1111", &errorMessage))
        XCTAssertTrue(type.validateResult("4111 1111 1111 1111", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", false, "Card Number Incomplete"),
            ("4111", false, "Card Number Incomplete"),
            ("4123 4567 8901 234", false, "Card Number Incomplete"),
            ("4123 4567 8901 2345", true, nil),
            ("4111 1111 1111 1111", true, nil),
            ("5555 5555 5555 4444", true, nil),
            ("3782 8224 6310 0050", true, nil), // 15-digit Amex
            ("3056 9309 0259 043", false, "Card Number Incomplete"), // 14-digit incomplete
            ("6011 1111 1111 1117", true, nil) // Discover
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - Expiration Date Validation Tests
    
    func testExpDateValidateResult() {
        let type = TType.expDate
        var errorMessage = ""
        
        // Individual tests
        XCTAssertFalse(type.validateResult("12/2", &errorMessage))
        XCTAssertEqual(errorMessage, "Incomplete Date")
        
        errorMessage = ""
        XCTAssertFalse(type.validateResult("13/25", &errorMessage))
        XCTAssertEqual(errorMessage, "Invalid Month")
        
        errorMessage = ""
        XCTAssertTrue(type.validateResult("12/25", &errorMessage))
        
        // Array test - Note: These depend on current year validation logic
        let testCases: [(String, Bool, String?)] = [
            ("", false, "Incomplete Date"),
            ("1", false, "Incomplete Date"),
            ("12", false, "Incomplete Date"),
            ("12/2", false, "Incomplete Date"),
            ("12/25", true, nil), // Assuming 2025 is in valid range
            ("01/25", true, nil),
            ("13/25", false, "Invalid Month"),
            ("00/25", false, "Invalid Month"),
            ("12/99", false, "Year out of range"), // Assuming 1999 is out of range
            ("06/30", true, nil) // Assuming 2030 is in valid range
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - CVV Validation Tests
    
    func testCVVValidateResult() {
        let type = TType.cvv
        var errorMessage = ""
        
        // Individual tests
        XCTAssertFalse(type.validateResult("12", &errorMessage))
        XCTAssertEqual(errorMessage, "CVV Incomplete")
        
        errorMessage = ""
        XCTAssertTrue(type.validateResult("123", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", false, "CVV Incomplete"),
            ("1", false, "CVV Incomplete"),
            ("12", false, "CVV Incomplete"),
            ("123", true, nil),
            ("000", true, nil),
            ("999", true, nil),
            ("1234", true, nil) // Should pass if length >= 3
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - Age Validation Tests
    
    func testAgeValidateResult() {
        let ageType = TType.age(min: 18, max: 65)
        var errorMessage = ""
        
        // Individual tests
        XCTAssertTrue(ageType.validateResult("25", &errorMessage))
        XCTAssertFalse(ageType.validateResult("15", &errorMessage))
        XCTAssertTrue(errorMessage.contains("smaller"))
        
        errorMessage = ""
        XCTAssertFalse(ageType.validateResult("75", &errorMessage))
        XCTAssertTrue(errorMessage.contains("larger"))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            //("", true, nil), // Empty is valid for result validation
            ("17", false, "Value is smaller than 18"),
            ("18", true, nil),
            ("25", true, nil),
            ("65", true, nil),
            ("66", false, "Value is larger than 65"),
            ("99", false, "Value is larger than 65")
        ]
        
        testValidateResultWithArray(ageType, testCases: testCases)
    }
    
    func testAgeValidateResultThreeDigit() {
        let ageType = TType.age(min: 65, max: 120)
        
        // Array test for 3-digit range
        let testCases: [(String, Bool, String?)] = [
            //("", true, nil),
            ("0", false, "Value is smaller than 65"),
            ("12", false, "Value is smaller than 65"),
            ("64", false, "Value is smaller than 65"),
            ("65", true, nil),
            ("99", true, nil),
            ("120", true, nil),
            ("121", false, "Value is larger than 120"),
            ("150", false, "Value is larger than 120")
        ]
        
        testValidateResultWithArray(ageType, testCases: testCases)
    }
    
    // MARK: - Date Validation Tests
    
    func testDateValidateResult() {
        let type = TType.date
        var errorMessage = ""
        
        // Individual tests
        XCTAssertTrue(type.validateResult("12/25/2023", &errorMessage))
        XCTAssertFalse(type.validateResult("13/25/2023", &errorMessage))
        XCTAssertEqual(errorMessage, "Invalid Date")
        
        errorMessage = ""
        XCTAssertFalse(type.validateResult("12/32/2023", &errorMessage))
        XCTAssertEqual(errorMessage, "Invalid Date")
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            //("", true, nil), // Empty is valid
            ("12/25/2023", true, nil),
            ("01/01/2000", true, nil),
            ("02/29/2024", true, nil), // Leap year
            ("02/29/2023", false, "Invalid Date"), // Not a leap year
            ("13/01/2023", false, "Invalid Date"),
            ("12/32/2023", false, "Invalid Date"),
            ("00/01/2023", false, "Invalid Date"),
            ("12/00/2023", false, "Invalid Date"),
            ("06/15/1999", true, nil),
            ("incomplete", false, "Invalid Date")
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - Street Number Validation Tests
    
    func testStreetNumberValidateResult() {
        let type = TType.streetnumber
        var errorMessage = ""
        
        // Individual tests
        XCTAssertFalse(type.validateResult("0", &errorMessage))
        XCTAssertEqual(errorMessage, "Street Number cannot be zero")
        
        errorMessage = ""
        XCTAssertTrue(type.validateResult("123", &errorMessage))
        XCTAssertTrue(type.validateResult("1", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil), // Empty is valid
            ("0", false, "Street Number cannot be zero"),
            ("1", true, nil),
            ("123", true, nil),
            ("99999", true, nil),
            ("12345", true, nil)
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - Street Validation Tests
    
    func testStreetValidateResult() {
        let type = TType.street
        var errorMessage = ""
        
        // Individual tests - street always passes result validation
        XCTAssertTrue(type.validateResult("Main Street", &errorMessage))
        XCTAssertTrue(type.validateResult("", &errorMessage))
        XCTAssertTrue(type.validateResult("123 Oak Ave", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("Main Street", true, nil),
            ("Oak Ave", true, nil),
            ("123 Oak Ave", true, nil),
            ("First Avenue", true, nil),
            ("N. Main St.", true, nil)
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - ZIP Code Validation Tests
    
    func testZipValidateResult() {
        let type = TType.zip
        var errorMessage = ""
        
        // Individual tests
        XCTAssertFalse(type.validateResult("123", &errorMessage))
        XCTAssertEqual(errorMessage, "Incomplete Zip Code")
        
        errorMessage = ""
        XCTAssertTrue(type.validateResult("12345", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", false, "Incomplete Zip Code"),
            ("1", false, "Incomplete Zip Code"),
            ("123", false, "Incomplete Zip Code"),
            ("1234", false, "Incomplete Zip Code"),
            ("12345", true, nil),
            ("90210", true, nil),
            ("00000", true, nil),
            ("99999", true, nil)
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - Phone Validation Tests
    
    func testPhoneValidateResult() {
        let type = TType.phone
        var errorMessage = ""
        
        // Individual tests
        XCTAssertFalse(type.validateResult("555123456", &errorMessage))
        XCTAssertEqual(errorMessage, "Incomplete Phone #")
        
        errorMessage = ""
        XCTAssertTrue(type.validateResult("(555) 123-4567", &errorMessage))
        XCTAssertTrue(type.validateResult("(555) 123-9999", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", false, "Incomplete Phone #"),
            ("(555)", false, "Incomplete Phone #"),
            ("(555) 123-456", false, "Incomplete Phone #"),
            ("(555) 123-4567", true, nil),
            ("(800) 555-1212", true, nil)
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - SSN Validation Tests
    
    func testSSNValidateResult() {
        let type = TType.ssn
        var errorMessage = ""
        
        // Individual tests
        XCTAssertFalse(type.validateResult("12345678", &errorMessage))
        XCTAssertEqual(errorMessage, "Incomplete SSN")
        
        errorMessage = ""
        XCTAssertTrue(type.validateResult("123-45-6789", &errorMessage))
        XCTAssertTrue(type.validateResult("987-65-4321", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", false, "Incomplete SSN"),
            ("123", false, "Incomplete SSN"),
            ("123-45-678", false, "Incomplete SSN"),
            ("123-45-6789", true, nil),
            ("000-00-0000", true, nil),
            ("999-99-9999", true, nil)
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - City Validation Tests
    
    func testCityValidateResult() {
        let type = TType.city
        var errorMessage = ""
        
        // Individual tests - city always passes result validation
        XCTAssertTrue(type.validateResult("New York", &errorMessage))
        XCTAssertTrue(type.validateResult("", &errorMessage))
        XCTAssertTrue(type.validateResult("Chicago", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("New York", true, nil),
            ("Los Angeles", true, nil),
            ("St. Louis", true, nil),
            ("Winston-Salem", true, nil),
            ("a", true, nil)
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - International City Validation Tests
    
    func testIntCityValidateResult() {
        let type = TType.intcity
        var errorMessage = ""
        
        // Individual tests - intcity always passes result validation
        XCTAssertTrue(type.validateResult("London", &errorMessage))
        XCTAssertTrue(type.validateResult("", &errorMessage))
        XCTAssertTrue(type.validateResult("São Paulo", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("London", true, nil),
            ("São Paulo", true, nil),
            ("Mexico City", true, nil),
            ("Tel Aviv", true, nil),
            ("Québec", true, nil)
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - State Validation Tests
    
    func testStateValidateResult() {
        let type = TType.state
        var errorMessage = ""
        
        // Individual tests
        XCTAssertTrue(type.validateResult("CA", &errorMessage))
        XCTAssertTrue(type.validateResult("California", &errorMessage))
        XCTAssertTrue(type.validateResult("New York", &errorMessage))
        
        errorMessage = ""
        XCTAssertFalse(type.validateResult("XX", &errorMessage))
        XCTAssertEqual(errorMessage, "Invalid State Name")
        
        errorMessage = ""
        XCTAssertFalse(type.validateResult("X", &errorMessage))
        XCTAssertEqual(errorMessage, "Invalid State Name")
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            //("", true, nil), // Empty is valid
            ("CA", true, nil),
            ("NY", true, nil),
            ("TX", true, nil),
            ("California", true, nil),
            ("New York", true, nil),
            ("Texas", true, nil),
            ("CALIF", true, nil), // Old style abbreviation
            ("N.Y.", true, nil),
            ("N. Carolina", true, nil),
            ("S. Dakota", true, nil),
            ("XX", false, "Invalid State Name"),
            ("ZZ", false, "Invalid State Name"),
            ("X", false, "Invalid State Name"),
            ("Fakeland", false, "Invalid State Name"),
            ("Not A State", false, "Invalid State Name")
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
    
    // MARK: - State Code (ST) Validation Tests
    
    func testSTValidateResult() {
        let type = TType.st
        var errorMessage = ""
        
        // Individual tests
        XCTAssertTrue(type.validateResult("", &errorMessage)) // Empty is valid
        XCTAssertTrue(type.validateResult("CA", &errorMessage))
        XCTAssertTrue(type.validateResult("NY", &errorMessage))
        
        errorMessage = ""
        XCTAssertFalse(type.validateResult("XX", &errorMessage))
        XCTAssertEqual(errorMessage, "Invalid State")
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil), // Empty is valid
            ("CA", true, nil),
            ("NY", true, nil),
            ("TX", true, nil),
            ("FL", true, nil),
            ("DC", true, nil), // District of Columbia
            ("PR", true, nil), // Puerto Rico
            ("XX", false, "Invalid State"),
            ("ZZ", false, "Invalid State"),
            ("AB", false, "Invalid State"),
            ("QQ", false, "Invalid State")
        ]
        
        testValidateResultWithArray(type, testCases: testCases)
    }
}
