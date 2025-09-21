//
//  SwiftUIView.swift
//  XCodeAdditions
//
//  Created by Timothy Riggle on 9/11/25.
//

import SwiftUI

public struct Tfield<T: TBType>: View {
    @Binding var text: String
    var label: String
    var required: Bool
    var type: T
    @State var inputState: InputState = .idle
    @State private var prompt: String
    @FocusState var isFocused: Bool
    @State private var contentPriority: Double = 1.0
    @State private var cachedMinWidth: CGFloat = 120
    
    @Environment(\.tFieldDebugEnabled) private var debugEnabled
    @Environment(\.font) private var environmentFont
    @Environment(\.sizeCategory) private var sizeCategory
    
    // Cached values for performance
    @State private var cachedCapsuleHeight: CGFloat = TFieldConstants.defaultCapsuleHeight
    @State private var cachedScaleFactor: CGFloat = 1.0
    @State private var cachedAlignedFont: Font = .system(.body, design: .monospaced)
    @State private var cachedBaseCapsuleHeight: CGFloat = TFieldConstants.defaultCapsuleHeight

    // Init For TType (built-in types) - allows .cvv, .name, etc.
    public init(
        _ text: Binding<String>, type: TType = .phrase, required: Bool = false,
        label: String = ""
    ) where T == TType {
        self._text = text
        self.type = type
        self.required = required
        self.label = label
        _prompt = State(initialValue: type.template)
    }

    // Init For any other TBType implementation (external by user)- requires explicit typing
    public init(
        _ text: Binding<String>, type: T, required: Bool = false,
        label: String = ""
    ) {
        self._text = text
        self.type = type
        self.required = required
        self.label = label
        _prompt = State(initialValue: type.template)
    }

    public var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .leading) {
                TextFieldView
                requiredIndicator
                floatingLabel
                makeStateMessage()
                makeErrorMessage()
            }

        }
        .frame(height: mainFrameHeight)
        .layoutPriority(contentPriority)
        .animation(.spring(duration: 0.2), value: inputState)
        .animation(.easeInOut(duration: 0.2), value: contentPriority)
        .onChange(of: isFocused) { _, _ in
            updateState()
            updateLayoutPriority()
        }
        .onChange(of: text) { old, newInput in
            updateState()
            updateLayoutPriority()
            updateMinWidth()
        }
        .onChange(of: prompt) { _, _ in
            updateLayoutPriority()
            updateMinWidth()
        }
        .onChange(of: sizeCategory) { _, _ in
            updateCachedValues()
        }
        .onChange(of: environmentFont) { _, _ in
            updateCachedValues()
        }
        .onAppear {
            updateCachedValues()
            formatInputText()
            updateLayoutPriority()
            updateMinWidth()
        }

    }
    private func formatInputText() {  //this will handle any input filtering (like only numbers, or only 3 digits)
        text = TFieldFormatting.reconstruct(type.filter(text), template: type.template, placeHolders: type.placeHolders)
    }

    //MARK: Update State Controller
    private func updateState() {
          var errorMessage: String = ""
          let previousState = inputState
          
          if isFocused {
              formatInputText()
              if type.validateLive(text, &errorMessage) { //focused and valid
                  inputState = .focused(.valid)
              } else {
                  inputState = .focused(.invalid(errorMessage))  // focused and invalid
              }
          } else {
              if text.isEmpty {
                  formatInputText()
                  if required {
                      inputState = .inactive(.invalid("Required Entry")) // Loss of focus, required but empty
                  } else {
                      inputState = .idle  // Loss of focus, optional and empty
                  }
              } else {
                  if type.validateResult(text, &errorMessage) {
                      inputState = .inactive(.valid) // Loss of focus, valid
                  } else {
                      inputState = .inactive(.invalid(errorMessage))  // Loss of focus, invalid
                  }
              }
          }
          
          // CHANGE: Simple conditional logging
          #if DEBUG
          if debugEnabled && inputState != previousState {
              print("TField '\(getLabel())': \(previousState.description) → \(inputState.description)")
          }
          #endif
      }
    
    
    //MARK: Update Layout Priority Controller
    private func updateLayoutPriority() {
        // Higher priority for fields with more content
        let textLength = text.count
        let promptLength = prompt.count
        let totalContent = max(textLength, promptLength)

        // Base priority on content length and type
        contentPriority = 1.0 + (Double(totalContent) * 0.1)

        // Boost priority for fields that are actively being edited
        if isFocused {
            contentPriority += 0.5
        }

        // Special handling for different field types

        if type.fieldPriority < 1.0 {
            // cap the priority for smaller content at 1.2
            contentPriority = min(contentPriority, 1.2)
        } else {
            // priority floor for larger content is 1.3
            contentPriority = max(contentPriority, 1.3)
        }

    }
    private func updateMinWidth() {
        let minChars = max(10, text.count, prompt.count)
        cachedMinWidth = CGFloat(minChars) * 12
    }


}

