//
//  TFieldConstantsTests.swift
//  TFieldTests
//
//  Created by Timothy Riggle on 9/20/25.
//

import XCTest
@testable import TField

final class TFieldConstantsTests: XCTestCase {
    
    // MARK: - Default Height Tests
    
    func testDefaultCapsuleHeight() {
        // Default height should be reasonable for UI elements
        XCTAssertGreaterThan(TFieldConstants.defaultCapsuleHeight, 30.0,
                            "Default height too small for touch targets")
        XCTAssertLessThan(TFieldConstants.defaultCapsuleHeight, 100.0,
                         "Default height too large for typical UI")
        
        // Should be a reasonable value (55 is expected)
        XCTAssertEqual(TFieldConstants.defaultCapsuleHeight, 55.0, accuracy: 0.1)
    }
    
    // MARK: - Offset Ratio Tests
    
    func testOffsetRatios() {
        // All ratios should be between 0 and 1
        XCTAssertGreaterThan(TFieldConstants.labelOffsetRatio, 0.0)
        XCTAssertLessThan(TFieldConstants.labelOffsetRatio, 1.0)
        
        XCTAssertGreaterThan(TFieldConstants.errorOffsetRatio, 0.0)
        XCTAssertLessThan(TFieldConstants.errorOffsetRatio, 1.0)
        
        XCTAssertGreaterThan(TFieldConstants.debugOffsetRatio, 0.0)
        XCTAssertLessThan(TFieldConstants.debugOffsetRatio, 1.0)
        
        XCTAssertGreaterThan(TFieldConstants.requiredOffsetRatio, 0.0)
        XCTAssertLessThan(TFieldConstants.requiredOffsetRatio, 1.0)
        
        // Test specific expected values
        XCTAssertEqual(TFieldConstants.labelOffsetRatio, 0.58, accuracy: 0.01)
        XCTAssertEqual(TFieldConstants.errorOffsetRatio, 0.33, accuracy: 0.01)
        XCTAssertEqual(TFieldConstants.debugOffsetRatio, 0.65, accuracy: 0.01)
        XCTAssertEqual(TFieldConstants.requiredOffsetRatio, 0.44, accuracy: 0.01)
    }
    
    func testOffsetRatioRelationships() {
        // Label should be higher than debug (further from center)
        XCTAssertLessThan(TFieldConstants.labelOffsetRatio, TFieldConstants.debugOffsetRatio,
                         "Label should appear above debug info")
        
        // Required indicator should be between label and debug
        XCTAssertGreaterThan(TFieldConstants.requiredOffsetRatio, TFieldConstants.errorOffsetRatio,
                            "Required indicator should be higher than error")
        XCTAssertLessThan(TFieldConstants.requiredOffsetRatio, TFieldConstants.labelOffsetRatio,
                         "Required indicator should be lower than label")
    }
    
    // MARK: - Font Height Tests
    
    func testFontHeightProgression() {
        let fontHeights = TFieldConstants.FontHeights.self
        
        // Heights should progress logically from smallest to largest
        XCTAssertEqual(fontHeights.caption2, fontHeights.caption)
        XCTAssertLessThan(fontHeights.caption, fontHeights.footnote)
        XCTAssertLessThan(fontHeights.footnote, fontHeights.callout)
        XCTAssertLessThan(fontHeights.callout, fontHeights.body)
        
        // Note: body and subheadline are the same height (48)
        XCTAssertEqual(fontHeights.body, fontHeights.subheadline)
        
        XCTAssertLessThan(fontHeights.subheadline, fontHeights.headline)
        
        // Note: headline and title3 are the same height (55)
        XCTAssertEqual(fontHeights.headline, fontHeights.title3)
        
        XCTAssertLessThan(fontHeights.title3, fontHeights.title2)
        XCTAssertLessThan(fontHeights.title2, fontHeights.title)
        XCTAssertLessThan(fontHeights.title, fontHeights.largeTitle)
    }
    
    func testFontHeightReasonableValues() {
        let fontHeights = TFieldConstants.FontHeights.self
        
        // All heights should be reasonable for UI
        let allHeights = [
            fontHeights.largeTitle, fontHeights.title, fontHeights.title2,
            fontHeights.title3, fontHeights.headline, fontHeights.subheadline,
            fontHeights.body, fontHeights.callout, fontHeights.footnote,
            fontHeights.caption, fontHeights.caption2
        ]
        
        for height in allHeights {
            XCTAssertGreaterThan(height, 20.0, "Font height too small: \(height)")
            XCTAssertLessThan(height, 100.0, "Font height too large: \(height)")
        }
        
        // Test specific expected values
        XCTAssertEqual(fontHeights.largeTitle, 70.0)
        XCTAssertEqual(fontHeights.body, 48.0)
        XCTAssertEqual(fontHeights.caption2, 35.0)
    }
    
