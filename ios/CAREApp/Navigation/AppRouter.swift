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
    case surveyQuestion
    case surveyResults
    case surveyResultsExpanded
    case pastResults
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
}
