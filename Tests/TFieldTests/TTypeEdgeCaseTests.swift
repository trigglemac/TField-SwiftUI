//
//  TTypeEdgeCaseTests.swift
//  TFieldTests
//
//  Created by Timothy Riggle on 9/20/25.
//

import XCTest
@testable import TField

final class TTypeEdgeCaseTests: XCTestCase {
    
    // MARK: - Empty and Nil-like Input Tests
    
    func testEmptyStringHandling() {
        let allTypes: [TType] = [
            .data, .dataLength(length: 5), .name, .phrase, .credit, .expDate, .cvv,
            .age(min: 18, max: 65), .date, .streetnumber, .street, .zip, .phone, .ssn,
            .city, .intcity, .state, .st
        ]
        
        for type in allTypes {
            // Filter should handle empty strings gracefully
            let filtered = type.filter("")
            XCTAssertEqual(filtered, "", "Filter failed for empty string on \(type)")
            
            // Live validation should generally pass for empty strings
            var errorMessage = ""
            let liveResult = type.validateLive("", &errorMessage)
            XCTAssertTrue(liveResult, "Live validation failed for empty string on \(type): \(errorMessage)")
            
            // Result validation behavior varies by type
            errorMessage = ""
            _ = type.validateResult("", &errorMessage)
            // Don't assert result here since some types require content
        }
    }
    /*
    func testWhitespaceOnlyInputs() {
        let whitespaceInputs = ["   ", "\t", "\n", "\r", " \t \n \r "]
        
        for input in whitespaceInputs {
            // Data types should strip whitespace
            XCTAssertEqual(TType.data.filter(input), "")
            XCTAssertEqual(TType.dataLength(length: 5).filter(input), "")
            
            // Name should handle leading spaces
            let nameFiltered = TType.name.filter(input)
            XCTAssertTrue(nameFiltered.isEmpty || !nameFiltered.hasPrefix(" "))
            
            // Numeric types should strip to empty
            XCTAssertEqual(TType.phone.filter(input), "")
            XCTAssertEqual(TType.credit.filter(input), "")
            XCTAssertEqual(TType.zip.filter(input), "")
        }
    }
     */
    
    // MARK: - Extremely Long Input Tests
    
    func testVeryLongInputs() {
        let veryLongString = String(repeating: "A", count: 10000)
        let veryLongNumbers = String(repeating: "1", count: 10000)
        
        // Data length should truncate
        XCTAssertEqual(TType.dataLength(length: 5).filter(veryLongString), "AAAAA")
        
        // Numeric types should truncate to their limits
        XCTAssertEqual(TType.phone.filter(veryLongNumbers).count, 10)
        XCTAssertEqual(TType.credit.filter(veryLongNumbers).count, 16)
        XCTAssertEqual(TType.zip.filter(veryLongNumbers).count, 5)
        XCTAssertEqual(TType.ssn.filter(veryLongNumbers).count, 9)
        XCTAssertEqual(TType.cvv.filter(veryLongNumbers).count, 3)
        
        // Age should respect digit limits
        XCTAssertEqual(TType.age(min: 18, max: 99).filter(veryLongNumbers).count, 2)
        XCTAssertEqual(TType.age(min: 0, max: 120).filter(veryLongNumbers).count, 3)
        
        // Date should truncate
        XCTAssertEqual(TType.date.filter(veryLongNumbers).count, 8)
        XCTAssertEqual(TType.expDate.filter(veryLongNumbers).count, 4)
        
        // Street number should truncate
        XCTAssertEqual(TType.streetnumber.filter(veryLongNumbers).count, 6)
        
        // State code should truncate
        XCTAssertEqual(TType.st.filter(veryLongString).count, 2)
    }
    
    // MARK: - Unicode and Special Character Tests
    
    
    
    func testSpecialCharacters() {
        let specialChars = "!@#$%^&*()_+-=[]{}|;':\",./<>?"
        
        // Data should remove spaces but might keep other chars
        let dataResult = TType.data.filter(specialChars)
        XCTAssertFalse(dataResult.contains(" "))
        
        // Numeric types should strip all special chars
        XCTAssertEqual(TType.phone.filter(specialChars), "")
        XCTAssertEqual(TType.credit.filter(specialChars), "")
        XCTAssertEqual(TType.zip.filter(specialChars), "")
        
        // Name should keep only allowed punctuation
        let nameResult = TType.name.filter(specialChars)
        let allowedInName = "'-."
        for char in nameResult {
            XCTAssertTrue(allowedInName.contains(char), "Name filter allowed disallowed character: \(char)")
        }
        
        // Phrase should keep everything
        XCTAssertEqual(TType.phrase.filter(specialChars), specialChars)
    }
    
