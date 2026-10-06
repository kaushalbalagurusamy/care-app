import Foundation
import Observation
import SwiftUI
import SwiftData
import Photos
import AVKit

// MARK: - Exercise Category
public enum ExerciseCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case calm = "Calm"
    case accepted = "Accepted"
    case resonant = "Resonant"
    case energetic = "Energetic"
    
    public var id: String { rawValue }

    public var badgeColor: Color {
        switch self {
        case .calm: return Theme.Colors.Domains.calm
        case .accepted: return Theme.Colors.Domains.accepted
        case .resonant: return Theme.Colors.Domains.resonant
        case .energetic: return Theme.Colors.Domains.energetic
        }
    }

    public var accentColor: Color {
        switch self {
        case .calm: return Theme.Colors.Domains.calmAccent
        case .accepted: return Theme.Colors.Domains.acceptedAccent
        case .resonant: return Theme.Colors.Domains.resonantAccent
        case .energetic: return Theme.Colors.Domains.energeticAccent
        }
    }
    
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
    public let minimumDurationMinutes: Int
    public let maximumDurationMinutes: Int
    public var timesCompleted: Int
    public var lastCompletedDate: String?
    public var ratingStars: Int
    public var isFavorite: Bool

    // The labels on the reviewed exercise screens are the source for these
    // catalog traits. Exercises without a two-person label can be done solo.
    public var isPositiveRelationalMoment: Bool {
        Self.positiveRelationalMomentIDs.contains(id)
    }

    public var requiresTwoPeople: Bool {
        Self.twoPersonExerciseIDs.contains(id)
    }

    private static let positiveRelationalMomentIDs: Set<String> = [
        "keep-photo-close", "accepted-moments-library", "save-a-resonant-moment",
        "revisit-an-early-spark", "recall-a-warm-connection"
    ]

    private static let twoPersonExerciseIDs: Set<String> = [
        "active-listening-together", "relational-mindfulness", "ask-for-a-safe-hug",
        "what-are-you-hiding", "listen-across-difference", "invite-a-trusted-perspective",
        "check-your-read", "practice-feeling-better-together", "revisit-an-early-spark",
        "move-together", "daylight-connection", "make-a-nourishing-meal-together",
        "try-something-new-together", "make-a-tiny-project-together",
        "do-a-small-kindness-together", "share-a-music-moment"
    ]
    
    public init(
        id: String,
        title: String,
        category: ExerciseCategory,
        emoji: String,
        subtitle: String,
        durationMinutesRange: String,
        minimumDurationMinutes: Int,
        maximumDurationMinutes: Int,
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
        precondition(minimumDurationMinutes > 0 && maximumDurationMinutes >= minimumDurationMinutes)
        self.minimumDurationMinutes = minimumDurationMinutes
        self.maximumDurationMinutes = maximumDurationMinutes
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
            durationMinutesRange: "7–10 min",
            minimumDurationMinutes: 7,
            maximumDurationMinutes: 10,
            timesCompleted: 0
        ),
        ExerciseItem(
            id: "keep-photo-close",
            title: "Keep a Photo Close",
            category: .calm,
            emoji: "📷",
            subtitle: "Ground yourself with an image of someone you love.",
            durationMinutesRange: "1–2 min",
            minimumDurationMinutes: 1,
            maximumDurationMinutes: 2,
            timesCompleted: 0
        )
    ]
    
    public static let sampleAcceptedExercises: [ExerciseItem] = [
        ExerciseItem(id: "belonging-list", title: "Make a Belonging List", category: .accepted, emoji: "👥", subtitle: "Notice the people, places, and communities where you feel you belong.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        ExerciseItem(id: "share-something-small", title: "Share Something Small", category: .accepted, emoji: "💬", subtitle: "Share a small thought or appreciation with someone you trust.", durationMinutesRange: "2–5 min", minimumDurationMinutes: 2, maximumDurationMinutes: 5)
    ]

    public static let sampleResonantExercises: [ExerciseItem] = [
        ExerciseItem(
            id: "mirror-emotion",
            title: "Mirror the Emotion",
            category: .resonant,
            emoji: "🎥",
            subtitle: "Gently mirror expressions and notice any shift in your mood.",
            durationMinutesRange: "2–4 min",
            minimumDurationMinutes: 2,
            maximumDurationMinutes: 4
        ),
        ExerciseItem(
            id: "mirror-loved-one",
            title: "Mirror Someone You Love",
            category: .resonant,
            emoji: "📷",
            subtitle: "Mirror a loved one’s expressions and notice what shifts in you.",
            durationMinutesRange: "2–5 min",
            minimumDurationMinutes: 2,
            maximumDurationMinutes: 5
        )
    ]

    public static let sampleEnergeticExercises: [ExerciseItem] = [
        ExerciseItem(id: "share-something-new", title: "Share Something New", category: .energetic, emoji: "💡", subtitle: "Send a new discovery to someone who might enjoy it.", durationMinutesRange: "2–5 min", minimumDurationMinutes: 2, maximumDurationMinutes: 5),
        ExerciseItem(id: "connection-countdown", title: "Connection Countdown", category: .energetic, emoji: "⌛", subtitle: "Look forward to a small moment with someone you care about.", durationMinutesRange: "1–3 min", minimumDurationMinutes: 1, maximumDurationMinutes: 3)
    ]

    // Paid catalog preview: titles, descriptions, and durations transcribed from
    // the current CARE Figma exercise screens. Detailed exercise flows follow later.
    public static let additionalExercises: [ExerciseItem] = [
        .init(id: "build-safe-support-plan", title: "Build a Safe Support Plan", category: .calm, emoji: "🛟", subtitle: "Identify steady people and make clear expectations that help you feel secure when the situation feels hard.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "practice-pausing", title: "Practice Pausing", category: .calm, emoji: "⏸️", subtitle: "Rehearse a steady pause with a supportive memory before a difficult moment.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "relabel-stress-story", title: "Relabel and Refocus", category: .calm, emoji: "💭", subtitle: "Notice a stressful thought, pause with your breath, and choose a steadier view.", durationMinutesRange: "5–7 min", minimumDurationMinutes: 5, maximumDurationMinutes: 7),
        .init(id: "notice-friendly-exchange", title: "Notice a Friendly Exchange", category: .calm, emoji: "🙂", subtitle: "Let a small moment of warmth register and notice what it brings up in you.", durationMinutesRange: "2–4 min", minimumDurationMinutes: 2, maximumDurationMinutes: 4),
        .init(id: "listen-yourself-into-safety", title: "Listen Yourself into Safety", category: .calm, emoji: "🎧", subtitle: "Choose a familiar sound or voice and notice how it helps your body settle.", durationMinutesRange: "2–5 min", minimumDurationMinutes: 2, maximumDurationMinutes: 5),
        .init(id: "active-listening-together", title: "Active Listening Together", category: .calm, emoji: "👂", subtitle: "Practice taking turns so both of you can feel heard, understood, and unhurried.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "relational-mindfulness", title: "Relational Mindfulness", category: .calm, emoji: "🧘", subtitle: "Share a few quiet minutes of attention, consent, and presence with someone you trust.", durationMinutesRange: "2–4 min", minimumDurationMinutes: 2, maximumDurationMinutes: 4),
        .init(id: "meditation-pause", title: "Meditation Pause", category: .calm, emoji: "🧘", subtitle: "Sit with your breath and notice what is here, without needing to change it.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "alternate-nostril-breathing", title: "Alternate Nostril Breathing", category: .calm, emoji: "🌬️", subtitle: "Learn a slow four-minute breathing pattern that can help your body settle.", durationMinutesRange: "4–5 min", minimumDurationMinutes: 4, maximumDurationMinutes: 5),
        .init(id: "play-with-a-pet", title: "Play with a Pet", category: .calm, emoji: "🐾", subtitle: "Spend a few minutes in gentle play, noticing warmth, delight, and shared attention.", durationMinutesRange: "2–5 min", minimumDurationMinutes: 2, maximumDurationMinutes: 5),
        .init(id: "warm-bath-reset", title: "Warm Bath Reset", category: .calm, emoji: "🛁", subtitle: "Use comfortable warmth and unhurried rest to help your body soften and settle.", durationMinutesRange: "5–10 min", minimumDurationMinutes: 5, maximumDurationMinutes: 10),
        .init(id: "massage-for-relaxation", title: "Massage for Relaxation", category: .calm, emoji: "🤲", subtitle: "Use gentle, comfortable touch to invite your body to soften, rest, and feel supported.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "ask-for-a-safe-hug", title: "Ask for a Safe Hug", category: .calm, emoji: "🫂", subtitle: "Ask someone you trust for a hug that feels safe, welcome, and easy to decline.", durationMinutesRange: "2–4 min", minimumDurationMinutes: 2, maximumDurationMinutes: 4),
        .init(id: "move-out-of-freeze", title: "Move Out of Freeze", category: .calm, emoji: "🌱", subtitle: "Use small, comfortable movements to help your body reconnect with the present.", durationMinutesRange: "2–4 min", minimumDurationMinutes: 2, maximumDurationMinutes: 4),
        .init(id: "spot-removal", title: "SPOT Removal", category: .accepted, emoji: "💚", subtitle: "Notice how exclusion and judgment shape your thoughts, body, and relationships. Practice relabeling a judgment and choosing a more connected response.", durationMinutesRange: "30–35 min", minimumDurationMinutes: 30, maximumDurationMinutes: 35),
        .init(id: "what-are-you-hiding", title: "What Are You Hiding?", category: .accepted, emoji: "💚", subtitle: "Notice what you keep private and why that may feel protective. If it feels safe, invite someone you trust to share one small thing, with room for either person to pass.", durationMinutesRange: "5–10 min", minimumDurationMinutes: 5, maximumDurationMinutes: 10),
        .init(id: "root-chakra-work", title: "Root Chakra Work", category: .accepted, emoji: "💚", subtitle: "Rest your hands where they feel comfortable, then imagine roots growing from your feet into the earth. As you breathe, picture steady energy rising back through you.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "compassion-meditation", title: "Compassion Meditation", category: .accepted, emoji: "🧘", subtitle: "Begin with kind wishes for yourself and people you know, then widen the circle at your own pace. Notice how the practice feels without forcing a particular emotion.", durationMinutesRange: "5–7 min", minimumDurationMinutes: 5, maximumDurationMinutes: 7),
        .init(id: "notice-the-pullback", title: "Notice the Pullback", category: .accepted, emoji: "💚", subtitle: "Notice when uncertainty makes you hold back.", durationMinutesRange: "2–3 min", minimumDurationMinutes: 2, maximumDurationMinutes: 3),
        .init(id: "accepted-moments-library", title: "Positive Relational Moments", category: .accepted, emoji: "💚", subtitle: "Recall a moment when you felt welcomed or at ease. Save the words, sensations, and details that could help you revisit that feeling later.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "feedback-that-connects", title: "Feedback That Connects", category: .accepted, emoji: "💚", subtitle: "Start with a small, manageable conflict. Turn a label into an observation, explain its effect on you, and form a respectful request.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "listen-across-difference", title: "Listen Across Difference", category: .accepted, emoji: "💚", subtitle: "Choose a low-stakes difference and take turns speaking and listening without interruption. Reflect on what helped each person feel heard, whether or not you agree.", durationMinutesRange: "8–10 min", minimumDurationMinutes: 8, maximumDurationMinutes: 10),
        .init(id: "hot-button-practice", title: "Hot Button Practice", category: .accepted, emoji: "💚", subtitle: "Rehearse a difficult moment in a safe setting. Notice your first reaction, try another interpretation, and choose responses that fit your values and limits.", durationMinutesRange: "5–7 min", minimumDurationMinutes: 5, maximumDurationMinutes: 7),
        .init(id: "name-what-hurts", title: "Name What Hurts", category: .accepted, emoji: "💚", subtitle: "Find a more precise word for a social feeling.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "a-kind-note", title: "A Kind Note", category: .accepted, emoji: "💚", subtitle: "Notice a manageable moment of social hurt, then write to yourself with the care you would offer a friend. Let the words be kind without forcing yourself to feel better.", durationMinutesRange: "5–7 min", minimumDurationMinutes: 5, maximumDurationMinutes: 7),
        .init(id: "choose-your-support", title: "Choose Your Support", category: .accepted, emoji: "💚", subtitle: "Notice the kind of support you want and the people or places that might offer it. Draft a clear request you can keep private or share when ready.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "values-beyond-approval", title: "Values Beyond Approval", category: .accepted, emoji: "💚", subtitle: "Choose a value that matters to you beyond others' opinions. Plan one small action that expresses it, even if no one notices or praises you.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "plan-in-person-connection", title: "Plan an In-Person Connection", category: .resonant, emoji: "🤝", subtitle: "Make a gentle plan for spending time with someone who helps you feel seen. Choose a simple moment that feels comfortable, and share the plan when you are ready.", durationMinutesRange: "5–10 min", minimumDurationMinutes: 5, maximumDurationMinutes: 10),
        .init(id: "make-room-for-resonant-relationships", title: "Make Room for Resonant Relationships", category: .resonant, emoji: "💜", subtitle: "Choose one relationship from your assessments that you’d like to grow, then try one small change to nurture it.", durationMinutesRange: "10–15 min", minimumDurationMinutes: 10, maximumDurationMinutes: 15),
        .init(id: "find-an-emotion-in-your-body", title: "Find an Emotion in Your Body", category: .resonant, emoji: "🫶", subtitle: "Begin with a feeling and a memory that feel manageable. Notice where the feeling shows up in your body, then compare what changes when you recall another positive relational moment.", durationMinutesRange: "8–12 min", minimumDurationMinutes: 8, maximumDurationMinutes: 12),
        .init(id: "name-the-emotional-spectrum", title: "Name the Emotional Spectrum", category: .resonant, emoji: "🌈", subtitle: "Emotions can arrive in different strengths. Choose one feeling, explore its range from mild to strong, and notice the signals that help you name it more clearly.", durationMinutesRange: "6–10 min", minimumDurationMinutes: 6, maximumDurationMinutes: 10),
        .init(id: "bring-feelings-and-thoughts-together", title: "Bring Feelings and Thoughts Together", category: .resonant, emoji: "💭", subtitle: "When thoughts and feelings arrive together, we feel more integrated. Give each one a name, then practice expressing both in a clear statement that honors your experience.", durationMinutesRange: "8–12 min", minimumDurationMinutes: 8, maximumDurationMinutes: 12),
        .init(id: "choose-a-gentler-media-moment", title: "Choose a Gentler Media Moment", category: .resonant, emoji: "📺", subtitle: "Notice how what you watch affects your mood. Choose one small swap toward something playful, kind, or collaborative, and check how your body feels afterward.", durationMinutesRange: "5–10 min", minimumDurationMinutes: 5, maximumDurationMinutes: 10),
        .init(id: "notice-a-relational-template", title: "Notice a Relational Template", category: .resonant, emoji: "🧩", subtitle: "An old relationship rule can shape how a new moment feels. Notice one familiar assumption, then make room for other explanations that may also fit.", durationMinutesRange: "8–12 min", minimumDurationMinutes: 8, maximumDurationMinutes: 12),
        .init(id: "spot-patterns-across-relationships", title: "Spot Patterns Across Relationships", category: .resonant, emoji: "🔎", subtitle: "Look across your relationships for a pattern that keeps returning. You can draw on your C.A.R.E. assessment, then choose one gentle way to respond differently.", durationMinutesRange: "8–12 min", minimumDurationMinutes: 8, maximumDurationMinutes: 12),
        .init(id: "invite-a-trusted-perspective", title: "Invite a Trusted Perspective", category: .resonant, emoji: "👥", subtitle: "With someone you trust, ask how they experienced a small interaction and listen with curiosity. Reflect on what you learned; you may share your reflection afterward if you wish.", durationMinutesRange: "10–15 min", minimumDurationMinutes: 10, maximumDurationMinutes: 15),
        .init(id: "find-a-bridging-truth", title: "Find a Bridging Truth", category: .resonant, emoji: "🌉", subtitle: "Choose a manageable disagreement and hold your view alongside a possible view from the other person. Look for a statement that respects both without forcing agreement.", durationMinutesRange: "12–18 min", minimumDurationMinutes: 12, maximumDurationMinutes: 18),
        .init(id: "read-a-characters-feelings", title: "Read a Character’s Feelings", category: .resonant, emoji: "🎬", subtitle: "Watch a short, gentle expression clip and practice noticing visible clues. Try more than one interpretation before deciding what a character may be feeling.", durationMinutesRange: "5–8 min", minimumDurationMinutes: 5, maximumDurationMinutes: 8),
        .init(id: "relabel-an-old-relational-image", title: "Relabel an Old Relational Image", category: .resonant, emoji: "🖼️", subtitle: "Notice a familiar relational story when it appears, name it as an old pattern, and reconnect with a memory of being seen or supported. Move at a pace that feels safe.", durationMinutesRange: "10–15 min", minimumDurationMinutes: 10, maximumDurationMinutes: 15),
        .init(id: "mirror-a-gentle-gesture", title: "Mirror a Gentle Gesture", category: .resonant, emoji: "🪞", subtitle: "Choose a short demonstration, then try a gentle facial expression or movement at your own pace. Notice whether mirroring changes your sense of connection.", durationMinutesRange: "5–8 min", minimumDurationMinutes: 5, maximumDurationMinutes: 8),
        .init(id: "check-your-read", title: "Check Your Read", category: .resonant, emoji: "👀", subtitle: "With someone you trust, gently check whether your reading of their emotion was close. Let their answer add to what you noticed, without needing to be exactly right.", durationMinutesRange: "5–8 min", minimumDurationMinutes: 5, maximumDurationMinutes: 8),
        .init(id: "save-a-resonant-moment", title: "Save a Resonant Moment", category: .resonant, emoji: "📷", subtitle: "Keep a small reminder of a time you felt understood or connected. A photo can help you revisit that feeling, and you may share the memory with someone if you wish.", durationMinutesRange: "5–8 min", minimumDurationMinutes: 5, maximumDurationMinutes: 8),
        .init(id: "map-your-feel-good-sources", title: "Map Your Feel-Good Sources", category: .energetic, emoji: "🗺️", subtitle: "Notice where you look for a lift, from people and movement to food, work, and screens. Map what feels nourishing and choose one small source of connection to make room for this week.", durationMinutesRange: "5–10 min", minimumDurationMinutes: 5, maximumDurationMinutes: 10),
        .init(id: "find-your-high-zest-people", title: "Find Your High-Zest People", category: .energetic, emoji: "✨", subtitle: "Think about the people whose presence leaves you more alive and at ease. Name a few, choose one connection to nurture, and make a realistic plan for reaching out.", durationMinutesRange: "5–10 min", minimumDurationMinutes: 5, maximumDurationMinutes: 10),
        .init(id: "energetic-relabel-and-refocus", title: "Relabel and Refocus", category: .energetic, emoji: "🔎", subtitle: "When a craving for a quick reward appears, pause to notice what you need. Try naming the feeling, then choose a response that supports your energy and sense of connection.", durationMinutesRange: "5 min", minimumDurationMinutes: 5, maximumDurationMinutes: 5),
        .init(id: "practice-feeling-better-together", title: "Practice Feeling Better Together", category: .energetic, emoji: "🤝", subtitle: "Invite someone you trust to share a brief, supportive pause. Notice what each of you needs, try one caring response together, and reflect on how connection changes the moment.", durationMinutesRange: "5–10 min", minimumDurationMinutes: 5, maximumDurationMinutes: 10),
        .init(id: "revisit-an-early-spark", title: "Revisit an Early Spark", category: .energetic, emoji: "💫", subtitle: "With someone close to you, remember an early moment of ease, excitement, or fun. Share the details that still feel alive and find one small way to bring that spirit into the present.", durationMinutesRange: "5–10 min", minimumDurationMinutes: 5, maximumDurationMinutes: 10),
        .init(id: "move-together", title: "Move Together", category: .energetic, emoji: "🚶", subtitle: "Choose a gentle movement you can enjoy with another person. Move at a comfortable pace, then notice whether sharing the experience changes your energy or mood.", durationMinutesRange: "5–15 min", minimumDurationMinutes: 5, maximumDurationMinutes: 15),
        .init(id: "daylight-connection", title: "Daylight Connection", category: .energetic, emoji: "☀️", subtitle: "Spend a brief moment outdoors with another person when daylight is available. Let the light, air, and shared company become an easy setting for connection.", durationMinutesRange: "5–15 min", minimumDurationMinutes: 5, maximumDurationMinutes: 15),
        .init(id: "make-a-nourishing-meal-together", title: "Make a Nourishing Meal Together", category: .energetic, emoji: "🥣", subtitle: "Plan and prepare a simple meal or snack with someone else. Share the choices and the work, then enjoy how making something together can become its own reward.", durationMinutesRange: "15–30 min", minimumDurationMinutes: 15, maximumDurationMinutes: 30),
        .init(id: "share-a-small-win", title: "Share a Small Win", category: .energetic, emoji: "🏅", subtitle: "Take a moment to notice something you finished, tried, or showed up for. Let yourself feel the win, and share it with someone if that would add to the joy.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "try-something-new-together", title: "Try Something New Together", category: .energetic, emoji: "🧭", subtitle: "Choose a manageable new experience with someone you trust. Keep the stakes low, enjoy the discovery, and notice what you learned about each other.", durationMinutesRange: "10–20 min", minimumDurationMinutes: 10, maximumDurationMinutes: 20),
        .init(id: "make-a-tiny-project-together", title: "Make a Tiny Project Together", category: .energetic, emoji: "🛠️", subtitle: "Pick a small project you can finish with another person. Plan the first step, create it together, and notice the satisfaction of making shared progress.", durationMinutesRange: "15–30 min", minimumDurationMinutes: 15, maximumDurationMinutes: 30),
        .init(id: "say-what-you-appreciate", title: "Say What You Appreciate", category: .energetic, emoji: "💌", subtitle: "Notice one specific quality or action you appreciate in someone. Put it into your own words, then decide whether you would like to send it.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "do-a-small-kindness-together", title: "Do a Small Kindness Together", category: .energetic, emoji: "🌱", subtitle: "Join someone in a small act that could make another person’s day easier. Choose a doable action, share the effort, and reflect on the experience.", durationMinutesRange: "10–20 min", minimumDurationMinutes: 10, maximumDurationMinutes: 20),
        .init(id: "share-a-music-moment", title: "Share a Music Moment", category: .energetic, emoji: "🎵", subtitle: "Pick a song with someone and listen together. Notice the rhythm, memory, or feeling it brings up, then share what each of you heard.", durationMinutesRange: "5–10 min", minimumDurationMinutes: 5, maximumDurationMinutes: 10),
        .init(id: "find-a-small-delight", title: "Find a Small Delight", category: .energetic, emoji: "🌼", subtitle: "Look for one pleasant detail in your day, however small. Slow down long enough to notice it with your senses and let the moment count.", durationMinutesRange: "3 min", minimumDurationMinutes: 3, maximumDurationMinutes: 3),
        .init(id: "mark-a-tiny-win", title: "Mark a Tiny Win", category: .energetic, emoji: "⭐", subtitle: "Give yourself credit for one small effort today. Naming what you did can make progress easier to notice, even when the day feels ordinary.", durationMinutesRange: "3 min", minimumDurationMinutes: 3, maximumDurationMinutes: 3),
        .init(id: "recall-a-warm-connection", title: "Recall a Warm Connection", category: .energetic, emoji: "🧡", subtitle: "Bring to mind a moment when you felt seen, welcomed, or at ease with someone. Revisit the details privately and notice what that memory brings up now.", durationMinutesRange: "3–5 min", minimumDurationMinutes: 3, maximumDurationMinutes: 5),
        .init(id: "take-a-solo-movement-break", title: "Take a Solo Movement Break", category: .energetic, emoji: "🚶", subtitle: "Choose a gentle movement that fits your body and space. Try it for a few minutes, then notice any shift in your energy without expecting a particular result.", durationMinutesRange: "5–10 min", minimumDurationMinutes: 5, maximumDurationMinutes: 10),
        .init(id: "follow-your-curiosity", title: "Follow Your Curiosity", category: .energetic, emoji: "🔭", subtitle: "Pick one tiny thing you are curious about and explore it on your own. Let discovery be the reward, then notice what held your attention.", durationMinutesRange: "5–10 min", minimumDurationMinutes: 5, maximumDurationMinutes: 10)
    ]

    public static var allExercises: [ExerciseItem] {
        sampleCalmExercises + sampleAcceptedExercises + sampleResonantExercises + sampleEnergeticExercises + additionalExercises
    }
}

public struct ExerciseProgressRecord: Codable, Equatable {
    public var completionDates: [Date] = []
    public var completionTokens: [UUID]? = nil
    public var rating: Int = 0
    public var isFavorite: Bool = false
}

/// Sorts the static catalog against persisted activity. Equal keys preserve catalog order.
public enum ExerciseSortEngine {
    public static func sorted(_ items: [ExerciseItem], by option: ExerciseSortOption,
                              records: [String: ExerciseProgressRecord]) -> [ExerciseItem] {
        items.enumerated().sorted { left, right in
            let a = left.element
            let b = right.element
            let activityA = records[a.id] ?? .init()
            let activityB = records[b.id] ?? .init()
            switch option {
            case .mostRecentlyCompleted:
                let aDate = activityA.completionDates.max() ?? .distantPast
                let bDate = activityB.completionDates.max() ?? .distantPast
                if aDate != bDate { return aDate > bDate }
            case .numberOfTimesCompleted:
                let aCount = activityA.completionDates.count
                let bCount = activityB.completionDates.count
                if aCount != bCount { return aCount > bCount }
            case .highestRated:
                if activityA.rating != activityB.rating { return activityA.rating > activityB.rating }
            case .longestDuration:
                if a.maximumDurationMinutes != b.maximumDurationMinutes { return a.maximumDurationMinutes > b.maximumDurationMinutes }
            case .shortestDuration:
                if a.minimumDurationMinutes != b.minimumDurationMinutes { return a.minimumDurationMinutes < b.minimumDurationMinutes }
            }
            return left.offset < right.offset
        }.map(\.element)
    }
}

@Observable
@MainActor
public final class ExerciseProgressStore {
    private static let storageKey = "care.exerciseProgress.v1"
    public private(set) var records: [String: ExerciseProgressRecord]
    public private(set) var storageError: String?

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.sharedStore = nil
        if let data = defaults.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode([String: ExerciseProgressRecord].self, from: data) {
            records = decoded
        } else {
            records = [:]
        }
    }

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let sharedStore: UserDraftStore?

    public init(sharedStore: UserDraftStore) {
        self.defaults = .standard
        self.sharedStore = sharedStore
        self.records = (try? sharedStore.loadValue([String: ExerciseProgressRecord].self, key: "exercise-progress")) ?? [:]
    }

    public func record(for id: String) -> ExerciseProgressRecord { records[id] ?? .init() }

    public func complete(_ id: String, at date: Date = .now) {
        records[id, default: .init()].completionDates.append(date)
        persist()
    }

    public func completeAndDiscard(_ id: String, at date: Date = .now) throws {
        guard let sharedStore else {
            complete(id, at: date)
            return
        }
        records = try sharedStore.finishExercise(id, at: date)
    }

    public func setRating(_ rating: Int, for id: String) {
        var next = records
        next[id, default: .init()].rating = min(max(rating, 0), 5)
        commit(next)
    }

    public func toggleFavorite(_ id: String) {
        var next = records
        next[id, default: .init()].isFavorite.toggle()
        commit(next)
    }

    public func clearAll() throws {
        if let sharedStore { try sharedStore.removeValue(key: "exercise-progress") }
        else { defaults.removeObject(forKey: Self.storageKey) }
        records = [:]
        storageError = nil
    }

    public func resetAfterErasure() {
        records = [:]
        storageError = nil
    }

    public func completionCount(for category: ExerciseCategory? = nil) -> Int {
        matchingDates(for: category).count
    }

    public func weekCompletionCount(for category: ExerciseCategory? = nil, now: Date = .now, calendar: Calendar = .current) -> Int {
        guard let monday = monday(for: now, calendar: calendar),
              let nextMonday = calendar.date(byAdding: .day, value: 7, to: monday) else { return 0 }
        return matchingDates(for: category).filter { $0 >= monday && $0 < nextMonday }.count
    }

    public func weekCompletedDays(for category: ExerciseCategory? = nil, now: Date = .now, calendar: Calendar = .current) -> Int {
        let days = Set(matchingDates(for: category).map { calendar.startOfDay(for: $0) })
        guard let monday = monday(for: now, calendar: calendar),
              let nextMonday = calendar.date(byAdding: .day, value: 7, to: monday) else { return 0 }
        return days.filter { $0 >= monday && $0 < nextMonday }.count
    }

    public func currentStreak(for category: ExerciseCategory? = nil, now: Date = .now, calendar: Calendar = .current) -> Int {
        let days = Set(matchingDates(for: category).map { calendar.startOfDay(for: $0) })
        var day = calendar.startOfDay(for: now)
        if !days.contains(day), let yesterday = calendar.date(byAdding: .day, value: -1, to: day) { day = yesterday }
        var count = 0
        while days.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    public func weekStatuses(now: Date = .now, calendar: Calendar = .current) -> [Bool] {
        guard let monday = monday(for: now, calendar: calendar) else { return Array(repeating: false, count: 7) }
        let days = Set(matchingDates(for: nil).map { calendar.startOfDay(for: $0) })
        return (0..<7).map { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else { return false }
            return days.contains(calendar.startOfDay(for: date))
        }
    }

    private func monday(for date: Date, calendar: Calendar) -> Date? {
        let daysSinceMonday = (calendar.component(.weekday, from: date) + 5) % 7
        return calendar.date(byAdding: .day, value: -daysSinceMonday, to: calendar.startOfDay(for: date))
    }

    private func matchingDates(for category: ExerciseCategory?) -> [Date] {
        let ids = ExerciseItem.allExercises.filter { category == nil || $0.category == category }.map(\.id)
        return ids.flatMap { records[$0]?.completionDates ?? [] }
    }

    private func persist() {
        if let sharedStore {
            try? sharedStore.saveValue(records, key: "exercise-progress")
            return
        }
        guard let data = try? JSONEncoder().encode(records) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }

    private func commit(_ next: [String: ExerciseProgressRecord]) {
        do {
            if let sharedStore { try sharedStore.saveValue(next, key: "exercise-progress") }
            else { defaults.set(try JSONEncoder().encode(next), forKey: Self.storageKey) }
            records = next
            storageError = nil
        } catch { storageError = "Your exercise change could not be saved. Please try again." }
    }
}

// Drafts share the app's SwiftData container with contacts and completed assessments.
// An exercise draft contains references to Photos assets, never picker temporary URLs.
public struct ExerciseDraft: Codable, Equatable, Sendable {
    public let exerciseID: String
    public var completionToken: UUID? = nil
    public var step: Int = 0
    public var fields: [String: String] = [:]
    public var photoAssetID: String?
    public var videoAssetID: String?
    public var webURL: String?

    public init(exerciseID: String) { self.exerciseID = exerciseID }
}

public struct PRMMomentAnswer: Codable, Equatable, Sendable {
    public let question: String
    public let response: String
}

public struct PRMSavedMoment: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let exerciseID: String
    public let title: String
    public let emoji: String
    public let category: ExerciseCategory
    public let savedAt: Date
    public let answers: [PRMMomentAnswer]
    public let photoFilename: String?
    public var photoDescription: String
    public var isFavorite: Bool
    public var lastViewedAt: Date?

    public var summary: String { answers.first?.response ?? "A moment to revisit" }

    static func capture(_ draft: ExerciseDraft, at date: Date) -> PRMSavedMoment? {
        guard let item = ExerciseItem.allExercises.first(where: { $0.id == draft.exerciseID }),
              item.isPositiveRelationalMoment else { return nil }
        var answers: [PRMMomentAnswer] = []
        if item.id == "keep-photo-close" {
            let prompts = [
                ("firstReflection", "After looking at the photo, do you notice any warmth, calm, or shift in your body?"),
                ("secondReflection", "What did you notice?")
            ]
            for (key, question) in prompts {
                if let response = draft.fields[key]?.trimmingCharacters(in: .whitespacesAndNewlines), !response.isEmpty {
                    answers.append(.init(question: question, response: response))
                }
            }
        } else {
            for step in 0..<8 {
                guard let screen = FigmaExerciseScreenCatalog.screen(for: item.id, step: step) else { break }
                for input in screen.nodes where input.n == "reflection-input" || input.n.hasPrefix("list-item") {
                    guard let response = draft.fields[input.id]?.trimmingCharacters(in: .whitespacesAndNewlines),
                          !response.isEmpty else { continue }
                    let question: String
                    if input.n == "reflection-input" {
                        question = screen.nodes.filter { $0.n == "question" && $0.y < input.y }
                            .min { input.y - $0.y < input.y - $1.y }?.txt ?? "Your reflection"
                    } else {
                        question = screen.nodes.filter { $0.n == "placeholder" && abs($0.y - input.y) < 35 }
                            .min { abs($0.y - input.y) < abs($1.y - input.y) }?.txt ?? "A detail to remember"
                    }
                    answers.append(.init(question: question, response: response))
                }
            }
        }
        return .init(id: draft.completionToken ?? UUID(), exerciseID: item.id, title: item.title,
                     emoji: item.emoji, category: item.category, savedAt: date, answers: answers,
                     photoFilename: draft.fields["prm-photo"] ?? draft.fields.first(where: { $0.key.hasPrefix("photo:") })?.value,
                     photoDescription: "", isFavorite: false, lastViewedAt: nil)
    }
}

public struct QuizDraft: Codable, Equatable, Sendable {
    public let topicSlug: EducationTopicSlug
    public var questionIDs: [String]
    public var questionIndex: Int
    public var selectedOptionLetter: String?
    public var hasSubmitted: Bool
    public var score: Int
    /// Completed choices keyed by stable question ID, including earlier editable steps.
    public var answeredLetters: [String: String]

    public init(topicSlug: EducationTopicSlug, questionIDs: [String], questionIndex: Int = 0, selectedOptionLetter: String? = nil, hasSubmitted: Bool = false, score: Int = 0, answeredLetters: [String: String] = [:]) {
        self.topicSlug = topicSlug
        self.questionIDs = questionIDs
        self.questionIndex = questionIndex
        self.selectedOptionLetter = selectedOptionLetter
        self.hasSubmitted = hasSubmitted
        self.score = score
        self.answeredLetters = answeredLetters
    }

    private enum CodingKeys: String, CodingKey {
        case topicSlug, questionIDs, questionIndex, selectedOptionLetter, hasSubmitted, score, answeredLetters
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        topicSlug = try values.decode(EducationTopicSlug.self, forKey: .topicSlug)
        questionIDs = try values.decode([String].self, forKey: .questionIDs)
        questionIndex = try values.decode(Int.self, forKey: .questionIndex)
        selectedOptionLetter = try values.decodeIfPresent(String.self, forKey: .selectedOptionLetter)
        hasSubmitted = try values.decode(Bool.self, forKey: .hasSubmitted)
        score = try values.decode(Int.self, forKey: .score)
        answeredLetters = try values.decodeIfPresent([String: String].self, forKey: .answeredLetters) ?? [:]
    }
}

public enum AssessmentDailyLimitError: LocalizedError, Equatable {
    case alreadyCompletedToday

    public var errorDescription: String? {
        "You already completed an assessment today. You can start another tomorrow."
    }
}

@Model
public final class StoredUserDraft {
    public var key: String = ""
    public var payload: Data = Data()
    public var updatedAt: Date = Date()

    public init(key: String, payload: Data, updatedAt: Date = .now) {
        self.key = key
        self.payload = payload
        self.updatedAt = updatedAt
    }
}

@Observable
@MainActor
public final class UserDraftStore {
    @ObservationIgnored private let container: ModelContainer
    public private(set) var exerciseDrafts: [String: ExerciseDraft] = [:]
    public private(set) var savedMoments: [PRMSavedMoment] = []
    public private(set) var quizDrafts: [EducationTopicSlug: QuizDraft] = [:]
    public private(set) var mostRecentExerciseID: String?
    public private(set) var mostRecentQuizSlug: EducationTopicSlug?
    public private(set) var failedExerciseSaves: Set<String> = []
    public private(set) var failedQuizSaves: Set<EducationTopicSlug> = []
    public private(set) var unreadableDraftKeys: Set<String> = []

    public init(container: ModelContainer, migrateLegacyPhotos: Bool = true) throws {
        self.container = container
        let records = try container.mainContext.fetch(FetchDescriptor<StoredUserDraft>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]))
        for record in records {
            if record.key.hasPrefix("exercise:") {
                if let draft = try? JSONDecoder().decode(ExerciseDraft.self, from: record.payload) {
                    exerciseDrafts[draft.exerciseID] = draft
                    if mostRecentExerciseID == nil { mostRecentExerciseID = draft.exerciseID }
                } else { unreadableDraftKeys.insert(record.key) }
            } else if record.key == "prm-moments" {
                if let moments = try? JSONDecoder().decode([PRMSavedMoment].self, from: record.payload) {
                    savedMoments = moments
                } else { unreadableDraftKeys.insert(record.key) }
            } else if record.key.hasPrefix("quiz:") {
                if let draft = try? JSONDecoder().decode(QuizDraft.self, from: record.payload) {
                    quizDrafts[draft.topicSlug] = draft
                    if mostRecentQuizSlug == nil { mostRecentQuizSlug = draft.topicSlug }
                } else { unreadableDraftKeys.insert(record.key) }
            } else if record.key == "assessment-draft",
                      (try? JSONDecoder().decode(AssessmentSessionState.self, from: record.payload)) == nil {
                unreadableDraftKeys.insert(record.key)
            } else if record.key == "profile-edit",
                      (try? JSONDecoder().decode(ProfileEditDraft.self, from: record.payload)) == nil {
                unreadableDraftKeys.insert(record.key)
            } else if record.key.hasPrefix("contact-edit:"),
                      (try? JSONDecoder().decode(ContactEditDraft.self, from: record.payload)) == nil {
                unreadableDraftKeys.insert(record.key)
            }
        }
        if migrateLegacyPhotos { try migrateLegacyContactPhotos() }
    }

    private static let legacyPhotoPrefix = "care.contact.photo."

    private static func legacyPhotoKeys() -> [String] {
        UserDefaults.standard.dictionaryRepresentation().keys.filter { $0.hasPrefix(legacyPhotoPrefix) }
    }

    private func migrateLegacyContactPhotos() throws {
        let contacts = try container.mainContext.fetch(FetchDescriptor<StoredContact>())
        let validIDs = Set(contacts.map { $0.id.uuidString })
        for key in Self.legacyPhotoKeys() {
            let suffix = String(key.dropFirst(Self.legacyPhotoPrefix.count))
            guard validIDs.contains(suffix), let data = UserDefaults.standard.data(forKey: key) else {
                UserDefaults.standard.removeObject(forKey: key)
                continue
            }
            let destination = "contact-photo:\(suffix)"
            if try loadValue(Data.self, key: destination) == nil {
                let compact = ProfilePhotoProcessor.compactJPEG(data) ?? data
                try saveValue(compact, key: destination)
            }
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    private static func removeLegacyContactPhotos() {
        for key in legacyPhotoKeys() { UserDefaults.standard.removeObject(forKey: key) }
    }

    public func exercise(for id: String) -> ExerciseDraft? { exerciseDrafts[id] }
    public func quiz(for slug: EducationTopicSlug) -> QuizDraft? { quizDrafts[slug] }

    public func saveExercise(_ draft: ExerciseDraft) throws {
        guard !unreadableDraftKeys.contains("exercise:\(draft.exerciseID)") else {
            throw CocoaError(.fileReadCorruptFile)
        }
        var stableDraft = draft
        stableDraft.completionToken = exerciseDrafts[draft.exerciseID]?.completionToken ?? draft.completionToken ?? UUID()
        do { try save(key: "exercise:\(draft.exerciseID)", payload: JSONEncoder().encode(stableDraft)) }
        catch { failedExerciseSaves.insert(draft.exerciseID); throw error }
        failedExerciseSaves.remove(draft.exerciseID)
        exerciseDrafts[draft.exerciseID] = stableDraft
        mostRecentExerciseID = draft.exerciseID
    }

    public func saveQuiz(_ draft: QuizDraft) throws {
        guard !unreadableDraftKeys.contains("quiz:\(draft.topicSlug.rawValue)") else {
            throw CocoaError(.fileReadCorruptFile)
        }
        do { try save(key: "quiz:\(draft.topicSlug.rawValue)", payload: JSONEncoder().encode(draft)) }
        catch { failedQuizSaves.insert(draft.topicSlug); throw error }
        failedQuizSaves.remove(draft.topicSlug)
        quizDrafts[draft.topicSlug] = draft
        mostRecentQuizSlug = draft.topicSlug
    }

    public func discardExercise(_ id: String) throws {
        try remove(key: "exercise:\(id)")
        exerciseDrafts.removeValue(forKey: id)
        unreadableDraftKeys.remove("exercise:\(id)")
        failedExerciseSaves.remove(id)
        if mostRecentExerciseID == id { mostRecentExerciseID = exerciseDrafts.keys.sorted().first }
    }

    public func discardQuiz(for slug: EducationTopicSlug) throws {
        try remove(key: "quiz:\(slug.rawValue)")
        quizDrafts.removeValue(forKey: slug)
        unreadableDraftKeys.remove("quiz:\(slug.rawValue)")
        failedQuizSaves.remove(slug)
        if mostRecentQuizSlug == slug { mostRecentQuizSlug = quizDrafts.keys.sorted { $0.rawValue < $1.rawValue }.first }
    }

    public func loadValue<T: Decodable>(_ type: T.Type, key: String) throws -> T? {
        let descriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == key })
        guard let record = try container.mainContext.fetch(descriptor).first else { return nil }
        return try JSONDecoder().decode(T.self, from: record.payload)
    }

    /// Validate canonical records before any view can treat a decode failure as empty data.
    /// The caller blocks startup on failure, preserving the original bytes for recovery.
    public func validateCanonicalRecords() throws {
        _ = try loadValue(ProfileSettingsStore.Saved.self, key: "care.profile.settings.v1")
        _ = try loadValue([Person].self, key: "assessment-selection")
        _ = try loadValue([ParticipantAllocation].self, key: "assessment-allocations")
        _ = try loadValue([String: ExerciseProgressRecord].self, key: "exercise-progress")
        _ = try loadValue([PRMSavedMoment].self, key: "prm-moments")
        _ = try loadValue([String: TopicProgressRecord].self, key: "education-progress")
        _ = try loadValue(Bool.self, key: "com.careapp.security.isAppLockEnabled")
    }

    public func saveValue<T: Encodable>(_ value: T, key: String) throws {
        guard !unreadableDraftKeys.contains(key) else { throw CocoaError(.fileReadCorruptFile) }
        try save(key: key, payload: JSONEncoder().encode(value))
    }

    public func saveValueAndRemoveDraft<T: Encodable>(_ value: T, key: String, draftKey: String) throws {
        guard !unreadableDraftKeys.contains(draftKey) else { throw CocoaError(.fileReadCorruptFile) }
        let context = container.mainContext
        let valueDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == key })
        let draftDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == draftKey })
        do {
            let payload = try JSONEncoder().encode(value)
            if let record = try context.fetch(valueDescriptor).first { record.payload = payload; record.updatedAt = .now }
            else { context.insert(StoredUserDraft(key: key, payload: payload)) }
            for draft in try context.fetch(draftDescriptor) { context.delete(draft) }
            try context.save()
        } catch { context.rollback(); throw error }
    }

    public func removeValue(key: String) throws {
        try remove(key: key)
        unreadableDraftKeys.remove(key)
    }

    public func clearAllDrafts() throws {
        for id in Array(exerciseDrafts.keys) { try discardExercise(id) }
        for slug in Array(quizDrafts.keys) { try discardQuiz(for: slug) }
        try removeValue(key: "assessment-draft")
    }

    /// Discard every unfinished assessment record in one durable transaction.
    public func discardAssessmentDraft() throws {
        let context = container.mainContext
        let keys: Set<String> = ["assessment-draft", "assessment-selection", "assessment-allocations"]
        do {
            for record in try context.fetch(FetchDescriptor<StoredUserDraft>()) where keys.contains(record.key) {
                context.delete(record)
            }
            try context.save()
            unreadableDraftKeys.subtract(keys)
        } catch { context.rollback(); throw error }
    }

    public func commitContact(_ person: Person, photoData: Data?, editDraftKey: String) throws {
        guard !unreadableDraftKeys.contains(editDraftKey) else { throw CocoaError(.fileReadCorruptFile) }
        let context = container.mainContext
        let contactID = person.id
        let photoKey = "contact-photo:\(contactID.uuidString)"
        let contactDescriptor = FetchDescriptor<StoredContact>(predicate: #Predicate { $0.id == contactID })
        let photoDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == photoKey })
        let editDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == editDraftKey })
        do {
            if let existing = try context.fetch(contactDescriptor).first {
                existing.name = person.name
                existing.initials = person.initials
                existing.categoryRaw = person.category.rawValue
                existing.customCategoryName = person.customCategoryName
            } else {
                let count = try context.fetchCount(FetchDescriptor<StoredContact>())
                guard count < StorageContainerFactory.maxContactsLimit else {
                    throw StorageLimitError.contactLimitExceeded(max: StorageContainerFactory.maxContactsLimit)
                }
                context.insert(StoredContact(from: person))
            }
            if let photoData {
                let payload = try JSONEncoder().encode(photoData)
                if let photo = try context.fetch(photoDescriptor).first { photo.payload = payload; photo.updatedAt = .now }
                else { context.insert(StoredUserDraft(key: photoKey, payload: payload)) }
            }
            for record in try context.fetch(editDescriptor) { context.delete(record) }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    public func deleteRelationships() throws {
        let context = container.mainContext
        do {
            for contact in try context.fetch(FetchDescriptor<StoredContact>()) { context.delete(contact) }
            for record in try context.fetch(FetchDescriptor<StoredUserDraft>()) {
                if record.key.hasPrefix("contact-photo:") || record.key.hasPrefix("contact-edit:") ||
                   ["assessment-selection", "assessment-allocations", "assessment-draft"].contains(record.key) {
                    context.delete(record)
                }
            }
            try context.save()
            Self.removeLegacyContactPhotos()
        } catch { context.rollback(); throw error }
    }

    public func deleteContact(id: UUID) throws {
        let context = container.mainContext
        let photoKey = "contact-photo:\(id.uuidString)"
        let editKey = "contact-edit:\(id.uuidString)"
        let descriptor = FetchDescriptor<StoredContact>(predicate: #Predicate { $0.id == id })
        do {
            for contact in try context.fetch(descriptor) { context.delete(contact) }
            for record in try context.fetch(FetchDescriptor<StoredUserDraft>()) {
                switch record.key {
                case photoKey, editKey:
                    context.delete(record)
                case "assessment-selection":
                    let remaining = try JSONDecoder().decode([Person].self, from: record.payload).filter { $0.id != id }
                    if remaining.isEmpty { context.delete(record) }
                    else { record.payload = try JSONEncoder().encode(remaining) }
                case "assessment-allocations":
                    let remaining = try JSONDecoder().decode([ParticipantAllocation].self, from: record.payload).filter { $0.id != id }
                    if remaining.isEmpty { context.delete(record) }
                    else { record.payload = try JSONEncoder().encode(remaining) }
                case "assessment-draft":
                    let assessment = try JSONDecoder().decode(AssessmentSessionState.self, from: record.payload)
                    if assessment.participants.contains(where: { $0.id == id }) { context.delete(record) }
                default: break
                }
            }
            try context.save()
            UserDefaults.standard.removeObject(forKey: Self.legacyPhotoPrefix + id.uuidString)
        } catch { context.rollback(); throw error }
    }

    public func hasCompletedAssessment(on date: Date = .now, calendar: Calendar = .current) throws -> Bool {
        let stored = try container.mainContext.fetch(FetchDescriptor<StoredAssessmentSession>())
        return stored.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    public func commitAssessmentResult(_ result: AssessmentResult, calendar: Calendar = .current) throws {
        let context = container.mainContext
        let resultID = result.id
        let duplicate = FetchDescriptor<StoredAssessmentSession>(predicate: #Predicate { $0.id == resultID })
        do {
            if try context.fetch(duplicate).isEmpty {
                let all = try context.fetch(FetchDescriptor<StoredAssessmentSession>())
                guard !all.contains(where: { calendar.isDate($0.date, inSameDayAs: result.timestamp) }) else {
                    throw AssessmentDailyLimitError.alreadyCompletedToday
                }
                context.insert(StoredAssessmentSession(from: result))
            }
            let keys = ["assessment-draft", "assessment-selection", "assessment-allocations"]
            for record in try context.fetch(FetchDescriptor<StoredUserDraft>()) where keys.contains(record.key) {
                context.delete(record)
            }
            try context.save()
        } catch { context.rollback(); throw error }
    }

    public func deleteAssessments() throws {
        let context = container.mainContext
        do {
            for result in try context.fetch(FetchDescriptor<StoredAssessmentSession>()) { context.delete(result) }
            let keys = ["assessment-draft", "assessment-selection", "assessment-allocations"]
            for record in try context.fetch(FetchDescriptor<StoredUserDraft>()) where keys.contains(record.key) { context.delete(record) }
            try context.save()
        } catch { context.rollback(); throw error }
    }

    public func eraseAllUserData() throws {
        let context = container.mainContext
        do {
            for contact in try context.fetch(FetchDescriptor<StoredContact>()) { context.delete(contact) }
            for result in try context.fetch(FetchDescriptor<StoredAssessmentSession>()) { context.delete(result) }
            for record in try context.fetch(FetchDescriptor<StoredUserDraft>()) { context.delete(record) }
            try context.save()
            Self.removeLegacyContactPhotos()
            exerciseDrafts = [:]
            savedMoments = []
            quizDrafts = [:]
            unreadableDraftKeys = []
            mostRecentExerciseID = nil
            mostRecentQuizSlug = nil
        } catch { context.rollback(); throw error }
    }

    public func finishExercise(_ id: String, at date: Date = .now) throws -> [String: ExerciseProgressRecord] {
        let context = container.mainContext
        let draftKey = "exercise:\(id)"
        let progressKey = "exercise-progress"
        let momentsKey = "prm-moments"
        let draftDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == draftKey })
        let progressDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == progressKey })
        do {
            guard let draftRecord = try context.fetch(draftDescriptor).first else {
                throw CocoaError(.fileNoSuchFile)
            }
            let draft = try JSONDecoder().decode(ExerciseDraft.self, from: draftRecord.payload)
            guard !unreadableDraftKeys.contains(momentsKey) else { throw CocoaError(.fileReadCorruptFile) }
            let progressRecord = try context.fetch(progressDescriptor).first
            var all = try progressRecord.map { try JSONDecoder().decode([String: ExerciseProgressRecord].self, from: $0.payload) } ?? [:]
            var progress = all[id] ?? .init()
            let token = draft.completionToken ?? UUID()
            let isNewCompletion = !(progress.completionTokens ?? []).contains(token)
            if isNewCompletion {
                progress.completionDates.append(date)
                progress.completionTokens = (progress.completionTokens ?? []) + [token]
                all[id] = progress
            }
            let payload = try JSONEncoder().encode(all)
            if let progressRecord { progressRecord.payload = payload; progressRecord.updatedAt = .now }
            else { context.insert(StoredUserDraft(key: progressKey, payload: payload)) }
            var nextMoments = savedMoments
            if isNewCompletion, let moment = PRMSavedMoment.capture(draft, at: date),
               !nextMoments.contains(where: { $0.id == moment.id }) {
                nextMoments.insert(moment, at: 0)
                let descriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == momentsKey })
                let momentsPayload = try JSONEncoder().encode(nextMoments)
                if let record = try context.fetch(descriptor).first {
                    record.payload = momentsPayload; record.updatedAt = .now
                } else { context.insert(StoredUserDraft(key: momentsKey, payload: momentsPayload)) }
            }
            context.delete(draftRecord)
            try context.save()
            exerciseDrafts.removeValue(forKey: id)
            savedMoments = nextMoments
            if mostRecentExerciseID == id { mostRecentExerciseID = exerciseDrafts.keys.sorted().first }
            return all
        } catch {
            context.rollback()
            throw error
        }
    }

    public func updateMoment(_ id: UUID, _ edit: (inout PRMSavedMoment) -> Void) throws {
        guard let index = savedMoments.firstIndex(where: { $0.id == id }) else { return }
        var next = savedMoments
        edit(&next[index])
        try saveValue(next, key: "prm-moments")
        savedMoments = next
    }

    public func deleteMoment(_ id: UUID) throws {
        let next = savedMoments.filter { $0.id != id }
        guard next.count != savedMoments.count else { return }
        try saveValue(next, key: "prm-moments")
        savedMoments = next
    }

    public func finishQuiz(slug: EducationTopicSlug, score: Int, totalQuestions: Int, at date: Date = .now) throws {
        let context = container.mainContext
        let draftKey = "quiz:\(slug.rawValue)"
        let progressKey = "education-progress"
        let draftDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == draftKey })
        let progressDescriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == progressKey })
        do {
            guard let draft = try context.fetch(draftDescriptor).first else { throw CocoaError(.fileNoSuchFile) }
            let progressRecord = try context.fetch(progressDescriptor).first
            var all = try progressRecord.map { try JSONDecoder().decode([String: TopicProgressRecord].self, from: $0.payload) } ?? [:]
            var record = all[slug.rawValue] ?? TopicProgressRecord(slug: slug)
            record.quizAttemptsCount += 1
            record.lastScore = score
            record.bestScore = max(record.bestScore, score)
            if score == totalQuestions && totalQuestions > 0 {
                record.quizPassed = true
                record.quizPassedAt = date
                record.isCompleted = true
                if record.completedAt == nil { record.completedAt = date }
            }
            all[slug.rawValue] = record
            let payload = try JSONEncoder().encode(all)
            if let progressRecord { progressRecord.payload = payload; progressRecord.updatedAt = date }
            else { context.insert(StoredUserDraft(key: progressKey, payload: payload, updatedAt: date)) }
            context.delete(draft)
            try context.save()
            quizDrafts.removeValue(forKey: slug)
            if mostRecentQuizSlug == slug { mostRecentQuizSlug = quizDrafts.keys.sorted { $0.rawValue < $1.rawValue }.first }
        } catch {
            context.rollback()
            throw error
        }
    }

    private func save(key: String, payload: Data) throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == key })
        do {
            if let record = try context.fetch(descriptor).first {
                record.payload = payload
                record.updatedAt = .now
            } else {
                context.insert(StoredUserDraft(key: key, payload: payload))
            }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    private func remove(key: String) throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<StoredUserDraft>(predicate: #Predicate { $0.key == key })
        do {
            for record in try context.fetch(descriptor) { context.delete(record) }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

@MainActor
public enum ExercisePhotoReference {
    public static func loadImage(assetID: String) async -> UIImage? {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        guard status == .authorized || status == .limited else { return nil }
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil).firstObject else { return nil }
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 1200, height: 1200),
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                if info?[PHImageResultIsDegradedKey] as? Bool == true { return }
                continuation.resume(returning: image)
            }
        }
    }

    public static func loadVideoPlayer(assetID: String) async -> AVPlayer? {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        guard status == .authorized || status == .limited else { return nil }
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil).firstObject else { return nil }
        let video: AVAsset? = await withCheckedContinuation { continuation in
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { video, _, _ in
                continuation.resume(returning: video)
            }
        }
        guard let video else { return nil }
        return AVPlayer(playerItem: AVPlayerItem(asset: video))
    }
}
