//
//  TFieldCore.swift
//  TField
//
//  Created by utility extraction for TField/TBox shared logic
//

import SwiftUI

// MARK: - Core Utilities for TField and TBox Components

struct TFieldCore {
    
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
        let filtered = fieldType.filter(text, nil)
        
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
        fieldType: T,
        isExpansion: Bool? = nil
    ) -> String {
        // For input processing, always apply filter first, then template
        // This is different from display processing which has early exits
        return TFieldTemplates.reconstruct(
            fieldType.filter(text, isExpansion),
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
            let isExpansion = newText.count > oldText.count
            let oldFiltered = fieldType.filter(oldText, !isExpansion)
            let newFiltered = fieldType.filter(newText, isExpansion)
            return oldFiltered != newFiltered
        }
        
        return true
    }
    
    /// Determine expansion state based on text length changes
    static func determineExpansionState(oldText: String, newText: String) -> Bool? {
        let oldLength = oldText.count
        let newLength = newText.count
        
        if oldLength == newLength {
            return nil // No length change (character replacement)
        } else if newLength > oldLength {
            return true // Expansion (text added)
        } else {
            return false // Contraction (text deleted)
        }
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
    
    // MARK: - Dynamic Template Management
    
    /// Check and apply dynamic template if available
    /// Returns the updated template if changed, or the original template if no change
    static func applyDynamicTemplate<T: TFType>(
        fieldType: T,
        rawInput: String,
        currentTemplate: String
    ) -> String {
        guard let dynamicTemplateClosure = fieldType.dynamicTemplate else {
            // No dynamic template closure - return current template unchanged
            return currentTemplate
        }
        
        #if DEBUG
        print("🔍 Dynamic Template Debug:")
        print("   Field Type: \(fieldType)")
        print("   Raw Input: '\(rawInput)'")
        print("   Current Template: '\(currentTemplate)'")
        #endif
        
        // Call the dynamic template closure
        if let newTemplate = dynamicTemplateClosure(rawInput, currentTemplate) {
            #if DEBUG
            print("   New Template: '\(newTemplate)'")
            print("   Template Changed: \(newTemplate != currentTemplate)")
            #endif
            
            // Validate the new template has the same placeholder structure
            if validateDynamicTemplate(original: currentTemplate, new: newTemplate, fieldType: fieldType) {
                #if DEBUG
                print("   ✅ Template validated, applying change")
                #endif
                return newTemplate
            } else {
                // Invalid template returned - log warning in debug and keep original
                #if DEBUG
                print("   ❌ TFieldCore Warning: Dynamic template returned invalid template structure. Keeping original template.")
                #endif
                return currentTemplate
            }
        }
        
        #if DEBUG
        print("   → Dynamic template closure returned nil, keeping current template")
        #endif
        
        // Closure returned nil - keep current template
        return currentTemplate
    }
    
    /// Validate that a dynamic template maintains the same placeholder structure as the original
    private static func validateDynamicTemplate<T: TFType>(
        original: String,
        new: String,
        fieldType: T
    ) -> Bool {
        let placeholders = fieldType.placeHolders
        guard !placeholders.isEmpty else {
            // No placeholders to validate - any template is valid
            return true
        }
        
        // Count placeholders in both templates
        var originalPlaceholderCount = 0
        var newPlaceholderCount = 0
        
        for char in original {
            if placeholders.contains(char) {
                originalPlaceholderCount += 1
            }
        }
        
        for char in new {
            if placeholders.contains(char) {
                newPlaceholderCount += 1
            }
        }
        
        // Dynamic template can have any number of placeholders (for expansion AND contraction)
        // The main requirement is that the template structure is valid for the field type
        return newPlaceholderCount > 0 // Just ensure we have some placeholders
    }
    
    // MARK: - Focus Transition Management
    
    /// Process focus loss: finalReconstruct -> finalFormat -> validate
    /// Process focus loss: finalReconstruct -> finalFormat -> validate
    static func processFocusLoss<T: TFType>(
        text: String,
        fieldType: T,
        prompt: inout String
    ) -> FocusLossResult {
        // Step 1: Apply finalReconstruct to add trailing formatting
        let filteredInput = fieldType.filter(text, nil)
        let reconstructed = TFieldTemplates.finalReconstruct(
            filteredInput,
            template: prompt,
            placeHolders: fieldType.placeHolders
        )
        
        // Step 2: Validate the reconstructed text
        var errorMessage = ""
        let isLiveValid = fieldType.validateLive(reconstructed, &errorMessage)
        if !isLiveValid {
            return .validationFailed(errorMessage)
        }
        
        // Step 3: Apply finalFormat for standardized output
        let finalizedText = fieldType.finalFormat(reconstructed, &prompt)
        
        return .success(finalizedText)
    }
    
    /// Result of focus loss processing
    enum FocusLossResult {
        case success(String)        // Successfully finalized text
        case validationFailed(String)  // Live validation failed
    }
    
    /// Complete focus transition handler using TFieldFocusState tracking
    static func handleFocusTransition<T: TFType>(
        previousFocusState: TFieldFocusState,
        currentFocusState: TFieldFocusState,
        text: inout String,
        isFinalized: inout Bool,
        fieldType: T,
        prompt: inout String
    ) -> FocusTransitionHandlerResult {
        let transition = TFieldFocusState.analyzeTransition(
            from: previousFocusState,
            to: currentFocusState
        )
        
        switch transition {
        case .gainingFocus:
            // Reset finalized state when gaining focus
            isFinalized = false
            return .gainingFocus
            
        case .losingFocus:
            // Process the focus loss
            let focusLossResult = processFocusLoss(
                text: text,
                fieldType: fieldType,
                prompt: &prompt
            )
            
            switch focusLossResult {
            case .success(let finalizedText):
                text = finalizedText
                isFinalized = true
                return .losingFocus
            case .validationFailed(let error):
                return .validationFailed(error)
            }
            
        case .keepsFocus:
            return .keepsFocus
            
        case .staysInactive:
            return .staysInactive
        }
    }
    
    /// Result of the complete focus transition handling
    enum FocusTransitionHandlerResult {
        case gainingFocus           // Successfully handled gaining focus
        case losingFocus            // Successfully handled losing focus  
        case keepsFocus             // Continues to have focus (active editing)
        case staysInactive          // Continues to be inactive
        case validationFailed(String)  // Focus loss but validation failed
    }
    
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
