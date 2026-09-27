import Testing
import SwiftUI
@testable import CAREApp

@Suite("Figma V2 Design Tokens & Polish Test Suite")
struct DesignTokensAndPolishTests {
    
    @Test("DailyExerciseTrackerView default initialization provides 7-day timeline")
    func testDailyExerciseTrackerDefaultInitialization() {
        let tracker = DailyExerciseTrackerView()
        #expect(tracker.completedDaysCount == 5)
        #expect(tracker.totalDaysCount == 7)
        #expect(tracker.days.count == 7)
        #expect(tracker.days.map(\.label) == ["M", "T", "W", "T", "F", "S", "S"])
        #expect(tracker.days[0].isCompleted == true)
        #expect(tracker.days[5].isCompleted == false)
        #expect(tracker.days[5].isCurrent == true)
    }
    
    @Test("DailyExerciseTrackerView supports custom days configuration")
    func testDailyExerciseTrackerCustomDays() {
        let customDays = [
            DailyExerciseTrackerView.DayStatus(id: 0, label: "Day 1", isCompleted: true),
            DailyExerciseTrackerView.DayStatus(id: 1, label: "Day 2", isCompleted: false)
        ]
        let tracker = DailyExerciseTrackerView(completedDaysCount: 1, totalDaysCount: 2, days: customDays)
        #expect(tracker.completedDaysCount == 1)
        #expect(tracker.totalDaysCount == 2)
        #expect(tracker.days.count == 2)
    }
    
    @Test("SecondaryButton default properties and tap action callback")
    func testSecondaryButtonDefaultProperties() {
        var clicked = false
        let button = SecondaryButton(title: "Return to Home", icon: "house.fill") {
            clicked = true
        }
        #expect(button.title == "Return to Home")
        #expect(button.icon == "house.fill")
        #expect(button.minHeight == 56.0)
        button.action()
        #expect(clicked == true)
    }
    
    @Test("HeaderNavBar default properties and back/home configuration")
    func testHeaderNavBarDefaultProperties() {
        let header = HeaderNavBar(showBackButton: true, showHomeButton: true, title: "Test Title")
        #expect(header.showBackButton == true)
        #expect(header.showHomeButton == true)
        #expect(header.title == "Test Title")
    }
    
    @Test("Theme.Spacing.headerTitleSpacing standardized at 14pt")
    func testHeaderTitleSpacingStandardization() {
        #expect(Theme.Spacing.headerTitleSpacing == 14.0)
    }
    
    @Test("PrimaryButton supports disabled and enabled state")
    func testPrimaryButtonEnabledState() {
        var tapped = false
        let disabledBtn = PrimaryButton(title: "Locked", isEnabled: false) {
            tapped = true
        }
        #expect(disabledBtn.isEnabled == false)
        #expect(disabledBtn.title == "Locked")
        // Invoking action directly checks callback when guarded
        disabledBtn.action()
        #expect(tapped == true)
        
        let enabledBtn = PrimaryButton(title: "Unlocked", isEnabled: true) {}
        #expect(enabledBtn.isEnabled == true)
    }
    
    @Test("ScrollBottomSentinelKey preference key reduces correctly")
    func testScrollBottomSentinelKey() {
        #expect(ScrollBottomSentinelKey.defaultValue == nil)
        var value: CGFloat? = 100.0
        ScrollBottomSentinelKey.reduce(value: &value, nextValue: { 200.0 })
        #expect(value == 200.0)
    }
}
