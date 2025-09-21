//
//  SwiftUIView.swift
//  TField
//
//  Created by Timothy Riggle on 9/21/25.
//

struct TFieldFormatting {
    static func reconstruct(_ input: String, template: String, placeHolders: String) -> String {
        // input is a data string stripped of any formatting, and guaranteed to be between 0 and max characters
        // additionally, the characters are guaranteed to be of the specified type (for instance numbers for a zip code or phone number


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

}
