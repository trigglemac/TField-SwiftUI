//
//  SwiftUIView.swift
//  XCodeAdditions
//
//  Created by Timothy Riggle on 9/11/25.
//

import SwiftUI

public struct Tfield<T: TFType>: View {
    @Binding var text: String
    var label: String
    var required: Bool
    var type: T
    var group: String?
    @State private var fieldId = UUID().uuidString
    @State var inputState: InputState = .idle
    @State private var prompt: String
    @FocusState var isFocused: Bool
    @State private var previousFocusState: Bool = false
    @State private var isFinalized: Bool = false
    @State private var contentPriority: Double = 1.0
    
    @State private var lastExpansionState: Bool? = nil

    @Environment(\.tFieldDebugEnabled) private var debugEnabled
    @Environment(\.font) private var environmentFont
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.tFieldGroupManager) private var groupManager

    // Cached values for performance
    @State private var cache = TFieldCache()

    // Init For TType (built-in types) - allows .cvv, .name, etc.
    public init(
        _ text: Binding<String>,
        type: TType = .phrase,
        required: Bool = false,
        label: String = "",
        group: String? = nil
    ) where T == TType {
        self._text = text
        self.type = type
        self.required = required
        self.label = label
        self.group = group
        _prompt = State(initialValue: type.template)
    }

    // Init For any other TFType implementation (external by user)- requires explicit typing
    public init(
        _ text: Binding<String>,
        type: T,
        required: Bool = false,
        label: String = "",
        group: String? = nil
    ) {
        self._text = text
        self.type = type
        self.required = required
        self.label = label
        self.group = group
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
            lastExpansionState = TFieldCore.determineExpansionState(oldText: old, newText: newInput)
                
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

            // Register with group manager - utility handles nil values
            let isValid: Bool
            if text.isEmpty {
                isValid = !required
            } else {
                var errorMessage = ""
                isValid = type.validateResult(text, &errorMessage)
            }

            TFieldCore.updateGroupManager(
                groupManager: groupManager,
                group: group,
                fieldId: fieldId,
                isValid: isValid
            )
        }
        .onDisappear {
            // Unregister from group manager
            TFieldCore.cleanupGroupManager(
                groupManager: groupManager,
                group: group,
                fieldId: fieldId
            )
        }
    }
    private func formatInputText() {
        // Don't process finalized text to avoid corrupting trailing formatting
        guard !isFinalized else {
            return
        }
        
        // Step 1: Check for dynamic template and update if needed
        let newTemplate = TFieldCore.applyDynamicTemplate(
            fieldType: type,
            rawInput: text,
            currentTemplate: prompt
        )
        
        // Update prompt if template changed
        if newTemplate != prompt {
            prompt = newTemplate
        }
        
        // Step 2: Apply filter and reconstruct as usual
        // Note: We don't have access to old text here, so pass nil
        text = TFieldTemplates.reconstruct(
            type.filter(text, lastExpansionState),
            template: prompt,
            placeHolders: type.placeHolders
        )
    }

    //MARK: Update State Controller
    private func updateState() {
        let previousState = inputState
        
        // Create focus state objects for enum-based transition handling
        let previousFocusState = TFieldFocusState(isFocused: self.previousFocusState)
        let currentFocusState = TFieldFocusState(isFocused: isFocused)
        
        // Handle focus transitions using the new enum-based system
        let transitionResult = TFieldCore.handleFocusTransition(
            previousFocusState: previousFocusState,
            currentFocusState: currentFocusState,
            text: &text,
            isFinalized: &isFinalized,
            fieldType: type,
            prompt: &prompt
        )
        
        // Update focus state tracking
        self.previousFocusState = isFocused
        
        // Handle transition results
        switch transitionResult {
        case .validationFailed(let error):
            inputState = .inactive(.invalid(error))
            // Update group manager
            TFieldCore.updateGroupManager(
                groupManager: groupManager,
                group: group,
                fieldId: fieldId,
                isValid: submissionValid
            )
            // Log the state change
            TFieldCore.logStateChange(
                fieldType: type,
                label: getLabel(),
                from: previousState,
                to: inputState,
                enabled: debugEnabled
            )
            return
            
        case .gainingFocus, .losingFocus:
            // For focus transitions, the handleFocusTransition already handled text processing
            break
            
        case .keepsFocus, .staysInactive:
            // For non-transition cases, apply normal formatting if not finalized
            if !isFinalized {
                formatInputText()
            }
        }
        
        // Calculate new input state
        inputState = TFieldCore.calculateInputState(
            isFocused: isFocused,
            text: text,
            fieldType: type,
            required: required
        )

        // Update group manager if field belongs to a group and manager is available
        TFieldCore.updateGroupManager(
            groupManager: groupManager,
            group: group,
            fieldId: fieldId,
            isValid: submissionValid
        )

        // Log state changes
        TFieldCore.logStateChange(
            fieldType: type,
            label: getLabel(),
            from: previousState,
            to: inputState,
            enabled: debugEnabled
        )
    }
    private var submissionValid: Bool {
        return TFieldCore.isSubmissionValid(
            inputState: inputState,
            text: text,
            fieldType: type,
            required: required
        )
    }

    //MARK: Update Layout Priority Controller
    private func updateLayoutPriority() {
        contentPriority = TFieldCore.calculateLayoutPriority(
            text: text,
            template: prompt,
            fieldType: type,
            isFocused: isFocused
        )
    }
    private func updateMinWidth() {
        cache.updateWidthIfNeeded(textCount: text.count, templateCount: prompt.count)
    }


}

