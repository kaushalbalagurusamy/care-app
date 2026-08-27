import Foundation
import SwiftUI

// MARK: - C.A.R.E. Domain Categories Enum
public enum CAREDomain: String, CaseIterable, Codable, Hashable {
    case calm = "calm"
    case accepted = "accepted"
    case resonant = "resonant"
    case energetic = "energetic"
    
    public var letter: String {
        return String(rawValue.prefix(1)).uppercased()
    }
    
    public var title: String {
        return rawValue.capitalized
    }
    
    public var subtitle: String {
        switch self {
        case .calm: return "C is for Calm"
        case .accepted: return "A is for Accepted"
        case .resonant: return "R is for Resonant"
        case .energetic: return "E is for Energetic"
        }
    }
    
    public var explanation: String {
        switch self {
        case .calm:
            return "Calmness is related to the functioning of the smart vagus nerve and your social engagement system. When these systems are healthy, they help you to modulate stress levels."
        case .accepted:
            return "Acceptance reflects feelings of belonging, safety, and mutual respect in your relational network."
        case .resonant:
            return "Resonance captures emotional attunement and mutual empathy without losing your own grounding."
        case .energetic:
            return "Energy describes the vitality, motivation, and positive arousal derived from growth-fostering social bonds."
        }
    }
    
    public var themeColor: Color {
        switch self {
        case .calm: return Theme.Colors.Domains.calm
        case .accepted: return Theme.Colors.Domains.accepted
        case .resonant: return Theme.Colors.Domains.resonant
        case .energetic: return Theme.Colors.Domains.energetic
        }
    }
}

// MARK: - Configurable Multi-Domain Weight Mapping
public struct DomainWeightMapping: Hashable, Codable {
    public let domain: CAREDomain
    public let weightMultiplier: Double
    
    public init(domain: CAREDomain, weightMultiplier: Double = 1.0) {
        self.domain = domain
        self.weightMultiplier = weightMultiplier
    }
}

// MARK: - Survey Option
public struct SurveyOption: Identifiable, Hashable, Codable {
    public let id: String
    public let text: String
    public let rawScoreValue: Double // Normalized value 0.0 - 1.0 (e.g. 0.2, 0.4, 0.6, 0.8, 1.0)
    
    public init(id: String, text: String, rawScoreValue: Double) {
        self.id = id
        self.text = text
        self.rawScoreValue = rawScoreValue
    }
}

// MARK: - Survey Question
public struct SurveyQuestion: Identifiable, Hashable, Codable {
    public let id: String
    public let prompt: String
    public let targetDomains: [DomainWeightMapping]
    public let options: [SurveyOption]
    
    public init(
        id: String,
        prompt: String,
        targetDomains: [DomainWeightMapping],
        options: [SurveyOption]
    ) {
        self.id = id
        self.prompt = prompt
        self.targetDomains = targetDomains
        self.options = options
    }
}

