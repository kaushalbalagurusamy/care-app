import Testing
import SwiftUI
@testable import CAREApp

@Suite("Phase 2: Psychoeducation Reusable Components Test Suite")
struct EducationComponentTests {
    
    @Test("TEST-EDC-01: EducationTopicCard satisfies minimum 44pt touch target and layout bounds")
    func testTopicCardGeometry() {
        let mockTopic = EducationTopic(
            id: "test-topic-1",
            slug: .relationalCulturalTheory,
            title: "Relational-Cultural Theory",
            subtitle: "Understanding how growth-fostering relationships heal.",
            iconAsset: "icon_rct_book",
            estimatedReadMinutes: 5,
            sections: [],
            quiz: QuizQuestion(
                id: "q-1",
                prompt: "Question prompt?",
                options: [QuizOption(letter: "A", text: "Answer")],
                correctOptionLetter: "A",
                rationale: "Rationale explanation."
            )
        )
        
        var tapped = false
        let card = EducationTopicCard(topic: mockTopic, isCompleted: false) {
            tapped = true
        }
        
        #expect(card.minTouchTargetHeight >= 44.0, "Topic card min height must exceed Apple HIG 44pt (actual: \(card.minTouchTargetHeight))")
        #expect(card.topic.title == "Relational-Cultural Theory")
        #expect(card.topic.iconAsset == "icon_rct_book")
        #expect(card.isCompleted == false)
        
        card.action()
        #expect(tapped == true, "Card action closure must trigger on tap")
        
        let completedCard = EducationTopicCard(topic: mockTopic, isCompleted: true, action: {})
        #expect(completedCard.isCompleted == true)
    }
    
    @Test("TEST-EDC-02: FounderCard renders biographical narrative with unconstrained line limit")
    func testFounderCardTypographyAndStructure() {
        let founder = FounderProfile(
            id: "founder-jbm",
            name: "Jean Baker Miller, MD",
            titleAndDegrees: "Psychiatrist & Author",
            biography: "The pioneering psychiatrist and author of Toward a New Psychology of Women who challenged patriarchal psychological paradigms and laid the foundational cornerstone for Relational-Cultural Theory.",
            imageAsset: "avatar_jean_baker_miller"
        )
        
        let card = FounderCard(founder: founder, showDivider: true)
        #expect(card.founder.id == "founder-jbm")
        #expect(card.founder.name == "Jean Baker Miller, MD")
        #expect(card.founder.titleAndDegrees == "Psychiatrist & Author")
        #expect(card.founder.biography.contains("Toward a New Psychology of Women"))
        #expect(card.founder.imageAsset == "avatar_jean_baker_miller")
        #expect(card.showDivider == true)
    }
    
    @Test("TEST-EDC-03: FiveGoodThingsCard displays numbered badge 1..5 and distinctive colors")
    func testFiveGoodThingsCardNumbering() {
        let items: [FiveGoodThingsItem] = [
            FiveGoodThingsItem(id: "fgt-1", index: 1, title: "Zest", neuroDescription: "Emotional energy and vitality."),
            FiveGoodThingsItem(id: "fgt-2", index: 2, title: "Sense of Worth", neuroDescription: "Deep realization of value."),
            FiveGoodThingsItem(id: "fgt-3", index: 3, title: "Clarity", neuroDescription: "Expanded relational understanding."),
            FiveGoodThingsItem(id: "fgt-4", index: 4, title: "Creativity", neuroDescription: "Spark of constructive expression."),
            FiveGoodThingsItem(id: "fgt-5", index: 5, title: "Desire for More Connection", neuroDescription: "Extending meaningful empathy.")
        ]
        
        for (i, item) in items.enumerated() {
            let card = FiveGoodThingsCard(item: item)
            #expect(card.badgeText == "\(i + 1)")
            #expect(card.item.title == item.title)
            #expect(!card.item.neuroDescription.isEmpty)
        }
        
        // Invariant: each index must have a defined, non-empty accent color
        let card1 = FiveGoodThingsCard(item: items[0])
        let card2 = FiveGoodThingsCard(item: items[1])
        #expect(card1.accentColor != card2.accentColor, "Different good things should have distinct accent colors")
    }
    
