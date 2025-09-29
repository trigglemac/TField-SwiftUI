# TField Swift UI Enhanced Text Field - Version 1.3

A SwiftUI package that implements an ENUM-controlled TextField with comprehensive validation, formatting, and state management. All internal operations are controlled by state enums, while the external interface uses a public, extendable ENUM system.

## Features Overview

- **Enum-driven architecture** - Field behavior controlled by type enums
- **Real-time validation** - Live input validation with immediate feedback
- **Template-based formatting** - Visual input guides with automatic formatting
- **Dynamic templates** - Templates that expand/contract based on input
- **Smart auto-correction** - Intelligent input assistance (e.g., "2" becomes "02" for months)
- **Floating labels** - Animated labels that adapt to field state
- **Group validation** - Organize related fields for collective validation
- **Extensible type system** - Easy creation of custom field types
- **Accessibility support** - Dynamic Type and accessibility features
- **Debug utilities** - Built-in debugging tools for development

## Installation

Add the package to your project:
```
https://github.com/trigglemac/TField-SwiftUI.git
```

Import TField in files where you use it:
```swift
import TField
```

## Basic Usage

- Tfield view provides defaults for every paramter except the data.  So in its most basic form you can use Tfield($data) and you will get an optional .phrase type, with a label "Phrase"
- Each type has a default label that may make sense for you
- Modify as many of the basic parameters as you need.
- The current implementation is able to be size modified with .font(.caption) or some similar modifier... layout alignment may not be perfect yet, as I have not tried every combination.  Please send feedback if there are any issues that you notice
- Similarly the current implementation should support dark mode and dynamic type, but again especially as type gets a LOT bigger or a LOT smaller, things are not going to line up perfectly.

### Simple Implementation
```swift
struct ContentView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    
    var body: some View {
        VStack {
            Tfield($name, type: .name, required: true, label: "Full Name")
            Tfield($email, type: .phrase, label: "Email Address")
            Tfield($phone, type: .phone, required: true)
        }
        .padding()
    }
}
```

### Built-in Field Types

TField includes comprehensive built-in types:

```swift
.data              // Alphanumeric, no spaces
.dataLength(Int)   // Fixed length alphanumeric
.name              // Capitalized names with punctuation
.phrase            // Free-form text with spaces
.credit            // 16-digit credit card (0000 0000 0000 0000)
.expDate           // Credit card expiration (MM/YY)
.cvv               // 3-digit security code
.age(min, max)     // Age within specified range
.date              // Full date (MM/DD/YYYY)
.phone             // US phone number ((000) 000-0000)
.ssn               // Social Security (000-00-0000)
.zip               // 5-digit ZIP code
.street            // Street name (capitalized)
.streetnumber      // Street number (numeric)
.city              // US city name
.intcity           // International city name
.state             // US state (any format)
.st                // Two-letter state code
.currency          // US dollar amounts ($0.00)
.percent           // Percentage values (0.00%)
```

### Smart Auto-Correction Features

Several field types include intelligent input assistance:

```swift
// Expiration dates: typing "2" becomes "02"
Tfield($expDate, type: .expDate, label: "Expiry")

// Dates: "4" becomes "04" for days, "3" becomes "03" for months
Tfield($birthday, type: .date, label: "Birthday")

// Auto-deletion: deleting text that leaves only "0" clears the field
```

## Group Validation

Group validation allows you to organize related fields and validate them collectively:

