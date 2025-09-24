//
//  TFieldCoreUtilities.swift
//  TField
//
//  Created by utility extraction for TField/TBox shared logic
//

import SwiftUI

// MARK: - Core Utilities for TField and TBox Components

struct TFieldCoreUtilities {
    
    // MARK: - State Management
    
    /// Calculate the appropriate input state based on current conditions
    static func calculateInputState<T: TFType>(
        isFocused: Bool,
        text: String,
        fieldType: T,
        required: Bool
    ) -> InputState {
        var errorMessage = ""
        
        if isFocused {
            if fieldType.validateLive(text, &errorMessage) {
                return .focused(.valid)
            } else {
                return .focused(.invalid(errorMessage))
            }
        } else {
            if text.isEmpty {
                if required {
                    return .inactive(.invalid("Required Entry"))
                } else {
                    return .idle
                }
            } else {
                if fieldType.validateResult(text, &errorMessage) {
                    return .inactive(.valid)
                } else {
                    return .inactive(.invalid(errorMessage))
                }
            }
        }
    }
    
    /// Determine if a field state represents submission-ready validity
    static func isSubmissionValid<T: TFType>(
        inputState: InputState,
        text: String,
        fieldType: T,
        required: Bool
    ) -> Bool {
        switch inputState {
        case .idle:
            return !required
        case .inactive(.valid):
            return true
        case .focused(.valid):
            if required && text.isEmpty {
                return false
            }
            var errorMessage = ""
            return fieldType.validateResult(text, &errorMessage)
        case .focused(.invalid), .inactive(.invalid):
            return false
        case .focused(.empty), .inactive(.empty):
            return !required
        }
    }
    
    // MARK: - Text Processing
    
    /// Process text for display purposes (used by TBox for read-only display)
    static func processDisplayText<T: TFType>(
        _ text: String,
        fieldType: T
    ) -> String {
        let filtered = fieldType.filter(text)
        
        guard fieldType.hasTemplate && !filtered.isEmpty else {
            return filtered
        }
        
        return TFieldTemplates.reconstruct(
            filtered,
            template: fieldType.template,
            placeHolders: fieldType.placeHolders
        )
    }
    
    /// Process input text during active editing (specialized for TField input handling)
    static func processInputText<T: TFType>(
        _ text: String,
        fieldType: T
    ) -> String {
        // For input processing, always apply filter first, then template
        // This is different from display processing which has early exits
        return TFieldTemplates.reconstruct(
            fieldType.filter(text),
            template: fieldType.template,
            placeHolders: fieldType.placeHolders
        )
    }
    
    /// Check if text processing should be updated based on changes
    static func shouldUpdateProcessedText<T: TFType>(
        oldText: String,
        newText: String,
        fieldType: T
    ) -> Bool {
        guard oldText != newText else { return false }
        
        if fieldType.hasTemplate {
            let oldFiltered = fieldType.filter(oldText)
            let newFiltered = fieldType.filter(newText)
            return oldFiltered != newFiltered
        }
        
        return true
    }
    
    // MARK: - Layout Priority Management
    
    /// Calculate layout priority based on content and field characteristics
    static func calculateLayoutPriority<T: TFType>(
        text: String,
        template: String,
        fieldType: T,
        isFocused: Bool
    ) -> Double {
        let textLength = text.count
        let templateLength = template.count
        let totalContent = max(textLength, templateLength)
        
        var priority = 1.0 + (Double(totalContent) * 0.1)
        
        if isFocused {
            priority += 0.5
        }
        
        if fieldType.fieldPriority < 1.0 {
            priority = min(priority, 1.2)
        } else {
            priority = max(priority, 1.3)
        }
        
        return priority
    }
    
    /// Calculate minimum width requirements for a field
    static func calculateMinWidth(
        textCount: Int,
        templateCount: Int
    ) -> CGFloat {
        let minChars = max(10, textCount, templateCount)
        return CGFloat(minChars) * 12
    }
    
    // MARK: - Cached Value Management
    
    /// Consolidated cache structure for field calculations
    struct FieldCache {
        var capsuleHeight: CGFloat
        var scaleFactor: CGFloat
        var alignedFont: Font
        var baseCapsuleHeight: CGFloat
        var minWidth: CGFloat
        var lastTextLength: Int
        
        init() {
            self.capsuleHeight = TFieldConstants.defaultCapsuleHeight
            self.scaleFactor = 1.0
            self.alignedFont = .system(.body, design: .monospaced)
            self.baseCapsuleHeight = TFieldConstants.defaultCapsuleHeight
            self.minWidth = 120
            self.lastTextLength = 0
        }
        
        /// Update all font-related values at once for efficiency
        mutating func updateFontValues(
            environmentFont: Font?,
            sizeCategory: ContentSizeCategory
        ) {
            let config = TFieldFonts.calculateFontConfiguration(
                environmentFont: environmentFont,
                sizeCategory: sizeCategory
            )
            
            self.alignedFont = config.alignedFont
            self.baseCapsuleHeight = config.baseCapsuleHeight
            self.scaleFactor = config.scaleFactor
            self.capsuleHeight = config.scaledCapsuleHeight
        }
        
        /// Update width cache only when text length changes significantly
        mutating func updateWidthIfNeeded(textCount: Int, templateCount: Int) {
            let currentLength = max(textCount, templateCount)
            if abs(currentLength - lastTextLength) > 2 { // Only recalculate for significant changes
                self.minWidth = TFieldCoreUtilities.calculateMinWidth(
                    textCount: textCount,
                    templateCount: templateCount
                )
                self.lastTextLength = currentLength
            }
        }
    }
    
    // MARK: - Debug Utilities
    
    #if DEBUG
    /// Optimized debug logging that only executes in debug builds
    static func logStateChange<T: TFType>(
        fieldType: T,
        label: String,
        from oldState: InputState,
        to newState: InputState,
        enabled: Bool
    ) {
        guard enabled && oldState != newState else { return }
        print("TField '\(label)': \(oldState.description) → \(newState.description)")
    }
    
    /// Generate debug description string
    static func debugDescription<T: TFType>(
        fieldType: T,
        inputState: InputState,
        contentPriority: Double
    ) -> String {
        return "\(String(describing: fieldType)) / \(inputState.description) / P:\(String(format: "%.1f", contentPriority))"
    }
    #else
    /// No-op in release builds
    @inline(__always)
    static func logStateChange<T: TFType>(
        fieldType: T,
        label: String,
        from oldState: InputState,
        to newState: InputState,
        enabled: Bool
    ) {}
    
    @inline(__always)
    static func debugDescription<T: TFType>(
        fieldType: T,
        inputState: InputState,
        contentPriority: Double
    ) -> String { "" }
    #endif
    
    // MARK: - Group Management Integration
    
    /// Update group manager with field validation state (only if group validation is used)
    static func updateGroupManager(
        groupManager: TFieldGroupManager?,
        group: String?,
        fieldId: String,
        isValid: Bool
    ) {
        guard let group = group, let manager = groupManager else { return }
        manager.updateField(group: group, fieldId: fieldId, isValid: isValid)
    }
    
    /// Cleanup group manager registration
    static func cleanupGroupManager(
        groupManager: TFieldGroupManager?,
        group: String?,
        fieldId: String
    ) {
        guard let group = group, let manager = groupManager else { return }
        manager.removeField(group: group, fieldId: fieldId)
    }
}