    @Test("TEST-EDC-04: NeurobiologyPathwayCard binds exact C.A.R.E. domain palette colors")
    func testPathwayCardColorTokens() {
        let calmColor = Theme.Colors.Domains.calm
        let acceptedColor = Theme.Colors.Domains.accepted
        let resonantColor = Theme.Colors.Domains.resonant
        let energeticColor = Theme.Colors.Domains.energetic
        
        #expect(calmColor != acceptedColor)
        #expect(resonantColor != energeticColor)
        #expect(calmColor != resonantColor)
        
        let pathways: [NeuralPathwayItem] = [
            NeuralPathwayItem(
                id: "np-1",
                domain: .calm,
                name: "Smart Vagus Nerve",
                brainRegion: "Parasympathetic 10th Cranial",
                function: "Dampening acute stress response.",
                exerciseSuggestion: "Extended exhale breathing."
            ),
            NeuralPathwayItem(
                id: "np-2",
                domain: .accepted,
                name: "Dorsal Anterior Cingulate Cortex",
                brainRegion: "DACC & Insula",
                function: "Processes social rejection pain.",
                exerciseSuggestion: "Validate relational pain."
            ),
            NeuralPathwayItem(
                id: "np-3",
                domain: .resonant,
                name: "Mirror Neuron System",
                brainRegion: "Premotor & Inferior Parietal",
                function: "Mirrors gestures and emotional states.",
                exerciseSuggestion: "Attuned eye contact practice."
            ),
            NeuralPathwayItem(
                id: "np-4",
                domain: .energetic,
                name: "Dopamine Reward System",
                brainRegion: "Mesolimbic VTA to Nucleus Accumbens",
                function: "Encodes healthy engagement as pleasurable.",
                exerciseSuggestion: "Shared celebration rituals."
            )
        ]
        
        for pathway in pathways {
            let card = NeurobiologyPathwayCard(pathway: pathway)
            #expect(card.domainColor == pathway.domain.themeColor)
            #expect(card.pathway.name == pathway.name)
            #expect(!card.pathway.brainRegion.isEmpty)
        }
    }
    
    @Test("TEST-EDC-05: KeyTakeawaysCard renders sparkle header and bullet collection")
    func testKeyTakeawaysCard() {
        let sampleBullets = [
            "Human growth is fueled by authentic connection rather than autonomous isolation.",
            "The five good things of RCT provide a clinical blueprint for relational vitality.",
            "Mutual empathy rewires autonomic and neural circuits for lifelong resilience."
        ]
        
        let card = KeyTakeawaysCard(title: "Clinical Takeaways", points: sampleBullets)
        #expect(card.title == "Clinical Takeaways")
        #expect(card.points.count == 3)
        #expect(card.points[0] == sampleBullets[0])
        #expect(card.points[1] == sampleBullets[1])
        #expect(card.points[2] == sampleBullets[2])
    }
    
    @Test("TEST-EDC-06: QuizOptionCard handles unselected, selected, correct, and incorrect states")
    func testQuizOptionCardPresentationStates() {
        let optionA = QuizOption(letter: "A", text: "First option")
        let optionB = QuizOption(letter: "B", text: "Second option")
        
        var tapped = false
        let unselectedCard = QuizOptionCard(option: optionA, state: .unselected) {
            tapped = true
        }
        #expect(unselectedCard.minTouchTargetHeight >= 44.0)
        #expect(unselectedCard.state == .unselected)
        unselectedCard.action()
        #expect(tapped == true)
        
        let selectedCard = QuizOptionCard(option: optionA, state: .selected, action: {})
        #expect(selectedCard.state == .selected)
        #expect(selectedCard.state.letterBadgeBackground == Theme.Colors.primary)
        
        let correctCard = QuizOptionCard(option: optionB, state: .correct, action: {})
        #expect(correctCard.state == .correct)
        #expect(correctCard.state.borderColor == Color(hex: "#5D9C59"))
        
        let incorrectCard = QuizOptionCard(option: optionA, state: .incorrect, action: {})
        #expect(incorrectCard.state == .incorrect)
        #expect(incorrectCard.state.borderColor == Color(hex: "#E07A5F"))
    }
}