#Preview {
    TFieldExamples()
}

//MARK: TextFieldView
extension Tfield {
    var TextFieldView: some View {
        ZStack {
            // Custom background that matches across platforms
            Capsule()
                .fill(stateGradient)  // Use system background color
                .stroke(inputState.tintColor, lineWidth: isFocused ? 2 : 1)
                .animation(.easeInOut(duration: 0.2), value: inputState)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            TextField("", text: $text)
                .accessibilityLabel(getLabel())
                .accessibilityValue(text.isEmpty ? "Empty" : text)
                .font(alignedFont)
                #if canImport(UIKit)
                    .keyboardType(type.keyboardType)
                #endif
                .autocorrectionDisabled(true)
                .focused($isFocused)
                #if canImport(AppKit)
                    .textFieldStyle(.plain)
                #endif
                .background(Color.clear)  // Ensure transparent background
                .overlay(alignment: .leading) {
                    createColoredTemplate()
                        .font(alignedFont)
                        .allowsHitTesting(false)
                        .offset(x: templateXOffset)
                        .offset(y: templateYOffset)
                        .onTapGesture {
                            isFocused = true
                        }
                }
                .padding(.horizontal)
        }
        .frame(height: capsuleHeight)
        .frame(minWidth: cachedMinWidth, maxWidth: .infinity)
    }

    // State-responsive gradient:
    var stateGradient: LinearGradient {
        let baseOpacity: Double = isFocused ? 0.08 : 0.04

        switch inputState.validity {
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

    private func createColoredTemplate() -> Text {
        let template = type.template
        let textLength = text.count

        guard !template.isEmpty else {
            return Text("")
        }

        var result = Text("")

        for (index, char) in template.enumerated() {
            if index < textLength {
                // This position is covered by the formatted text - make it clear
                result = result + Text(String(char)).foregroundColor(.clear)
            } else {
                // This position is not covered - show in gray
                result = result + Text(String(char)).foregroundColor(.gray)
            }
        }

        return result
    }
}

extension Tfield {
    var floatingLabel: some View {

        Text(getLabel())
            .padding(.horizontal, 5)
            .background(labelBackground)
            .foregroundStyle(inputState.tintColor)
            .padding(.leading)
            .offset(y: labelOffset)
            .scaleEffect(labelScale)
            .onTapGesture {
                isFocused = true
            }

    }

    var requiredIndicator: some View {

        Text(required ? "*" : "")
            .font(.title)
            .foregroundColor(.red)
            .padding(.horizontal, 5)
            .background(.clear)
            .offset(y: requiredIndicatorOffset)  // Use dynamic offset

    }

    //Dynamic label background
    var labelBackground: Color {
        if isLabelFloating {
            #if canImport(UIKit)
                return Color(UIColor.systemBackground)
            #else
                return Color(NSColor.windowBackgroundColor)
            #endif
        } else {
            return Color.clear
        }

    }
    var isLabelFloating: Bool {
        if case .idle = inputState, text.isEmpty && prompt.isEmpty {
            return false
        }
        return true
    }

    private func getLabel() -> String {
        if label.isEmpty {
            return type.description
        } else {
            return label
        }
    }
}  // floatingLabel

extension Tfield {
    @ViewBuilder
    func makeErrorMessage() -> some View {
        Group {
            if case let .invalid(message) = inputState.validity {
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.leading, 4)
                    .padding(.trailing, 4)

                    .background(errorBackground)
                    .padding(.leading)
                    .offset(y: errorOffset)
                    .offset(x: 10)
                    .padding(.top, 4)
            }
        }
    }
    var errorBackground: Color {

        #if canImport(UIKit)
            return Color(UIColor.systemBackground)
        #else
            return Color(NSColor.windowBackgroundColor)
        #endif

    }
}  // makeErrorMessage

extension Tfield {
    @ViewBuilder
    func makeStateMessage() -> some View {
        #if DEBUG
        if debugEnabled {
            Text(debugDescription)
                .foregroundStyle(inputState.debugDescriptionColor)
                .bold(required)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.leading)
                .offset(y: debugOffset)
                .offset(x: -10)
                .allowsHitTesting(false)
        }
        #endif
    }
    
