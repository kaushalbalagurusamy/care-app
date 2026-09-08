import Foundation

// MARK: - Topic Slugs
public enum EducationTopicSlug: String, Codable, Sendable, CaseIterable, Hashable {
    case relationalCulturalTheory = "relational-cultural-theory"
    case relationalNeuroscience = "relational-neuroscience"
    case neuroplasticity = "neuroplasticity"
    case brainHealthyRelationships = "brain-healthy-relationships"
    case powerOverVsPowerWith = "power-over-vs-power-with"
    case impactOfRelationships = "impact-of-relationships"
}

// MARK: - Founder Profile
public struct FounderProfile: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let titleAndDegrees: String
    public let biography: String
    public let imageAsset: String?
    
    public init(
        id: String,
        name: String,
        titleAndDegrees: String,
        biography: String,
        imageAsset: String? = nil
    ) {
        self.id = id
        self.name = name
        self.titleAndDegrees = titleAndDegrees
        self.biography = biography
        self.imageAsset = imageAsset
    }
}

// MARK: - Five Good Things Item
public struct FiveGoodThingsItem: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let index: Int
    public let title: String
    public let neuroDescription: String
    
    public init(id: String, index: Int, title: String, neuroDescription: String) {
        self.id = id
        self.index = index
        self.title = title
        self.neuroDescription = neuroDescription
    }
}

// MARK: - Neural Pathway Item
public struct NeuralPathwayItem: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let domain: CAREDomain
    public let name: String
    public let brainRegion: String
    public let function: String
    public let exerciseSuggestion: String
    
    public init(
        id: String,
        domain: CAREDomain,
        name: String,
        brainRegion: String,
        function: String,
        exerciseSuggestion: String
    ) {
        self.id = id
        self.domain = domain
        self.name = name
        self.brainRegion = brainRegion
        self.function = function
        self.exerciseSuggestion = exerciseSuggestion
    }
}

// MARK: - Knowledge Check Quiz Models
public struct QuizOption: Identifiable, Codable, Hashable, Sendable {
    public var id: String { letter }
    public let letter: String // "A", "B", "C", "D"
    public let text: String
    
    public init(letter: String, text: String) {
        self.letter = letter
        self.text = text
    }
}

public struct QuizQuestion: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let prompt: String
    public let options: [QuizOption]
    public let correctOptionLetter: String // "A", "B", "C", or "D"
    public let rationale: String
    
    public init(
        id: String,
        prompt: String,
        options: [QuizOption],
        correctOptionLetter: String,
        rationale: String
    ) {
        self.id = id
        self.prompt = prompt
        self.options = options
        self.correctOptionLetter = correctOptionLetter
        self.rationale = rationale
    }
}

// MARK: - Polymorphic Education Section Payload
public enum EducationSectionPayload: Codable, Hashable, Sendable {
    case textOverview(heading: String, body: String)
    case foundersGrid(founders: [FounderProfile])
    case fiveGoodThings(items: [FiveGoodThingsItem])
    case neuralPathwayMapping(pathways: [NeuralPathwayItem])
    case illustrationParagraph(imageAsset: String, body: String)
    case keyTakeaways(points: [String])
    
    private enum CodingKeys: String, CodingKey {
        case type, heading, body, founders, items, pathways, imageAsset, points
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "textOverview":
            let heading = try container.decode(String.self, forKey: .heading)
            let body = try container.decode(String.self, forKey: .body)
            self = .textOverview(heading: heading, body: body)
            
        case "foundersGrid":
            let founders = try container.decode([FounderProfile].self, forKey: .founders)
            self = .foundersGrid(founders: founders)
            
        case "fiveGoodThings":
            let items = try container.decode([FiveGoodThingsItem].self, forKey: .items)
            self = .fiveGoodThings(items: items)
            
        case "neuralPathwayMapping":
            let pathways = try container.decode([NeuralPathwayItem].self, forKey: .pathways)
            self = .neuralPathwayMapping(pathways: pathways)
            
        case "illustrationParagraph":
            let imageAsset = try container.decode(String.self, forKey: .imageAsset)
            let body = try container.decode(String.self, forKey: .body)
            self = .illustrationParagraph(imageAsset: imageAsset, body: body)
            
        case "keyTakeaways":
            let points = try container.decode([String].self, forKey: .points)
            self = .keyTakeaways(points: points)
            
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown EducationSectionPayload type: \(type)"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .textOverview(let heading, let body):
            try container.encode("textOverview", forKey: .type)
            try container.encode(heading, forKey: .heading)
            try container.encode(body, forKey: .body)
            
        case .foundersGrid(let founders):
            try container.encode("foundersGrid", forKey: .type)
            try container.encode(founders, forKey: .founders)
            
        case .fiveGoodThings(let items):
            try container.encode("fiveGoodThings", forKey: .type)
            try container.encode(items, forKey: .items)
            
