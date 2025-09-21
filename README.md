# TField Swift UI Enhanced Text Field

A SwiftUI package that implements an ENUM controlled TextField.  All of the internal operation is controlled by a state enum, and the external interface is controlled by a public extendable ENUM.  The user is able to select any of the preexisting types, or define their own.  Data validation is self contained in the field, and input filtering is used when applicable.

## TField Features

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
- Built in Control of State Debugging Display
- New!  Ability to group fields and check validity of the field grouping. 

## How to Run
  
1. Import the package into your project  -  https://github.com/trigglemac/TField-SwiftUI.git
2. import TField on any file that makes use of the feature
3. I am working on this fairly regular at this point.  You can be assured that basic functionality and usage will not be impacted with versions up to 1.9.9.  I would suggest automatically updating to current minor releases (1.0.0 - 1.9.9) automatically as there are some validation errors, bugs, etc that are being rooted out.

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
    .city - capitalizes and limits punctuation for US City
    .intcity - capitalizes and limits punctuation for an international city (does not handle unicode)
    .state - accepts any state, two letter, oldstyle abbreviation, or full name
    .st - accepts only two letter capitalized state code

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
            #if canImport(UIKit)
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
            #endif
        
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

## Group Validation for fields.
- TField's group validation feature allows you to organize related form fields into logical groups and validate them collectively. This is essential for complex forms with multiple sections like personal information, addresses, payment details, etc. 