    private var debugDescription: String {
        "\(String(describing: type)) / \(inputState.description) / P:\(String(format: "%.1f", contentPriority))"
    }
}

extension Tfield {

    var labelOffset: CGFloat {
            switch inputState {
            case .idle where text.isEmpty && prompt.isEmpty:
                return 0
            default:
                return -(cachedCapsuleHeight * TFieldConstants.labelOffsetRatio)
            }
        }

    var labelScale: CGFloat {
        switch inputState {
        case .idle where text.isEmpty && prompt.isEmpty: return 1
        default:
            return 0.85
        }
    }

    var errorOffset: CGFloat {
            switch inputState {
            case .idle where text.isEmpty:
                return 0
            default:
                return cachedCapsuleHeight * TFieldConstants.errorOffsetRatio
            }
        }

    var debugOffset: CGFloat {
            switch inputState {
            case .idle where text.isEmpty && prompt.isEmpty:
                return 0
            case .inactive(.valid) where text.isEmpty && prompt.isEmpty:
                return 0
            case .inactive(.invalid) where text.isEmpty && prompt.isEmpty:
                return 0
            default:
                return -(cachedCapsuleHeight * TFieldConstants.debugOffsetRatio)
            }
        }

    var requiredIndicatorOffset: CGFloat {
            return -(cachedCapsuleHeight * TFieldConstants.requiredOffsetRatio)
        }

    var mainFrameHeight: CGFloat {
        var height: CGFloat = cachedCapsuleHeight
        
        // Always account for error message space (core functionality)
        if hasError {
            height += 0  // Error messages use offset, not additional height
        }
        
        // Only add debug space when debugging is enabled
        #if DEBUG
        if debugEnabled {
            height += 12 * cachedScaleFactor
        }
        #endif
        
        return height
    }

    var hasError: Bool {  //Computed Boolean.  If an error is detected, this will be true
        switch inputState {
        case .focused(.invalid): return true
        case .inactive(.invalid): return true
        default: return false
        }
    }

    var templateXOffset: CGFloat {
        var offset = 0
        #if canImport(UIKit)
            offset = 1
        #else
            offset = 1
        #endif
        return CGFloat(offset)
    }

    var templateYOffset: CGFloat {
        var offset = 0
        #if canImport(UIKit)
            switch inputState {
            case .focused(.invalid), .inactive(.invalid):
                offset = 1
            default:
                offset = 0
            }
        #else
            switch inputState {
            case .focused(.invalid), .inactive(.invalid):
                offset = 0
            default:
                offset = 0
            }

        #endif
        return CGFloat(offset)
    }

