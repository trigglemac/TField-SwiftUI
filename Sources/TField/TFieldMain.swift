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
    @State private var contentPriority: Double = 1.0

    @Environment(\.tFieldDebugEnabled) private var debugEnabled
    @Environment(\.font) private var environmentFont
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.tFieldGroupManager) private var groupManager

    // Cached values for performance
    @State private var cache = TFieldCoreUtilities.FieldCache()

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

            // Register with group manager if part of a group and manager is available
            if let group = group, let manager = groupManager {
                var errorMessage = ""
                let isValid: Bool

                if text.isEmpty {
                    isValid = !required
                } else {
                    isValid = type.validateResult(text, &errorMessage)
                }

                TFieldCoreUtilities.updateGroupManager(
                    groupManager: manager,
                    group: group,
                    fieldId: fieldId,
                    isValid: isValid
                )
            }
        }
        .onDisappear {
            // Unregister from group manager
            TFieldCoreUtilities.cleanupGroupManager(
                groupManager: groupManager,
                group: group,
                fieldId: fieldId
            )
        }
    }
    private func formatInputText() {
        text = TFieldTemplates.reconstruct(
            type.filter(text),
            template: type.template,
            placeHolders: type.placeHolders
        )
    }

    //MARK: Update State Controller
    private func updateState() {
        
        let previousState = inputState

        if isFocused {
            formatInputText()
        }
        if text.isEmpty && !isFocused {
            formatInputText()
        }

        inputState = TFieldCoreUtilities.calculateInputState(
            isFocused: isFocused,
            text: text,
            fieldType: type,
            required: required
        )

        // Update group manager if field belongs to a group and manager is available
        TFieldCoreUtilities.updateGroupManager(
            groupManager: groupManager,
            group: group,
            fieldId: fieldId,
            isValid: submissionValid
        )

        // CHANGE: Simple conditional logging
        TFieldCoreUtilities.logStateChange(
            fieldType: type,
            label: getLabel(),
            from: previousState,
            to: inputState,
            enabled: debugEnabled
        )
    }
    private var submissionValid: Bool {
        return TFieldCoreUtilities.isSubmissionValid(
            inputState: inputState,
            text: text,
            fieldType: type,
            required: required
        )
    }

    //MARK: Update Layout Priority Controller
    private func updateLayoutPriority() {
        contentPriority = TFieldCoreUtilities.calculateLayoutPriority(
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
            fieldType: type,
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
        TFieldCoreUtilities.debugDescription(
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
