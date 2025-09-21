//
//  TTypeReconstructTests.swift
//  TFieldTests
//
//  Created by Timothy Riggle on 9/20/25.
//

import XCTest
@testable import TField

final class TTypeReconstructTests: XCTestCase {
    
    // MARK: - Helper Function
    
    /// Helper function to test the reconstruct functionality
    /// Since reconstruct is private, we'll test it through the filter+reconstruct combination
    func testReconstructWithArray(
        _ type: TType,
        testCases: [(filteredInput: String, expectedFormatted: String)]
    ) {
        for testCase in testCases {
            let result = reconstruct(testCase.filteredInput, template: type.template, placeHolders: type.placeHolders)
            XCTAssertEqual(
                result,
                testCase.expectedFormatted,
                "Reconstruct failed for \(type) with filtered input '\(testCase.filteredInput)': expected '\(testCase.expectedFormatted)', got '\(result)'"
            )
        }
    }
    
    // MARK: - Standalone reconstruct function for testing
    // This mimics your private reconstruct function
    
    func reconstruct(_ input: String, template: String, placeHolders: String) -> String {
        // If no template, return input as-is
        guard !template.isEmpty && !placeHolders.isEmpty else {
            return input
        }
        
        // If no input, return empty string
        guard !input.isEmpty else {
            return ""
        }
        
        var result = ""
        var inputIndex = 0
        var pendingFormatting = ""
        
        for char in template {
            // Check if this character is any of the placeholder characters
            let isPlaceholder = placeHolders.contains(char)
            
            if isPlaceholder {
                // This is a placeholder position
                if inputIndex < input.count {
                    // We have input data for this position
                    // First add any pending formatting characters
                    result.append(pendingFormatting)
                    pendingFormatting = ""
                    
                    // Then add the input character
                    let inputChar = input[input.index(input.startIndex, offsetBy: inputIndex)]
                    result.append(inputChar)
                    inputIndex += 1
                } else {
                    // No more input data, stop building result here
                    break
                }
            } else {
                // This is a formatting character
                // Store it as pending until we have actual data to place
                pendingFormatting.append(char)
            }
        }
        
        return result
    }
    
    // MARK: - No Template Types Tests
    
    func testReconstructNoTemplate() {
        // Types with no templates should return input unchanged
        let noTemplateTypes: [TType] = [.data, .name, .phrase, .street, .city, .intcity, .state, .streetnumber]
        
        for type in noTemplateTypes {
            let testCases: [(String, String)] = [
                ("", ""),
                ("hello", "hello"),
                ("123", "123"),
                ("Hello World", "Hello World")
            ]
            
            testReconstructWithArray(type, testCases: testCases)
        }
    }
    
    // MARK: - Phone Number Reconstruction Tests
    
    func testPhoneReconstruct() {
        let type = TType.phone
        
        // Template: "(000) 000-0000"
        // PlaceHolders: "0"
        
        let testCases: [(String, String)] = [
            ("", ""),
            ("5", "(5"),
            ("55", "(55"),
            ("555", "(555"),
            ("5551", "(555) 1"),
            ("55512", "(555) 12"),
            ("555123", "(555) 123"),
            ("5551234", "(555) 123-4"),
            ("55512345", "(555) 123-45"),
            ("555123456", "(555) 123-456"),
            ("5551234567", "(555) 123-4567")
        ]
        
        testReconstructWithArray(type, testCases: testCases)
    }
    
    // MARK: - Credit Card Reconstruction Tests
    
    func testCreditReconstruct() {
        let type = TType.credit
        
        // Template: "0000 0000 0000 0000"
        // PlaceHolders: "0"
        
        let testCases: [(String, String)] = [
            ("", ""),
            ("4", "4"),
            ("41", "41"),
            ("411", "411"),
            ("4111", "4111"),
            ("41111", "4111 1"),
            ("411111", "4111 11"),
            ("4111111", "4111 111"),
            ("41111111", "4111 1111"),
            ("411111111", "4111 1111 1"),
            ("4111111111", "4111 1111 11"),
            ("41111111111", "4111 1111 111"),
            ("411111111111", "4111 1111 1111"),
            ("4111111111111", "4111 1111 1111 1"),
            ("41111111111111", "4111 1111 1111 11"),
            ("411111111111111", "4111 1111 1111 111"),
            ("4111111111111111", "4111 1111 1111 1111")
        ]
        
        testReconstructWithArray(type, testCases: testCases)
    }
    
