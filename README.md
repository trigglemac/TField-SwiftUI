# TField Swift UI Enhanced Text Field

A SwiftUI package that implements an ENUM controlled TextField.  All of the internal operation is controlled by a state enum, and the external interface is controlled by a public extendable ENUM.  The user is able to select any of the preexisting types, or define their own.  Data validation is self contained in the field, and input filtering is used when applicable.

## Tfield Features

- Simple calling function...  Tfield($text) will work with a default label of "Phrase", and no input filtering, or data validation
- More options as needed... Tfield($text, required: true, type: .credit, label: "Enter Credit Card Number")
- Ability to validate while typing... if an input template is specified, for instance type = .expDate, the input template is "MM/YY"  As digits are entered, they are filtered (only 4 digits) and validated for rather they could construct a valid expiration date
- Ability to use an input template... if an input template is specified, it is displayed on the field, and as each digit is entered, the template character is replaced by the actual character
- Input Filtering... If input is of a specific character set or length, ie expiration date would be 4 numeric digits, this is restricted real time and invalid input is not accepted
- Result Filtering... Once a field looses focus, a validation routine can be executed to verify if a required entry is present, if an entry is complete or partial, and if the final data is valid.
- Floating Label... All types have a default label value, or one can be specified.  In either case, the label shows up inside the box if it is empty.  If there is an input template or data, the label will float up to the top of the box and remain visible
- enum driven state... All state is driven by enums to determine status - idle, active, or inactive, and validity - valid, or invalid(errorMessage).
- Error Messages built into data type... and displayed in real time automatically
- TType enum (TBType protocol) controls data type.  Add a case to the type enum, including all the extension variables, and you have a new viable type.
- All data is passed to and returned from the field in text format.  An initial value must be text, but need not be formatted.  Any offensive characters or extra length will be filtered and the string will be formatted before the data is presented in the view.
- Data is returned from the view as a formatted text string ready for print or display.  If you need a numeric value or date value for calculations, simply filter the formatting and convert. 
- No external dependencies 

## How to Run
  
1. Import the package into your project  -  https://github.com/trigglemac/TField-SwiftUI.git
2. import TField on any file that makes use of the feature

## Tfield Usage
1. There are several types available.  As of this version, those types include the following...

    .data  single alphanumeric string, no spaces allowed
    .dataLength(length: Int)   single alphanumeric string, specified length
    .name   Alpha string(s) any length, spaces and limited puctuation, every word capitalized
    .phrase  current default! alphanumeric string, spaces are allowed, no formatting or filtering at all
    .credit  16 digit card number grouped in 4's
    .expDate  CC expiration date in the format of  MM/YY
    .cvv   3 digit numeric number.  3 digits required
    .age(min: Int, max: Int) age inside specified range.  min is two digits, max is 2 or 3 digits
    .date  numeric string in the form of mm/dd/yyyy, with live and result validation
    .streetnumber - numeric number, max 6 digits, no commas
    .street - Similar to .name, but without restrictions on input.  Capitlaized
    .phone - 10 digit formatted phone number
    .zip - five digit zip code
    .ssn - nine digit formatted social security number

2. the control can be called by the parent view in the following manner...
    Tfield($text) // where text is any state variable in your view.  text will be accepted as a @Binding var text: String.
    
3. The default behavior is of type .phrase (No filtering, or validation), optional, and with an input string of "Enter Info".  You can modify any of these defaults by adding the type:, required:, and label: parameters to your call.
4. A few examples of calls might be as follows...

            Tfield($test1, type: .credit)
            Tfield($test2, type: .expDate, required: true, label: "Exp Date")
            Tfield($test3, type: .name, label: "Enter Your Full Name")
            Tfield($test4)
                .autocorrectionDisabled(true)
            Tfield($test5, type: .dataLength(length: 10), label: "Enter your 10 digit code")
            Tfield($test6, type: .phrase, required: false, label: "Enter Info")  // Same as default
            Tfield($test7, type: .cvv, required: true)
            Tfield($test8, type: .age(min: 65, max: 120), label: "Enter your Age")
            Tfield($test9, type: .date)

5. The view is implemented as a textfield inside of a vstack and a zstack, so some modifiers - such as .autocorrectionDisabled() may be added.  If it works, give it a try, but I have not tried a lot of this, so no guarantees it renders right even if it doesnt flake out.
6. If you don't see the data type you are looking for, you can implement it yourself by extending TType.  Instructions on how to do this are included next.


