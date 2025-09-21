//
//  SwiftUIView.swift
//  XCodeAdditions
//
//  Created by Timothy Riggle on 9/11/25.
//

import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

// This is the TType enum definition.  To Add a type, you must first add a case to this enum, then you must add an appropriate case statement to each of the extensions...

public enum TType: TBType, Equatable {
    case data  //Current Default!  single alphanumeric string, no spaces allowed
    case dataLength(length: Int)  // single alphanumeric string, specified length
    case name  //name  Alpha string any length, allowed spaces, capitalized, limited punctuation (period, space, dash, apostrophe)
    case phrase  //phrase  alphanumeric string, spaces are allowed
    case credit  // 16 digit card number grouped in 4's
    case expDate  // MM/YY
    case cvv  // 3 digit numeric number.  3 digits required
    case age(min: Int, max: Int)  //two digit age within the specified range
    case date  // mm/dd/yyyy
    case streetnumber  //Numbers only, no template, length <= 6, no formatting, cant be 0
    case street  // Capitalized, spaces and punctuation allowed.
    case zip  // 5 digit zip
    case phone  // 10 digit phone number
    case ssn  //9 digit social security number
    case city // US city name
    case intcity
    case state  // state name, any form allowed, but no live validation
    case st // two letter capitalized state.

}

extension TType {
    public var description: String {
        switch self {
        case .data:
            return "Data"
        case .dataLength(let length):
            return "Data(\(length) characters)"
        case .name:
            return "Name"
        case .phrase:
            return "Enter Info"
        case .credit:
            return "Credit Card Number"
        case .cvv:
            return "CVV"
        case .expDate:
            return "Expiration Date"
        case .age(let min, let max):
            return "Age(\(min)-\(max))"
        case .date:
            return "Date"
        case .streetnumber:
            return "Street #"
        case .street:
            return "Street Name"
        case .zip:
            return "Zip Code"
        case .phone:
            return "Phone Number"
        case .ssn:
            return "Social Security #"
        case .city:
            return "City"
        case .intcity:
            return "City"
        case .state:
            return "State"
        case .st:
            return "State"
        }
    }
}

extension TType {
    public var template: String {
        switch self {
        case .data:
            return ""
        case .dataLength(let length):
            return String(repeating: "X", count: length)
        case .name:
            return ""
        case .phrase:
            return ""
        case .credit:
            return "0000 0000 0000 0000"
        case .expDate:
            return "MM/YY"
        case .cvv:
            return "000"
        case .age(_, let max):
            return max >= 100 ? "000" : "00"
        case .date:
            return "MM/DD/YYYY"
        case .streetnumber:
            return ""
        case .street:
            return ""
        case .zip:
            return "00000"
        case .phone:
            return "(000) 000-0000"
        case .ssn:
            return "000-00-0000"
        case .city:
            return ""
        case .intcity:
            return ""
        case .state:
            return ""
        case .st:
            return "XX"
        
        }
    }
}

extension TType {
    public var placeHolders: String {
        switch self {
        case .data:
            return ""
        case .dataLength(_):
            return "X"
        case .name:
            return ""
        case .phrase:
            return ""
        case .credit:
            return "0"
        case .expDate:
            return "MY"
        case .cvv:
            return "0"
        case .age(_, _):
            return "0"
        case .date:
            return "MDY"
        case .streetnumber:
            return ""
        case .street:
            return ""
        case .zip:
            return "0"
        case .phone:
            return "0"
        case .ssn:
            return "0"
        case .city:
            return ""
        case .intcity:
            return ""
        case .state:
            return ""
        case .st:
            return "X"
        }
    }
}

extension TType {
    public var fieldPriority: Double {
        switch self {
        case .data: return 1.0
        case .dataLength(_): return 1.1
        case .name: return 1.5
        case .phrase: return 1.7
        case .credit: return 1.5
        case .expDate: return 0.5
        case .cvv: return 0.5
        case .age(_, _): return 0.5
        case .date: return 1.0
        case .streetnumber: return 0.6
        case .street: return 1.5
        case .zip: return 0.6
        case .phone: return 0.7
        case .ssn: return 0.7
        case .city: return 2.5
        case .intcity: return 1.5
        case .state: return 1.0
        case .st: return 0.2
        }
    }
}

