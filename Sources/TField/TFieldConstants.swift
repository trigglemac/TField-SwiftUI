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
    static let labelOffsetRatio: CGFloat = 0.58  // 32/55 ≈ 0.58
    static let errorOffsetRatio: CGFloat = 0.33  // 18/55 ≈ 0.33
    static let debugOffsetRatio: CGFloat = 0.65  // 36/55 ≈ 0.65
    static let requiredOffsetRatio: CGFloat = 0.44  // 24/55 ≈ 0.44

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

let validStateCodes = [
    // 50 States
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
    // District and Territories
    "DC", "AS", "GU", "MP", "PR", "VI"
]
let oldStyleAbbreviations = [
    // States
    "ALA", "ALAS", "ARIZ", "ARK", "CAL", "CALIF", "COLO", "CONN",
    "DEL", "FLA", "GA", "ILL", "IND", "KANS", "KY", "LA", "MASS",
    "MICH", "MINN", "MISS", "MO", "MONT", "NEB", "NEV", "NH",
    "NJ", "NM", "NY", "NC", "ND", "OKLA", "ORE", "PA", "RI",
    "SC", "SD", "TENN", "TEX", "VT", "VA", "WASH", "WV", "WIS", "WYO",
    // Territories (less common abbreviations)
    "DC", "PR", "VI"
]
let fullStateNames = [
    // 50 States
    "ALABAMA", "ALASKA", "ARIZONA", "ARKANSAS", "CALIFORNIA", "COLORADO",
    "CONNECTICUT", "DELAWARE", "FLORIDA", "GEORGIA", "HAWAII", "IDAHO",
    "ILLINOIS", "INDIANA", "IOWA", "KANSAS", "KENTUCKY", "LOUISIANA",
    "MAINE", "MARYLAND", "MASSACHUSETTS", "MICHIGAN", "MINNESOTA",
    "MISSISSIPPI", "MISSOURI", "MONTANA", "NEBRASKA", "NEVADA",
    "NEW HAMPSHIRE", "NEW JERSEY", "NEW MEXICO", "NEW YORK",
    "NORTH CAROLINA", "NORTH DAKOTA", "OHIO", "OKLAHOMA", "OREGON",
    "PENNSYLVANIA", "RHODE ISLAND", "SOUTH CAROLINA", "SOUTH DAKOTA",
    "TENNESSEE", "TEXAS", "UTAH", "VERMONT", "VIRGINIA", "WASHINGTON",
    "WEST VIRGINIA", "WISCONSIN", "WYOMING",
    // District and Territories
    "DISTRICT OF COLUMBIA", "AMERICAN SAMOA", "GUAM",
    "NORTHERN MARIANA ISLANDS", "PUERTO RICO", "VIRGIN ISLANDS",
    "US VIRGIN ISLANDS", "U.S. VIRGIN ISLANDS"
]
let directionalVariations = [
    // North variations
    ("N CAROLINA", "NORTH CAROLINA"),
    ("N. CAROLINA", "NORTH CAROLINA"),
    ("N DAKOTA", "NORTH DAKOTA"),
    ("N. DAKOTA", "NORTH DAKOTA"),
    // South variations
    ("S CAROLINA", "SOUTH CAROLINA"),
    ("S. CAROLINA", "SOUTH CAROLINA"),
    ("S DAKOTA", "SOUTH DAKOTA"),
    ("S. DAKOTA", "SOUTH DAKOTA"),
    // West variations
    ("W VIRGINIA", "WEST VIRGINIA"),
    ("W. VIRGINIA", "WEST VIRGINIA"),
    // Territory variations
    ("N MARIANA ISLANDS", "NORTHERN MARIANA ISLANDS"),
    ("N. MARIANA ISLANDS", "NORTHERN MARIANA ISLANDS")
]
let oldStyleDirectional = [
    "N.C.", "N.D.", "S.C.", "S.D.", "W.V.", "W.VA."
]