    func testFontHeightConsistency() {
        let fontHeights = TFieldConstants.FontHeights.self
        
        // Some fonts should have the same height (based on your constants)
        XCTAssertEqual(fontHeights.title3, fontHeights.headline)
        XCTAssertEqual(fontHeights.body, fontHeights.subheadline)
        XCTAssertEqual(fontHeights.caption, fontHeights.caption2)
        
        // Default should match one of the standard sizes
        XCTAssertEqual(TFieldConstants.defaultCapsuleHeight, fontHeights.title3)
    }
    
    // MARK: - Dynamic Type Scale Tests
    
    func testDynamicTypeScaleProgression() {
        let scales = TFieldConstants.DynamicTypeScales.self
        
        // Scales should progress from smallest to largest
        XCTAssertLessThan(scales.extraSmall, scales.small)
        XCTAssertLessThan(scales.small, scales.medium)
        XCTAssertLessThanOrEqual(scales.medium, scales.large) // These are equal
        XCTAssertLessThan(scales.large, scales.extraLarge)
        XCTAssertLessThan(scales.extraLarge, scales.extraExtraLarge)
        XCTAssertLessThan(scales.extraExtraLarge, scales.extraExtraExtraLarge)
        XCTAssertLessThan(scales.extraExtraExtraLarge, scales.accessibilityMedium)
        XCTAssertLessThan(scales.accessibilityMedium, scales.accessibilityLarge)
        XCTAssertLessThan(scales.accessibilityLarge, scales.accessibilityExtraLarge)
        XCTAssertLessThan(scales.accessibilityExtraLarge, scales.accessibilityExtraExtraLarge)
        XCTAssertLessThan(scales.accessibilityExtraExtraLarge, scales.accessibilityExtraExtraExtraLarge)
    }
    
    func testDynamicTypeScaleReasonableValues() {
        let scales = TFieldConstants.DynamicTypeScales.self
        
        let allScales = [
            scales.extraSmall, scales.small, scales.medium, scales.large,
            scales.extraLarge, scales.extraExtraLarge, scales.extraExtraExtraLarge,
            scales.accessibilityMedium, scales.accessibilityLarge, scales.accessibilityExtraLarge,
            scales.accessibilityExtraExtraLarge, scales.accessibilityExtraExtraExtraLarge
        ]
        
        for scale in allScales {
            XCTAssertGreaterThan(scale, 0.5, "Scale factor too small: \(scale)")
            XCTAssertLessThan(scale, 3.0, "Scale factor too large: \(scale)")
        }
        
        // Medium should be baseline
        XCTAssertEqual(scales.medium, 1.0)
        XCTAssertEqual(scales.large, 1.0) // These should be the same
        
        // Test specific expected values
        XCTAssertEqual(scales.extraSmall, 0.85, accuracy: 0.01)
        XCTAssertEqual(scales.accessibilityExtraExtraExtraLarge, 2.2, accuracy: 0.01)
    }
    
    func testDynamicTypeScaleAccessibilityRange() {
        let scales = TFieldConstants.DynamicTypeScales.self
        
        // Accessibility scales should provide meaningful size increases
        let standardMax = scales.extraExtraExtraLarge
        let accessibilityMin = scales.accessibilityMedium
        
        XCTAssertGreaterThan(accessibilityMin, standardMax,
                            "Accessibility sizes should be larger than standard")
        
        // Accessibility range should be reasonable
        let accessibilityRange = scales.accessibilityExtraExtraExtraLarge - scales.accessibilityMedium
        XCTAssertGreaterThan(accessibilityRange, 0.5,
                            "Accessibility range should provide meaningful variation")
        XCTAssertLessThan(accessibilityRange, 1.5,
                         "Accessibility range shouldn't be excessive")
    }
    
    // MARK: - Calculated Values Tests
    
    func testCalculatedOffsets() {
        let defaultHeight = TFieldConstants.defaultCapsuleHeight
        
        // Test that calculated offsets are reasonable
        let labelOffset = defaultHeight * TFieldConstants.labelOffsetRatio
        XCTAssertGreaterThan(labelOffset, 15.0, "Label offset too small")
        XCTAssertLessThan(labelOffset, 50.0, "Label offset too large")
        
        let errorOffset = defaultHeight * TFieldConstants.errorOffsetRatio
        XCTAssertGreaterThan(errorOffset, 10.0, "Error offset too small")
        XCTAssertLessThan(errorOffset, 30.0, "Error offset too large")
        
        let debugOffset = defaultHeight * TFieldConstants.debugOffsetRatio
        XCTAssertGreaterThan(debugOffset, 20.0, "Debug offset too small")
        XCTAssertLessThan(debugOffset, 50.0, "Debug offset too large")
        
        let requiredOffset = defaultHeight * TFieldConstants.requiredOffsetRatio
        XCTAssertGreaterThan(requiredOffset, 15.0, "Required offset too small")
        XCTAssertLessThan(requiredOffset, 40.0, "Required offset too large")
    }
    