#if canImport(UIKit)
    extension TType {
        public var keyboardType: UIKeyboardType {
            switch self {
            case .data:
                return .default
            case .dataLength(length: _):
                return .default
            case .name:
                return .default
            case .phrase:
                return .default
            case .credit:
                return .numberPad
            case .expDate:
                return .numberPad
            case .cvv:
                return .numberPad
            case .age(min: _, max: _):
                return .numberPad
            case .date:
                return .numberPad
            case .streetnumber:
                return .numberPad
            case .street:
                return .default
            case .phone:
                return .numberPad
            case .zip:
                return .numberPad
            case .ssn:
                return .numberPad
            case .city:
                return .default
            case .intcity:
                return .default
            case .state:
                return .default
            case .st:
                return .default
            }
        }
    }
#endif

extension TType {  // This will handle any data verification as numbers are being entered
    public var validateLive:
        (_ text: String, _ errorMessage: inout String) -> Bool
    {
        //  Each closure should return a Bool based on the intermediate validity, and if their is an error, set the errorMessage to the proper error description.  Note the value entered is not updated.  It is up to the user to delete and enter valid data

        switch self {
        case .data:  // Any data is allowed, except no spaces...
            return { text, errorMessage in
                // Check for spaces since filter removes them
                if text.contains(" ") {
                    errorMessage = "Spaces not allowed"
                    return false
                }
                return true
            }
        case .dataLength(_):
            return { text, errorMessage in
                // Check for spaces since filter removes them
                if text.contains(" ") {
                    errorMessage = "Spaces not allowed"
                    return false
                }
                // No need to check length here since filter handles truncation
                return true
            }
        case .name:
            return { text, errorMessage in
                // Input Filtering handles all live validation, and also handles capitalization in real time.
                return true
            }
        case .phrase:
            return { text, errorMessage in
                // profanity checks??
                return true
            }

        case .credit:  // Input filter handles all live error controls
            return { text, errorMessage in
                // Let filter handle most validation, but check for obvious issues
                let digitsOnly = text.filter { $0.isNumber }

                if digitsOnly.count == 1 {
                    // Simple card type validation based on first digit
                    let firstDigit = digitsOnly.prefix(1)
                    switch firstDigit {
                    case "4":  // Visa
                        break
                    case "5":  // Mastercard
                        break
                    case "3":  // Amex
                        break
                    case "6":  // Discover
                        break
                    default:
                        errorMessage = "Invalid credit type"
                        return false
                    }
                }
                return true
            }
        case .expDate:
            return { text, errorMessage in
                var digitsOnly = text.replacingOccurrences(of: "/", with: "")
                if digitsOnly.count > 4 {
                    digitsOnly = String(digitsOnly.prefix(4))
                }
                switch digitsOnly.count {
                case 0:  // dont errorcheck empty string
                    return true
                case 1:  // Must be 0 or 1 to be valid month
                    errorMessage = "Invalid Month"
                    return digitsOnly.prefix(1) == "0"
                        || digitsOnly.prefix(1) == "1"
                case 2:  // first two digits must be between 1 and 12
                    if let month = Int(digitsOnly.prefix(2)) {
                        errorMessage = "Invalid Month"
                        return month > 0 && month < 13
                    } else {
                        errorMessage = "Invalid Month/Year #"  // This should not be possible
                        return false
                    }
                case 3:
                    if let month = Int(digitsOnly.prefix(2)) {
                        if month < 1 || month > 12 {
                            errorMessage = "Invalid Month"
                            return false
                        } else {  //month valid, test year
                            // +/-12 year window around current...
                            let thisYear = Calendar.current.component(
                                .year, from: Date())
                            let min = String(thisYear - 12).dropFirst(2).prefix(
                                1)
                            let max = String(thisYear + 12).dropFirst(2).prefix(
                                1)
                            if let minInt = Int(min), let maxInt = Int(max),
                                let yearInt = Int(
                                    digitsOnly.dropFirst(2).prefix(1))
                            {
                                if yearInt < minInt || yearInt > maxInt {
                                    errorMessage = "Year out of range"
                                    return false
                                } else {
                                    return true
                                }
                            } else {
                                errorMessage = "Invalid Month/Year #"  // This should not be possible
                                return false
                            }
                        }

                    } else {
                        errorMessage = "Invalid Month/Year #"  // This should not be possible
                        return false
                    }
                case 4:
                    if let month = Int(digitsOnly.prefix(2)) {
                        if month < 1 || month > 12 {
                            errorMessage = "Invalid Month"
                            return false
                        } else {  //month valid, test year
                            // +/-12 year window around current...
                            let thisYear = Calendar.current.component(
                                .year, from: Date())
                            let min = String(thisYear - 12).dropFirst(2).prefix(
                                2)
                            let max = String(thisYear + 12).dropFirst(2).prefix(
                                2)
                            if let minInt = Int(min), let maxInt = Int(max),
                                let yearInt = Int(
                                    digitsOnly.dropFirst(2).prefix(2))
                            {
                                if yearInt < minInt || yearInt > maxInt {
                                    errorMessage = "Year out of range"
                                    return false
                                } else {
                                    return true
                                }
                            } else {
                                errorMessage = "Invalid Month/Year #"  // This should not be possible
                                return false
                            }
                        }

                    } else {
                        errorMessage = "Invalid Month/Year #"  // This should not be possible
                        return false
                    }
                default:
                    return false  // this should not be possible with input filtering
                }
            }
        case .cvv:  // Input filter handles all error controls
            return { text, errorMessage in
                return true
            }
        case .age(let min, let max):  // Only a two or three digit numeric string, between the min and max values
            return { text, errorMessage in
                if text.isEmpty {
                    return true  // Don't validate empty input
                }

                guard let value = Int(text) else {  // should never happen, as input filtering guarantees a number, and first test guarantees not empty string
                    errorMessage = "INVALID AGE FORMAT"
                    return false
                }

                let expectedDigits = max >= 100 ? 3 : 2
                if text.count > expectedDigits {  // Also should not be possible if input filtering is working right
                    errorMessage = "Age cannot exceed \(max)"
                    return false
                }

                // For partial input, check if it could potentially be valid
                switch text.count {
                // we handled 0 with the empty string test
                case 1:
                    // if first digit is 0, and max is 3 digits, then return true
                    if value == 0 && max >= 100 {
                        return true
                    } else if value == 0 {  //and max < 100
                        errorMessage = "Age must be at least \(min)"
                        return false
                    }
                    // now test all non- zero cases...
                    let digit = value
                    let twoDigitStart = digit * 10
                    let twoDigitEnd = twoDigitStart + 9
                    let threeDigitStart = digit * 100
                    let threeDigitEnd = threeDigitStart + 99

                    let inputRange = min...max
                    let twoDigitRange = twoDigitStart...twoDigitEnd
                    let threeDigitRange = threeDigitStart...threeDigitEnd

                    // If there's any overlap, return true
                    if inputRange.overlaps(twoDigitRange)
                        || inputRange.overlaps(threeDigitRange)
                    {
                        return true
                    }

                    // Now handle false case with appropriate print
                    if max < twoDigitStart {
                        // max is less than the lowest possible number with that first digit
                        errorMessage = "Age cannot exceed \(max)"
                    } else if min > threeDigitEnd {
                        // min is greater than the highest possible number with that first digit
                        errorMessage = "Age must be at least \(min)"
                    } else if max < threeDigitStart {
                        // The max falls between the two-digit and three-digit ranges (i.e., in the gap)
                        errorMessage = "Age cannot exceed \(max)"
                    } else {
                        // Catch-all for unexpected case
                        errorMessage = "LOGIC ERROR VALIDATE LIVE"
                    }

                    return false

                case 2:

                    guard text.count == 2, let digitsInt = Int(text),
                        (10...99).contains(digitsInt)
                    else {
                        errorMessage = "LOGIC ERROR VALIDATE LIVE"
                        return false
                    }

                    // Interpret digits as a possible 2-digit number
                    let twoDigitValue = digitsInt

                    // Also, interpret digits as the prefix of a 3-digit number range: e.g., "23" → 230...239
                    let threeDigitStart = digitsInt * 10
                    let threeDigitEnd = threeDigitStart + 9

                    let inputRange = min...max

                    // Check if the two-digit value is directly in range
                    if inputRange.contains(twoDigitValue) {
                        return true
                    }

                    // Check if any of the three-digit possibilities fall in the range
                    if inputRange.overlaps(threeDigitStart...threeDigitEnd) {
                        return true
                    }

                    // Handle false case with proper error messages
                    if twoDigitValue < min {
                        // Direct 2-digit value is too small
                        errorMessage = "Age must be at least \(min)"
                    } else if twoDigitValue > max {
                        // Direct 2-digit value is too large
                        errorMessage = "Age cannot exceed \(max)"
                    } else if min > threeDigitEnd {
                        // min is higher than the highest 3-digit value from digits
                        errorMessage = "Age must be at least \(min)"
                    } else if max < threeDigitStart {
                        // max falls between the 2-digit value and possible 3-digit expansions
                        errorMessage = "Age cannot exceed \(max)"
                    } else {
                        // Fallback case
                        errorMessage = "LOGIC ERROR VALIDATE LIVE"
                    }
                    return false
                case 3:
                    if value < min {
                        errorMessage = "Age must be at least \(min)"
                        return false
                    }
                    if value > max {
                        errorMessage = "Age cannot exceed \(max)"
                        return false
                    }
                    return true

                default:
                    return true
                }
            }
        case .date:
            return { text, errorMessage in
                var digitsOnly = text.replacingOccurrences(of: "/", with: "")
                if digitsOnly.count > 8 {
                    digitsOnly = String(digitsOnly.prefix(8))
                }
                switch digitsOnly.count {
                case 0:  // dont errorcheck empty string
                    return true
                case 1:  // Must be 0 or 1 to be valid month
                    errorMessage = "Invalid Month"
                    return digitsOnly.prefix(1) == "0"
                        || digitsOnly.prefix(1) == "1"
                case 2:  // first two digits must be between 1 and 12
                    if let month = Int(digitsOnly.prefix(2)) {
                        errorMessage = "Invalid Month"
                        return month > 0 && month < 13
                    } else {
                        errorMessage = "INVALID DATE"  // This should not be possible
                        return false
                    }
                case 3:
                    if let month = Int(digitsOnly.prefix(2)) {
                        if month < 1 || month > 12 {
                            errorMessage = "Invalid Month"
                            return false
                        } else {  //month valid, test day
                            let day = digitsOnly.dropFirst(2).prefix(2)
                            if day == "0" || day == "1" || day == "2"
                                || day == "3"
                            {
                                return true
                            } else {
                                errorMessage = "Invalid Day"
                                return false
                            }
                        }

                    } else {
                        errorMessage = "INVALID DATE"  // This should not be possible
                        return false
                    }
                case 4:
                    if let month = Int(digitsOnly.prefix(2)) {
                        if month < 1 || month > 12 {
                            errorMessage = "Invalid Month"
                            return false
                        } else {  //month valid, test day
                            if let day = Int(digitsOnly.dropFirst(2).prefix(2))
                            {
                                if day > 0 && day < 32 {
                                    return true
                                } else {
                                    errorMessage = "Invalid Day"
                                    return false
                                }
                            } else {
                                errorMessage = "INVALID DATE"  // This should not be possible
                                return false
                            }
                        }
                    } else {
                        errorMessage = "INVALID DATE"  // This should not be possible
                        return false
                    }
                case 5...8:  // accept any 4 digit year
                    if let month = Int(digitsOnly.prefix(2)) {
                        if month < 1 || month > 12 {
                            errorMessage = "Invalid Month"
                            return false
                        } else {  //month valid, test day
                            if let day = Int(digitsOnly.dropFirst(2).prefix(2))
                            {
                                if day < 1 || day > 31 {
                                    errorMessage = "Invalid Day"
                                    return false
                                } else {  //month and day valid, accept any year
                                    return true
                                }
                            } else {
                                errorMessage = "INVALID DATE"  // This should not be possible
                                return false
                            }
                        }
                    } else {
                        errorMessage = "INVALID DATE"  // This should not be possible
                        return false
                    }
                default:
                    return false  // this should not be possible with input filtering
                }
            }
        case .streetnumber:
            return { text, errorMessage in
                return true
            }
        case .street:
            return { text, errorMessage in
                return true
            }
        case .zip:
            return { text, errorMessage in
                return true
            }
        case .phone:
            return { text, errorMessage in
                return true
            }
        case .ssn:
            return { text, errorMessage in
                return true
            }
        case .city:
            return { text, errorMessage in
                // input filtering and capitalization handled in filter
                return true
            }
        case .intcity:
                // international city filtering and capitalization handled in filter
            return { text, errorMessage in
                return true
            }
        case .state:
            return { text, errorMessage in
                return true
            }
        case .st:
            return { text, errorMessage in
                // Empty text is valid
                if text.isEmpty {
                    return true
                }
                
                // Two character text - check if it's a valid state code
                if text.count == 2 {
                    if validStateCodes.contains(text.uppercased()) {
                        return true
                    } else {
                        errorMessage = "Invalid State"
                        return false
                    }
                }
                
                // One character text - check if any valid state codes start with this letter
                if text.count == 1 {
                    let firstLetter = text.uppercased()
                    let hasValidStart = validStateCodes.contains { $0.hasPrefix(firstLetter) }
                    
                    if hasValidStart {
                        return true
                    } else {
                        errorMessage = "Invalid State"
                        return false
                    }
                }
                
                // Should not reach here given the assumption, but handle gracefully
                errorMessage = "Invalid State"
                return false
            }
        }
    }
}