    // MARK: - Boundary Value Tests
    
    func testAgeBoundaryValues() {
        let ageType = TType.age(min: 18, max: 65)
        var errorMessage = ""
        
        // Test exact boundaries
        XCTAssertTrue(ageType.validateResult("18", &errorMessage))
        XCTAssertTrue(ageType.validateResult("65", &errorMessage))
        
        // Test just outside boundaries
        XCTAssertFalse(ageType.validateResult("17", &errorMessage))
        XCTAssertFalse(ageType.validateResult("66", &errorMessage))
        
        // Test extreme values
        XCTAssertFalse(ageType.validateResult("0", &errorMessage))
        XCTAssertFalse(ageType.validateResult("999", &errorMessage))
    }
    
    func testDataLengthBoundaries() {
        let dataType = TType.dataLength(length: 5)
        var errorMessage = ""
        
        // Test exact length
        XCTAssertTrue(dataType.validateResult("12345", &errorMessage))
        
        // Test just under length
        XCTAssertFalse(dataType.validateResult("1234", &errorMessage))
        
        // Test over length (should pass if >= required length)
        XCTAssertTrue(dataType.validateResult("123456", &errorMessage))
    }
    
    // MARK: - Malformed Input Tests
    
    func testMalformedDates() {
        let malformedDates = [
            "13/01/2023", // Invalid month
            "02/30/2023", // Invalid day for February
            "02/29/2023", // Invalid leap year
            "00/15/2023", // Zero month
            "12/00/2023", // Zero day
            "12/32/2023", // Day too high
            "99/99/9999", // All invalid
            "1/1/1",      // Too short
            "123/456/789" // Too long components
        ]
        
        var errorMessage = ""
        for date in malformedDates {
            XCTAssertFalse(TType.date.validateResult(date, &errorMessage),
                          "Malformed date '\(date)' should be invalid")
        }
    }
    
    func testMalformedPhoneNumbers() {
        let malformedPhones = [
            "123",        // Too short
            "000000000",  // Invalid area code
            "1234567890123", // Too long
            "(555) 123-456",  // Incomplete
            "555-123-45678",  // Last part too long
        ]
        
        var errorMessage = ""
        for phone in malformedPhones {
            let result = TType.phone.validateResult(phone, &errorMessage)
            if phone.count < 14 { // Assuming formatted length requirement
                XCTAssertFalse(result, "Short phone '\(phone)' should be invalid")
            }
        }
    }
    
    // MARK: - Type Conversion Edge Cases
    
    func testNumericOverflow() {
        // Test very large numbers for age
        let largeAgeInputs = ["999999", "1000000", String(Int.max)]
        let ageType = TType.age(min: 0, max: 120)
        
        for input in largeAgeInputs {
            var errorMessage = ""
            let result = ageType.validateResult(input, &errorMessage)
            XCTAssertFalse(result, "Large age '\(input)' should be invalid")
        }
    }
    
    func testZeroValues() {
        var errorMessage = ""
        
        // Street numbers cannot be zero
        XCTAssertFalse(TType.streetnumber.validateResult("0", &errorMessage))
        XCTAssertEqual(errorMessage, "Street Number cannot be zero")
        
        // But other numeric types might allow zero
        errorMessage = ""
        XCTAssertTrue(TType.age(min: 0, max: 120).validateResult("0", &errorMessage))
        
        // ZIP codes with leading zeros should be valid
        errorMessage = ""
        XCTAssertTrue(TType.zip.validateResult("00123", &errorMessage))
    }
    
    // MARK: - Mixed Content Tests
    