```swift
struct RegistrationForm: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zip = ""
    
    var body: some View {
        VStack {
            Text("User Registration")
                .font(.title)
                .padding()
        }
        .withGroupValidation(groups: ["personal", "address"]) { validator in
            VStack(spacing: 20) {
                // Personal Information Group
                GroupBox("Personal Information") {
                    VStack {
                        Tfield($firstName, type: .name, required: true,
                               label: "First Name", group: "personal")
                        Tfield($lastName, type: .name, required: true,
                               label: "Last Name", group: "personal")
                        Tfield($email, type: .phrase, required: true,
                               label: "Email", group: "personal")
                    }
                }
                .background(
                    validator.verifyGroup("personal") ? 
                    Color.green.opacity(0.1) : Color.red.opacity(0.1)
                )
                
                // Address Group
                GroupBox("Address") {
                    VStack {
                        Tfield($street, type: .street, required: true,
                               label: "Street", group: "address")
                        HStack {
                            Tfield($city, type: .city, required: true,
                                   label: "City", group: "address")
                            Tfield($state, type: .st, required: true,
                                   label: "State", group: "address")
                            Tfield($zip, type: .zip, required: true,
                                   label: "ZIP", group: "address")
                        }
                    }
                }
                .background(
                    validator.verifyGroup("address") ? 
                    Color.green.opacity(0.1) : Color.red.opacity(0.1)
                )
                
                // Submit Button
                Button("Create Account") {
                    if validator.allGroupsValid() {
                        createAccount()
                    }
                }
                .disabled(!validator.allGroupsValid())
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
    
    private func createAccount() {
        print("Account created successfully!")
    }
}
```

### Group Validation Methods

```swift
// Check if a specific group is valid
let isPersonalValid = validator.verifyGroup("personal")

// Get the number of fields in a group
let fieldCount = validator.groupCount("personal")

// Check if all monitored groups are valid
let allValid = validator.allGroupsValid()

// Debug group state (DEBUG builds only)
validator.debugGroupState("personal")
```

## Debug Features

TField includes comprehensive debugging tools to help during development:

### Enabling Debug Mode

```swift
// Global debug control
MyApp()
    .tFieldDebug(false) // Disable for entire application

// Granular control
VStack {
    Tfield($username, type: .phrase, required: true)
    Tfield($password, type: .phrase, required: true)
}
.tFieldDebug(true) // Enable debug for this section only

// Individual field control
Tfield($email, type: .phrase, required: true)
    .tFieldDebug(true)
```

### Debug Information Display

When enabled, debug mode shows:
- Field type and current state
- Validation status
- Layout priority values
- State transitions in console

```swift
// Debug messages appear above fields showing:
// "phrase / focused(valid) / P:1.2"
// This indicates: field type / current state / layout priority
```

### Custom Type Debug Integration

```swift
public var validateResult: (String, inout String) -> Bool {
    return { text, errorMessage in
        let isValid = text.count >= 2
        
        #if DEBUG
        print("Country validation: '\(text)' -> \(isValid ? "valid" : "invalid")")
        #endif
        
        if !isValid {
            errorMessage = "Country name too short"
        }
        return isValid
    }
}
```

## Creating Custom Field Types

You can extend TField with custom types by conforming to the `TFType` protocol:
Besides defining the name for your new type, you must also define a description.  This is the string that will be used if no label is specified.
It is recommended to specify the fieldPriority(Double) and the keyboardType for IOS.
If you need input Filtering, live validation, result validation, or an input template, you will need to specify it.
If you use templates, you will also need to specify placeHolders, indicating exactly what characters are formatting and what are data in you input template
Finally, if you need dynamic templates (expanding or contracting templates) or finalFormatting (for instance, automatically adding ".00" onto a currency field if it is only entered as dollars) then you will need to implement this functionality as well
See the examples below for various example implementations.

### Example 1: Simple Country Field

```swift
public enum CustomTypes: TFType {
    case country
    
    public var description: String {
        switch self {
        case .country: return "Country"
        }
    }
    
    public var filter: (String, Bool?) -> String {
        switch self {
        case .country:
            return { text, _ in
                // Trim leading spaces and filter to letters and spaces only
                let trimmedText = text.drop(while: { $0 == " " })
                let allowedCharacters = CharacterSet.letters.union(
                    CharacterSet(charactersIn: " ")
                )
                let filteredText = String(trimmedText).filter { char in
                    String(char).rangeOfCharacter(from: allowedCharacters) != nil
                }
                
                // Capitalize each word
                return filteredText.lowercased().capitalized
            }
        }
    }
    
    public var validateResult: (String, inout String) -> Bool {
        switch self {
        case .country:
            return { text, errorMessage in
                // Basic validation - you could integrate with a country database here
                if text.count < 2 {
                    errorMessage = "Country name too short"
                    return false
                }
                
                // Here you could add actual country validation:
                // - Check against ISO country codes
                // - Validate against a countries database
                // - Use a web service for validation
                
                return true
            }
        }
    }
}
```

