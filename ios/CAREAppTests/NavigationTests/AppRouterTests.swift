import Testing
import SwiftUI
@testable import CAREApp

@Suite("Phase 2: App Router & Navigation State Test Suite")
struct AppRouterTests {

    @Test("Finishing an assessment removes all editable routes from Back history")
    @MainActor
    func testCommittedFlowBoundary() {
        let router = AppRouter(path: [.assessmentOverview, .surveyOverview, .chooseRelationships, .surveyQuestion])
        router.finishFlow(at: .surveyResults)
        #expect(router.path == [.surveyResults])
        router.pop()
        #expect(router.path.isEmpty)
    }

    @Test("Education resume card names the active quiz")
    func testQuizProgressCardLabel() {
        let card = ActionCardView(title: "Education", iconName: "icon_book_open", backgroundImageName: "card_education_bg", hasResumeControls: true, action: {})
        #expect(card.progressTitle == "Quiz in Progress")
    }
    
    @Test("TEST-NAV-01: Deep navigation traversal correctly tracks stacked routes")
    @MainActor
    func testDeepNavigationTraversal() {
        let router = AppRouter()
        #expect(router.path.isEmpty)
        
        // Deep assessment route flow
        router.navigate(to: .assessmentOverview)
        router.navigate(to: .surveyOverview)
        router.navigate(to: .chooseRelationships)
        router.navigate(to: .relationshipFrequency)
        router.navigate(to: .surveyQuestion)
        router.navigate(to: .surveyResults)
        router.navigate(to: .surveyResultsExpanded)
        
        #expect(router.path.count == 7)
    }

    @Test("TEST-NAV-02: Pop decrements navigation stack deterministically")
    @MainActor
    func testPopBehavior() {
        let router = AppRouter()
        router.navigate(to: .assessmentOverview)
        router.navigate(to: .surveyOverview)
        #expect(router.path.count == 2)
        
        router.pop()
        #expect(router.path.count == 1)
        
        router.pop()
        #expect(router.path.isEmpty)
        
        // Extra pop on empty stack is safe
        router.pop()
        #expect(router.path.isEmpty)
    }

    @Test("TEST-NAV-03: PopToRoot resets multi-level stack completely back to Home")
    @MainActor
    func testPopToRootReset() {
        let router = AppRouter()
        router.navigate(to: .assessmentOverview)
        router.navigate(to: .surveyOverview)
        router.navigate(to: .chooseRelationships)
        router.navigate(to: .surveyResults)
        #expect(router.path.count == 4)
        
        router.popToRoot()
        #expect(router.path.isEmpty)
    }

    @Test("TEST-NAV-04: Secondary module routes are navigable")
    @MainActor
    func testSecondaryModuleRoutes() {
        let router = AppRouter()
        router.navigate(to: .education)
        #expect(router.path.count == 1)
        
        router.pop()
        router.navigate(to: .exercises)
        #expect(router.path.count == 1)
        
        router.pop()
        router.navigate(to: .pastResults)
        #expect(router.path.count == 1)
    }
}
