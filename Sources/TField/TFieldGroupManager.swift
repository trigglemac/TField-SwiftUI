//
//  TFieldGroupManager.swift
//  TField
//
//  Created by Timothy Riggle on 9/21/25.
//

import Foundation
import SwiftUI

// MARK: - Group Manager (Internal Only)
internal final class TFieldGroupManager: @unchecked Sendable {
    private var fieldStates: [String: [String: FieldInfo]] = [:]
    private let lock = NSRecursiveLock()
    private var lastCleanup = Date()
    private let cleanupInterval: TimeInterval = 30.0
    
    // Batching properties
    private var pendingUpdates: Set<String> = []
    private var batchTimer: Timer?
    private let batchDelay: TimeInterval = 0.1
    
    // Lifecycle tracking for automatic cleanup
    private var isActive = true
    
    struct FieldInfo {
        let isValid: Bool
        let registrationTime: Date
        
        var isStale: Bool {
            Date().timeIntervalSince(registrationTime) > 300
        }
    }
    
    deinit {
        cleanup()
    }
    
    private func cleanup() {
        batchTimer?.invalidate()
        batchTimer = nil
        fieldStates.removeAll()
        pendingUpdates.removeAll()
        isActive = false
    }
    
    func updateField(group: String, fieldId: String, isValid: Bool) {
        guard isActive else { return }
        
        lock.lock()
        defer { lock.unlock() }
        
        if fieldStates[group] == nil {
            fieldStates[group] = [:]
        }
        
        fieldStates[group]?[fieldId] = FieldInfo(
            isValid: isValid,
            registrationTime: Date()
        )
        
        pendingUpdates.insert(group)
        scheduleBatchUpdate()
        performPeriodicCleanup()
        
        #if DEBUG && TFIELD_VERBOSE_LOGGING
        print("TFieldGroup: Queued update for field \(fieldId) in group '\(group)' to \(isValid ? "valid" : "invalid")")
        #endif
    }
    
    private func scheduleBatchUpdate() {
        batchTimer?.invalidate()
        batchTimer = Timer.scheduledTimer(withTimeInterval: batchDelay, repeats: false) { [weak self] _ in
            self?.processPendingUpdates()
        }
    }
    
    private func processPendingUpdates() {
        guard isActive else { return }
        
        lock.lock()
        let groupsToProcess = pendingUpdates
        pendingUpdates.removeAll()
        lock.unlock()
        
        #if DEBUG && TFIELD_VERBOSE_LOGGING
        if !groupsToProcess.isEmpty {
            print("TFieldGroup: Processing batched updates for groups: \(groupsToProcess)")
        }
        #endif
    }
    
    func removeField(group: String, fieldId: String) {
        guard isActive else { return }
        
        lock.lock()
        defer { lock.unlock() }
        
        fieldStates[group]?.removeValue(forKey: fieldId)
        if fieldStates[group]?.isEmpty == true {
            fieldStates.removeValue(forKey: group)
        }
        
        pendingUpdates.insert(group)
        scheduleBatchUpdate()
        
        #if DEBUG && TFIELD_VERBOSE_LOGGING
        print("TFieldGroup: Removed field \(fieldId) from group '\(group)'")
        #endif
    }
    
    private func performPeriodicCleanup() {
        guard Date().timeIntervalSince(lastCleanup) > cleanupInterval else { return }
        
        lastCleanup = Date()
        var removedCount = 0
        var affectedGroups: Set<String> = []
        
        for (groupName, fields) in fieldStates {
            let staleFields = fields.filter { $0.value.isStale }
            for (fieldId, _) in staleFields {
                fieldStates[groupName]?.removeValue(forKey: fieldId)
                removedCount += 1
                affectedGroups.insert(groupName)
            }
            
            if fieldStates[groupName]?.isEmpty == true {
                fieldStates.removeValue(forKey: groupName)
            }
        }
        
        if !affectedGroups.isEmpty {
            pendingUpdates.formUnion(affectedGroups)
            scheduleBatchUpdate()
        }
        
        #if DEBUG && TFIELD_VERBOSE_LOGGING
        if removedCount > 0 {
            print("TFieldGroup: Cleaned up \(removedCount) stale field registrations")
        }
        #endif
    }
    