### Example 2: Checking Account Number with Template

```swift
extension CustomTypes {
    case cknum
}

extension CustomTypes {
    public var description: String {
        switch self {
        case .country: return "Country"
        case .cknum: return "Checking Account"
        }
    }
    
    public var template: String {
        switch self {
        case .country: return ""
        case .cknum: return "000 0000"
        }
    }
    
    public var placeHolders: String {
        switch self {
        case .country: return ""
        case .cknum: return "0"
        }
    }
    
    public var filter: (String, Bool?) -> String {
        switch self {
        case .country:
            // ... previous country implementation
        case .cknum:
            return { text, _ in
                // Extract only digits, limit to 7 digits max
                let digitsOnly = text.filter { $0.isNumber }
                return String(digitsOnly.prefix(7))
            }
        }
    }
    
    public var validateResult: (String, inout String) -> Bool {
        switch self {
        case .country:
            // ... previous country implementation
        case .cknum:
            return { text, errorMessage in
                // Remove formatting to check digit count
                let digitsOnly = text.filter { $0.isNumber }
                if digitsOnly.count < 7 {
                    errorMessage = "Account number must be 7 digits"
                    return false
                }
                return true
            }
        }
    }
}
```

### Example 3: Variable Percent Field with Dynamic Template

```swift
extension CustomTypes {
    case pct
}

extension CustomTypes {
    public var description: String {
        switch self {
        case .country: return "Country"
        case .cknum: return "Checking Account"
        case .pct: return "Percentage"
        }
    }
    
    public var template: String {
        switch self {
        case .country: return ""
        case .cknum: return "000 0000"
        case .pct: return "0%"
        }
    }
    
    public var placeHolders: String {
        switch self {
        case .country: return ""
        case .cknum: return "0"
        case .pct: return "0."
        }
    }
    
    public var filter: (String, Bool?) -> String {
        switch self {
        case .country, .cknum:
            // ... previous implementations
        case .pct:
            return { text, _ in
                // Allow only digits and one decimal point
                let allowedChars = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
                var filtered = text.filter { char in
                    String(char).rangeOfCharacter(from: allowedChars) != nil
                }
                
                // Ensure only one decimal point
                let decimalCount = filtered.filter { $0 == "." }.count
                if decimalCount > 1 {
                    var foundFirst = false
                    filtered = String(filtered.compactMap { char in
                        if char == "." {
                            if foundFirst {
                                return nil
                            } else {
                                foundFirst = true
                                return char
                            }
                        }
                        return char
                    })
                }
                
                return filtered
            }
        }
    }
    
    public var dynamicTemplate: ((String, String) -> String?)? {
        switch self {
        case .country, .cknum:
            return nil
        case .pct:
            return { rawInput, currentTemplate in
                let digits = rawInput.filter { $0.isNumber }
                let hasDecimal = rawInput.contains(".")
                
                if hasDecimal {
                    let components = rawInput.components(separatedBy: ".")
                    let beforeDecimal = components.first?.filter { $0.isNumber } ?? ""
                    let afterDecimal = components.count > 1 ? components.last?.filter { $0.isNumber } ?? "" : ""
                    
                    // Handle case where no whole number is entered (starts with decimal)
                    let wholeTemplate = beforeDecimal.isEmpty ? "0" : String(repeating: "0", count: min(5, max(1, beforeDecimal.count)))
                    let decimalTemplate = afterDecimal.isEmpty ? "" : String(repeating: "0", count: min(5, afterDecimal.count))
                    
                    return "\(wholeTemplate).\(decimalTemplate)%"
                } else {
                    let digitCount = min(5, max(1, digits.count))
                    return String(repeating: "0", count: digitCount) + "%"
                }
            }
        }
    }
    
    public var finalFormat: (String, inout String) -> String {
        switch self {
        case .country, .cknum:
            return { data, _ in data }
        case .pct:
            return { data, template in
                var workingData = data
                
                // Ensure % sign is present
                if !workingData.hasSuffix("%") {
                    workingData = workingData + "%"
                }
                
                // Extract numeric part
                let numericPart = String(workingData.dropLast())
                
                // Handle empty input
                guard !numericPart.isEmpty else {
                    template = "0%"
                    return "0%"
                }
                
                // Handle case where input starts with decimal point
                if numericPart.hasPrefix(".") {
                    let result = "0" + numericPart + "%"
                    template = "0." + String(repeating: "0", count: numericPart.count - 1) + "%"
                    return result
                }
                
                return workingData
            }
        }
    }
}
```

