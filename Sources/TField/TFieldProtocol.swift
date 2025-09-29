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

// MARK: - TFType Protocol Definition
public protocol TFType {
    
    
    // Required by protocol.  This is the default string that will be used if none provided by the calling view
    var description: String { get }
    
    // Number indicating the field priority for the field if needs to be shrunk.  1.0 is  Standard.  values 0-.99 shrink first, generally lower capapcity field, like age (2 or 3 digits).  1.1 - 2.0 are numbers used currenly to restrict priority.  5+ would almost NEVER shrink.  10.0 is the max value.
    var fieldPriority: Double { get }

    // This is a text string representing the input template overlay that may be displayed, such as "(000) 000-0000"  If you do not provide it, then none will be displayed.  This is represented by an empty string in the implementation, which is why the default is an empty string.  Please note, if you provide an input filter, you must also provide four closures - filter, reconstruct, validateLive, and validateResult.
    var template: String { get }

    
     // These are the data placeholders in your template.  For instance, if your template was "MM/DD/YYYY" then your placeholders would be "MDY".  Note this means you cannot use the same character for formatting as you also use for a placeholder.
    var placeHolders: String { get }
    

    #if canImport(UIKit)
        // KeyboardType that will be used.  Not used in MacOS
        var keyboardType: UIKeyboardType { get }
    #endif

    ///This closure will test the string on a character by character basis.  You will receive a partially formatted string of length 0 to max (if there is a max).
    ///In the case of an empty string, you should return true.  Otherwise you should validate each character that has been entered so far.
    /// In some cases, no live validation is needed.  For instance on a zip code, the input filter would limit to 5 numeric digits, so validateLive would always be true.
    /// If, for instance, we were testing an expiration date for a credit card "MM/YY", then the first digit has to be 0 or 1, the second can be any digit, but the first two combined must be between 1 and 12 inclusive, and so forth.
    var validateLive: (String, inout String) -> Bool { get }

    ///This closure will validate the final result when the field looses focus.  You may test if the data entered is valid, or if it is a partial entry ("" should not throw an error even if a field is required, as that testing is done elsewhere).
    ///The String to be tested will be a formatted string, the inout string is an error message.  If the result is valid, return true.
    ///If the result is not valid, set the error message and return false.  The error message does not matter unless the result is false.
    var validateResult: (String, inout String) -> Bool { get }

    /// This is a closure which accepts a string, and strips it of any formatting characters, returning only the raw, unformatted data.  If there is a maximum length, the string returned must be between 0 and max characters
    /// for instance, a phone number with template "(000) 000-0000" would have at most 10 numeric digits.  Filter will remove any non-numeric characters, and truncate to a maximum of 10 digits.
    /// The boolean indicates rather the string has expanded or contracted, which may be of use in some cases.
    var filter: (String, Bool?) -> String { get }
    
    // Optional closure for dynamic template generation based on current input
    // Parameters: (currentRawInput: String, currentTemplate: String) -> String?
    // Returns: New template if dynamic behavior is needed, nil to keep existing template
    // This closure is called before filtering to allow template expansion based on raw user input
    var dynamicTemplate: ((String, String) -> String?)? { get }

    /// A closure that receives the current (filtered, user) data and the current template,
    /// and returns the fully normalized/formatted value for storage or output.
    /// Default is identity (returns data unchanged).
    /// data parameter has passed liveValidation, but not passed resultValidation.  additionally, it will have been reconstructed with finalReconstruct to add any trailing formatting, and lost focus
    /// validateResult will run after this closure.
    /// Meant for types such as currency that require standardized output (e.g., always two decimal digits).
    var finalFormat: (String, inout String) -> String { get }

}

// MARK: - Default Protocol implementations provided for convenience...
extension TFType {

    public var template: String { "" }
    public var placeHolders: String { "" }
    public var fieldPriority: Double { 1.0 }
    public var validateLive: (String, inout String) -> Bool { { _, _ in true } }
    public var validateResult: (String, inout String) -> Bool { { _, _ in true } }
    public var filter: (String, Bool?) -> String { { text, _ in text } }
    public var dynamicTemplate: ((String, String) -> String?)? { nil }
    public var finalFormat: (String, inout String) -> String { { data, _ in data } }

    #if canImport(UIKit)
    public var keyboardType: UIKeyboardType { .default }
    #endif

}

// MARK: - Template Validation Extension
extension TFType {
    /// Validate the template configuration for this field type
    /// Returns a tuple with validation result and optional error message
    public var templateValidation: (isValid: Bool, error: String?) {
        return TFieldTemplates.validateTemplateConfiguration(self)
    }
    
    /// Check if this field type has a template
    public var hasTemplate: Bool {
        return TFieldTemplates.hasTemplate(self)
    }
    
    /// Check if this field type has placeholders
    public var hasPlaceholders: Bool {
        return TFieldTemplates.hasPlaceholders(self)
    }
    
    /// Get the expected final length of formatted text for this template
    public var templateLength: Int {
        return TFieldTemplates.getTemplateLength(self)
    }
    
    /// Get the maximum number of data characters that can fit in this template
    public var maxDataLength: Int {
        return TFieldTemplates.getMaxDataLength(self)
    }
}