        case .neuralPathwayMapping(let pathways):
            try container.encode("neuralPathwayMapping", forKey: .type)
            try container.encode(pathways, forKey: .pathways)
            
        case .illustrationParagraph(let imageAsset, let body):
            try container.encode("illustrationParagraph", forKey: .type)
            try container.encode(imageAsset, forKey: .imageAsset)
            try container.encode(body, forKey: .body)
            
        case .keyTakeaways(let points):
            try container.encode("keyTakeaways", forKey: .type)
            try container.encode(points, forKey: .points)
        }
    }
}

// MARK: - Core Education Topic Model
public struct EducationTopic: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let slug: EducationTopicSlug
    public let title: String
    public let subtitle: String
    public let iconAsset: String
    public let estimatedReadMinutes: Int
    public let sections: [EducationSectionPayload]
    public let quizBank: [QuizQuestion]
    
    public var quiz: QuizQuestion {
        quizBank.first ?? QuizQuestion(
            id: "\(slug.rawValue)-fallback",
            prompt: "Knowledge check for \(title)",
            options: [
                QuizOption(letter: "A", text: "Option A"),
                QuizOption(letter: "B", text: "Option B"),
                QuizOption(letter: "C", text: "Option C"),
                QuizOption(letter: "D", text: "Option D")
            ],
            correctOptionLetter: "A",
            rationale: "Rationale pending"
        )
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, slug, title, subtitle, iconAsset, estimatedReadMinutes, sections, quizBank, quiz
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.slug = try container.decode(EducationTopicSlug.self, forKey: .slug)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        self.iconAsset = try container.decode(String.self, forKey: .iconAsset)
        self.estimatedReadMinutes = try container.decode(Int.self, forKey: .estimatedReadMinutes)
        self.sections = try container.decode([EducationSectionPayload].self, forKey: .sections)
        
        if let bank = try container.decodeIfPresent([QuizQuestion].self, forKey: .quizBank), !bank.isEmpty {
            self.quizBank = bank
        } else if let single = try container.decodeIfPresent(QuizQuestion.self, forKey: .quiz) {
            self.quizBank = [single]
        } else {
            self.quizBank = []
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(slug, forKey: .slug)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(iconAsset, forKey: .iconAsset)
        try container.encode(estimatedReadMinutes, forKey: .estimatedReadMinutes)
        try container.encode(sections, forKey: .sections)
        try container.encode(quizBank, forKey: .quizBank)
        if let first = quizBank.first {
            try container.encode(first, forKey: .quiz)
        }
    }
    
    public init(
        id: String,
        slug: EducationTopicSlug,
        title: String,
        subtitle: String,
        iconAsset: String,
        estimatedReadMinutes: Int,
        sections: [EducationSectionPayload],
        quizBank: [QuizQuestion]
    ) {
        self.id = id
        self.slug = slug
        self.title = title
        self.subtitle = subtitle
        self.iconAsset = iconAsset
        self.estimatedReadMinutes = estimatedReadMinutes
        self.sections = sections
        self.quizBank = quizBank
    }
    
    public init(
        id: String,
        slug: EducationTopicSlug,
        title: String,
        subtitle: String,
        iconAsset: String,
        estimatedReadMinutes: Int,
        sections: [EducationSectionPayload],
        quiz: QuizQuestion
    ) {
        self.id = id
        self.slug = slug
        self.title = title
        self.subtitle = subtitle
        self.iconAsset = iconAsset
        self.estimatedReadMinutes = estimatedReadMinutes
        self.sections = sections
        self.quizBank = [quiz]
    }
}

// MARK: - Manifest Loader & Error Types
public enum EducationManifestError: Error, LocalizedError {
    case manifestNotFound
    case decodingFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .manifestNotFound:
            return "EducationManifest.json could not be located in any bundle or file path."
        case .decodingFailed(let underlying):
            return "Failed to decode EducationManifest.json: \(underlying.localizedDescription)"
        }
    }
}

public enum EducationManifestLoader {
    public static func loadBundledManifest() throws -> [EducationTopic] {
        // 1. Try Bundle.main
        if let url = Bundle.main.url(forResource: "EducationManifest", withExtension: "json") {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([EducationTopic].self, from: data)
        }
        
        // 2. Search all loaded bundles (for unit test target hosts)
        for bundle in Bundle.allBundles {
            if let url = bundle.url(forResource: "EducationManifest", withExtension: "json") {
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode([EducationTopic].self, from: data)
            }
        }
        
        // 3. Fallback to direct relative paths for CLI / xcodebuild test execution
        let fallbackPaths = [
            "Resources/Education/EducationManifest.json",
            "ios/CAREApp/Resources/Education/EducationManifest.json",
            "../ios/CAREApp/Resources/Education/EducationManifest.json"
        ]
        for path in fallbackPaths {
            if FileManager.default.fileExists(atPath: path),
               let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                return try JSONDecoder().decode([EducationTopic].self, from: data)
            }
        }
        
        throw EducationManifestError.manifestNotFound
    }
}