    var alignedFont: Font {
        // Always use monospaced design for perfect character alignment
        // Scale the size based on environment font if available
        return cachedAlignedFont
    }
    private func updateCachedValues() {
        cachedScaleFactor = calculateDynamicTypeScaleFactor()
        cachedBaseCapsuleHeight = calculateBaseCapsuleHeight()
        cachedCapsuleHeight = cachedBaseCapsuleHeight * cachedScaleFactor
        cachedAlignedFont = calculateAlignedFont()
    }

    private func calculateDynamicTypeScaleFactor() -> CGFloat {
         switch sizeCategory {
         case .extraSmall:
             return TFieldConstants.DynamicTypeScales.extraSmall
         case .small:
             return TFieldConstants.DynamicTypeScales.small
         case .medium:
             return TFieldConstants.DynamicTypeScales.medium
         case .large:
             return TFieldConstants.DynamicTypeScales.large
         case .extraLarge:
             return TFieldConstants.DynamicTypeScales.extraLarge
         case .extraExtraLarge:
             return TFieldConstants.DynamicTypeScales.extraExtraLarge
         case .extraExtraExtraLarge:
             return TFieldConstants.DynamicTypeScales.extraExtraExtraLarge
         case .accessibilityMedium:
             return TFieldConstants.DynamicTypeScales.accessibilityMedium
         case .accessibilityLarge:
             return TFieldConstants.DynamicTypeScales.accessibilityLarge
         case .accessibilityExtraLarge:
             return TFieldConstants.DynamicTypeScales.accessibilityExtraLarge
         case .accessibilityExtraExtraLarge:
             return TFieldConstants.DynamicTypeScales.accessibilityExtraExtraLarge
         case .accessibilityExtraExtraExtraLarge:
             return TFieldConstants.DynamicTypeScales.accessibilityExtraExtraExtraLarge
         @unknown default:
             return TFieldConstants.DynamicTypeScales.medium
         }
     }
     
     private func calculateBaseCapsuleHeight() -> CGFloat {
         if let envFont = environmentFont {
             switch envFont {
             case .largeTitle:
                 return TFieldConstants.FontHeights.largeTitle
             case .title:
                 return TFieldConstants.FontHeights.title
             case .title2:
                 return TFieldConstants.FontHeights.title2
             case .title3:
                 return TFieldConstants.FontHeights.title3
             case .headline:
                 return TFieldConstants.FontHeights.headline
             case .subheadline:
                 return TFieldConstants.FontHeights.subheadline
             case .body:
                 return TFieldConstants.FontHeights.body
             case .callout:
                 return TFieldConstants.FontHeights.callout
             case .footnote:
                 return TFieldConstants.FontHeights.footnote
             case .caption:
                 return TFieldConstants.FontHeights.caption
             case .caption2:
                 return TFieldConstants.FontHeights.caption2
             default:
                 return TFieldConstants.defaultCapsuleHeight
             }
         } else {
             return TFieldConstants.defaultCapsuleHeight
         }
     }
     
     private func calculateAlignedFont() -> Font {
         if let envFont = environmentFont {
             switch envFont {
             case .largeTitle:
                 return .system(.largeTitle, design: .monospaced)
             case .title:
                 return .system(.title, design: .monospaced)
             case .title2:
                 return .system(.title2, design: .monospaced)
             case .title3:
                 return .system(.title3, design: .monospaced)
             case .headline:
                 return .system(.headline, design: .monospaced)
             case .subheadline:
                 return .system(.subheadline, design: .monospaced)
             case .callout:
                 return .system(.callout, design: .monospaced)
             case .footnote:
                 return .system(.footnote, design: .monospaced)
             case .caption:
                 return .system(.caption, design: .monospaced)
             case .caption2:
                 return .system(.caption2, design: .monospaced)
             default:
                 return .system(.body, design: .monospaced)
             }
         } else {
             return .system(.body, design: .monospaced)
         }
     }
 


    var capsuleHeight: CGFloat {
        // Get the base height from font style
        return cachedCapsuleHeight
    }
    var dynamicTypeScaleFactor: CGFloat {
        return cachedScaleFactor
    }

}  // offset calculations for floating elements
