//
//  StateDataIntegrityTests.swift
//  TFieldTests
//
//  Created by Timothy Riggle on 9/20/25.
//

import XCTest
@testable import TField

final class StateDataIntegrityTests: XCTestCase {
    
    // MARK: - Data Completeness Tests
    
    func testValidStateCodesCompleteness() {
        // Test that we have all 50 states + DC + territories
        let expectedStateCount = 50 + 6 // 50 states + DC + 5 territories (AS, GU, MP, PR, VI)
        XCTAssertEqual(validStateCodes.count, expectedStateCount,
                      "Should have exactly \(expectedStateCount) state/territory codes")
        
        // Test specific required codes exist
        let requiredCodes = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
                           "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
                           "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
                           "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
                           "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
                           "DC", "AS", "GU", "MP", "PR", "VI"]
        
        for code in requiredCodes {
            XCTAssertTrue(validStateCodes.contains(code), "Missing required state code: \(code)")
        }
    }
    
    func testFullStateNamesCompleteness() {
        // Test that we have all state names
        let expectedNameCount = 58 // 50 states + DC + territories + variations
        XCTAssertGreaterThanOrEqual(fullStateNames.count, expectedNameCount,
                                   "Should have at least \(expectedNameCount) state names")
        
        // Test specific required names exist
        let requiredNames = ["ALABAMA", "ALASKA", "ARIZONA", "ARKANSAS", "CALIFORNIA",
                           "COLORADO", "CONNECTICUT", "DELAWARE", "FLORIDA", "GEORGIA",
                           "HAWAII", "IDAHO", "ILLINOIS", "INDIANA", "IOWA", "KANSAS",
                           "KENTUCKY", "LOUISIANA", "MAINE", "MARYLAND", "MASSACHUSETTS",
                           "MICHIGAN", "MINNESOTA", "MISSISSIPPI", "MISSOURI", "MONTANA",
                           "NEBRASKA", "NEVADA", "NEW HAMPSHIRE", "NEW JERSEY", "NEW MEXICO",
                           "NEW YORK", "NORTH CAROLINA", "NORTH DAKOTA", "OHIO", "OKLAHOMA",
                           "OREGON", "PENNSYLVANIA", "RHODE ISLAND", "SOUTH CAROLINA",
                           "SOUTH DAKOTA", "TENNESSEE", "TEXAS", "UTAH", "VERMONT",
                           "VIRGINIA", "WASHINGTON", "WEST VIRGINIA", "WISCONSIN", "WYOMING",
                           "DISTRICT OF COLUMBIA"]
        
        for name in requiredNames {
            XCTAssertTrue(fullStateNames.contains(name), "Missing required state name: \(name)")
        }
    }
    
    // MARK: - Data Uniqueness Tests
    
    func testValidStateCodesUniqueness() {
        let uniqueCodes = Set(validStateCodes)
        XCTAssertEqual(validStateCodes.count, uniqueCodes.count,
                      "validStateCodes contains duplicates")
        
        // Test all codes are exactly 2 characters
        for code in validStateCodes {
            XCTAssertEqual(code.count, 2, "State code '\(code)' is not exactly 2 characters")
            XCTAssertTrue(code.allSatisfy { $0.isLetter && $0.isUppercase },
                         "State code '\(code)' contains non-uppercase letters")
        }
    }
    
    func testFullStateNamesUniqueness() {
        let uniqueNames = Set(fullStateNames)
        XCTAssertEqual(fullStateNames.count, uniqueNames.count,
                      "fullStateNames contains duplicates")
        
        // Test all names are uppercase
        for name in fullStateNames {
            XCTAssertEqual(name, name.uppercased(), "State name '\(name)' is not uppercase")
            XCTAssertFalse(name.isEmpty, "Empty state name found")
        }
    }
    
    func testOldStyleAbbreviationsUniqueness() {
        let uniqueAbbreviations = Set(oldStyleAbbreviations)
        XCTAssertEqual(oldStyleAbbreviations.count, uniqueAbbreviations.count,
                      "oldStyleAbbreviations contains duplicates")
        
        // Test reasonable length constraints
        for abbrev in oldStyleAbbreviations {
            XCTAssertGreaterThanOrEqual(abbrev.count, 2, "Abbreviation '\(abbrev)' is too short")
            XCTAssertLessThanOrEqual(abbrev.count, 6, "Abbreviation '\(abbrev)' is too long")
            XCTAssertEqual(abbrev, abbrev.uppercased(), "Abbreviation '\(abbrev)' is not uppercase")
        }
    }
    
    // MARK: - Data Consistency Tests
    
    func testStateCodeToNameMapping() {
        // Test that major state codes have corresponding full names
        let codeToNameMappings: [(String, String)] = [
            ("CA", "CALIFORNIA"),
            ("NY", "NEW YORK"),
            ("TX", "TEXAS"),
            ("FL", "FLORIDA"),
            ("IL", "ILLINOIS"),
            ("PA", "PENNSYLVANIA"),
            ("OH", "OHIO"),
            ("NC", "NORTH CAROLINA"),
            ("MI", "MICHIGAN"),
            ("NJ", "NEW JERSEY"),
            ("DC", "DISTRICT OF COLUMBIA")
        ]
        
        for (code, expectedName) in codeToNameMappings {
            XCTAssertTrue(validStateCodes.contains(code), "Missing state code: \(code)")
            XCTAssertTrue(fullStateNames.contains(expectedName), "Missing state name: \(expectedName)")
        }
    }
    
    func testDirectionalVariationsConsistency() {
        // Test that directional variations are properly formatted
        for (abbreviated, full) in directionalVariations {
            XCTAssertEqual(abbreviated, abbreviated.uppercased(),
                          "Directional abbreviation '\(abbreviated)' should be uppercase")
            XCTAssertEqual(full, full.uppercased(),
                          "Directional full form '\(full)' should be uppercase")
            XCTAssertTrue(fullStateNames.contains(full),
                         "Directional full form '\(full)' should exist in fullStateNames")
        }
    }
    
    func testOldStyleDirectionalConsistency() {
        // Test that old style directional codes are properly formatted
        for code in oldStyleDirectional {
            XCTAssertTrue(code.contains("."), "Old style directional '\(code)' should contain periods")
            XCTAssertEqual(code, code.uppercased(), "Old style directional '\(code)' should be uppercase")
            XCTAssertGreaterThanOrEqual(code.count, 3, "Old style directional '\(code)' too short")
            XCTAssertLessThanOrEqual(code.count, 5, "Old style directional '\(code)' too long")
        }
    }
    
    // MARK: - Data Format Validation Tests
    
    func testStateCodeFormats() {
        let validPattern = "^[A-Z]{2}$"
        let regex = try! NSRegularExpression(pattern: validPattern)
        
        for code in validStateCodes {
            let range = NSRange(location: 0, length: code.utf16.count)
            let matches = regex.numberOfMatches(in: code, range: range)
            XCTAssertEqual(matches, 1, "State code '\(code)' doesn't match expected pattern")
        }
    }
    
    func testFullStateNameFormats() {
        for name in fullStateNames {
            // Should not start or end with spaces
            XCTAssertEqual(name, name.trimmingCharacters(in: .whitespaces),
                          "State name '\(name)' has leading/trailing spaces")
            
            // Should not have multiple consecutive spaces
            XCTAssertFalse(name.contains("  "), "State name '\(name)' has multiple consecutive spaces")
            
            // Should only contain letters, spaces, and periods
            let allowedCharacters = CharacterSet.letters.union(CharacterSet(charactersIn: ". "))
            let nameCharacterSet = CharacterSet(charactersIn: name)
            XCTAssertTrue(allowedCharacters.isSuperset(of: nameCharacterSet),
                         "State name '\(name)' contains invalid characters")
        }
    }
    
    // MARK: - Cross-Reference Validation Tests
    
    func testNoInvalidCrossReferences() {
        // Test that directional variations reference valid full names
        for (_, fullForm) in directionalVariations {
            XCTAssertTrue(fullStateNames.contains(fullForm),
                         "Directional variation references invalid full name: '\(fullForm)'")
        }
    }
    

    
    // MARK: - Logical Consistency Tests
    

    
    func testReasonableDataSizes() {
        // Sanity check data sizes
        XCTAssertGreaterThan(validStateCodes.count, 50, "Too few valid state codes")
        XCTAssertLessThan(validStateCodes.count, 70, "Too many valid state codes")
        
        XCTAssertGreaterThan(fullStateNames.count, 50, "Too few full state names")
        XCTAssertLessThan(fullStateNames.count, 100, "Too many full state names")
        
        XCTAssertGreaterThan(oldStyleAbbreviations.count, 20, "Too few old style abbreviations")
        XCTAssertLessThan(oldStyleAbbreviations.count, 80, "Too many old style abbreviations")
        
        XCTAssertGreaterThan(directionalVariations.count, 5, "Too few directional variations")
        XCTAssertLessThan(directionalVariations.count, 20, "Too many directional variations")
    }
    
    // MARK: - Real-World Validation Tests
    
    func testCommonStateInputs() {
        // Test that common real-world state inputs would be recognized
        let commonInputs = [
            "California", "Texas", "Florida", "New York", "Pennsylvania",
            "CA", "TX", "FL", "NY", "PA",
            "CALIF", "MASS", "CONN", "MICH"
        ]
        
        let stateType = TType.state
        var errorMessage = ""
        
        for input in commonInputs {
            XCTAssertTrue(stateType.validateResult(input, &errorMessage),
                         "Common state input '\(input)' should be valid but got error: \(errorMessage)")
        }
    }
    
    func testObviouslyInvalidStates() {
        // Test that obviously invalid inputs are rejected
        let invalidInputs = ["XX", "ZZ", "ABC", "Fakeland", "NotAState", "123"]
        
        let stateType = TType.state
        var errorMessage = ""
        
        for input in invalidInputs {
            XCTAssertFalse(stateType.validateResult(input, &errorMessage),
                          "Invalid state input '\(input)' should be rejected")
        }
    }
}
