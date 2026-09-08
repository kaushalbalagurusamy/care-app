import Testing
import SwiftUI
@testable import CAREApp

// MARK: - Phase 4: Education Navigation Tests (TEST-EDN-01 through TEST-EDN-04)
@Suite("Phase 4: Education Navigation Routing Test Suite")
struct EducationNavigationTests {
    
    @Test("TEST-EDN-01: Home Dashboard to Education Hub navigation")
    @MainActor
    func testHomeDashboardToEducationHub() throws {
        let router = AppRouter()
        #expect(router.path.isEmpty)
        
        let homeView = HomeView(router: router)
        // Simulate tapping Education card on HomeView
        router.navigate(to: .education)
        
        #expect(router.path.count == 1)
        #expect(router.currentRoute == .education)
    }
    
    @Test("TEST-EDN-02: Education Hub to Topic Detail navigation")
    @MainActor
    func testEducationHubToTopicDetail() throws {
        let router = AppRouter()
        router.navigate(to: .education)
        #expect(router.currentRoute == .education)
        
        let manifest = try EducationManifestLoader.loadBundledManifest()
        let firstTopic = try #require(manifest.first)
        
        var selectedTopic: EducationTopic? = nil
        let topicsView = EducationTopicsView(
            topics: manifest,
            onSelectTopic: { topic in
                selectedTopic = topic
                router.navigate(to: .educationDetail(topic: topic))
            }
        )
        
        topicsView.onSelectTopic?(firstTopic)
        #expect(selectedTopic?.id == firstTopic.id)
        #expect(router.path.count == 2)
        #expect(router.currentRoute == .educationDetail(topic: firstTopic))
    }
    
    @Test("TEST-EDN-03: Standardized Top Bar Actions operate router seamlessly")
    @MainActor
    func testStandardizedTopBarActions() throws {
        let router = AppRouter()
        let manifest = try EducationManifestLoader.loadBundledManifest()
        let topic = manifest[0]
        
        // Setup deep stack: home -> education -> educationDetail
        router.navigate(to: .education)
        router.navigate(to: .educationDetail(topic: topic))
        #expect(router.path.count == 2)
        
        // Test Back: pops 1 level back to .education
        router.pop()
        #expect(router.path.count == 1)
        #expect(router.currentRoute == .education)
        
        // Push detail again, then test Home: pops to root
        router.navigate(to: .educationDetail(topic: topic))
        #expect(router.path.count == 2)
        router.popToRoot()
        #expect(router.path.isEmpty)
        
        // Test Chart button navigation: navigates to pastResults
        router.navigate(to: .pastResults)
        #expect(router.currentRoute == .pastResults)
        
        // Test HeaderNavBar callback integration
        var backTapped = false
        var homeTapped = false
        var chartTapped = false
        var profileTapped = false
        
        let header = HeaderNavBar(
            showBackButton: true,
            showHomeButton: true,
            showChartButton: true,
            showProfileButton: true,
            onBack: { backTapped = true },
            onHome: { homeTapped = true },
            onChart: { chartTapped = true },
            onProfile: { profileTapped = true }
        )
        
        header.onBack?()
        #expect(backTapped == true)
        
        header.onHome?()
        #expect(homeTapped == true)
        
        header.onChart?()
        #expect(chartTapped == true)
        
        header.onProfile?()
        #expect(profileTapped == true)
    }
    
    @Test("TEST-EDN-04: Topic Detail to Quiz and return button flow")
    @MainActor
    func testTopicDetailToQuizAndReturnFlow() throws {
        let router = AppRouter()
        let manifest = try EducationManifestLoader.loadBundledManifest()
        let topic = manifest[0]
        
        router.navigate(to: .education)
        router.navigate(to: .educationDetail(topic: topic))
        #expect(router.path.count == 2)
        
        var quizTriggered = false
        let detailView = TopicDetailView(
            topic: topic,
            onTakeQuiz: {
                quizTriggered = true
                router.navigate(to: .educationQuiz(topic: topic))
            }
        )
        detailView.onTakeQuiz?()
        #expect(quizTriggered == true)
        #expect(router.path.count == 3)
        #expect(router.currentRoute == .educationQuiz(topic: topic))
        
        // Return button from quiz pops back to TopicDetailView
        var returnedFromQuiz = false
        let quizView = EducationQuizView(
            topic: topic,
            onReturn: {
                returnedFromQuiz = true
                router.pop()
            }
        )
        quizView.onReturn?()
        #expect(returnedFromQuiz == true)
        #expect(router.path.count == 2)
        #expect(router.currentRoute == .educationDetail(topic: topic))
    }
}
