import SwiftUI

// MARK: - Exhaustive Type-Safe Application Routes (Matching 10 Figma Frames)
public enum AppRoute: Hashable {
    case loading
    case home
    case education
    case exercises
    case assessmentOverview
    case surveyOverview
    case chooseRelationships
    case relationshipFrequency
    case personTransition
    case surveyQuestion
    case surveyResults
    case surveyResultsExpanded
    case pastResults
    case educationDetail(topic: EducationTopic)
    case educationQuiz(topic: EducationTopic)
    case welcomeAccountSetup
    case personalizedActionPlan
    case profile
    case careInfo
    case addRelationship
    case editContact(UUID)
    case calmExercises
    case acceptedExercises
    case resonantExercises
    case energeticExercises
    case watchFunny
    case keepPhoto
    case belongingList
    case shareSomethingSmall
    case mirrorEmotion
    case mirrorLovedOne
    case shareSomethingNew
    case connectionCountdown
    case careResultsExercises
    case exerciseComplete
    case exerciseCompleteFor(String)
    case surveyResultsV2
    case pastResultsV2
    case historicalSurveyResults(UUID)
}

// MARK: - Swift 6 Observable Application Router
@Observable
@MainActor
public final class AppRouter {
    public var path: [AppRoute] = []
    
    public var currentRoute: AppRoute {
        return path.last ?? .loading
    }
    
    public init(path: [AppRoute] = []) {
        self.path = path
    }
    
    /// Navigate forward to a typed destination
    public func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    /// Pop top-most route from stack
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    /// Reset navigation stack completely back to root (Home)
    public func popToRoot() {
        path.removeAll()
    }

    /// Close an editable flow before presenting its committed result.
    public func finishFlow(at resultRoute: AppRoute) {
        path = [resultRoute]
    }
}
