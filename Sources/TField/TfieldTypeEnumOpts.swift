//
//  SwiftUIView.swift
//  TField
//
//  Created by Timothy Riggle on 9/28/25.
//

// Added to conform to new finalFormat requirement in TFType protocol
extension TType {
    /// Returns the final formatted string for the given data.
    /// Current default implementation returns the original data unchanged.
    public var finalFormat: (String, inout String) -> String {
        return { (data: String, template: inout String) -> String in
            switch self {
            case .currency:
                var workingData = data
                if !workingData.hasPrefix("$") {
                    print("⚠️ ERROR: Currency finalFormat received data without $ sign: '\(data)' - adding $ sign")
                    workingData = "$" + workingData
                }
                
                // Extract numeric part after $ sign
                let numericPart = String(workingData.dropFirst()) // Remove the $
                
                // Handle empty or invalid numeric part
                guard !numericPart.isEmpty else {
                    template = "$0.00"  // Update template
                    return "$0.00"
                }
                
                // Split on decimal point if present
                let components = numericPart.components(separatedBy: ".")
                let wholePart = components[0]
                let decimalPart = components.count > 1 ? components[1] : ""
                
                // Process whole part - remove leading zeros unless result would be empty
                var processedWhole = wholePart
                if wholePart.count > 1 {
                    processedWhole = wholePart.drop(while: { $0 == "0" }).isEmpty ? "0" : String(wholePart.drop(while: { $0 == "0" }))
                }
                
                // Process decimal part - ensure exactly 2 digits
                var processedDecimal: String
                if decimalPart.isEmpty {
                    processedDecimal = "00"
                } else if decimalPart.count == 1 {
                    processedDecimal = decimalPart + "0"
                } else if decimalPart.count >= 2 {
                    processedDecimal = String(decimalPart.prefix(2))
                } else {
                    processedDecimal = "00"
                }
                
                // Update template to match the processed data size
                if processedWhole.count <= 1 {
                    template = "$0.00"
                } else {
                    let leadingZeros = String(repeating: "0", count: processedWhole.count - 1)
                    template = "$\(leadingZeros)0.00"
                }
                
                let result = "$\(processedWhole).\(processedDecimal)"
                return result
            case .percent:
                var workingData = data
                
                // Ensure % sign is present at the end
                if !workingData.hasSuffix("%") {
                    print("⚠️ ERROR: Percent finalFormat received data without % sign: '\(data)' - adding % sign")
                    workingData = workingData + "%"
                }
                
                // Extract numeric part before % sign
                let numericPart = String(workingData.dropLast()) // Remove the %
                
                // Handle empty or invalid numeric part
                guard !numericPart.isEmpty else {
                    template = "0.00%"
                    return "0.00%"
                }
                
                // Split on decimal point if present
                let components = numericPart.components(separatedBy: ".")
                let wholePart = components[0]
                let decimalPart = components.count > 1 ? components[1] : ""
                
                // Process whole part - remove leading zeros unless result would be empty
                var processedWhole = wholePart
                if wholePart.count > 1 {
                    processedWhole = wholePart.drop(while: { $0 == "0" }).isEmpty ? "0" : String(wholePart.drop(while: { $0 == "0" }))
                }
                
                // Process decimal part - ensure exactly 2 digits
                var processedDecimal: String
                if decimalPart.isEmpty {
                    processedDecimal = "00"
                } else if decimalPart.count == 1 {
                    processedDecimal = decimalPart + "0"
                } else {
                    processedDecimal = String(decimalPart.prefix(2))
                }
                
                // Update template to match the processed data size
                if processedWhole.count <= 1 {
                    template = "0.00%"
                } else {
                    let leadingZeros = String(repeating: "0", count: processedWhole.count - 1)
                    template = "\(leadingZeros)0.00%"
                }
                
                return "\(processedWhole).\(processedDecimal)%"
                
            default:
                return data
            }
        }
    }
}
extension TType {
    public var dynamicTemplate: ((String, String) -> String?)? {
        switch self {
        case .currency:
            return { rawInput, currentTemplate in
                let digits = rawInput.filter { $0.isNumber }
                let hasDecimal = rawInput.contains(".")
                
                if hasDecimal {
                    // Split on decimal to analyze parts separately
                    let components = rawInput.components(separatedBy: ".")
                    let digitsBeforeDecimal = components.first?.filter { $0.isNumber } ?? ""
                    
                    // Calculate template for whole number portion
                    let wholeDigitCount = digitsBeforeDecimal.count
                    let wholeNumberPart: String
                    if wholeDigitCount <= 1 {
                        wholeNumberPart = "0"
                    } else {
                        let leadingZeros = String(repeating: "0", count: wholeDigitCount - 1)
                        wholeNumberPart = "\(leadingZeros)0"
                    }
                    
                    // Decimal portion is always exactly 2 digits
                    let newTemplate = "$\(wholeNumberPart).00"
                    return newTemplate
                }
                
                // No decimal yet - existing logic for whole numbers only
                let digitCount = digits.count
                let newTemplate: String
                if digitCount <= 1 {
                    newTemplate = "$0.00"
                } else {
                    let leadingZeros = String(repeating: "0", count: digitCount - 1)
                    newTemplate = "$\(leadingZeros)0.00"
                }
                
                return newTemplate
            }
        case .percent:
            return { rawInput, currentTemplate in
                // Extract digits and check for decimal point
                let digits = rawInput.filter { $0.isNumber }
                let hasDecimal = rawInput.contains(".")
                
                if hasDecimal {
                    // Split on decimal to analyze digits before and after
                    let components = rawInput.components(separatedBy: ".")
                    let digitsBeforeDecimal = components.first?.filter { $0.isNumber } ?? ""
                    let digitsAfterDecimal = components.count > 1 ? components.last?.filter { $0.isNumber } ?? "" : ""
                    
                    // Calculate template for whole number portion (before decimal)
                    let wholeDigitCount = digitsBeforeDecimal.count
                    let wholeNumberPart: String
                    if wholeDigitCount <= 1 {
                        wholeNumberPart = "0"
                    } else {
                        let leadingZeros = String(repeating: "0", count: wholeDigitCount - 1)
                        wholeNumberPart = "\(leadingZeros)0"
                    }
                    
                    // Calculate template for decimal portion (after decimal)
                    let decimalDigitCount = digitsAfterDecimal.count
                    let decimalPart: String
                    if decimalDigitCount < 2 {
                        decimalPart = "00"  // Always show at least 2 decimal places
                    } else {
                        decimalPart = String(repeating: "0", count: decimalDigitCount)  // Expand as needed
                    }
                    
                    let newTemplate = "\(wholeNumberPart).\(decimalPart)%"
                    
                    return newTemplate
                }
                
                // No decimal yet - handle whole number expansion only
                let digitCount = digits.count
                let newTemplate: String
                if digitCount <= 1 {
                    newTemplate = "0.00%"
                } else {
                    // Multiple digits before decimal - expand the front part
                    let leadingZeros = String(repeating: "0", count: digitCount - 1)
                    newTemplate = "\(leadingZeros)0.00%"
                }
                
                return newTemplate
            }
        default:
            return nil // No dynamic template for other types
        }
    }
}


// Added to conform to new finalFormat requirement in TFType protocol