    internal func verifyGroup(_ group: String) -> Bool {
        guard isActive else { return true }
        
        lock.lock()
        defer { lock.unlock() }
        
        guard let groupFields = fieldStates[group], !groupFields.isEmpty else {
            return true
        }
        
        return groupFields.values.allSatisfy { $0.isValid }
    }
    
    internal func groupCount(_ group: String) -> Int {
        guard isActive else { return 0 }
        
        lock.lock()
        defer { lock.unlock() }
        
        return fieldStates[group]?.count ?? 0
    }
    
    #if DEBUG
    internal func debugGroupState(_ group: String) {
        guard isActive else { return }
        
        lock.lock()
        defer { lock.unlock() }
        
        guard let groupFields = fieldStates[group] else {
            print("TFieldGroup Debug: Group '\(group)' does not exist")
            return
        }
        
        print("TFieldGroup Debug: Group '\(group)' has \(groupFields.count) fields:")
        for (fieldId, info) in groupFields {
            print("  - \(fieldId): \(info.isValid ? "valid" : "invalid"), age: \(Date().timeIntervalSince(info.registrationTime))s")
        }
    }
    #endif
}

// MARK: - Environment Key
struct TFieldGroupManagerKey: EnvironmentKey {
    static let defaultValue: TFieldGroupManager? = nil
}

extension EnvironmentValues {
    var tFieldGroupManager: TFieldGroupManager? {
        get { self[TFieldGroupManagerKey.self] }
        set { self[TFieldGroupManagerKey.self] = newValue }
    }
}

// MARK: - Auto-Creating GroupValidator
@MainActor
public final class GroupValidator: ObservableObject {
    @Published private var refreshTrigger = false
    private let groups: [String]
    internal let groupManager: TFieldGroupManager  // Changed to internal
    nonisolated(unsafe) private var timer: Timer?
    
    public init(groups: [String]) {
        self.groups = groups
        self.groupManager = TFieldGroupManager()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timerRefreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshTrigger.toggle()
            }
        }
    }
    
    public func verifyGroup(_ group: String) -> Bool {
        _ = refreshTrigger
        return groupManager.verifyGroup(group)
    }
    
    public func groupCount(_ group: String) -> Int {
        _ = refreshTrigger
        return groupManager.groupCount(group)
    }
    
    public func allGroupsValid() -> Bool {
        _ = refreshTrigger
        return groups.allSatisfy { groupManager.verifyGroup($0) }
    }
    
    #if DEBUG
    public func debugGroupState(_ group: String) {
        groupManager.debugGroupState(group)
    }
    #endif
}

// MARK: - Environment-Providing View Modifier
extension View {
    public func withGroupValidation<Content: View>(
        groups: [String],
        @ViewBuilder content: @escaping (GroupValidator) -> Content
    ) -> some View {
        GroupValidationProvider(groups: groups, content: content)
    }
}

@MainActor
private struct GroupValidationProvider<Content: View>: View {
    let groups: [String]
    let content: (GroupValidator) -> Content
    @StateObject private var validator: GroupValidator
    
    init(groups: [String], @ViewBuilder content: @escaping (GroupValidator) -> Content) {
        self.groups = groups
        self.content = content
        self._validator = StateObject(wrappedValue: GroupValidator(groups: groups))
    }
    
    var body: some View {
        content(validator)
            .environment(\.tFieldGroupManager, validator.groupManager)
    }
}

// MARK: - TField Manager Access
extension TFieldGroupManager {
    static func fromEnvironment(_ environment: EnvironmentValues) -> TFieldGroupManager? {
        return environment.tFieldGroupManager
    }
}