### Using Custom Types

```swift
// Basic usage
Tfield($country, type: CustomTypes.country, required: true, label: "Country")
Tfield($account, type: CustomTypes.cknum, required: true, label: "Account Number")
Tfield($percentage, type: CustomTypes.pct, label: "Rate")

// With convenience initializer (optional)
extension Tfield where T == CustomTypes {
    public init(
        _ text: Binding<String>, 
        type: CustomTypes, 
        required: Bool = false,
        label: String = "",
        group: String? = nil
    ) {
        self._text = text
        self.type = type
        self.required = required
        self.label = label
        self.group = group
        _prompt = State(initialValue: type.template)
    }
}

// Now you can use simplified syntax
Tfield($country, type: .country, required: true, label: "Country")
```

## Advanced Features

### Dynamic Templates

Dynamic templates automatically adjust based on user input:

```swift
// Currency fields expand as more digits are entered
Tfield($amount, type: .currency, label: "Amount")
// Template starts as "$0.00" and expands to "$000.00", "$0000.00", etc.

// Percentage fields expand before and after decimal
Tfield($rate, type: .percent, label: "Interest Rate")
// Template adjusts from "0.00%" to accommodate longer numbers
```

### Final Formatting

The `finalFormat` closure standardizes output when fields lose focus:

```swift
public var finalFormat: (String, inout String) -> String {
    return { data, template in
        // Ensure consistent formatting for storage/display
        // Called after field validation but before final storage
        return processedData
    }
}
```

## Field Priority and Layout

Control how fields shrink in constrained layouts:

```swift
public var fieldPriority: Double {
    switch self {
    case .zip: return 0.6        // Shrinks first (short content)
    case .name: return 1.5       // Standard priority
    case .phrase: return 1.7     // Resists shrinking
    case .city: return 2.5       // Almost never shrinks
    }
}
```

## Version History

### Version 1.3 (Current)
- Smart auto-correction for date and expDate fields
- Enhanced deletion handling with expansion/contraction detection
- Improved dynamic templates for currency and percentage fields
- Better template validation and error handling

### Version 1.2
- Added currency and percentage field types with dynamic templates
- Implemented `finalFormat` closure for standardized output
- Enhanced template system for expansion/contraction

### Version 1.1
- Group validation system for complex forms
- Debug utilities and environment controls
- Additional field types (city, state, international city)
- Improved capitalization and filtering

### Version 1.0
- Initial stable release with core field types
- Template-based formatting system
- Real-time validation framework
- Floating label animations

## Best Practices

1. **Use appropriate field types** - Choose the most specific type for your data
2. **Implement group validation** - Organize related fields for better UX
3. **Test with debug mode** - Use debugging tools during development
4. **Consider field priority** - Set appropriate shrinking behavior for layouts
5. **Validate thoroughly** - Implement both live and result validation for custom types
6. **Handle edge cases** - Consider empty states, partial input, and deletion scenarios

## Known Limitations

- Browser storage APIs (localStorage, sessionStorage) are not supported in artifacts
- Complex template changes during dynamic updates may require careful validation
- Some edge cases in rapid typing scenarios may need additional handling

For the latest updates and issue tracking, visit the GitHub repository.
