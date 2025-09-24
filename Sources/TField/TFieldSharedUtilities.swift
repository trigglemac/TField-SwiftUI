//
//  TFieldSharedUtils.swift
//  TField
//
//  Created by Timothy Riggle on 9/21/25.
//

import SwiftUI

// MARK: - Shared Utility Functions for TField Components

struct TFieldUtils {
    
    // MARK: - Label Utilities
    
    /// Get the display label for a field, using custom label or type description as fallback
    static func getDisplayLabel<T: TFType>(customLabel: String, fieldType: T) -> String {
        if customLabel.isEmpty {
            return fieldType.description
        } else {
            return customLabel
        }
    }
    
    // MARK: - Background Color Utilities
    
    /// Get the appropriate label background color based on floating state
    static func getLabelBackground(isFloating: Bool) -> Color {
        if isFloating {
            #if canImport(UIKit)
                return Color(UIColor.systemBackground)
            #else
                return Color(NSColor.windowBackgroundColor)
            #endif
        } else {
            return Color.clear
        }
    }
    
    /// Get the error message background color
    static func getErrorBackground() -> Color {
        #if canImport(UIKit)
            return Color(UIColor.systemBackground)
        #else
            return Color(NSColor.windowBackgroundColor)
        #endif
    }
    
    // MARK: - State Gradient Utilities
    
    /// Calculate state-responsive gradient for field backgrounds
    static func calculateStateGradient(validity: InputState.InputValidity, isFocused: Bool) -> LinearGradient {
        let baseOpacity: Double = isFocused ? 0.08 : 0.04

        switch validity {
        case .valid:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(baseOpacity * 3.0),
                    Color.blue.opacity(baseOpacity),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .invalid:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.red.opacity(baseOpacity * 5.0),
                    Color.red.opacity(baseOpacity),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(baseOpacity * 1.0),
                    Color.blue.opacity(baseOpacity),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
