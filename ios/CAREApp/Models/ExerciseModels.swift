import Foundation

// MARK: - Exercise Category
public enum ExerciseCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case calm = "Calm"
    case accepted = "Accepted"
    case resonant = "Resonant"
    case energetic = "Energetic"
    
    public var id: String { rawValue }
    
    public var pathwayDescription: String {
        switch self {
        case .calm:
            return "Exercises for feeling safe, grounded & connected."
        case .accepted:
            return "Exercises for feeling valued, validated & included."
        case .resonant:
            return "Exercises for emotional attunement & mutual empathy."
        case .energetic:
            return "Exercises for vitality, zest & shared motivation."
        }
    }
}

// MARK: - Exercise Item Model
public struct ExerciseItem: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let category: ExerciseCategory
    public let emoji: String
    public let subtitle: String
    public let durationMinutesRange: String
    public var timesCompleted: Int
    public var lastCompletedDate: String?
    public var ratingStars: Int
    public var isFavorite: Bool
    
    public init(
        id: String,
        title: String,
        category: ExerciseCategory,
        emoji: String,
        subtitle: String,
        durationMinutesRange: String,
        timesCompleted: Int = 0,
        lastCompletedDate: String? = nil,
        ratingStars: Int = 0,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.emoji = emoji
        self.subtitle = subtitle
        self.durationMinutesRange = durationMinutesRange
        self.timesCompleted = timesCompleted
        self.lastCompletedDate = lastCompletedDate
        self.ratingStars = ratingStars
        self.isFavorite = isFavorite
    }
    
    public static let sampleCalmExercises: [ExerciseItem] = [
        ExerciseItem(
            id: "watch-something-funny",
            title: "Watch Something Funny",
            category: .calm,
            emoji: "🎬",
            subtitle: "A quick way to reconnect with joy and shift your nervous system.",
            durationMinutesRange: "2-5 min",
            timesCompleted: 8,
            lastCompletedDate: "Sep 18",
            ratingStars: 4,
            isFavorite: true
        ),
        ExerciseItem(
            id: "keep-photo-close",
            title: "Keep a Photo Close",
            category: .calm,
            emoji: "📷",
            subtitle: "Ground yourself with an image of someone you love.",
            durationMinutesRange: "1-2 min",
            timesCompleted: 5,
            lastCompletedDate: "Sep 15",
            ratingStars: 5,
            isFavorite: false
        )
    ]
    
    public static let sampleResonantExercises: [ExerciseItem] = [
        ExerciseItem(
            id: "mirror-loved-one",
            title: "Mirror a Loved One's Emotions",
            category: .resonant,
            emoji: "🎭",
            subtitle: "Practice noticing and reflecting the precise emotional states of someone close to you.",
            durationMinutesRange: "2-5 min",
            timesCompleted: 3,
            lastCompletedDate: "Sep 18",
            ratingStars: 4
        ),
        ExerciseItem(
            id: "empathic-listening",
            title: "Empathic Listening Practice",
            category: .resonant,
            emoji: "👂",
            subtitle: "Listen to understand, not to respond. Focus entirely on feeling what the other person feels.",
            durationMinutesRange: "5-10 min",
            timesCompleted: 1,
            lastCompletedDate: "Sep 15",
            ratingStars: 5
        ),
        ExerciseItem(
            id: "resonance-breathing",
            title: "Resonance Breathing with a Partner",
            category: .resonant,
            emoji: "🌬️",
            subtitle: "Sync your breathing with someone you trust to build physiological and emotional attunement.",
            durationMinutesRange: "5 min",
            timesCompleted: 0,
            lastCompletedDate: "Never",
            ratingStars: 0
        )
    ]
}
