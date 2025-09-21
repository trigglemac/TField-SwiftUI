//
//  TTypeValidateLiveTests.swift
//  TFieldTests
//
//  Created by Timothy Riggle on 9/20/25.
//

import XCTest
@testable import TField

final class TTypeValidateLiveTests: XCTestCase {
    
    // MARK: - Helper Function for Array Testing
    
    func testValidateLiveWithArray(
        _ type: TType,
        testCases: [(input: String, expectedResult: Bool, expectedError: String?)]
    ) {
        for testCase in testCases {
            var errorMessage = ""
            let result = type.validateLive(testCase.input, &errorMessage)
            
            XCTAssertEqual(
                result,
                testCase.expectedResult,
                "validateLive failed for \(type) with input '\(testCase.input)': expected \(testCase.expectedResult), got \(result)"
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
    
    func testDataValidateLive() {
        let type = TType.data
        var errorMessage = ""
        
        // Individual tests
        XCTAssertFalse(type.validateLive("hello world", &errorMessage))
        XCTAssertEqual(errorMessage, "Spaces not allowed")
        
        errorMessage = ""
        XCTAssertTrue(type.validateLive("helloworld", &errorMessage))
        XCTAssertTrue(type.validateLive("", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("hello world", false, "Spaces not allowed"),
            ("test data", false, "Spaces not allowed"),
            ("  spaces", false, "Spaces not allowed"),
            ("helloworld", true, nil),
            ("test123", true, nil),
            ("", true, nil),
            ("single", true, nil),
            ("a", true, nil),
            ("123456789", true, nil)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    func testDataLengthValidateLive() {
        let type = TType.dataLength(length: 5)
        var errorMessage = ""
        
        // Individual tests
        XCTAssertFalse(type.validateLive("hello world", &errorMessage))
        XCTAssertEqual(errorMessage, "Spaces not allowed")
        
        errorMessage = ""
        XCTAssertTrue(type.validateLive("hello", &errorMessage))
        XCTAssertTrue(type.validateLive("hi", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("hello world", false, "Spaces not allowed"),
            ("test data", false, "Spaces not allowed"),
            ("hello", true, nil),
            ("hi", true, nil),
            ("", true, nil),
            ("12345", true, nil),
            ("toolong", true, nil), // Filter handles length, live validation passes
            ("a", true, nil)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - Name Validation Tests
    
    func testNameValidateLive() {
        let type = TType.name
        var errorMessage = ""
        
        // Individual tests - name validation should always pass (filter handles everything)
        XCTAssertTrue(type.validateLive("John Doe", &errorMessage))
        XCTAssertTrue(type.validateLive("O'Connor", &errorMessage))
        XCTAssertTrue(type.validateLive("Mary-Jane", &errorMessage))
        XCTAssertTrue(type.validateLive("", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("John Doe", true, nil),
            ("O'Connor", true, nil),
            ("Mary-Jane", true, nil),
            ("", true, nil),
            ("John123", true, nil), // Filter will clean this
            ("José", true, nil),
            ("van der Berg", true, nil),
            ("a", true, nil)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - Phrase Validation Tests
    
    func testPhraseValidateLive() {
        let type = TType.phrase
        var errorMessage = ""
        
        // Individual tests - phrase validation should always pass
        XCTAssertTrue(type.validateLive("anything goes", &errorMessage))
        XCTAssertTrue(type.validateLive("123!@#", &errorMessage))
        XCTAssertTrue(type.validateLive("", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("anything goes", true, nil),
            ("123!@#$%^&*()", true, nil),
            ("", true, nil),
            ("unicode: 🎉", true, nil),
            ("newlines\nallowed", true, nil),
            ("tabs\tallowed", true, nil)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - Credit Card Validation Tests
    
    func testCreditValidateLive() {
        let type = TType.credit
        var errorMessage = ""
        
        // Individual tests
        XCTAssertTrue(type.validateLive("4", &errorMessage)) // Visa
        XCTAssertTrue(type.validateLive("5", &errorMessage)) // Mastercard
        XCTAssertTrue(type.validateLive("3", &errorMessage)) // Amex
        XCTAssertTrue(type.validateLive("6", &errorMessage)) // Discover
        
        errorMessage = ""
        XCTAssertFalse(type.validateLive("7", &errorMessage))
        XCTAssertEqual(errorMessage, "Invalid credit type")
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("4", true, nil), // Visa
            ("5", true, nil), // Mastercard
            ("3", true, nil), // Amex
            ("6", true, nil), // Discover
            ("7", false, "Invalid credit type"),
            ("1", false, "Invalid credit type"),
            ("2", false, "Invalid credit type"),
            ("8", false, "Invalid credit type"),
            ("9", false, "Invalid credit type"),
            ("0", false, "Invalid credit type"),
            ("", true, nil), // Empty is valid
            ("41111", true, nil), // Valid visa start
            ("5555", true, nil)  // Valid mastercard start
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - Expiration Date Validation Tests
    
    func testExpDateValidateLive() {
        let type = TType.expDate
        var errorMessage = ""
        
        // Individual tests
        XCTAssertTrue(type.validateLive("", &errorMessage))
        XCTAssertTrue(type.validateLive("0", &errorMessage))
        XCTAssertTrue(type.validateLive("1", &errorMessage))
        XCTAssertFalse(type.validateLive("2", &errorMessage))
        
        errorMessage = ""
        XCTAssertTrue(type.validateLive("12", &errorMessage))
        XCTAssertFalse(type.validateLive("13", &errorMessage))
        XCTAssertEqual(errorMessage, "Invalid Month")
        
        // Array test - Note: These tests depend on current year logic
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("0", true, nil),
            ("1", true, nil),
            ("2", false, "Invalid Month"),
            ("9", false, "Invalid Month"),
            ("01", true, nil),
            ("12", true, nil),
            ("13", false, "Invalid Month"),
            ("00", false, "Invalid Month"),
            ("122", true, nil), // Valid month + year start
            ("1225", true, nil) // Valid full date (assuming 2025 is in range)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - CVV Validation Tests
    
    func testCVVValidateLive() {
        let type = TType.cvv
        var errorMessage = ""
        
        // Individual tests - CVV live validation always passes
        XCTAssertTrue(type.validateLive("1", &errorMessage))
        XCTAssertTrue(type.validateLive("12", &errorMessage))
        XCTAssertTrue(type.validateLive("123", &errorMessage))
        XCTAssertTrue(type.validateLive("", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("1", true, nil),
            ("12", true, nil),
            ("123", true, nil),
            ("000", true, nil),
            ("999", true, nil)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - Age Validation Tests
    
    func testAgeValidateLive() {
        let ageType = TType.age(min: 18, max: 65)
        let agebType = TType.age(min: 65, max: 150)
        var errorMessage = ""
        
        // Individual tests
        XCTAssertTrue(ageType.validateLive("", &errorMessage))
        
        // Test single digits that could lead to valid ages
        XCTAssertTrue(ageType.validateLive("1", &errorMessage)) // Could be 18, 19
        XCTAssertTrue(ageType.validateLive("2", &errorMessage)) // Could be 20-29
        XCTAssertTrue(ageType.validateLive("6", &errorMessage)) // Could be 60-65
        
        // Test invalid single digits
        errorMessage = ""
        XCTAssertFalse(ageType.validateLive("0", &errorMessage))
        XCTAssertTrue(errorMessage.contains("at least"))
        
        errorMessage = ""
        XCTAssertFalse(ageType.validateLive("7", &errorMessage))
        XCTAssertTrue(errorMessage.contains("exceed"))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("1", true, nil), // Could be 18, 19
            ("2", true, nil), // Could be 20-29
            ("3", true, nil), // Could be 30-39
            ("4", true, nil), // Could be 40-49
            ("5", true, nil), // Could be 50-59
            ("6", true, nil), // Could be 60-65
            ("0", false, "Age must be at least 18"),
            ("7", false, "Age cannot exceed 65"),
            ("8", false, "Age cannot exceed 65"),
            ("9", false, "Age cannot exceed 65"),
            ("18", true, nil),
            ("25", true, nil),
            ("65", true, nil),
            ("15", false, "Age must be at least 18"),
            ("75", false, "Age cannot exceed 65")
        ]
        let testbCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("1", true, nil), // Could be 100-150
            ("2", false, "Age cannot exceed 150"),
            ("5", false, "Age cannot exceed 150"),
            ("6", true, nil), // Could be 65-69
            ("0", true, nil), // Could be 065+
            ("7", true, nil), // could be 70-79
            ("65", true, nil),
            ("64", false, "Age must be at least 65"),
            ("100", true, nil),
            ("15", true, nil),  // could be 150
            ("16", false, "Age must be at least 65"),
            ("151", false, "Age cannot exceed 150"),
            ("150", true, nil)
        ]
        
        testValidateLiveWithArray(ageType, testCases: testCases)
        testValidateLiveWithArray(agebType, testCases: testbCases)

        
    }
    
    func testAgeValidateLiveThreeDigit() {
        let ageType = TType.age(min: 0, max: 120)
        var errorMessage = ""
        
        // Individual tests for 3-digit age range
        XCTAssertTrue(ageType.validateLive("", &errorMessage))
        XCTAssertTrue(ageType.validateLive("0", &errorMessage)) // Valid for 0-120 range
        XCTAssertTrue(ageType.validateLive("1", &errorMessage))
        XCTAssertTrue(ageType.validateLive("105", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("0", true, nil), // Valid for wider range
            ("1", true, nil),
            ("9", true, nil),
            ("12", true, nil),
            ("105", true, nil),
            ("120", true, nil),
            ("121", false, "Age cannot exceed 120")
        ]
        
        testValidateLiveWithArray(ageType, testCases: testCases)
    }
    
    // MARK: - Date Validation Tests
    
    func testDateValidateLive() {
        let type = TType.date
        var errorMessage = ""
        
        // Individual tests
        XCTAssertTrue(type.validateLive("", &errorMessage))
        XCTAssertTrue(type.validateLive("1", &errorMessage))
        XCTAssertFalse(type.validateLive("2", &errorMessage))
        
        errorMessage = ""
        XCTAssertTrue(type.validateLive("12", &errorMessage))
        XCTAssertFalse(type.validateLive("13", &errorMessage))
        XCTAssertEqual(errorMessage, "Invalid Month")
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("1", true, nil),
            ("2", false, "Invalid Month"),
            ("0", true, nil),
            ("01", true, nil),
            ("12", true, nil),
            ("13", false, "Invalid Month"),
            ("123", true, nil), // Valid month + day start
            ("124", false, "Invalid Day"),
            ("1225", true, nil), // Valid month + day
            ("1232", false, "Invalid Day"),
            ("12252023", true, nil) // Valid full date
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - Street Number Validation Tests
    
    func testStreetNumberValidateLive() {
        let type = TType.streetnumber
        var errorMessage = ""
        
        // Individual tests - street number live validation always passes
        XCTAssertTrue(type.validateLive("123", &errorMessage))
        XCTAssertTrue(type.validateLive("0", &errorMessage))
        XCTAssertTrue(type.validateLive("", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("1", true, nil),
            ("123", true, nil),
            ("0", true, nil), // Live validation passes, result validation would fail
            ("12345", true, nil),
            ("999999", true, nil)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - Street Validation Tests
    
    func testStreetValidateLive() {
        let type = TType.street
        var errorMessage = ""
        
        // Individual tests - street live validation always passes
        XCTAssertTrue(type.validateLive("Main Street", &errorMessage))
        XCTAssertTrue(type.validateLive("", &errorMessage))
        XCTAssertTrue(type.validateLive("123 Oak Ave", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("Main Street", true, nil),
            ("Oak Ave", true, nil),
            ("123 Oak Ave", true, nil),
            ("First Avenue", true, nil),
            ("N. Main St.", true, nil)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - ZIP Code Validation Tests
    
    func testZipValidateLive() {
        let type = TType.zip
        var errorMessage = ""
        
        // Individual tests - zip live validation always passes
        XCTAssertTrue(type.validateLive("12345", &errorMessage))
        XCTAssertTrue(type.validateLive("123", &errorMessage))
        XCTAssertTrue(type.validateLive("", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("1", true, nil),
            ("123", true, nil),
            ("12345", true, nil),
            ("00000", true, nil),
            ("99999", true, nil)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - Phone Validation Tests
    
    func testPhoneValidateLive() {
        let type = TType.phone
        var errorMessage = ""
        
        // Individual tests - phone live validation always passes
        XCTAssertTrue(type.validateLive("5551234567", &errorMessage))
        XCTAssertTrue(type.validateLive("555", &errorMessage))
        XCTAssertTrue(type.validateLive("", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("5", true, nil),
            ("555", true, nil),
            ("5551234567", true, nil),
            ("1234567890", true, nil),
            ("0000000000", true, nil)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - SSN Validation Tests
    
    func testSSNValidateLive() {
        let type = TType.ssn
        var errorMessage = ""
        
        // Individual tests - SSN live validation always passes
        XCTAssertTrue(type.validateLive("123456789", &errorMessage))
        XCTAssertTrue(type.validateLive("123", &errorMessage))
        XCTAssertTrue(type.validateLive("", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("1", true, nil),
            ("123", true, nil),
            ("123456789", true, nil),
            ("000000000", true, nil),
            ("999999999", true, nil)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - City Validation Tests
    
    func testCityValidateLive() {
        let type = TType.city
        var errorMessage = ""
        
        // Individual tests - city live validation always passes
        XCTAssertTrue(type.validateLive("New York", &errorMessage))
        XCTAssertTrue(type.validateLive("Chicago", &errorMessage))
        XCTAssertTrue(type.validateLive("", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("New York", true, nil),
            ("Los Angeles", true, nil),
            ("St. Louis", true, nil),
            ("Winston-Salem", true, nil),
            ("a", true, nil)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - International City Validation Tests
    
    func testIntCityValidateLive() {
        let type = TType.intcity
        var errorMessage = ""
        
        // Individual tests - intcity live validation always passes
        XCTAssertTrue(type.validateLive("London", &errorMessage))
        XCTAssertTrue(type.validateLive("São Paulo", &errorMessage))
        XCTAssertTrue(type.validateLive("", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("London", true, nil),
            ("São Paulo", true, nil),
            ("Mexico City", true, nil),
            ("Tel Aviv", true, nil),
            ("Québec", true, nil)
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - State Validation Tests
    
    func testStateValidateLive() {
        let type = TType.state
        var errorMessage = ""
        
        // Individual tests - state live validation always passes
        XCTAssertTrue(type.validateLive("California", &errorMessage))
        XCTAssertTrue(type.validateLive("CA", &errorMessage))
        XCTAssertTrue(type.validateLive("", &errorMessage))
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("CA", true, nil),
            ("California", true, nil),
            ("New York", true, nil),
            ("XX", true, nil), // Live validation passes, result validation would fail
            ("Texas", true, nil),
            ("Invalid State", true, nil) // Live validation passes
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
    
    // MARK: - State Code (ST) Validation Tests
    
    func testSTValidateLive() {
        let type = TType.st
        var errorMessage = ""
        
        // Individual tests
        XCTAssertTrue(type.validateLive("", &errorMessage))
        
        // Valid first letters
        XCTAssertTrue(type.validateLive("C", &errorMessage)) // CA, CO, CT
        XCTAssertTrue(type.validateLive("N", &errorMessage)) // NY, NV, etc.
        
        // Invalid first letters
        errorMessage = ""
        XCTAssertFalse(type.validateLive("Z", &errorMessage))
        XCTAssertEqual(errorMessage, "Invalid State")
        
        // Valid two-letter codes
        errorMessage = ""
        XCTAssertTrue(type.validateLive("CA", &errorMessage))
        XCTAssertTrue(type.validateLive("NY", &errorMessage))
        
        // Invalid two-letter codes
        errorMessage = ""
        XCTAssertFalse(type.validateLive("XX", &errorMessage))
        XCTAssertEqual(errorMessage, "Invalid State")
        
        // Array test
        let testCases: [(String, Bool, String?)] = [
            ("", true, nil),
            ("C", true, nil), // CA, CO, CT exist
            ("N", true, nil), // NY, NV, etc. exist
            ("A", true, nil), // AL, AK, AZ, AR exist
            ("T", true, nil), // TX, TN exist
            ("Z", false, "Invalid State"), // No states start with Z
            ("Q", false, "Invalid State"), // No states start with Q
            ("X", false, "Invalid State"), // No states start with X
            ("CA", true, nil),
            ("NY", true, nil),
            ("TX", true, nil),
            ("XX", false, "Invalid State"),
            ("ZZ", false, "Invalid State"),
            ("AB", false, "Invalid State")
        ]
        
        testValidateLiveWithArray(type, testCases: testCases)
    }
}
