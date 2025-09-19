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

public protocol TBType {
    
    
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

    // This closure will test the string on a character by character basis.  You will receive a partially formatted string of length 0 to max (if there is a max).  In the case of an empty string, you should return true.  Otherwise you should validate each character that has been entered so far.
    // In some cases, no live validation is needed.  For instance on a zip code, the input filter would limit to 5 numeric digits, so validateLive would always be true.  If, for instance, we were testing an expiration date for a credit card "MM/YY", then the first digit has to be 0 or 1, the second can be any digit, but the first two combined must be between 1 and 12 inclusive, and so forth.
    var validateLive: (String, inout String) -> Bool { get }

    // This closure will validate the final result when the field looses focus.  You may test if the data entered is valid, or if it is a partial entry ("" should not throw an error even if a field is required, as that testing is done elsewhere).  The String to be tested will be a formatted string, the inout string is an error message.  If the result is valid, return true.  If the result is not valid, set the error message and return false.  The error message does not matter unless the result is false.
    var validateResult: (String, inout String) -> Bool { get }

    // This is a closure which accepts a string, and strips it of any formatting characters, returning only the raw, unformatted data.  If there is a maximum length, the string returned must be between 0 and max characters
    // for instance, a phone number with template "(000) 000-0000" would have at most 10 numeric digits.  Filter will remove any non-numeric characters, and truncate to a maximum of 10 digits.
    var filter: (String) -> String { get }

}




// Default implementations provided for convenience...
extension TBType {

    public var template: String { "" }
    public var placeHolders: String { "" }
    public var fieldPriority: Double { 1.0 }
    public var validateLive: (String, inout String) -> Bool { { _, _ in true } }
    public var validateResult: (String, inout String) -> Bool {
        { _, _ in true }
    }
    public var filter: (String) -> String { { $0 } }

    #if canImport(UIKit)
    public var keyboardType: UIKeyboardType { .default }
    #endif

}