    func testScaledHeights() {
        let baseHeight = TFieldConstants.FontHeights.body
        
        // Test scaling with different dynamic type scales
        let smallScaled = baseHeight * TFieldConstants.DynamicTypeScales.small
        let largeScaled = baseHeight * TFieldConstants.DynamicTypeScales.accessibilityLarge
        
        XCTAssertLessThan(smallScaled, baseHeight)
        XCTAssertGreaterThan(largeScaled, baseHeight)
        
        // Scaled values should still be reasonable
        XCTAssertGreaterThan(smallScaled, 25.0, "Smallest scaled size still usable")
        XCTAssertLessThan(largeScaled, 150.0, "Largest scaled size not excessive")
    }
    
    // MARK: - Cross-Platform Consistency Tests
    
    func testPlatformIndependentValues() {
        // These values should be consistent across platforms
        XCTAssertEqual(TFieldConstants.defaultCapsuleHeight, 55.0)
        XCTAssertEqual(TFieldConstants.labelOffsetRatio, 0.58, accuracy: 0.01)
        XCTAssertEqual(TFieldConstants.DynamicTypeScales.medium, 1.0)
        
        // Font heights should be platform-independent
        XCTAssertEqual(TFieldConstants.FontHeights.body, 48.0)
        XCTAssertEqual(TFieldConstants.FontHeights.largeTitle, 70.0)
    }
    
    // MARK: - Mathematical Relationship Tests
    
    func testProportionalRelationships() {
        // Test that ratios create proportional relationships
        let height1 = TFieldConstants.FontHeights.caption
        let height2 = TFieldConstants.FontHeights.body
        let height3 = TFieldConstants.FontHeights.largeTitle
        
        // Larger fonts should have proportionally larger calculated offsets
        let offset1 = height1 * TFieldConstants.labelOffsetRatio
        let offset2 = height2 * TFieldConstants.labelOffsetRatio
        let offset3 = height3 * TFieldConstants.labelOffsetRatio
        
        XCTAssertLessThan(offset1, offset2)
        XCTAssertLessThan(offset2, offset3)
        
        // Ratios should maintain proportionality
        let ratio1 = offset2 / offset1
        let ratio2 = height2 / height1
        XCTAssertEqual(ratio1, ratio2, accuracy: 0.01,
                      "Offsets should scale proportionally with heights")
    }
    
    // MARK: - UI Guidelines Compliance Tests
    
    func testAppleHIGCompliance() {
        // Test compliance with Apple Human Interface Guidelines
        
        // Minimum touch target size (44 points)
        let minTouchTarget: CGFloat = 44.0
        XCTAssertGreaterThanOrEqual(TFieldConstants.defaultCapsuleHeight, minTouchTarget,
                                   "Default height meets minimum touch target size")
        
        // All font heights should meet minimum accessibility requirements
        let minAccessibleSize: CGFloat = 30.0
        let allHeights = [
            TFieldConstants.FontHeights.caption2,
            TFieldConstants.FontHeights.caption,
            TFieldConstants.FontHeights.footnote
        ]
        
        for height in allHeights {
            XCTAssertGreaterThanOrEqual(height, minAccessibleSize,
                                       "Font height \(height) meets minimum accessibility size")
        }
    }
    
    func testAccessibilityScaling() {
        // Test that maximum accessibility scaling doesn't break UI
        let baseHeight = TFieldConstants.defaultCapsuleHeight
        let maxScale = TFieldConstants.DynamicTypeScales.accessibilityExtraExtraExtraLarge
        let maxScaledHeight = baseHeight * maxScale
        
        // Should still be usable but not excessive
        XCTAssertLessThan(maxScaledHeight, 200.0,
                         "Maximum scaled height doesn't break UI layout")
        XCTAssertGreaterThan(maxScaledHeight, 80.0,
                            "Maximum scaled height provides meaningful increase")
    }
    
    // MARK: - Performance Impact Tests
    
    func testCalculationPerformance() {
        // Test that constant calculations are fast
        measure {
            for _ in 0..<10000 {
                let _ = TFieldConstants.defaultCapsuleHeight * TFieldConstants.labelOffsetRatio
                let _ = TFieldConstants.FontHeights.body * TFieldConstants.DynamicTypeScales.large
            }
        }
    }
    
    // MARK: - Validation of Design Intent Tests
    
    func testDesignIntentValidation() {
        // Test that constants reflect reasonable design decisions
        
        // Label should appear above the field center
        let labelOffset = TFieldConstants.defaultCapsuleHeight * TFieldConstants.labelOffsetRatio
        let fieldCenter = TFieldConstants.defaultCapsuleHeight / 2
        XCTAssertGreaterThan(labelOffset, fieldCenter * 0.8,
                            "Label appears sufficiently above center")
        
        // Error should appear below the field
        let errorOffset = TFieldConstants.defaultCapsuleHeight * TFieldConstants.errorOffsetRatio
        XCTAssertLessThan(errorOffset, fieldCenter,
                         "Error appears below field center")
        
        // Debug info should be clearly separated from label
        let debugOffset = TFieldConstants.defaultCapsuleHeight * TFieldConstants.debugOffsetRatio
        let separation = debugOffset - labelOffset
        XCTAssertGreaterThan(abs(separation), 3.0,
                            "Debug info has clear separation from label")
    }
}