extension TType {  // This will handle any data verification as numbers are being entered
    public var validateResult:
        (_ text: String, _ errorMessage: inout String) -> Bool
    {
        //  Each closure should return a Bool based on the intermediate validity, and if their is an error, set the errorMessage to the proper error description.  Note the value entered is not updated.  It is up to the user to delete and enter valid data

        switch self {
        case .data:  // Any data is allowed, except no spaces...
            return { text, errorMessage in
                return true
            }
        case .dataLength(let length):
            return { text, errorMessage in
                errorMessage = "Not Long Enough"
                return text.count >= length
            }
        case .name:
            return { text, errorMessage in
                return true
            }
        case .phrase:
            return { text, errorMessage in
                return true
            }
        case .credit:
            return { text, errorMessage in
                errorMessage = "Card Number Incomplete"
                return text.count >= self.template.count
            }
        case .expDate:
            return { text, errorMessage in
                if text.count != 5 {
                    errorMessage = "Incomplete Date"
                    return false
                }
                let digitsOnly = text.replacingOccurrences(of: "/", with: "")
                if let month = Int(digitsOnly.prefix(2)) {
                    if month < 1 || month > 12 {
                        errorMessage = "Invalid Month"
                        return false
                    } else {  //month valid, test year
                        // +/-12 year window around current...
                        let thisYear = Calendar.current.component(
                            .year, from: Date())
                        let min = String(thisYear - 12).dropFirst(2).prefix(2)
                        let max = String(thisYear + 12).dropFirst(2).prefix(2)
                        if let minInt = Int(min), let maxInt = Int(max),
                            let yearInt = Int(digitsOnly.dropFirst(2).prefix(2))
                        {
                            if yearInt < minInt || yearInt > maxInt {
                                errorMessage = "Year out of range"
                                return false
                            } else {
                                return true
                            }
                        } else {
                            errorMessage = "Invalid Month/Year #"  // This should not be possible
                            return false
                        }
                    }

                } else {
                    errorMessage = "Invalid Month/Year #"  // This should not be possible
                    return false
                }

            }
        case .cvv:  // input filter handles numeric input.  Final number acceptable if 3 digits
            return { text, errorMessage in
                errorMessage = "CVV Incomplete"
                return text.count >= self.template.count
            }
        case .age(let min, let max):  // Only a two  digit numeric string, between the min and max values
            return { text, errorMessage in
                guard let value = Int(text) else {
                    errorMessage = "LOGIC ERROR VALIDATE LIVE"  // This should never happen because of input filtering
                    return false
                }
                switch value {
                case ..<min:
                    errorMessage = "Value is smaller than \(min)"
                    return false
                case (max + 1)...:
                    errorMessage = "Value is larger than \(max)"
                    return false
                default: return true
                }

            }
        case .date:
            return { text, errorMessage in
                let dateFormatter = DateFormatter()

                // Set the date format to match the input string
                dateFormatter.dateFormat = "MM/dd/yyyy"

                // Ensure the formatter uses the correct locale and timezone
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")

                // Attempt to convert the string to a Date object
                if let date = dateFormatter.date(from: text) {
                    // If the conversion is successful, check if the original string matches
                    if dateFormatter.string(from: date) == text {
                        return true
                    } else {
                        errorMessage = "Invalid Date"
                        return false
                    }
                }
                // Return false if conversion fails
                errorMessage = "Invalid Date"
                return false
            }
        case .streetnumber:
            return { text, errorMessage in
                if text == "0" {
                    errorMessage = "Street Number cannot be zero"
                    return false
                } else {
                    return true
                }
            }
        case .street:
            return { text, errorMessage in
                return true
            }
        case .zip:
            return { text, errorMessage in
                if text.count == 5 {
                    return true
                } else {
                    errorMessage = "Incomplete Zip Code"
                    return false
                }
            }
        case .phone:
            return { text, errorMessage in
                if text.count == 14 {
                    return true
                } else {
                    errorMessage = "Incomplete Phone #"
                    return false
                }
            }
        case .ssn:
            return { text, errorMessage in
                if text.count == 11 {
                    return true
                } else {
                    errorMessage = "Incomplete SSN"
                    return false
                }
            }
        case .city:
            return { text, errorMessage in
                // could add a service here to test valid city name.
                return true
            }
        case .intcity:
            return { text, errorMessage in
                return true
            }
        case .state:
            return { text, errorMessage in
                // Clean the input - remove extra spaces and normalize
                let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                
                // Reject if too short
                if cleanText.count < 2 {
                    errorMessage = "Invalid State Name"
                    return false
                }
                
                // Test 1: Two-letter postal codes (states + territories)
                if cleanText.count == 2 && cleanText.allSatisfy({ $0.isLetter }) {

                    if validStateCodes.contains(cleanText.uppercased()) {
                        return true
                    } else {
                        errorMessage = "Invalid State Name"
                        return false
                    }
                }
                
                // Test 2: Old-style abbreviations (with or without periods)
                let withoutPeriods = cleanText.replacingOccurrences(of: ".", with: "")
                if withoutPeriods.count <= 5 {
                    if oldStyleAbbreviations.contains(withoutPeriods.uppercased()) {
                        return true
                    }
                }
                
                // Test 3: Full state and territory names
                if fullStateNames.contains(cleanText.uppercased()) {
                    return true
                }
                
                // Test 4: Directional abbreviations (N., S., E., W.)
                let upperText = cleanText.uppercased()
                for (abbreviated, _) in directionalVariations {
                    if upperText == abbreviated {
                        return true
                    }
                }
                
                // Test 5: Old-style directional abbreviations
                if oldStyleDirectional.contains(cleanText.uppercased()) {
                    return true
                }
                
                // If none of the tests pass
                errorMessage = "Invalid State Name"
                return false
            }
        case .st:
            return { text, errorMessage in
                // Empty text is valid
                if text.isEmpty {
                    return true
                }
                
                // Check if it's a valid two-letter state code
                if validStateCodes.contains(text.uppercased()) {
                    return true
                }
                
                // Invalid state code
                errorMessage = "Invalid State"
                return false
            }
            
        
        }
    }
}