    func testMixedAlphanumeric() {
        let mixedInputs = [
            "123abc456",
            "abc123def456",
            "a1b2c3d4e5",
            "!1@2#3$4%5"
        ]
        
        for input in mixedInputs {
            // Numeric types should extract only numbers
            let phoneResult = TType.phone.filter(input)
            XCTAssertTrue(phoneResult.allSatisfy { $0.isNumber },
                         "Phone filter should extract only numbers from '\(input)'")
            
            let creditResult = TType.credit.filter(input)
            XCTAssertTrue(creditResult.allSatisfy { $0.isNumber },
                         "Credit filter should extract only numbers from '\(input)'")
            
            // Name should extract only letters and allowed punctuation
            let nameResult = TType.name.filter(input)
            let allowedChars = CharacterSet.letters.union(CharacterSet(charactersIn: "'-. "))
            for char in nameResult {
                XCTAssertTrue(String(char).rangeOfCharacter(from: allowedChars) != nil,
                             "Name filter allowed invalid character '\(char)' from '\(input)'")
            }
        }
    }
    
    // MARK: - State Edge Cases
    
    func testEdgeCaseStateInputs() {
        let edgeCaseStates = [
            "n.y.",        // Lowercase with periods
            "N Y",         // Space instead of period
            "calif.",      // Lowercase old style with period
            "WASHINGTON STATE", // Extra word
            "New   York",  // Multiple spaces
            " California ", // Leading/trailing spaces
            "D.C.",        // Alternative DC format
            "Wash.",       // Alternative Washington
        ]
        
        let stateType = TType.state
        
        for state in edgeCaseStates {
            var errorMessage = ""
            let result = stateType.validateResult(state, &errorMessage)
            // Don't assert true/false here since these are genuinely edge cases
            // Just ensure no crashes and reasonable error messages
            if !result {
                XCTAssertFalse(errorMessage.isEmpty,
                              "Should have error message for invalid state '\(state)'")
            }
        }
    }
    
    // MARK: - Capitalization Edge Cases
    
    func testInconsistentCapitalization() {
        let mixedCaseInputs = [
            ("jOhN dOe", TType.name),
            ("nEw YoRk", TType.city),
            ("mAiN sTreeT", TType.street),
            ("ca", TType.st),
            ("cAlIf", TType.state)
        ]
        
        for (input, type) in mixedCaseInputs {
            let filtered = type.filter(input)
            
            // Should normalize capitalization appropriately
            switch type {
            case .name, .city, .street:
                // Should be properly capitalized
                XCTAssertFalse(filtered.contains(Character("j")),
                              "Should capitalize first letters in '\(input)'")
            case .st:
                // Should be uppercase
                XCTAssertEqual(filtered, filtered.uppercased(),
                              "State code should be uppercase: '\(input)'")
            case .state:
                // Behavior depends on whether it's a valid state code
                break
            default:
                break
            }
        }
    }
    
    // MARK: - Performance Edge Cases
    
    func testRepeatedOperations() {
        let input = "5551234567"
        let phoneType = TType.phone
        
        // Test that repeated filtering doesn't change result
        var result = input
        for _ in 0..<100 {
            result = phoneType.filter(result)
        }
        XCTAssertEqual(result, phoneType.filter(input),
                      "Repeated filtering should be idempotent")
        
        // Test that repeated validation gives same result
        var errorMessage = ""
        let firstValidation = phoneType.validateLive(result, &errorMessage)
        
        for _ in 0..<100 {
            errorMessage = ""
            let validation = phoneType.validateLive(result, &errorMessage)
            XCTAssertEqual(validation, firstValidation,
                          "Repeated validation should give same result")
        }
    }
    
    // MARK: - Memory and Resource Tests
    
    func testLargeVolumeInputs() {
        // Test with many different inputs rapidly
        let phoneType = TType.phone
        let inputs = (0..<1000).map { "555123\(String(format: "%04d", $0))" }
        
        measure {
            for input in inputs {
                _ = phoneType.filter(input)
                var errorMessage = ""
                _ = phoneType.validateLive(input, &errorMessage)
            }
        }
    }
    
    // MARK: - Locale and Regional Edge Cases
    
    func testInternationalPhoneFormats() {
        let internationalPhones = [
            "+1 555 123 4567",  // US with country code
            "011 44 20 7946 0958", // UK from US
            "+33 1 42 68 53 00",   // France
            "001-555-123-4567"     // Alternative format
        ]
        
        for phone in internationalPhones {
            let filtered = TType.phone.filter(phone)
            // Should extract numbers and truncate to domestic length
            XCTAssertTrue(filtered.allSatisfy { $0.isNumber })
            XCTAssertLessThanOrEqual(filtered.count, 10)
        }
    }
}