## Extending Tfield with additional types.
- You can extend Tfield by adding an extension with additional types.  You should start by adding the following code...
- Note that these three examples are now built in to the implementation, and are only provided as an example template to use...

public enum MyCustomTypes: TBType {
    case zipCode
    case phoneNumber
    case socialSecurity
    
    public var description: String {
        switch self {
        case .zipCode: return "ZIP Code"
        case .phoneNumber: return "Phone Number"
        case .socialSecurity: return "Social Security Number"
        }
    }
    
    // ... implement other protocol requirements
}

- This is the minimum implementation required...  The behavior will simply be a new type which can be specified, and an automatic label value associated with this type.  It will not have any additional features such as an input template, filtering, or validation and errorchecking.  If you want those associated with your type, then you need to implement them by adding the following public var statements to your 



import SwiftUI
import XCodeAdditions

public enum MyCustomTypes: TBType {
    
    case zipCode
    case phoneNumber
    case socialSecurity
    
    public var description: String {
        switch self {
        case .zipCode: return "ZIP Code"
        case .phoneNumber: return "Phone Number"
        case .socialSecurity: return "SSN"
        }
    }
    
    public var template: String {
        switch self {
        case .zipCode: return "00000"
        case .phoneNumber: return "(000) 000-0000"
        case .socialSecurity: return "000-00-0000"
        }
    }
    
    // Platform-specific keyboard handling - software keyboard (ios)
\#if canImport(UIKit)
    public var keyboardType: UIKeyboardType {
        switch self {
        case .zipCode:
            return .numberPad
        case .phoneNumber:
            return .phonePad
        case .socialSecurity:
            return .numberPad
        }
    }
\#endif
    
    // How likely a field is to be condensed if space is needed.  1.0 is neutral.  Value between 0 and 10.0
    public var fieldPriority: Double {
        switch self {
        case .zipCode:
            return 0.6
        case .phoneNumber:
            return 0.9
        case .socialSecurity:
            return 0.8
        }
    }

    // closure that will filter for expected characters and maximum characters, for instance numbers only, or exactly 5 digits.  Return the unformatted string (no formatting characters)    
    public var filter: (String) -> String {
        switch self {
        case .zipCode:
            return { text in
                String(text.filter { $0.isNumber }.prefix(5))
            }
        case .phoneNumber:
            return { text in
                String(text.filter { $0.isNumber }.prefix(10))
            }
        case .socialSecurity:
            return { text in
                String(text.filter { $0.isNumber }.prefix(9))
            }
        }
    }
    
