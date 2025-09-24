//
//  TFieldFonts.swift
//  TField
//
//  Created by Timothy Riggle on 9/22/25.
//

import SwiftUI

// MARK: - Font Calculation and Sizing Utilities

struct TFieldFonts {
    
    // MARK: - Dynamic Type Scale Factor Calculations
    
    /// Calculate the scale factor for Dynamic Type accessibility
    static func calculateDynamicTypeScaleFactor(_ sizeCategory: ContentSizeCategory) -> CGFloat {
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
    
    // MARK: - Base Capsule Height Calculations
    
    /// Calculate the base capsule height before Dynamic Type scaling
    static func calculateBaseCapsuleHeight(_ environmentFont: Font?) -> CGFloat {
        guard let envFont = environmentFont else {
            return TFieldConstants.defaultCapsuleHeight
        }
        
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
    }
    
    // MARK: - Aligned Font Calculations (for templates)
    
    /// Calculate the aligned monospaced font for template fields
    static func calculateAlignedFont(_ environmentFont: Font?) -> Font {
        guard let envFont = environmentFont else {
            return .system(.body, design: .monospaced)
        }
        
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
    }
    
    // MARK: - Complete Font Configuration
    
    /// Complete font configuration structure for a field
    struct FontConfiguration {
        let alignedFont: Font
        let baseCapsuleHeight: CGFloat
        let scaleFactor: CGFloat
        let scaledCapsuleHeight: CGFloat
        
        init(environmentFont: Font?, sizeCategory: ContentSizeCategory) {
            self.alignedFont = TFieldFonts.calculateAlignedFont(environmentFont)
            self.baseCapsuleHeight = TFieldFonts.calculateBaseCapsuleHeight(environmentFont)
            self.scaleFactor = TFieldFonts.calculateDynamicTypeScaleFactor(sizeCategory)
            self.scaledCapsuleHeight = baseCapsuleHeight * scaleFactor
        }
    }
    
    /// Calculate complete font configuration in one call
    static func calculateFontConfiguration(
        environmentFont: Font?,
        sizeCategory: ContentSizeCategory
    ) -> FontConfiguration {
        return FontConfiguration(environmentFont: environmentFont, sizeCategory: sizeCategory)
    }
    
    // MARK: - Width Estimation Utilities
    
    /// Calculate minimum width based on content length
    static func calculateMinWidth(textCount: Int, promptCount: Int) -> CGFloat {
        let minChars = max(10, textCount, promptCount)
        return CGFloat(minChars) * 12
    }
    
    /// Estimate character width for monospaced fonts (used for templates)
    static func estimateMonospacedCharWidth(for font: Font) -> CGFloat {
        // Base estimate - could be refined with actual text measurement
        switch font {
        case .largeTitle, .system(.largeTitle, design: .monospaced):
            return 20
        case .title, .system(.title, design: .monospaced):
            return 18
        case .title2, .system(.title2, design: .monospaced):
            return 16
        case .title3, .system(.title3, design: .monospaced):
            return 14
        case .headline, .system(.headline, design: .monospaced):
            return 14
        case .subheadline, .system(.subheadline, design: .monospaced):
            return 12
        case .callout, .system(.callout, design: .monospaced):
            return 11
        case .footnote, .system(.footnote, design: .monospaced):
            return 10
        case .caption, .system(.caption, design: .monospaced):
            return 9
        case .caption2, .system(.caption2, design: .monospaced):
            return 8
        default:
            return 12 // body default
        }
    }
}