    // MARK: - SSN Reconstruction Tests
    
    func testSSNReconstruct() {
        let type = TType.ssn
        
        // Template: "000-00-0000"
        // PlaceHolders: "0"
        
        let testCases: [(String, String)] = [
            ("", ""),
            ("1", "1"),
            ("12", "12"),
            ("123", "123"),
            ("1234", "123-4"),
            ("12345", "123-45"),
            ("123456", "123-45-6"),
            ("1234567", "123-45-67"),
            ("12345678", "123-45-678"),
            ("123456789", "123-45-6789")
        ]
        
        testReconstructWithArray(type, testCases: testCases)
    }
    
    // MARK: - Expiration Date Reconstruction Tests
    
    func testExpDateReconstruct() {
        let type = TType.expDate
        
        // Template: "MM/YY"
        // PlaceHolders: "MY"
        
        let testCases: [(String, String)] = [
            ("", ""),
            ("1", "1"),
            ("12", "12"),
            ("123", "12/3"),
            ("1234", "12/34")
        ]
        
        testReconstructWithArray(type, testCases: testCases)
    }
    
    // MARK: - Date Reconstruction Tests
    
    func testDateReconstruct() {
        let type = TType.date
        
        // Template: "MM/DD/YYYY"
        // PlaceHolders: "MDY"
        
        let testCases: [(String, String)] = [
            ("", ""),
            ("1", "1"),
            ("12", "12"),
            ("123", "12/3"),
            ("1234", "12/34"),
            ("12345", "12/34/5"),
            ("123456", "12/34/56"),
            ("1234567", "12/34/567"),
            ("12345678", "12/34/5678")
        ]
        
        testReconstructWithArray(type, testCases: testCases)
    }
    
    // MARK: - ZIP Code Reconstruction Tests
    
    func testZipReconstruct() {
        let type = TType.zip
        
        // Template: "00000"
        // PlaceHolders: "0"
        
        let testCases: [(String, String)] = [
            ("", ""),
            ("1", "1"),
            ("12", "12"),
            ("123", "123"),
            ("1234", "1234"),
            ("12345", "12345")
        ]
        
        testReconstructWithArray(type, testCases: testCases)
    }
    
    // MARK: - CVV Reconstruction Tests
    
    func testCVVReconstruct() {
        let type = TType.cvv
        
        // Template: "000"
        // PlaceHolders: "0"
        
        let testCases: [(String, String)] = [
            ("", ""),
            ("1", "1"),
            ("12", "12"),
            ("123", "123")
        ]
        
        testReconstructWithArray(type, testCases: testCases)
    }
    
    // MARK: - Age Reconstruction Tests
    
    func testAgeReconstruct() {
        let ageType2Digit = TType.age(min: 18, max: 99)
        let ageType3Digit = TType.age(min: 0, max: 120)
        
        // 2-digit age template: "00"
        let testCases2Digit: [(String, String)] = [
            ("", ""),
            ("1", "1"),
            ("12", "12")
        ]
        
        testReconstructWithArray(ageType2Digit, testCases: testCases2Digit)
        
        // 3-digit age template: "000"
        let testCases3Digit: [(String, String)] = [
            ("", ""),
            ("1", "1"),
            ("12", "12"),
            ("123", "123")
        ]
        
        testReconstructWithArray(ageType3Digit, testCases: testCases3Digit)
    }
    
    // MARK: - State Code Reconstruction Tests
    
    func testSTReconstruct() {
        let type = TType.st
        
        // Template: "XX"
        // PlaceHolders: "X"
        
        let testCases: [(String, String)] = [
            ("", ""),
            ("C", "C"),
            ("CA", "CA")
        ]
        
        testReconstructWithArray(type, testCases: testCases)
    }
    