// MARK: - Full 20 Question Assessment Bank (C.A.R.E. Framework)
public extension SurveyQuestion {
    static let full20QuestionBank: [SurveyQuestion] = [
        // 1. Calm (C) - Physical body response
        SurveyQuestion(
            id: "q_1",
            prompt: "When you are around them, how does your body physically respond?",
            targetDomains: [DomainWeightMapping(domain: .calm, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q1_opt_1", text: "I feel constantly on edge, tense, or bracing for a negative reaction.", rawScoreValue: 0.20),
                SurveyOption(id: "q1_opt_2", text: "I feel a lingering background anxiety or stress that is hard to shake.", rawScoreValue: 0.40),
                SurveyOption(id: "q1_opt_3", text: "I feel neutral; my stress level doesn't go up, but I don't necessarily relax either.", rawScoreValue: 0.60),
                SurveyOption(id: "q1_opt_4", text: "I feel noticeably more settled; my physical tension noticeably decreases.", rawScoreValue: 0.80),
                SurveyOption(id: "q1_opt_5", text: "I feel completely grounded, relaxed, and physically safe in their presence.", rawScoreValue: 1.00)
            ]
        ),
        
        // 2. Calm (C) - Sharing personal feelings
        SurveyQuestion(
            id: "q_2",
            prompt: "How do you handle sharing your personal feelings with them?",
            targetDomains: [DomainWeightMapping(domain: .calm, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q2_opt_1", text: "I completely hide my true feelings because it is unsafe to share them.", rawScoreValue: 0.20),
                SurveyOption(id: "q2_opt_2", text: "I highly filter what I say, sharing only surface-level thoughts to avoid judgment.", rawScoreValue: 0.40),
                SurveyOption(id: "q2_opt_3", text: "I share some feelings, but hold back my deeper vulnerabilities.", rawScoreValue: 0.60),
                SurveyOption(id: "q2_opt_4", text: "I feel comfortable opening up about most of my feelings and struggles.", rawScoreValue: 0.80),
                SurveyOption(id: "q2_opt_5", text: "I share my deepest feelings openly, knowing they will be protected and honored.", rawScoreValue: 1.00)
            ]
        ),
        
        // 3. Calm (C) - Disagreements
        SurveyQuestion(
            id: "q_3",
            prompt: "What happens when you have a disagreement with them?",
            targetDomains: [DomainWeightMapping(domain: .calm, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q3_opt_1", text: "Disagreements escalate into hostility, shutting down, or threats to the relationship.", rawScoreValue: 0.20),
                SurveyOption(id: "q3_opt_2", text: "I avoid disagreeing at all costs because it causes severe tension or anxiety.", rawScoreValue: 0.40),
                SurveyOption(id: "q3_opt_3", text: "We manage to get through disagreements, but it leaves things awkward for a while.", rawScoreValue: 0.60),
                SurveyOption(id: "q3_opt_4", text: "We can disagree openly and calmly without me fearing I will lose the connection.", rawScoreValue: 0.80),
                SurveyOption(id: "q3_opt_5", text: "We navigate conflict constructively, and working through it actually builds our trust.", rawScoreValue: 1.00)
            ]
        ),
        
        // 4. Calm (C) - Differing opinions & lifestyles
        SurveyQuestion(
            id: "q_4",
            prompt: "How are differing opinions or lifestyle choices handled between you two?",
            targetDomains: [DomainWeightMapping(domain: .calm, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q4_opt_1", text: "My differences are actively attacked, mocked, or heavily criticized.", rawScoreValue: 0.20),
                SurveyOption(id: "q4_opt_2", text: "I hide our differences because expressing them leads to immediate friction.", rawScoreValue: 0.40),
                SurveyOption(id: "q4_opt_3", text: "We politely ignore our differences to keep the peace.", rawScoreValue: 0.60),
                SurveyOption(id: "q4_opt_4", text: "We openly acknowledge our differences and respect each other's right to have them.", rawScoreValue: 0.80),
                SurveyOption(id: "q4_opt_5", text: "Our differences are entirely welcomed, valued, and discussed with genuine curiosity.", rawScoreValue: 1.00)
            ]
        ),
        
        // 5. Calm (C) - Immediate crisis support
        SurveyQuestion(
            id: "q_5",
            prompt: "If you had an immediate crisis (e.g., medical emergency, work crisis), how would they respond?",
            targetDomains: [DomainWeightMapping(domain: .calm, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q5_opt_1", text: "I would not ask them; they would either refuse or make the situation more stressful.", rawScoreValue: 0.20),
                SurveyOption(id: "q5_opt_2", text: "They might help, but it would feel like a massive burden or come with strings attached.", rawScoreValue: 0.40),
                SurveyOption(id: "q5_opt_3", text: "They would likely help if it didn’t severely inconvenience their own schedule.", rawScoreValue: 0.60),
                SurveyOption(id: "q5_opt_4", text: "They would step up and provide the necessary help reliably.", rawScoreValue: 0.80),
                SurveyOption(id: "q5_opt_5", text: "They would drop everything immediately to support me without hesitation or complaint.", rawScoreValue: 1.00)
            ]
        ),
        
        // 6. Accepted (A) - Belonging & inclusion
        SurveyQuestion(
            id: "q_6",
            prompt: "How included do you feel when you are a part of their life?",
            targetDomains: [DomainWeightMapping(domain: .accepted, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q6_opt_1", text: "I feel actively excluded, isolated, or like an unwanted burden.", rawScoreValue: 0.20),
                SurveyOption(id: "q6_opt_2", text: "I feel like an outsider looking in; I am tolerated but not truly included.", rawScoreValue: 0.40),
                SurveyOption(id: "q6_opt_3", text: "I feel included in certain situations, but insecure about my standing in others.", rawScoreValue: 0.60),
                SurveyOption(id: "q6_opt_4", text: "I feel warmly welcomed and secure in my place in their life.", rawScoreValue: 0.80),
                SurveyOption(id: "q6_opt_5", text: "I feel completely at home; I belong unconditionally.", rawScoreValue: 1.00)
            ]
        ),
        
        // 7. Accepted (A) - Personal worth
        SurveyQuestion(
            id: "q_7",
            prompt: "How is your personal worth treated in this relationship?",
            targetDomains: [DomainWeightMapping(domain: .accepted, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q7_opt_1", text: "I am completely taken for granted or made to feel worthless.", rawScoreValue: 0.20),
                SurveyOption(id: "q7_opt_2", text: "I only feel valued for what I can do for them, not for who I am.", rawScoreValue: 0.40),
                SurveyOption(id: "q7_opt_3", text: "I receive occasional appreciation, though it feels sparse or generic.", rawScoreValue: 0.60),
                SurveyOption(id: "q7_opt_4", text: "I receive consistent, genuine appreciation for my contributions and presence.", rawScoreValue: 0.80),
                SurveyOption(id: "q7_opt_5", text: "I am unconditionally cherished; they actively celebrate who I am as a person.", rawScoreValue: 1.00)
            ]
        ),
        
        // 8. Accepted (A) - Personal boundaries & dignity
        SurveyQuestion(
            id: "q_8",
            prompt: "How are your personal boundaries and dignity treated?",
            targetDomains: [DomainWeightMapping(domain: .accepted, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q8_opt_1", text: "My boundaries are routinely ignored, mocked, or violated.", rawScoreValue: 0.20),
                SurveyOption(id: "q8_opt_2", text: "I am treated with impatience or condescension regularly.", rawScoreValue: 0.40),
                SurveyOption(id: "q8_opt_3", text: "I am treated politely, but occasionally dismissed or interrupted.", rawScoreValue: 0.60),
                SurveyOption(id: "q8_opt_4", text: "My boundaries and opinions are consistently respected.", rawScoreValue: 0.80),
                SurveyOption(id: "q8_opt_5", text: "I am treated with profound dignity, care, and unwavering respect at all times.", rawScoreValue: 1.00)
            ]
        ),
        
        // 9. Accepted (A) - Differing needs & capacities
        SurveyQuestion(
            id: "q_9",
            prompt: "How well are both of your differing needs, abilities, and capacities honored in this relationship?",
            targetDomains: [DomainWeightMapping(domain: .accepted, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q9_opt_1", text: "My specific needs and limitations are completely ignored or used against me.", rawScoreValue: 0.20),
                SurveyOption(id: "q9_opt_2", text: "Support is rigid; they only offer help on their terms, largely ignoring what I actually need.", rawScoreValue: 0.40),
                SurveyOption(id: "q9_opt_3", text: "We try to accommodate each other, though our differing needs sometimes cause friction or frustration.", rawScoreValue: 0.60),
                SurveyOption(id: "q9_opt_4", text: "We adapt well to each other's specific capacities, ensuring both of us feel supported in our own ways.", rawScoreValue: 0.80),
                SurveyOption(id: "q9_opt_5", text: "Our different needs and abilities are deeply respected, and we both feel fully supported and accommodated.", rawScoreValue: 1.00)
            ]
        ),
        
        // 10. Accepted (A) - Effort & mutual support
        SurveyQuestion(
            id: "q_10",
            prompt: "How do effort and support flow between you, considering your different life circumstances and abilities?",
            targetDomains: [DomainWeightMapping(domain: .accepted, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q10_opt_1", text: "Support is entirely one-sided; one person is drained while the other's needs are constantly centered.", rawScoreValue: 0.20),
                SurveyOption(id: "q10_opt_2", text: "Support feels transactional; there is a strict, stressful tracking of who owes whom.", rawScoreValue: 0.40),
                SurveyOption(id: "q10_opt_3", text: "We support each other, but it requires active negotiation to make sure neither person feels overwhelmed.", rawScoreValue: 0.60),
                SurveyOption(id: "q10_opt_4", text: "We reliably support each other according to what we can each manage at the time.", rawScoreValue: 0.80),
                SurveyOption(id: "q10_opt_5", text: "Effort flows seamlessly; we generously support each other according to our different capacities without keeping score.", rawScoreValue: 1.00)
            ]
        ),
        
        // 11. Resonant (R) - Communication & bridging differences
        SurveyQuestion(
            id: "q_11",
            prompt: "How effectively do you communicate and bridge the gap between your different backgrounds, minds, or experiences?",
            targetDomains: [DomainWeightMapping(domain: .resonant, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q11_opt_1", text: "We constantly misunderstand each other and make no effort to bridge the gap.", rawScoreValue: 0.20),
                SurveyOption(id: "q11_opt_2", text: "We frequently talk past one another, and differences in how we communicate create deep frustration.", rawScoreValue: 0.40),
                SurveyOption(id: "q11_opt_3", text: "We navigate our differences adequately, though complex issues still cause confusion.", rawScoreValue: 0.60),
                SurveyOption(id: "q11_opt_4", text: "We communicate effectively, actively working to understand the other person's unique perspective.", rawScoreValue: 0.80),
                SurveyOption(id: "q11_opt_5", text: "We bridge our differences beautifully; we cultivate a shared understanding that honors our unique ways of communicating.", rawScoreValue: 1.00)
            ]
        ),
        
        // 12. Resonant (R) - Sensing your emotional state
        SurveyQuestion(
            id: "q_12",
            prompt: "How well do they sense your emotional state?",
            targetDomains: [DomainWeightMapping(domain: .resonant, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q12_opt_1", text: "They are completely oblivious or indifferent to my emotions.", rawScoreValue: 0.20),
                SurveyOption(id: "q12_opt_2", text: "They only notice I am upset if I explicitly state it or exhibit extreme distress.", rawScoreValue: 0.40),
                SurveyOption(id: "q12_opt_3", text: "They notice obvious mood shifts but miss subtle feelings.", rawScoreValue: 0.60),
                SurveyOption(id: "q12_opt_4", text: "They accurately sense my feelings during most interactions.", rawScoreValue: 0.80),
                SurveyOption(id: "q12_opt_5", text: "They are deeply attuned, picking up on my subtlest emotional shifts immediately.", rawScoreValue: 1.00)
            ]
        ),
        
        // 13. Resonant (R) - Sensing their emotional state
        SurveyQuestion(
            id: "q_13",
            prompt: "How clearly can you sense what they are feeling?",
            targetDomains: [DomainWeightMapping(domain: .resonant, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q13_opt_1", text: "I have no idea what they are feeling; they are a completely closed book.", rawScoreValue: 0.20),
                SurveyOption(id: "q13_opt_2", text: "I struggle to read their feelings and often guess incorrectly.", rawScoreValue: 0.40),
                SurveyOption(id: "q13_opt_3", text: "I can pick up on their general mood (happy, mad, sad) but miss the nuances.", rawScoreValue: 0.60),
                SurveyOption(id: "q13_opt_4", text: "I can reliably read their emotional state in the moment.", rawScoreValue: 0.80),
                SurveyOption(id: "q13_opt_5", text: "I feel profoundly tuned into their emotional reality and easily feel what they feel.", rawScoreValue: 1.00)
            ]
        ),
        
        // 14. Resonant (R) - Emotional mutual impact awareness
        SurveyQuestion(
            id: "q_14",
            prompt: "How aware are both of you regarding how your feelings affect one another?",
            targetDomains: [DomainWeightMapping(domain: .resonant, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q14_opt_1", text: "Neither of us notices or cares how our moods impact the other person.", rawScoreValue: 0.20),
                SurveyOption(id: "q14_opt_2", text: "We only realize our emotional impact after an argument or hurt feelings occur.", rawScoreValue: 0.40),
                SurveyOption(id: "q14_opt_3", text: "We are somewhat aware, but our moods still frequently clash or cause accidental stress.", rawScoreValue: 0.60),
                SurveyOption(id: "q14_opt_4", text: "We are mindful of our impact and adjust our behavior when the other is struggling.", rawScoreValue: 0.80),
                SurveyOption(id: "q14_opt_5", text: "We are highly attuned; our emotional states naturally respond to and support one another.", rawScoreValue: 1.00)
            ]
        ),
        
        // 15. Resonant (R) - Clarity & groundedness
        SurveyQuestion(
            id: "q_15",
            prompt: "How does interacting with them affect your overall sense of clarity and groundedness?",
            targetDomains: [DomainWeightMapping(domain: .resonant, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q15_opt_1", text: "I feel totally lost, confused, or actively doubt reality when with them.", rawScoreValue: 0.20),
                SurveyOption(id: "q15_opt_2", text: "Conversations leave me feeling clouded, second-guessing things, or caught in confusing dynamics.", rawScoreValue: 0.40),
                SurveyOption(id: "q15_opt_3", text: "Things are generally straightforward, though our interactions don't necessarily provide deeper insight or focus.", rawScoreValue: 0.60),
                SurveyOption(id: "q15_opt_4", text: "I feel centered, steady, and clear-headed during and after our interactions.", rawScoreValue: 0.80),
                SurveyOption(id: "q15_opt_5", text: "Interactions leave me feeling profoundly clear, grounded, and focused; this connection brings out the best in me.", rawScoreValue: 1.00)
            ]
        ),
        
        // 16. Energetic (E) - Physical & mental energy
        SurveyQuestion(
            id: "q_16",
            prompt: "How do you feel physically and mentally after spending time with them?",
            targetDomains: [DomainWeightMapping(domain: .energetic, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q16_opt_1", text: "I leave interactions feeling completely exhausted, depleted, or drained.", rawScoreValue: 0.20),
                SurveyOption(id: "q16_opt_2", text: "I feel tired; navigating the interaction costs me more energy than it gives back.", rawScoreValue: 0.40),
                SurveyOption(id: "q16_opt_3", text: "My energy stays the same; the interaction is neutral.", rawScoreValue: 0.60),
                SurveyOption(id: "q16_opt_4", text: "I leave feeling refreshed, positive, and uplifted.", rawScoreValue: 0.80),
                SurveyOption(id: "q16_opt_5", text: "I am vibrantly recharged; the interaction deeply restores my energy.", rawScoreValue: 1.00)
            ]
        ),
        
        // 17. Energetic (E) - Time spent together
        SurveyQuestion(
            id: "q_17",
            prompt: "How do you feel about the time you spend together?",
            targetDomains: [DomainWeightMapping(domain: .energetic, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q17_opt_1", text: "I actively dread it; time together feels like a miserable obligation.", rawScoreValue: 0.20),
                SurveyOption(id: "q17_opt_2", text: "I find it boring or tense; I frequently watch the clock.", rawScoreValue: 0.40),
                SurveyOption(id: "q17_opt_3", text: "I find it generally pleasant, though routine or ordinary.", rawScoreValue: 0.60),
                SurveyOption(id: "q17_opt_4", text: "I genuinely enjoy our time and look forward to our interactions.", rawScoreValue: 0.80),
                SurveyOption(id: "q17_opt_5", text: "Spending time with them is a highlight of my life; it brings me genuine joy.", rawScoreValue: 1.00)
            ]
        ),
        
        // 18. Energetic (E) - Playfulness & humor
        SurveyQuestion(
            id: "q_18",
            prompt: "What role do playfulness and humor have in the relationship?",
            targetDomains: [DomainWeightMapping(domain: .energetic, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q18_opt_1", text: "None; interactions are strictly rigid, tense, or severe.", rawScoreValue: 0.20),
                SurveyOption(id: "q18_opt_2", text: "Humor is rare, forced, or sometimes used aggressively (e.g., biting sarcasm).", rawScoreValue: 0.40),
                SurveyOption(id: "q18_opt_3", text: "We share light moments and occasional polite smiles.", rawScoreValue: 0.60),
                SurveyOption(id: "q18_opt_4", text: "We regularly share genuine laughter and a lighthearted connection.", rawScoreValue: 0.80),
                SurveyOption(id: "q18_opt_5", text: "Spontaneous play, rich humor, and deep laughter are core foundations of our bond.", rawScoreValue: 1.00)
            ]
        ),
        
        // 19. Energetic (E) - Daily life & goals impact
        SurveyQuestion(
            id: "q_19",
            prompt: "How does this relationship affect your ability to manage your daily life and goals?",
            targetDomains: [DomainWeightMapping(domain: .energetic, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q19_opt_1", text: "It is severely distracting; the drama or stress actively harms my focus and goals.", rawScoreValue: 0.20),
                SurveyOption(id: "q19_opt_2", text: "It requires enough mental energy that I sometimes fall behind on my own priorities.", rawScoreValue: 0.40),
                SurveyOption(id: "q19_opt_3", text: "It doesn’t actively hinder me, but it doesn't boost my focus either.", rawScoreValue: 0.60),
                SurveyOption(id: "q19_opt_4", text: "It provides a supportive foundation that helps me comfortably manage my day.", rawScoreValue: 0.80),
                SurveyOption(id: "q19_opt_5", text: "It is highly catalytic; the connection actively inspires and motivates me to succeed.", rawScoreValue: 1.00)
            ]
        ),
        
        // 20. Energetic (E) - Uplift & reward
        SurveyQuestion(
            id: "q_20",
            prompt: "When you want to feel good or need a boost, how does this relationship factor in?",
            targetDomains: [DomainWeightMapping(domain: .energetic, weightMultiplier: 1.0)],
            options: [
                SurveyOption(id: "q20_opt_1", text: "I completely avoid them; I turn to isolation or unhealthy habits to cope instead.", rawScoreValue: 0.20),
                SurveyOption(id: "q20_opt_2", text: "I rarely turn to them; I'd rather seek distractions (shopping, scrolling, etc.) to feel better.", rawScoreValue: 0.40),
                SurveyOption(id: "q20_opt_3", text: "I occasionally turn to them, but it’s a coin-toss whether it will actually make me feel better.", rawScoreValue: 0.60),
                SurveyOption(id: "q20_opt_4", text: "Reaching out to them is one of my primary, reliable ways to feel motivated and positive.", rawScoreValue: 0.80),
                SurveyOption(id: "q20_opt_5", text: "Simply thinking about our connection provides me with a profound sense of enthusiasm and reward.", rawScoreValue: 1.00)
            ]
        )
    ]
    
    static var mockQuestionBank: [SurveyQuestion] {
        return full20QuestionBank
    }
}
