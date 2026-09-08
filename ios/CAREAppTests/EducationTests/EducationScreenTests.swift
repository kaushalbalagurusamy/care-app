import Testing
import SwiftUI
@testable import CAREApp

@Suite("Phase 3: Education Screen Views Test Suite")
struct EducationScreenTests {
    
    @Test("TEST-EDS-01: EducationTopicsView renders all 6 curriculum topics and handles selection")
    @MainActor
    func testEducationTopicsView() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        #expect(manifest.count == 6)
        
        var selectedTopic: EducationTopic? = nil
        let hubView = EducationTopicsView(
            topics: manifest,
            completedTopicSlugs: [.relationalCulturalTheory],
            onSelectTopic: { topic in
                selectedTopic = topic
            }
        )
        
        #expect(hubView.topics.count == 6)
        #expect(hubView.completedTopicSlugs.contains(.relationalCulturalTheory))
        
        hubView.onSelectTopic?(manifest[0])
        #expect(selectedTopic?.slug == .relationalCulturalTheory)
    }
    
    @Test("TEST-EDS-02: TopicDetailView correctly renders Relational-Cultural Theory structure")
    @MainActor
    func testRCTDetailView() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        guard let rct = manifest.first(where: { $0.slug == .relationalCulturalTheory }) else {
            Issue.record("Missing RCT topic in manifest")
            return
        }
        
        var quizTriggered = false
        let detailView = TopicDetailView(topic: rct, onTakeQuiz: {
            quizTriggered = true
        })
        
        #expect(detailView.topic.slug == .relationalCulturalTheory)
        #expect(detailView.topic.sections.count >= 4)
        
        detailView.onTakeQuiz?()
        #expect(quizTriggered == true, "CTA should trigger quiz action")
    }
    
    @Test("TEST-EDS-03: TopicDetailView correctly renders Relational Neuroscience 4 C.A.R.E. pathways")
    @MainActor
    func testNeuroscienceDetailView() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        guard let neuro = manifest.first(where: { $0.slug == .relationalNeuroscience }) else {
            Issue.record("Missing Relational Neuroscience topic")
            return
        }
        
        let detailView = TopicDetailView(topic: neuro)
        #expect(detailView.topic.slug == .relationalNeuroscience)
        
        var pathwayCount = 0
        for section in detailView.topic.sections {
            if case .neuralPathwayMapping(let pathways) = section {
                pathwayCount = pathways.count
            }
        }
        #expect(pathwayCount == 4, "Must contain exactly 4 neural pathways")
    }
    
    @Test("TEST-EDS-04: TopicDetailView correctly renders Neuroplasticity illustrations and narrative")
    @MainActor
    func testNeuroplasticityDetailView() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        guard let topic = manifest.first(where: { $0.slug == .neuroplasticity }) else {
            Issue.record("Missing Neuroplasticity topic")
            return
        }
        
        let detailView = TopicDetailView(topic: topic)
        #expect(detailView.topic.slug == .neuroplasticity)
        #expect(detailView.topic.sections.count == 2)
        
        let hasIllustrations = detailView.topic.sections.contains { section in
            if case .illustrationParagraph(let imageAsset, _) = section {
                return !imageAsset.isEmpty
            }
            return false
        }
        #expect(hasIllustrations, "Neuroplasticity must include illustration sections")
    }
    
    @Test("TEST-EDS-05: TopicDetailView correctly renders The Brain in Healthy Relationships narrative")
    @MainActor
    func testBrainHealthyRelationshipsDetailView() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        guard let topic = manifest.first(where: { $0.slug == .brainHealthyRelationships }) else {
            Issue.record("Missing Brain in Healthy Relationships topic")
            return
        }
        
        let detailView = TopicDetailView(topic: topic)
        #expect(detailView.topic.slug == .brainHealthyRelationships)
        #expect(detailView.topic.sections.count == 2)
    }
    
    @Test("TEST-EDS-06: TopicDetailView correctly renders Power-Over vs. Power-With narrative")
    @MainActor
    func testPowerOverVsPowerWithDetailView() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        guard let topic = manifest.first(where: { $0.slug == .powerOverVsPowerWith }) else {
            Issue.record("Missing Power-Over vs Power-With topic")
            return
        }
        
        let detailView = TopicDetailView(topic: topic)
        #expect(detailView.topic.slug == .powerOverVsPowerWith)
        #expect(detailView.topic.sections.count == 2)
    }
    
    @Test("TEST-EDS-07: TopicDetailView correctly renders The Impact of Relationships narrative")
    @MainActor
    func testImpactOfRelationshipsDetailView() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        guard let topic = manifest.first(where: { $0.slug == .impactOfRelationships }) else {
            Issue.record("Missing Impact of Relationships topic")
            return
        }
        
        let detailView = TopicDetailView(topic: topic)
        #expect(detailView.topic.slug == .impactOfRelationships)
        #expect(detailView.topic.sections.count == 2)
    }
    
    @Test("TEST-EDS-08: EducationQuizView evaluates answers and presents rationale")
    @MainActor
    func testEducationQuizViewInteraction() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        let topic = manifest[0]
        
        var returned = false
        var quizPassed: Bool? = nil
        let initialQuizView = EducationQuizView(
            topic: topic,
            onReturn: { returned = true },
            onCompleteQuiz: { passed in quizPassed = passed }
        )
        
        #expect(initialQuizView.topic.id == topic.id)
        #expect(initialQuizView.topic.quiz.options.count == 4)
        #expect(initialQuizView.hasSubmitted == false)
        #expect(initialQuizView.selectedOptionLetter == nil)
        
        // Check unselected initial states
        for option in topic.quiz.options {
            #expect(initialQuizView.presentationState(for: option) == .unselected)
        }
        
        let correctLetter = topic.quiz.correctOptionLetter
        let correctOption = topic.quiz.options.first(where: { $0.letter == correctLetter })!
        let wrongOption = topic.quiz.options.first(where: { $0.letter != correctLetter })!
        
        // Check static evaluation helper
        #expect(EducationQuizView.evaluateOption(letter: correctOption.letter, selectedLetter: nil, correctLetter: correctLetter, hasSubmitted: false) == .unselected)
        #expect(EducationQuizView.evaluateOption(letter: correctOption.letter, selectedLetter: correctLetter, correctLetter: correctLetter, hasSubmitted: true) == .correct)
        #expect(EducationQuizView.evaluateOption(letter: wrongOption.letter, selectedLetter: wrongOption.letter, correctLetter: correctLetter, hasSubmitted: true) == .incorrect)
        #expect(EducationQuizView.evaluateOption(letter: correctOption.letter, selectedLetter: wrongOption.letter, correctLetter: correctLetter, hasSubmitted: true) == .correct)
        
        // Check initialized state with correct answer
        let correctQuizView = EducationQuizView(
            topic: topic,
            selectedOptionLetter: correctLetter,
            hasSubmitted: true
        )
        #expect(correctQuizView.isCorrect == true)
        #expect(correctQuizView.presentationState(for: correctOption) == .correct)
        
        // Check initialized state with wrong answer
        let wrongQuizView = EducationQuizView(
            topic: topic,
            selectedOptionLetter: wrongOption.letter,
            hasSubmitted: true
        )
        #expect(wrongQuizView.isCorrect == false)
        #expect(wrongQuizView.presentationState(for: wrongOption) == .incorrect)
        #expect(wrongQuizView.presentationState(for: correctOption) == .correct, "Correct option should still be revealed as correct")
        
        initialQuizView.onReturn?()
        #expect(returned == true)
    }
}
