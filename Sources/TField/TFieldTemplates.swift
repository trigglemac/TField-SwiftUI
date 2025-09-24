//
//  TFieldTemplates.swift
//  TField
//
//  Created by Timothy Riggle on 9/22/25.
//

import SwiftUI

// MARK: - Template Creation and Processing Utilities

struct TFieldTemplates {
    
    // MARK: - Colored Template Creation
    
    /// Create colored template text showing filled vs unfilled positions
    /// This is the core template display logic that both TField and TBox can use
    static func createColoredTemplate<T: TFType>(
        fieldType: T,
        currentTextLength: Int,
        filledColor: Color = .clear,
        unfilledColor: Color = .gray
    ) -> Text {
        let template = fieldType.template

        guard !template.isEmpty else {
            return Text("")
        }

        var result = Text("")

        for (index, char) in template.enumerated() {
            if index < currentTextLength {
                // This position is covered by the formatted text - make it the filled color
                result = result + Text(String(char)).foregroundColor(filledColor)
            } else {
                // This position is not covered - show in unfilled color
                result = result + Text(String(char)).foregroundColor(unfilledColor)
            }
        }

        return result
    }
    
    // MARK: - Template Analysis
    
    /// Check if a field type has a template
    static func hasTemplate<T: TFType>(_ fieldType: T) -> Bool {
        return !fieldType.template.isEmpty
    }
    
    /// Check if a field type has placeholders
    static func hasPlaceholders<T: TFType>(_ fieldType: T) -> Bool {
        return !fieldType.placeHolders.isEmpty
    }
    
    /// Get the expected final length of formatted text for a template
    static func getTemplateLength<T: TFType>(_ fieldType: T) -> Int {
        return fieldType.template.count
    }
    
    /// Get the maximum data characters that can fit in a template
    static func getMaxDataLength<T: TFType>(_ fieldType: T) -> Int {
        let template = fieldType.template
        let placeholders = fieldType.placeHolders
        
        guard !template.isEmpty && !placeholders.isEmpty else {
            return 0
        }
        
        // Count how many placeholder characters are in the template
        var count = 0
        for char in template {
            if placeholders.contains(char) {
                count += 1
            }
        }
        return count
    }
    
    // MARK: - Template Formatting Logic
    
    /// Reconstruct formatted text from raw input using template and placeholders
    /// This is the core formatting logic that handles template-based input reconstruction
    static func reconstruct(
        _ input: String,
        template: String,
        placeHolders: String
    ) -> String {
        // If no template, return input as-is
        guard !template.isEmpty && !placeHolders.isEmpty else {
            return input
        }

        // If no input, return empty string
        guard !input.isEmpty else {
            return ""
        }

        var result = ""
        var inputIndex = 0
        var pendingFormatting = ""

        for char in template {
            // Check if this character is any of the placeholder characters
            let isPlaceholder = placeHolders.contains(char)

            if isPlaceholder {
                // This is a placeholder position
                if inputIndex < input.count {
                    // We have input data for this position
                    // First add any pending formatting characters
                    result.append(pendingFormatting)
                    pendingFormatting = ""

                    // Then add the input character
                    let inputChar = input[
                        input.index(input.startIndex, offsetBy: inputIndex)]
                    result.append(inputChar)
                    inputIndex += 1
                } else {
                    // No more input data, stop building result here
                    break
                }
            } else {
                // This is a formatting character
                // Store it as pending until we have actual data to place
                pendingFormatting.append(char)
            }
        }

        return result
    }
    
    // MARK: - Template Validation
    
    /// Validate that a template and placeholder configuration is valid
    static func validateTemplateConfiguration<T: TFType>(_ fieldType: T) -> (isValid: Bool, error: String?) {
        let template = fieldType.template
        let placeholders = fieldType.placeHolders
        
        // Empty template is valid (no template fields)
        if template.isEmpty {
            if !placeholders.isEmpty {
                return (false, "Placeholders defined but no template provided")
            }
            return (true, nil)
        }
        
        // Template exists, must have placeholders
        if placeholders.isEmpty {
            return (false, "Template provided but no placeholders defined")
        }
        
        // Check that template contains at least one placeholder character
        var hasPlaceholderInTemplate = false
        for char in template {
            if placeholders.contains(char) {
                hasPlaceholderInTemplate = true
                break
            }
        }
        
        if !hasPlaceholderInTemplate {
            return (false, "Template does not contain any placeholder characters")
        }
        
        // Check for placeholder character conflicts with common formatting chars
        let commonFormatting = "()-./ "
        for placeholder in placeholders {
            if commonFormatting.contains(placeholder) {
                return (false, "Placeholder '\(placeholder)' conflicts with common formatting characters")
            }
        }
        
        return (true, nil)
    }
    
    // MARK: - Custom Template Creation Helpers
    
    /// Helper for creating custom templates with validation
    /// This helps users create their own field types with proper templates
    struct TemplateBuilder {
        private var template: String = ""
        private var placeholders: String = ""
        
        mutating func setTemplate(_ template: String) -> TemplateBuilder {
            self.template = template
            return self
        }
        
        mutating func setPlaceholders(_ placeholders: String) -> TemplateBuilder {
            self.placeholders = placeholders
            return self
        }
        
        func build() -> (template: String, placeholders: String, isValid: Bool, error: String?) {
            // Create a temporary type for validation
            let tempType = CustomTemplateType(template: template, placeholders: placeholders)
            let validation = TFieldTemplates.validateTemplateConfiguration(tempType)
            
            return (template: template, placeholders: placeholders, isValid: validation.isValid, error: validation.error)
        }
    }
    
    /// Create a new template builder
    static func createTemplate() -> TemplateBuilder {
        return TemplateBuilder()
    }
}

// MARK: - Helper type for template validation
private struct CustomTemplateType: TFType {
    let template: String
    let placeHolders: String
    
    var description: String { "Custom Template" }
    
    init(template: String, placeholders: String) {
        self.template = template
        self.placeHolders = placeholders
    }
}

