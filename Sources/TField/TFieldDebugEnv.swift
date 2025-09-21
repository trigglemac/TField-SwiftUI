//
//  SwiftUIView.swift
//  TField
//
//  Created by Timothy Riggle on 9/20/25.
//

import SwiftUI

// MARK: - Simple Debug Environment Key
struct TFieldDebugKey: EnvironmentKey {
    static let defaultValue: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
}

extension EnvironmentValues {
    var tFieldDebugEnabled: Bool {
        get { self[TFieldDebugKey.self] }
        set { self[TFieldDebugKey.self] = newValue }
    }
}

// MARK: - Public Debug Extension
extension View {
    /// Enable or disable TField debug information for this view and its children
    public func tFieldDebug(_ enabled: Bool) -> some View {
        self.environment(\.tFieldDebugEnabled, enabled)
    }
}