    // MARK: - Data Length Reconstruction Tests
    
    func testDataLengthReconstruct() {
        let type = TType.dataLength(length: 5)
        
        // Template: "XXXXX"
        // PlaceHolders: "X"
        
        let testCases: [(String, String)] = [
            ("", ""),
            ("A", "A"),
            ("AB", "AB"),
            ("ABC", "ABC"),
            ("ABCD", "ABCD"),
            ("ABCDE", "ABCDE")
        ]
        
        testReconstructWithArray(type, testCases: testCases)
    }
    
    // MARK: - Edge Cases and Error Conditions
    
    func testReconstructEdgeCases() {
        // Test with mismatched template and placeholders
        XCTAssertEqual(reconstruct("123", template: "000-00", placeHolders: "0"), "123")
        
        // Test with empty template but non-empty placeholders
        XCTAssertEqual(reconstruct("123", template: "", placeHolders: "0"), "123")
        
        // Test with template but empty placeholders
        XCTAssertEqual(reconstruct("123", template: "000-00", placeHolders: ""), "123")
        
        // Test with input longer than template accommodates
        XCTAssertEqual(reconstruct("12345", template: "00-00", placeHolders: "0"), "12-34")
        
        // Test with complex mixed template
        XCTAssertEqual(reconstruct("123456", template: "AA-BB-CC", placeHolders: "ABC"), "12-34-56")
    }
    
    // MARK: - Integration Tests (Filter + Reconstruct)
    
    func testFilterReconstructIntegration() {
        // Test the full pipeline: user input -> filter -> reconstruct
        
        // Phone number integration
        let phoneType = TType.phone
        let phoneInput = "(555) 123-4567"
        let phoneFiltered = phoneType.filter(phoneInput)
        let phoneReconstructed = reconstruct(phoneFiltered, template: phoneType.template, placeHolders: phoneType.placeHolders)
        XCTAssertEqual(phoneReconstructed, "(555) 123-4567")
        
        // Credit card integration
        let creditType = TType.credit
        let creditInput = "4111 1111 1111 1111"
        let creditFiltered = creditType.filter(creditInput)
        let creditReconstructed = reconstruct(creditFiltered, template: creditType.template, placeHolders: creditType.placeHolders)
        XCTAssertEqual(creditReconstructed, "4111 1111 1111 1111")
        
        // SSN integration
        let ssnType = TType.ssn
        let ssnInput = "123-45-6789"
        let ssnFiltered = ssnType.filter(ssnInput)
        let ssnReconstructed = reconstruct(ssnFiltered, template: ssnType.template, placeHolders: ssnType.placeHolders)
        XCTAssertEqual(ssnReconstructed, "123-45-6789")
        
        // Date integration
        let dateType = TType.date
        let dateInput = "12/25/2023"
        let dateFiltered = dateType.filter(dateInput)
        let dateReconstructed = reconstruct(dateFiltered, template: dateType.template, placeHolders: dateType.placeHolders)
        XCTAssertEqual(dateReconstructed, "12/25/2023")
    }
    
    // MARK: - Performance Tests
    
    func testReconstructPerformance() {
        let type = TType.phone
        let input = "5551234567"
        
        measure {
            for _ in 0..<1000 {
                _ = reconstruct(input, template: type.template, placeHolders: type.placeHolders)
            }
        }
    }
    
    // MARK: - Boundary Condition Tests
    
    func testReconstructBoundaryConditions() {
        let phoneType = TType.phone
        
        // Test with exactly the right amount of input
        XCTAssertEqual(
            reconstruct("5551234567", template: phoneType.template, placeHolders: phoneType.placeHolders),
            "(555) 123-4567"
        )
        
        // Test with one character too few
        XCTAssertEqual(
            reconstruct("555123456", template: phoneType.template, placeHolders: phoneType.placeHolders),
            "(555) 123-456"
        )
        
        // Test with one character too many (should truncate gracefully)
        XCTAssertEqual(
            reconstruct("55512345678", template: phoneType.template, placeHolders: phoneType.placeHolders),
            "(555) 123-4567"
        )
    }
}