#Preview("Main") {
    TFieldExamples()
}
#Preview("Group") {
    TFieldGroupTest()
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
        .frame(minWidth: cache.minWidth, maxWidth: .infinity)
    }

    // State-responsive gradient:
    var stateGradient: LinearGradient {
        return TFieldUtils.calculateStateGradient(validity: inputState.validity, isFocused: isFocused)
    }
    
    private func createColoredTemplate() -> Text {
        return TFieldTemplates.createColoredTemplate(
            customTemplate: prompt,  // Use dynamic prompt instead of static type.template
            currentTextLength: text.count
        )
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
        return TFieldUtils.getLabelBackground(isFloating: isLabelFloating)
    }
    
    var isLabelFloating: Bool {
        return TFieldPositioning.isLabelFloating(
            inputState: inputState,
            text: text,
            prompt: prompt
        )
    }

    private func getLabel() -> String {
        return TFieldUtils.getDisplayLabel(customLabel: label, fieldType: type)
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
        return TFieldUtils.getErrorBackground()
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
        TFieldCore.debugDescription(
            fieldType: type,
            inputState: inputState,
            contentPriority: contentPriority
        )
    }
}

extension Tfield {

    var labelOffset: CGFloat {
        return TFieldPositioning.calculateLabelOffset(
            inputState: inputState,
            text: text,
            prompt: prompt,
            capsuleHeight: cache.capsuleHeight
        )
    }

    var labelScale: CGFloat {
        return TFieldPositioning.calculateLabelScale(
            inputState: inputState,
            text: text,
            prompt: prompt
        )
    }

    var errorOffset: CGFloat {
        return TFieldPositioning.calculateErrorOffset(
            inputState: inputState,
            text: text,
            capsuleHeight: cache.capsuleHeight
        )
    }


    var debugOffset: CGFloat {
        return TFieldPositioning.calculateDebugOffset(
            inputState: inputState,
            text: text,
            prompt: prompt,
            capsuleHeight: cache.capsuleHeight
        )
    }

    var requiredIndicatorOffset: CGFloat {
        return TFieldPositioning.calculateRequiredIndicatorOffset(
            capsuleHeight: cache.capsuleHeight
        )
    }


    var mainFrameHeight: CGFloat {
        return TFieldPositioning.calculateMainFrameHeight(
            capsuleHeight: cache.capsuleHeight,
            scaleFactor: cache.scaleFactor,
            hasError: hasError,
            debugEnabled: debugEnabled
        )
    }

    var hasError: Bool {
        return TFieldPositioning.hasError(inputState: inputState)
    }

    var templateXOffset: CGFloat {
        return TFieldPositioning.calculateTemplateXOffset(
            inputState: inputState
        )
    }

    var templateYOffset: CGFloat {
        return TFieldPositioning.calculateTemplateYOffset(
            inputState: inputState
        )
    }

    var alignedFont: Font {
        return cache.alignedFont
    }
    
    private func updateCachedValues() {
        cache.updateFontValues(
            environmentFont: environmentFont,
            sizeCategory: sizeCategory
        )
    }

    var capsuleHeight: CGFloat {
        return cache.capsuleHeight
    }
    var dynamicTypeScaleFactor: CGFloat {
        return cache.scaleFactor
    }


}  // offset calculations for floating elements