    // Accepts a string - may not be complete string, that has been stripped of formatting, and adds in any formatting necessary.  Also responsible for capitalization or any other string modifications.  Only the portion of the data string that exists should be entered, so if you used an input filter of "(000) 000-0000", and three digits were entered, you should return "(123".  If a fourth digit is entered, you should return "(123) 4" (assuming data string was 123 or 1234).
    public var reconstruct: (String) -> String {
        switch self {
        case .zipCode:
            return { digitsOnly in
                // no formatting here, just a 5 digit max numeric number
                return "(\(digitsOnly.prefix(5))"
            }
        case .phoneNumber:
            return { digitsOnly in
                // Implementation for (000) 000-0000 formatting
                var formattedDigits = ""
                switch digitsOnly.count {
                case 0:
                    formattedDigits = ""
                case 1:
                    formattedDigits = "(\(digitsOnly.prefix(1))"
                case 2:
                    formattedDigits = "(\(digitsOnly.prefix(2))"
                case 3:
                    formattedDigits = "(\(digitsOnly.prefix(3))"
                case 4:
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(1))"
                case 5:
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(2))"
                case 6:
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(3))"
               case 7:
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(3))-\(digitsOnly.dropFirst(6).prefix(1))"
                case 8:
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(3))-\(digitsOnly.dropFirst(6).prefix(2))"
                case 9:
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(3))-\(digitsOnly.dropFirst(6).prefix(3))"
                case 10:
                    formattedDigits = "(\(digitsOnly.prefix(3))) \(digitsOnly.dropFirst(3).prefix(3))-\(digitsOnly.dropFirst(6).prefix(4))"
                default:
                    formattedDigits = ""  // This should never happen, because digitsonly is 0 - 10 characters
                }
                return formattedDigits
            }
        case .socialSecurity:
            return { digitsOnly in
                // Implementation for 000-00-0000 formatting
                var formattedDigits: String = ""
                switch digitsOnly.count {
                case 0:
                    formattedDigits = ""
                case 1:
                    formattedDigits = "\(digitsOnly.prefix(1))"
                case 2:
                    formattedDigits = "\(digitsOnly.prefix(2))"
                case 3:
                    formattedDigits = "\(digitsOnly.prefix(3))"
                case 4:
                    formattedDigits = "\(digitsOnly.prefix(3))-\(digitsOnly.dropFirst(3).prefix(1))"
                case 5:
                    formattedDigits = "\(digitsOnly.prefix(3))-\(digitsOnly.dropFirst(3).prefix(2))"
                case 6:
                    formattedDigits = "\(digitsOnly.prefix(3))-\(digitsOnly.dropFirst(3).prefix(2))-\(digitsOnly.dropFirst(5).prefix(1))"
                case 7:
                    formattedDigits = "\(digitsOnly.prefix(3))-\(digitsOnly.dropFirst(3).prefix(2))-\(digitsOnly.dropFirst(5).prefix(2))"
                case 8:
                    formattedDigits = "\(digitsOnly.prefix(3))-\(digitsOnly.dropFirst(3).prefix(2))-\(digitsOnly.dropFirst(5).prefix(3))"
                case 9:
                    formattedDigits = "\(digitsOnly.prefix(3))-\(digitsOnly.dropFirst(3).prefix(2))-\(digitsOnly.dropFirst(5).prefix(4))"
                default:
                    formattedDigits = ""  // This should never happen, because digitsonly is 0 - 9 characters
                }
                return formattedDigits
            }
        }
    }

    // implementation of character by character validation.  You know one or more characters have been added or deleted.  Text is a formatted string value.  You do not need to check for length or numbers only, as that is done with filtering.  What you might do here is for instance, verify that the first digit of "MM/YY" is a 0 or a 1.  If not, error out because there is no way to enter a valid number otherwise.
    // if you return true, the value of errorMessage does not matter.  If you return false (invalid) then you must set your errorMessage to a string indicating the error description.
    // Also note you do NOT get to alter the data value at all.  You flag the error only.
    // You are hashing a formatted string (either empty, partial, or complete) so you may need to strip the formatting before you can actually validate the data.

    public var validateLive: (_ text: String, _ errorMessage: inout String) -> Bool {
        switch self {
        // in these three cases, we do not need to do any live validation.  Any numeric digit is acceptable, and the input filter guarantees we only have at most the maximum number of numeric digits.
        case .zipCode:
            return { text, errorMessage in
                return true
            }
        case .phoneNumber:
            return { text, errorMessage in
                return true
            }
        case .socialSecurity:
            return { text, errorMessage in
                return true
            }
        }
    }
  
    // code to verify result after the field looses focus - in otherwords, the final answer.
    // You do not need to test for required status.  You may want to test that either your final value is valid, or that the value is a complete value.
    // For instance, here you may want to verify that a complete data string was entered, not a partial.

    public var validateResult: (_ text: String, _ errorMessage: inout String) -> Bool {
        switch self {
        case .zipCode:
            return { text, errorMessage in
                if text.count == 5 {
                    return true
                } else {
                    errorMessage = "Incomplete Zip Code"
                    return false
                }

            }
        case .phoneNumber:
            return { text, errorMessage in
                if text.count == 14 {
                    return true
                } else {
                    errorMessage = "Incomplete Phone #"
                    return false
                }
            }
        case .socialSecurity:
            return { text, errorMessage in
                if text.count == 11 {
                    return true
                } else {
                    errorMessage = "Incomplete SSN"
                    return false
                }
            }
        }
    }
}




- If you do not specify the other variables, the default implementation is as follows.
    keyboardType = .default
    template = "" //no input template
    validateLive, validateResult default to true, no data validation
    filter and reconstruct default to no action ie no filtering or formatting
    fieldPriority will default to 1.0

- Once you have added the above example code, or something similar to your project, you should be able to call Tfield using your custome type implementations.

            Tfield($text, type: MyCustomTypes.phoneNumber)
            Tfield($text10, type: MyCustomTypes.zipCode, label: "Zip5")