- To use this functionality, you need to inject a GroupValidation into your view... Notice the ".withGroupValidation" statement.  The snippet is also utilizing the validator.verifyGroup method to test rather specific groups of fields are valid.  Also the validator.allGroupsValid to control rather the submit button is active.

    struct UserRegistrationForm: View {
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
                    // Personal Information Section
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
                    
                    // Address Section
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
                        createAccount()
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

- For a more advanced example, consider the following code...

    struct CheckoutForm: View {
        // Customer Information
        @State private var firstName = ""
        @State private var lastName = ""
        @State private var email = ""
        @State private var phone = ""
        
        // Shipping Address
        @State private var shipStreet = ""
        @State private var shipCity = ""
        @State private var shipState = ""
        @State private var shipZip = ""
        
        // Billing Address
        @State private var billStreet = ""
        @State private var billCity = ""
        @State private var billState = ""
        @State private var billZip = ""
        @State private var sameAsShipping = false
        
        // Payment Information
        @State private var cardNumber = ""
        @State private var expDate = ""
        @State private var cvv = ""
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Checkout")
                        .font(.largeTitle)
                        .padding()
                }
            }
            .withGroupValidation(groups: ["customer", "shipping", "billing", "payment"]) { validator in
                VStack(spacing: 25) {
                    // Customer Information
                    GroupBox("Customer Information") {
                        VStack {
                            HStack {
                                Tfield($firstName, type: .name, required: true,
                                       label: "First Name", group: "customer")
                                Tfield($lastName, type: .name, required: true,
                                       label: "Last Name", group: "customer")
                            }
                            Tfield($email, type: .phrase, required: true,
                                   label: "Email", group: "customer")
                            Tfield($phone, type: .phone, required: true,
                                   label: "Phone", group: "customer")
                        }
                        .padding()
                    }
                    .background(
                        validator.verifyGroup("customer") ? 
                        Color.green.opacity(0.1) : Color.red.opacity(0.1)
                    )
                    
                    // Shipping Address
                    GroupBox("Shipping Address") {
                        VStack {
                            Tfield($shipStreet, type: .street, required: true,
                                   label: "Street Address", group: "shipping")
                            HStack {
                                Tfield($shipCity, type: .city, required: true,
                                       label: "City", group: "shipping")
                                Tfield($shipState, type: .st, required: true,
                                       label: "State", group: "shipping")
                                Tfield($shipZip, type: .zip, required: true,
                                       label: "ZIP", group: "shipping")
                            }
                        }
                        .padding()
                    }
                    .background(
                        validator.verifyGroup("shipping") ? 
                        Color.green.opacity(0.1) : Color.red.opacity(0.1)
                    )
                    
                    // Billing Address
                    GroupBox("Billing Address") {
                        VStack {
                            Toggle("Same as shipping address", isOn: $sameAsShipping)
                                .padding(.bottom)
                            
                            if !sameAsShipping {
                                Tfield($billStreet, type: .street, required: true,
                                       label: "Billing Street", group: "billing")
                                HStack {
                                    Tfield($billCity, type: .city, required: true,
                                           label: "City", group: "billing")
                                    Tfield($billState, type: .st, required: true,
                                           label: "State", group: "billing")
                                    Tfield($billZip, type: .zip, required: true,
                                           label: "ZIP", group: "billing")
                                }
                            }
                        }
                        .padding()
                    }
                    .background(
                        (validator.verifyGroup("billing") || sameAsShipping) ? 
                        Color.green.opacity(0.1) : Color.red.opacity(0.1)
                    )
                    
                    // Payment Information
                    GroupBox("Payment Information") {
                        VStack {
                            Tfield($cardNumber, type: .credit, required: true,
                                   label: "Card Number", group: "payment")
                            HStack {
                                Tfield($expDate, type: .expDate, required: true,
                                       label: "MM/YY", group: "payment")
                                Tfield($cvv, type: .cvv, required: true,
                                       label: "CVV", group: "payment")
                            }
                        }
                        .padding()
                    }
                    .background(
                        validator.verifyGroup("payment") ? 
                        Color.green.opacity(0.1) : Color.red.opacity(0.1)
                    )
                    
                    // Validation Status
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Form Status:")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: validator.verifyGroup("customer") ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(validator.verifyGroup("customer") ? .green : .red)
                            Text("Customer Info (\(validator.groupCount("customer")) fields)")
                        }
                        
                        HStack {
                            Image(systemName: validator.verifyGroup("shipping") ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(validator.verifyGroup("shipping") ? .green : .red)
                            Text("Shipping Address (\(validator.groupCount("shipping")) fields)")
                        }
                        
                        HStack {
                            Image(systemName: (validator.verifyGroup("billing") || sameAsShipping) ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor((validator.verifyGroup("billing") || sameAsShipping) ? .green : .red)
                            Text("Billing Address")
                        }
                        
                        HStack {
                            Image(systemName: validator.verifyGroup("payment") ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(validator.verifyGroup("payment") ? .green : .red)
                            Text("Payment Info (\(validator.groupCount("payment")) fields)")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Submit Button
                    Button("Complete Order") {
                        completeOrder()
                    }
                    .disabled(!isFormValid(validator))
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
                .padding()
            }
        }
        
        private func isFormValid(_ validator: GroupValidator) -> Bool {
            return validator.verifyGroup("customer") &&
                   validator.verifyGroup("shipping") &&
                   (validator.verifyGroup("billing") || sameAsShipping) &&
                   validator.verifyGroup("payment")
        }
        
        private func completeOrder() {
            print("Order completed successfully!")
        }
    }

- Core Validation Methods...

    // Check if a specific group is valid
    let isPersonalValid = validator.verifyGroup("personal")

    // Get the number of fields in a group
    let fieldCount = validator.groupCount("personal")

    // Check if all monitored groups are valid
    let allValid = validator.allGroupsValid()
    
    #if DEBUG
    validator.debugGroupState("personal") // used for debugging
    #endif

- Status Displays in real time...

    VStack {
        Text("Personal: \(validator.verifyGroup("personal") ? "✅ Valid" : "❌ Invalid")")
        Text("Address: \(validator.verifyGroup("address") ? "✅ Valid" : "❌ Invalid")")
        Text("Payment: \(validator.verifyGroup("payment") ? "✅ Valid" : "❌ Invalid")")
        Text("Ready to submit: \(validator.allGroupsValid() ? "✅" : "❌")")
    }

- Group Names: Case sensitive...  Personal ≠ personal
- Choose descriptive, consistent names
- Common patterns... "personal", "address", "payment"

- Fields specify their group using the group parameter
- Fields without a group do not participate in group validation
- One field can only belong to one group.

- Empty Groups: Return true (no fields = no errors)
- Required Fields Must have valid, complete content
- Optional Fields Valid when empty or when containing valid, complete content

- Group validates status updates every 0.5 seconds
- UI elements that depend on validation status will update reactively
- Background colors, button states, and status incators update in real time

- Batched updates: Rapid field changes are batched to reduce computational overhead
- Automatic Cleanup - Validation managers deallocate when views disappear
- Memory Efficient - No persistent global state.  Each from gets its own validation context
- Power Conscious - timers only run when validation is active

- Best Practices...

    // Good: Logical grouping
    .withGroupValidation(groups: ["personal", "address", "payment"])

    // Avoid: Too many small groups
    .withGroupValidation(groups: ["firstName", "lastName", "email", "phone"])
    
    // Good: Subtle background colors
    .background(validator.verifyGroup("personal") ? 
        Color.green.opacity(0.1) : Color.red.opacity(0.1))

    // Good: Icons with status
    Image(systemName: validator.verifyGroup("address") ? 
        "checkmark.circle.fill" : "xmark.circle.fill")
        
    // Good: Disable until all groups valid
    Button("Submit") {
        submitForm()
    }
    .disabled(!validator.allGroupsValid())

    // Good: Custom validation logic
    Button("Continue") {
        proceedToNextStep()
    }
    .disabled(!validator.verifyGroup("currentStep"))

- Error Handling...

    private func submitForm() {
        guard validator.allGroupsValid() else {
            // Show error message
            showValidationError()
            return
        }
        
        // Process valid form
        processFormData()
    }


## DeBugging TField Usage and User Extensions.
- since Tfield is completely controlled by a set of state enums, it can be beneficial to see the value of those enums as a field progresses through its life.  To that end, a state message can be displayed above a particular field, or above all fields.
- This debugging behavior is controlled by an environment variable @Environment(\.tFieldDebugEnabled)
- This value will default to True in DEBUG builds, and false in release builds.
- This value can be controlled by the package importer directly by using .tFieldDebug() 
- To control this globally in your app, add the following...  
 
        MyApp()
            .tFieldDebug(false) // control Tfield debugging for the entire application.  
            
- You can also control this granularly at any level by adding the modifier after any instance of Tfield, or any group of instances
- You can also debug your closures as they are being used by the package.  For instance if you create a validateLive closure for a custom TBType you have created  Otherwise, print statements place inside #DEBUG conditionals are may not be displayed because the closure is actually run in the TField package.
- Usage Examples...

    // Example 1: Default behavior (debug enabled in DEBUG builds, disabled in production builds)
        struct DefaultDebugUsage: View {
            @State private var name = ""
            @State private var email = ""
            
            var body: some View {
                VStack {
                    Tfield($name, type: .name, required: true)
                    Tfield($email, type: .phrase, required: true, label: "Email")
                }
                // Debug info automatically shown in DEBUG builds, hidden in production
            }
        }

    // Example 2: Explicitly disable debug for entire form
        struct NoDebugForm: View {
            @State private var username = ""
            @State private var password = ""
            
            var body: some View {
                VStack {
                    Tfield($username, type: .phrase, required: true)
                    Tfield($password, type: .phrase, required: true)
                }
                .tFieldDebug(false) // Disable debug for all child TFields
            }
        }

    // Example 3: Enable debug only for development section
        struct MixedDebugUsage: View {
            @State private var production1 = ""
            @State private var production2 = ""
            @State private var development1 = ""
            @State private var development2 = ""
            
            var body: some View {
                VStack {
                    // Production section - no debug
                    Section("Production") {
                        Tfield($production1, type: .name, required: true)
                        Tfield($production2, type: .phrase, required: true)
                    }
                    .tFieldDebug(false)
                    
                    // Development section - with debug
                    Section("Development") {
                        Tfield($development1, type: .phone, required: true)
                        Tfield($development2, type: .zip, required: true)
                    }
                    .tFieldDebug(true)
                }
            }
        }

    // Example 4: Custom TBType with debug logging
        public struct MyCustomTypes: TBType {
            case email
            
            public var description: String { "Email Address" }
            
            public var validateResult: (String, inout String) -> Bool {
                return { text, errorMessage in
                    let isValid = text.contains("@") && text.contains(".")
                    
                    // Simple debug logging for custom types
                    #if DEBUG
                        print("CustomEmailType validation: '\(text)' -> \(isValid ? "valid" : "invalid")")
                    #endif
                    
                    if !isValid {
                        errorMessage = "Must be a valid email address"
                    }
                    return isValid
                }
            }
        }

        struct CustomTypeExample: View {
            @State private var email = ""
            
            var body: some View {
                Tfield($email, type: CustomEmailType(), required: true)
                    .tFieldDebug(true) // Enable debug for custom type
            }
        }






## What's Next...

- expecting to add additional data types, along with additional testing of the validation closures
- expecting to expose validation state as a binding value to the parent view, so that the internal validation of multiple fields can be used to validate a form.
- expecting to add optional badging for any type...  badges would show up to the right of the label
    badges would be updatable at any time, for instance, as soon as the first digit is entered in a credit, a badge indicating the type of card could be added to the label.  A password field may have a badge that updates as the password becomes more cryptic
- expecting to add warning messages to supplement error messages.  Warning messages would be implemented in the validation routines.  An example might be warning that a credit is expired, or that that a password is too easy
- potentially add some totally custom TextFields to the package, such as a joined pair of password verification or email verification fields, or perhaps a date field with an attached date picker.  All would share the same formatting as the original.
- test suite for closure operations...
- timeline: honestly this is a hobby.  And I am an infant when it comes to XCode and practical usage.  Getting it into a user package is probably next, then a few more types like address, street, apt, city, and zip.  Uncertain on timeline.  Concurrent to that is probably learning more about GitHub cause hey - ive never done this before.
- possibly explore a conversion closure - for instance covert a state name to a two digit state abbreviation.  This would execute after validateResult is run.



## Known Issues...

- .credit tests the first digit when it is one digit long, but after a second digit is entered, the value is accepted regardless
- label does not always fit on one line when field is condensed, even though there should be enough space (when two or more in an HStack)
- .font(.title2) when applied there is vertical inconsistency between data and template.  Need to test other options as well and fix them.
- should .data allow tab key?  not stripping it properly
- how should phone number handle a 1 as the first digit.  perhaps not allow it, and add a "countrycode" for phone numbers also
- validateResult not handling empty string in .age and .date correctly.  If not required, should be valid and state go back to idle.
- several fields that strip whitespace not stripping tab keys.



## Version History
- version 1.1.0
    implement Group validation accessible to the parent view.  Added optional parameter group: String that allows you to specify a group for every field you want to monitor.  Then provide verifyGroup, and groupCount methods accessible to the parent view to indicate the validity of that group of fields.  See complete implementation notes above...

- version 1.0.1
    added .city, .intcity (international city), .state, .st (Two letter state code) types
    fixed capitalization (handled it in filter) still need to allow apostrophe, and still need to capitalize first letter after apostrophe and first letter after dash
    modified the debugging State message so end user can control rather it is displayed (no longer hard coded).  @Environment(\.tFieldDebugEnabled)  Usage is described in the debugging section of this document
    adjusted vertical size slightly... accounts for state debugging message if debugging is on, otherwise vertical spacing is zero (all spacing is controlled by parent view)
    fixed .date validation where day and month were not verified with live validation once a year was started to enter.
    fixed .name where input filter handles capitalization... all words lowercased, then first letters and letters after apostrophe are capitalized.  Additionally leading spaces are trimmed.
    added comprehensive test suite
    
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
