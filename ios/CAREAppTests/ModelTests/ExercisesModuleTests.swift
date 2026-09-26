import Testing
import SwiftUI
@testable import CAREApp

@Suite("Exercises Module Data Models & Views Test Suite")
struct ExercisesModuleTests {
    
    @Test("ExerciseCategory allCases covers all 4 CARE dimensions")
    func testExerciseCategories() {
        let categories = ExerciseCategory.allCases
        #expect(categories.count == 4)
        #expect(categories.map(\.rawValue) == ["Calm", "Accepted", "Resonant", "Energetic"])
        for cat in categories {
            #expect(!cat.pathwayDescription.isEmpty)
        }
    }
    
    @Test("Sample Calm exercises populate with valid defaults and stats")
    func testSampleCalmExercises() {
        let calmItems = ExerciseItem.sampleCalmExercises
        #expect(calmItems.count == 2)
        #expect(calmItems[0].id == "watch-something-funny")
        #expect(calmItems[0].category == .calm)
        #expect(calmItems[0].timesCompleted == 8)
        #expect(calmItems[0].ratingStars == 4)
        #expect(calmItems[0].isFavorite == true)
        
        #expect(calmItems[1].id == "keep-photo-close")
        #expect(calmItems[1].category == .calm)
        #expect(calmItems[1].timesCompleted == 5)
        #expect(calmItems[1].ratingStars == 5)
    }
    
    @Test("Sample Resonant exercises populate with valid identifiers")
    func testSampleResonantExercises() {
        let resonantItems = ExerciseItem.sampleResonantExercises
        #expect(resonantItems.count == 3)
        #expect(resonantItems[0].id == "mirror-loved-one")
        #expect(resonantItems[1].id == "empathic-listening")
        #expect(resonantItems[2].id == "resonance-breathing")
    }
    
    @Test("Exercise Views instantiate cleanly without runtime fatal errors")
    @MainActor
    func testExerciseViewsInstantiation() {
        let calmView = CalmExercisesView()
        #expect(calmView != nil)
        
        let watchFunny = WatchFunnyExerciseView()
        #expect(watchFunny != nil)
        
        let keepPhoto = KeepPhotoExerciseView()
        #expect(keepPhoto != nil)
        
        let belonging = BelongingListExerciseView()
        #expect(belonging != nil)
        
        let resultsExercises = CAREResultsExercisesView()
        #expect(resultsExercises != nil)
        
        let completeView = ExerciseCompleteView()
        #expect(completeView != nil)
    }
}
