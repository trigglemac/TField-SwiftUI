// TFieldGroupTest.swift (for testing)
#if DEBUG
import SwiftUI

@available(iOS 17.0, macOS 15.0, *)
public struct TFieldGroupTest: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zip = ""

    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("TField Group Validation Test")
                    .font(.title2)
                    .padding()
            }
        }
        .padding()
        .withGroupValidation(groups: ["personal", "address"]) { validator in
            VStack(spacing: 20) {
                // Personal Info Group
                GroupBox("Personal Information") {
                    VStack {
                        Tfield($firstName, type: .name, required: true,
                              label: "First Name", group: "personal")
                        Tfield($lastName, type: .name, required: true,
                              label: "Last Name", group: "personal")
                        Tfield($email, type: .phrase,
                              label: "Email", group: "personal")
                        Tfield($phone, type: .phone, required: true,
                              label: "Phone", group: "personal")
                    }
                    .font(.caption)
                }
                .background(validator.verifyGroup("personal") ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                
                // Address Group
                GroupBox("Address Information") {
                    VStack {
                        Tfield($street, type: .street, required: true,
                              label: "Street", group: "address")
                        Tfield($city, type: .city, required: true,
                              label: "City", group: "address")
                        Tfield($state, type: .st, required: true,
                              label: "State", group: "address")
                        Tfield($zip, type: .zip, required: true,
                              label: "ZIP", group: "address")
                    }
                    .font(.caption)
                }
                .background(validator.verifyGroup("address") ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                
                // Status Display
                VStack {
                    Text("Personal Info: \(validator.verifyGroup("personal") ? "✅ Valid" : "❌ Invalid") (\(validator.groupCount("personal")) fields)")
                    Text("Address Info: \(validator.verifyGroup("address") ? "✅ Valid" : "❌ Invalid") (\(validator.groupCount("address")) fields)")
                    Text("All Valid: \(validator.allGroupsValid() ? "✅" : "❌")")
                    
                    Button("Debug Personal Group") {
                        validator.debugGroupState("personal")
                    }
                    
                    Button("Debug Address Group") {
                        validator.debugGroupState("address")
                    }
                    
                    Button("Submit") {
                        if validator.allGroupsValid() {
                            print("Form is valid - submitting!")
                        } else {
                            print("Form has errors")
                        }
                    }
                    .disabled(!validator.allGroupsValid())
                }
                .padding()
            }
        }
    }
}

struct TFieldGroup_Previews: PreviewProvider {
    static var previews: some View {
        TFieldGroupTest()
            .previewDisplayName("TField Groups")
    }
}

#endif