extension TType {
    /// Helper to get credit card type from number
    private func creditCardType(from number: String) -> String? {
        guard let firstDigit = number.first?.wholeNumberValue else {
            return nil
        }

        switch firstDigit {
        case 4: return "Visa"
        case 5: return "Mastercard"
        case 3:
            if number.hasPrefix("34") || number.hasPrefix("37") {
                return "American Express"
            }
            return nil
        case 6: return "Discover"
        default: return nil
        }
    }
}

extension TType {
    public var filter: (String) -> String {
        switch self {
        case .data:
            return { text in
                text.replacingOccurrences(
                    of: "\\s+", with: "", options: .regularExpression)
            }  // no spaces, single character string
        case .dataLength(let length):
            return { text in
                String(
                    text.replacingOccurrences(
                        of: "\\s+", with: "", options: .regularExpression
                    ).prefix(length))
            }  // same as .data, but specified length
        case .name:
            return { text in
                // Trim leading spaces only
                let trimmedText = text.drop(while: { $0 == " " })
                
                // Filter to only allowed characters
                let allowedCharacters = CharacterSet.letters.union(
                    CharacterSet(charactersIn: "'-. ")
                )
                let filteredText = String(trimmedText).filter { char in
                    String(char).rangeOfCharacter(from: allowedCharacters) != nil
                }
                
                // Use built-in capitalized, then fix apostrophe cases
                var result = filteredText.lowercased().capitalized
                
                // Handle capitalization after apostrophes
                if result.contains("'") {
                    let parts = result.components(separatedBy: "'")
                    let capitalizedParts = parts.map { $0.capitalized }
                    result = capitalizedParts.joined(separator: "'")
                }
                
                return result
            }  // Multiple words, Proper Capitalization
        case .phrase:
            return { text in
                text
            }  //No filter or format at all
        case .credit:
            return { text in
                let inputText = text.filter { $0.isNumber || $0 == " " }
                let digitsOnly = inputText.replacingOccurrences(
                    of: " ", with: "")
                return String(digitsOnly.prefix(16))
            }  // 16 digit numeric
        case .expDate:
            return { text in
                let digitsOnly = text.filter { $0.isNumber }
                return String(digitsOnly.prefix(4))
            }  // 4 numeric digits
        case .cvv:
            return { text in
                let digitsOnly = String(text.filter { $0.isNumber })
                return String(digitsOnly.prefix(3))
            }  // 3 numeric digits
        case .age(_, let max):
            return { text in
                let maxLength = max >= 100 ? 3 : 2
                return String(text.filter { $0.isNumber }.prefix(maxLength))
            }  //two or three digits depending on max > 99
        case .date:
            return { text in
                let digitsOnly = text.filter { $0.isNumber }
                return String(digitsOnly.prefix(8))
            }
        case .streetnumber:
            return { text in
                let digitsOnly = text.filter { $0.isNumber }
                return String(digitsOnly.prefix(6))
            }
        case .street:
            return { text in
                text.capitalized
            }
        case .zip:
            return { text in
                String(text.filter { $0.isNumber }.prefix(5))
            }
        case .phone:
            return { text in
                String(text.filter { $0.isNumber }.prefix(10))
            }
        case .ssn:
            return { text in
                String(text.filter { $0.isNumber }.prefix(9))
            }
        case .city:
            return { text in
                // Trim leading spaces only
                let trimmedText = text.drop(while: { $0 == " " })
                
                // Filter to only allowed characters for US cities
                // Cities can have: letters, spaces, hyphens, periods (for abbreviations like St.)
                let allowedCharacters = CharacterSet.letters.union(
                    CharacterSet(charactersIn: "-. ")
                )
                let filteredText = String(trimmedText).filter { char in
                    String(char).rangeOfCharacter(from: allowedCharacters) != nil
                }
                
                // Use built-in capitalized for proper city name formatting
                let result = filteredText.lowercased().capitalized
                
                return result
            }
        case .intcity:
            return { text in
                // Trim leading spaces only
                let trimmedText = text.drop(while: { $0 == " " })
                
                // Filter to allowed characters for international cities
                let allowedCharacters = CharacterSet.letters.union(
                    CharacterSet(charactersIn: "-. '/()&")
                )
                let filteredText = String(trimmedText).filter { char in
                    String(char).rangeOfCharacter(from: allowedCharacters) != nil
                }
                
                // Use built-in capitalized for proper city name formatting
                let result = filteredText.lowercased().capitalized
                
                return result
            }
        case .state:
            return { text in
                // Trim leading spaces only
                let trimmedText = text.drop(while: { $0 == " " })
                
                // Filter to allowed characters for US states
                let allowedCharacters = CharacterSet.letters.union(
                    CharacterSet(charactersIn: ". ")
                )
                let filteredText = String(trimmedText).filter { char in
                    String(char).rangeOfCharacter(from: allowedCharacters) != nil
                }
                
                // Check if it's exactly 2 letters (potential state code)
                if filteredText.count == 2 && filteredText.allSatisfy({ $0.isLetter }) {
                    // Valid state codes - capitalize both letters
                    let upperCaseText = filteredText.uppercased()
                    if validStateCodes.contains(upperCaseText) {
                        return upperCaseText
                    }
                }
                
                // For all other cases, use normal capitalization
                let result = filteredText.lowercased().capitalized
                return result
            }
        case .st:
            return { text in
                // Filter to only alphabetic characters
                let lettersOnly = text.filter { $0.isLetter }
                
                // Take at most 2 characters and capitalize them
                let limitedText = String(lettersOnly.prefix(2))
                
                return limitedText.uppercased()
            }
        }
    }
}  // .filter - responsible for input filtering and max length filtering.  returns an UNFORMATTED string