- Alternatively, if you do not want to specify the MyCustomTypes in your usage call, include the following convenience initializer in the same file as you define MyCustomTypes.  This will allow you to call your custom types with the same syntax as the built in ones... type: .phoneNumber for instance

extension Tfield where T == MyCustomTypes {
    public init(
        _ text: Binding<String>, type: MyCustomTypes, required: Bool = false,
        label: String = ""
    ) {
        self._text = text
        self.type = type
        self.required = required
        self.label = label
        _prompt = State(initialValue: type.template)
    }
}



## What's Next...

- expecting to add additional data types, along with additional testing of the validation closures
- expecting to expose validation state as a binding value to the parent view, so that the internal validation of multiple fields can be used to validate a form.
- expecting to add optional badging for any type...  badges would show up to the right of the label
    badges would be updatable at any time, for instance, as soon as the first digit is entered in a credit, a badge indicating the type of card could be added to the label.  A password field may have a badge that updates as the password becomes more cryptic
- expecting to add warning messages to supplement error messages.  Warning messages would be implemented in the validation routines.  An example might be warning that a credit is expired, or that that a password is too easy
- potentially add some totally custom TextFields to the package, such as a joined pair of password verification or email verification fields, or perhaps a date field with an attached date picker.  All would share the same formatting as the original.
- timeline: honestly this is a hobby.  And I am an infant when it comes to XCode and practical usage.  Getting it into a user package is probably next, then a few more types like address, street, apt, city, and zip.  Uncertain on timeline.  Concurrent to that is probably learning more about GitHub cause hey - ive never done this before.



## Known Issues...

- Yeah, I dont know how to use GitHub.  I need to get versioning figured out next!
- .credit tests the first digit when it is one digit long, but after a second digit is entered, the value is accepted regardless
- .name has a validation error.  Space and hyphen are allowed, apostrophe is flagged as an error
- Capitalization is broken now that reconstruct is handled automatically.  Need to decide if another variable closure is needed for formatting, or if this should be rolled into one of the existing closures (filter, validateLive, validateResult)
- .age error messages are usually too long.  Just display the range.
- label does not always fit on one line when field is condensed, even though there should be enough space (when two or more in an HStack)


## Version History
- version 1.0.0
    posted correctly on GitHub...  version 1.0.0.  

- version 0.9.3
    added support for .font modifiers .font(.title) for instance, including adjusting the capsule size and the frame size
    added support for dynamic type, including adjusting the capsule size
    added accessibility labels to the textField
    
- version 0.92
    completly redesigned the reconstruct process.  Now instead of having to create a closure to handle this, you simply have to create a string containing any placeHolders for each data type.  Instead of deleting characters and adding spaces to the template, the template will always be displayed in full, but the used characters will be colored .clear, and the unused characters colored .gray.  Thus the data and the template will match up better.
    added .zip, .phone, .ssn
    fixed generic initializer to default to .phrase if no type is specified (version 1.0.2 broke this)
    added convenience initializer to facilitate creating custom types, and fixed several issues in the example readme code above.
    fixed behavior where a font size modifier only affected the label.  Now you can use .font(.title) for instance, and get proper results.

- version 0.91
    fixed the generic typing in TType to allow extensions to work properly
    adjusted template location by a couple pixels so it lined up better
    shifted the error message inside the capsule so that the field height stays consistent rather or not there is an error.
    adjusted size and location of Required indicator
    *known issues - versioning is not done right on GitHub, apostrophe in .name is not recognized, when lenght of view is shortened, label is not considered, when some fields are shortened you can tab into them but you cannot click into them, .credit verifies type on first digit, but then accepts a two digit or greater with invalid first digit.  adding .font(.title) to the field only affects the label - try to make it scale everything if possible.
    
- version 0.9:
    adjust spacing vertically and horizontally so template and field line up better on mac and iphone
    additional types : .streetnumber, .street
    added a red asterisk at the front of a field to indicate its required state
    added state based background to the textbox... light blue gradient for idle, darker blue gradient for valid, and red gradient for invalid state.
    fixed the macOS input not having the same background as the capsule
    added conditional background to the floating label... clear if in the middle of the field so as not to interfere with background gradient, and using system or window background color if floating, so that the background blocks out the capsule border
    Other tweaks to make light and dark mode work as expected.
    

## Local Storage

The app currently does not use local storage

## Screenshots

maybe someday ill do this

## License

MIT
