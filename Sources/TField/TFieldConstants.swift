//
//  TFieldConstants
//  TField
//
//  Created by Timothy Riggle on 9/18/25.
//

import SwiftUI


// MARK: - Constants
 struct TFieldConstants {
    static let defaultCapsuleHeight: CGFloat = 55
    static let labelOffsetRatio: CGFloat = 0.58        // 32/55 ≈ 0.58
    static let errorOffsetRatio: CGFloat = 0.33        // 18/55 ≈ 0.33
    static let debugOffsetRatio: CGFloat = 0.65        // 36/55 ≈ 0.65
    static let requiredOffsetRatio: CGFloat = 0.44     // 24/55 ≈ 0.44
    
    // Font size to height mapping
    struct FontHeights {
        static let largeTitle: CGFloat = 70
        static let title: CGFloat = 65
        static let title2: CGFloat = 60
        static let title3: CGFloat = 55
        static let headline: CGFloat = 55
        static let subheadline: CGFloat = 48
        static let body: CGFloat = 48
        static let callout: CGFloat = 45
        static let footnote: CGFloat = 42
        static let caption: CGFloat = 35
        static let caption2: CGFloat = 35
    }
    
    // Dynamic Type scale factors
    struct DynamicTypeScales {
        static let extraSmall: CGFloat = 0.85
        static let small: CGFloat = 0.90
        static let medium: CGFloat = 1.0
        static let large: CGFloat = 1.0
        static let extraLarge: CGFloat = 1.1
        static let extraExtraLarge: CGFloat = 1.2
        static let extraExtraExtraLarge: CGFloat = 1.3
        static let accessibilityMedium: CGFloat = 1.4
        static let accessibilityLarge: CGFloat = 1.6
        static let accessibilityExtraLarge: CGFloat = 1.8
        static let accessibilityExtraExtraLarge: CGFloat = 2.0
        static let accessibilityExtraExtraExtraLarge: CGFloat = 2.2
    }
}
