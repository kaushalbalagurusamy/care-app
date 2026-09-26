import Foundation

// MARK: - Relationship Sort Options (Figma Frame 422:905)
public enum RelationshipSortOption: String, CaseIterable, Identifiable, Sendable {
    case mostRecent = "Most recent"
    case mostCompleted = "Most completed assessments"
    case highestScore = "Highest overall score"
    case relationshipType = "Relationship type"
    case age = "Age"
    
    public var id: String { rawValue }
}

// MARK: - Exercise Sort Options (Figma Frame 427:98)
public enum ExerciseSortOption: String, CaseIterable, Identifiable, Sendable {
    case mostRecentlyCompleted = "Most recently completed"
    case numberOfTimesCompleted = "Number of times completed"
    case highestRated = "Highest rated"
    case longestDuration = "Longest duration"
    case shortestDuration = "Shortest duration"
    
    public var id: String { rawValue }
}
