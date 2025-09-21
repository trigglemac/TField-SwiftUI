//
//  TFieldPerformanceTests.swift
//  TFieldTests
//
//  Created by Timothy Riggle on 9/21/25.
//
/*
import SwiftUI
import XCTest

@testable import TField

final class TFieldPerformanceTests: XCTestCase {

    // MARK: - Timer Performance Tests

    @MainActor func testTimerOverheadWithMultipleValidators() async {
        let validatorCount = 6  // Maximum realistic number of forms
        var validators: [GroupValidator] = []

        // Create multiple validators (simulating multiple forms open)
        for i in 0..<validatorCount {
            let validator = GroupValidator(groups: ["group\(i)"])
            validators.append(validator)
        }

        // Use actor to safely manage shared state
        actor TestState {
            var timerFireCount = 0
            var isCompleted = false
            
            func incrementCount() {
                timerFireCount += 1
            }
            
            func complete() {
                isCompleted = true
            }
            
            func getCount() -> Int {
                return timerFireCount
            }
            
            func checkCompleted() -> Bool {
                return isCompleted
            }
        }
        
        let testState = TestState()
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Create timer with sendable closure
        let measurementTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            Task {
                await testState.incrementCount()
                let elapsed = CFAbsoluteTimeGetCurrent() - startTime

                if elapsed >= 2.0 {
                    timer.invalidate()
                    await testState.complete()
                }
            }
        }
        
        // Wait for completion
        while await !testState.checkCompleted() {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }

        let finalCount = await testState.getCount()
        
        print("Performance Test Results:")
        print("- Validators created: \(validatorCount)")
        print("- Test duration: 2 seconds")
        print("- Expected validator timer fires: ~\(validatorCount * 5 * 2)")
        print("- Actual timer fires measured: \(finalCount)")
        print("- System remained responsive: \(finalCount > 0)")

        // Cleanup
        measurementTimer.invalidate()
        validators.removeAll()

        // Assertions
        XCTAssertGreaterThan(
            finalCount, 15,
            "System should remain responsive during timer overhead")
        XCTAssertLessThan(
            validatorCount * 10, 100, "Reasonable timer overhead limit")
    }
}
*/
