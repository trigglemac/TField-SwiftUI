//
//  TFieldCache.swift
//  TField
//
//  Created by cache structure extraction
//

import SwiftUI

// MARK: - Performance Cache for TField and TBox Components

/// Consolidated cache structure for field calculations and performance optimization
struct TFieldCache {
    // Font and sizing cache
    var capsuleHeight: CGFloat
    var scaleFactor: CGFloat
    var alignedFont: Font
    var baseCapsuleHeight: CGFloat
    
    // Layout cache
    var minWidth: CGFloat
    var lastTextLength: Int
    
    // MARK: - Initialization
    
    init() {
        self.capsuleHeight = TFieldConstants.defaultCapsuleHeight
        self.scaleFactor = 1.0
        self.alignedFont = .system(.body, design: .monospaced)
        self.baseCapsuleHeight = TFieldConstants.defaultCapsuleHeight
        self.minWidth = 120
        self.lastTextLength = 0
    }
    
    // MARK: - Cache Update Methods
    
    /// Update all font-related values at once for efficiency
    mutating func updateFontValues(
        environmentFont: Font?,
        sizeCategory: ContentSizeCategory
    ) {
        // Calculate all new values first (don't modify cache yet)
        let config = TFieldFonts.calculateFontConfiguration(
            environmentFont: environmentFont,
            sizeCategory: sizeCategory
        )
        
        // Atomic update - all at once
        (self.alignedFont, self.baseCapsuleHeight, self.scaleFactor, self.capsuleHeight) = (
            config.alignedFont,
            config.baseCapsuleHeight,
            config.scaleFactor,
            config.scaledCapsuleHeight
        )
    }
    
    /// Update width cache only when text length changes significantly
    mutating func updateWidthIfNeeded(textCount: Int, templateCount: Int) {
        let currentLength = max(textCount, templateCount)
        if abs(currentLength - lastTextLength) > 2 { // Only recalculate for significant changes
            self.minWidth = TFieldCore.calculateMinWidth(
                textCount: textCount,
                templateCount: templateCount
            )
            self.lastTextLength = currentLength
        }
    }
    
    // MARK: - Cache Validation
    
    /// Validate that cache values are within expected ranges
    var isValid: Bool {
        return capsuleHeight > 0 &&
               scaleFactor > 0 &&
               minWidth > 0 &&
               baseCapsuleHeight > 0
    }
    
    // MARK: - Debug Support
    
    #if DEBUG
    /// Debug description of cache state
    var debugDescription: String {
        return """
        TFieldCache:
          - Capsule Height: \(capsuleHeight)
          - Scale Factor: \(scaleFactor)
          - Base Height: \(baseCapsuleHeight)
          - Min Width: \(minWidth)
          - Last Text Length: \(lastTextLength)
          - Valid: \(isValid)
        """
    }
    #endif
}

// MARK: - Cache Factory Methods

extension TFieldCache {
    
    /// Create cache with immediate font configuration
    static func configured(
        environmentFont: Font?,
        sizeCategory: ContentSizeCategory
    ) -> TFieldCache {
        var cache = TFieldCache()
        cache.updateFontValues(
            environmentFont: environmentFont,
            sizeCategory: sizeCategory
        )
        return cache
    }
}
