//
//  TFieldPositioning.swift
//  TField
//
//  Created by Timothy Riggle on 9/22/25.
//

import SwiftUI

// MARK: - Positioning and Offset Calculation Utilities

struct TFieldPositioning {
    
    // MARK: - Label Positioning
    
    /// Calculate the vertical offset for floating labels
        static func calculateLabelOffset(
            inputState: InputState,
            text: String,
            prompt: String,
            capsuleHeight: CGFloat
        ) -> CGFloat {
            // If there's a template/prompt, label always stays at top
            if !prompt.isEmpty {
                return -(capsuleHeight * TFieldConstants.labelOffsetRatio)
            }
            
            // For fields without templates, label centers when empty
            if text.isEmpty {
                return 0
            } else {
                // Label floats to top when field has content
                return -(capsuleHeight * TFieldConstants.labelOffsetRatio)
            }
        }
    
    /// Calculate the scale factor for floating labels
    static func calculateLabelScale(
        inputState: InputState,
        text: String,
        prompt: String
    ) -> CGFloat {
        // If there's a template/prompt, label always stays small
        if !prompt.isEmpty {
            return 0.85
        }
        
        // For fields without templates, label scales normally when empty
        if text.isEmpty {
            return 1.0
        } else {
            // Label scales down when floating
            return 0.85
        }
    }
    
    /// Determine if the label should be in floating state
    static func isLabelFloating(
        inputState: InputState,
        text: String,
        prompt: String
    ) -> Bool {
        // If there's a template, label is always floating
        if !prompt.isEmpty {
            return true
        }
         // For fields without templates, label only floats when field has content
         return !text.isEmpty
     }
    
    // MARK: - Error Message Positioning
    
    /// Calculate the vertical offset for error messages
    static func calculateErrorOffset(
         inputState: InputState,
         text: String,
         capsuleHeight: CGFloat
     ) -> CGFloat {
         switch inputState {
         case .idle where text.isEmpty:
             return 0
         default:
             return capsuleHeight * TFieldConstants.errorOffsetRatio
         }
     }
    
    // MARK: - Debug Message Positioning
    
    /// Calculate the vertical offset for debug messages
    static func calculateDebugOffset(
        inputState: InputState,
        text: String,
        prompt: String,
        capsuleHeight: CGFloat
    ) -> CGFloat {
        switch inputState {
        case .idle where text.isEmpty && prompt.isEmpty:
            return 0
        case .inactive(.valid) where text.isEmpty && prompt.isEmpty:
            return 0
        case .inactive(.invalid) where text.isEmpty && prompt.isEmpty:
            return 0
        default:
            return -(capsuleHeight * TFieldConstants.debugOffsetRatio)
        }
    }
    
    // MARK: - Required Indicator Positioning
    
    /// Calculate the vertical offset for required indicators (*)
    static func calculateRequiredIndicatorOffset(capsuleHeight: CGFloat) -> CGFloat {
           return -(capsuleHeight * TFieldConstants.requiredOffsetRatio)
       }
       
       // MARK: - Template Positioning
       
       /// Calculate horizontal offset for template overlay
       static func calculateTemplateXOffset(inputState: InputState) -> CGFloat {
           #if canImport(UIKit)
               return 1
           #else
               return 1
           #endif
       }
    
    /// Calculate vertical offset for template overlay
    static func calculateTemplateYOffset(inputState: InputState) -> CGFloat {
            #if canImport(UIKit)
                switch inputState {
                case .focused(.invalid), .inactive(.invalid):
                    return 1
                default:
                    return 0
                }
            #else
                switch inputState {
                case .focused(.invalid), .inactive(.invalid):
                    return 0
                default:
                    return 0
                }
            #endif
        }
    
    // MARK: - Frame Height Calculations
    
    /// Calculate the main frame height including space for error and debug messages
    /// Calculate the main frame height including space for error and debug messages
     static func calculateMainFrameHeight(
         capsuleHeight: CGFloat,
         scaleFactor: CGFloat,
         hasError: Bool,
         debugEnabled: Bool
     ) -> CGFloat {
         var height: CGFloat = capsuleHeight
         
         // Always account for error message space (core functionality)
         if hasError {
             height += 0  // Error messages use offset, not additional height
         }
         
         // Only add debug space when debugging is enabled
         #if DEBUG
             if debugEnabled {
                 height += 12 * scaleFactor
             }
         #endif
         
         return height
     }
    
    // MARK: - State Helper Functions
    
    /// Check if the current state has an error
    static func hasError(inputState: InputState) -> Bool {
         switch inputState {
         case .focused(.invalid), .inactive(.invalid):
             return true
         default:
             return false
         }
     }
 }

// MARK: - Convenience Extensions for InputState

extension InputState {
    /// Check if this state represents an error condition
    var hasError: Bool {
        return TFieldPositioning.hasError(inputState: self)
    }
}
