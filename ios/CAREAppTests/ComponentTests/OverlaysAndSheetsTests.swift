import Testing
import SwiftUI
@testable import CAREApp

@Suite("Figma V2 Overlays and Bottom Sheets Test Suite")
struct OverlaysAndSheetsTests {
    
    @Test("RelationshipSortOption enum cases and identifiers")
    func testRelationshipSortOptions() {
        let options = RelationshipSortOption.allCases
        #expect(options.count == 5)
        #expect(options.contains(.mostRecent))
        #expect(options.contains(.mostCompleted))
        #expect(options.contains(.highestScore))
        #expect(options.contains(.relationshipType))
        #expect(options.contains(.age))
        #expect(RelationshipSortOption.mostRecent.id == "Most recent")
    }
    
    @Test("ExerciseSortOption enum cases and identifiers")
    func testExerciseSortOptions() {
        let options = ExerciseSortOption.allCases
        #expect(options.count == 5)
        #expect(options.contains(.mostRecentlyCompleted))
        #expect(options.contains(.numberOfTimesCompleted))
        #expect(options.contains(.highestRated))
        #expect(options.contains(.longestDuration))
        #expect(options.contains(.shortestDuration))
        #expect(ExerciseSortOption.highestRated.id == "Highest rated")
    }
    
    @Test("CancelChangesConfirmationView triggers keepEditing and cancel callbacks")
    func testCancelChangesConfirmationViewCallbacks() {
        var keepEditingCalled = false
        var cancelWithoutSavingCalled = false
        
        let view = CancelChangesConfirmationView(
            onKeepEditing: { keepEditingCalled = true },
            onCancelWithoutSaving: { cancelWithoutSavingCalled = true }
        )
        
        view.onKeepEditing()
        #expect(keepEditingCalled)
        
        view.onCancelWithoutSaving()
        #expect(cancelWithoutSavingCalled)
    }
    
    @Test("SaveAssessmentConfirmationView triggers saveAssessment and discardAssessment callbacks")
    func testSaveAssessmentConfirmationViewCallbacks() {
        var saveCalled = false
        var discardCalled = false
        
        let view = SaveAssessmentConfirmationView(
            onSaveAssessment: { saveCalled = true },
            onDiscardAssessment: { discardCalled = true }
        )
        
        view.onSaveAssessment()
        #expect(saveCalled)
        
        view.onDiscardAssessment()
        #expect(discardCalled)
    }
}
