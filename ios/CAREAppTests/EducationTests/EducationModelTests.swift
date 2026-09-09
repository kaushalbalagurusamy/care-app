import Testing
import Foundation
@testable import CAREApp

@Suite("Phase 1: Education Content Models & Manifest Test Suite")
struct EducationModelTests {
    
    @Test("TEST-EDM-01: Bundled manifest decodes all 6 education curriculum topics")
    func testManifestDecoding() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        #expect(manifest.count == 6)
        
        let totalReadTime = manifest.reduce(0) { $0 + $1.estimatedReadMinutes }
        #expect(totalReadTime >= 15, "Curriculum read duration must be at least 15 minutes (actual: \(totalReadTime))")
        
        for topic in manifest {
            #expect(!topic.id.isEmpty)
            #expect(!topic.title.isEmpty)
            #expect(!topic.subtitle.isEmpty)
            #expect(!topic.iconAsset.isEmpty)
            #expect(!topic.sections.isEmpty)
        }
    }
    
    @Test("TEST-EDM-02: RCT topic contains 4 founders and 5 Good Things in order")
    func testRCTTopicStructure() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        guard let rct = manifest.first(where: { $0.slug == .relationalCulturalTheory }) else {
            Issue.record("Missing Relational-Cultural Theory topic in manifest")
            return
        }
        
        var foundFounders = false
        var foundFiveGoodThings = false
        
        for section in rct.sections {
            switch section {
            case .foundersGrid(let founders):
                #expect(founders.count == 4)
                #expect(founders.contains(where: { $0.name.contains("Jean Baker Miller") }))
                #expect(founders.contains(where: { $0.name.contains("Judith V. Jordan") }))
                #expect(founders.contains(where: { $0.name.contains("Janet Surrey") }))
                #expect(founders.contains(where: { $0.name.contains("Irene Stiver") }))
                foundFounders = true
            case .fiveGoodThings(let items):
                #expect(items.count == 5)
                #expect(items.map(\.index) == [1, 2, 3, 4, 5])
                #expect(items[0].title == "Zest")
                #expect(items[1].title == "Sense of Worth")
                #expect(items[2].title == "Clarity")
                #expect(items[3].title == "Creativity")
                #expect(items[4].title == "Desire for More Connection")
                foundFiveGoodThings = true
            default:
                break
            }
        }
        
        #expect(foundFounders, "RCT topic must contain founders grid")
        #expect(foundFiveGoodThings, "RCT topic must contain 5 Good Things")
    }
    
    @Test("TEST-EDM-03: Relational Neuroscience topic maps 4 C.A.R.E. neural pathways")
    func testNeurosciencePathwayMapping() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        guard let neuro = manifest.first(where: { $0.slug == .relationalNeuroscience }) else {
            Issue.record("Missing Relational Neuroscience topic in manifest")
            return
        }
        
        var foundPathways = false
        for section in neuro.sections {
            if case .neuralPathwayMapping(let pathways) = section {
                #expect(pathways.count == 4)
                let domains = Set(pathways.map(\.domain))
                #expect(domains.contains(.calm), "Must include Calm pathway")
                #expect(domains.contains(.accepted), "Must include Accepted pathway")
                #expect(domains.contains(.resonant), "Must include Resonant pathway")
                #expect(domains.contains(.energetic), "Must include Energetic pathway")
                foundPathways = true
            }
        }
        #expect(foundPathways, "Relational Neuroscience must contain neural pathway mapping")
    }
    
    @Test("TEST-EDM-04: Topic models satisfy Sendable, Hashable, and Identifiable")
    func testModelConcurrencySafety() async throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        let topic = manifest[0]
        
        let task = Task.detached { () -> String in
            return topic.title
        }
        let title = await task.value
        #expect(!title.isEmpty)
        
        // Verify Hashable / Set storage
        let set = Set([topic])
        #expect(set.contains(topic))
    }
    
    @Test("TEST-EDM-05: All topics have a valid knowledge check quiz with 4 options and valid answer")
    func testQuizIntegrity() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        #expect(manifest.count == 6)
        
        for topic in manifest {
            let quiz = topic.quiz
            #expect(!quiz.id.isEmpty, "Quiz id cannot be empty for \(topic.slug)")
            #expect(!quiz.prompt.isEmpty, "Quiz prompt cannot be empty for \(topic.slug)")
            #expect(quiz.options.count == 4, "Quiz must have exactly 4 options for \(topic.slug)")
            #expect(["A", "B", "C", "D"].contains(quiz.correctOptionLetter), "Correct option letter must be A, B, C, or D for \(topic.slug)")
            #expect(!quiz.rationale.isEmpty, "Rationale cannot be empty for \(topic.slug)")
            
            let optionLetters = quiz.options.map(\.letter)
            #expect(optionLetters == ["A", "B", "C", "D"], "Quiz options must be labeled A, B, C, D in order for \(topic.slug)")
        }
    }
    
    @Test("TEST-EDM-06: 60-question clinical quiz bank has 10 valid questions per topic")
    func testSixtyQuestionQuizBankIntegrity() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        #expect(manifest.count == 6)
        
        var totalQuestions = 0
        var allQuestionIds = Set<String>()
        
        for topic in manifest {
            let bank = topic.quizBank
            #expect(bank.count == 10, "Topic \(topic.slug) must have exactly 10 questions in quizBank (actual: \(bank.count))")
            totalQuestions += bank.count
            
            for (idx, q) in bank.enumerated() {
                #expect(!q.id.isEmpty, "Question at index \(idx) in \(topic.slug) has empty id")
                #expect(!allQuestionIds.contains(q.id), "Duplicate question id detected: \(q.id)")
                allQuestionIds.insert(q.id)
                
                #expect(!q.prompt.isEmpty, "Question \(q.id) has empty prompt")
                #expect(q.options.count == 4, "Question \(q.id) must have 4 options")
                #expect(["A", "B", "C", "D"].contains(q.correctOptionLetter), "Question \(q.id) has invalid correct letter \(q.correctOptionLetter)")
                #expect(!q.rationale.isEmpty, "Question \(q.id) has empty rationale")
                
                let letters = q.options.map(\.letter)
                #expect(letters == ["A", "B", "C", "D"], "Question \(q.id) options must be A, B, C, D in order")
                for opt in q.options {
                    #expect(!opt.text.isEmpty, "Question \(q.id) option \(opt.letter) text cannot be empty")
                }
            }
        }
        
        #expect(totalQuestions == 60, "Global question bank must contain exactly 60 questions")
        #expect(allQuestionIds.count == 60, "All 60 questions must have unique IDs")
    }
    
    @Test("TEST-EDM-07: Quiz bank has balanced A/B/C/D answer distribution across all topics")
    func testBalancedAnswerDistribution() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        var letterCounts: [String: Int] = ["A": 0, "B": 0, "C": 0, "D": 0]
        
        for topic in manifest {
            for q in topic.quizBank {
                letterCounts[q.correctOptionLetter, default: 0] += 1
            }
        }
        
        // Assert every letter appears at least 12 times and at most 18 times across 60 questions (balanced ~25% each)
        for letter in ["A", "B", "C", "D"] {
            let count = letterCounts[letter] ?? 0
            #expect(count >= 12 && count <= 18, "Letter \(letter) count (\(count)) must be balanced near 15 (25%)")
        }
    }
}
