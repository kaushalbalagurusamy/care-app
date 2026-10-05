import SwiftUI

// MARK: - Reusable High-Fidelity Header Navigation Bar (Figma Frames 5:4, 11:4, 13:4, 29:4, 41:4)
public struct HeaderNavBar: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    @State private var pendingNavigation: (() -> Void)?
    @State private var showProgressWarning = false
    
    public let showBackButton: Bool
    public let showHomeButton: Bool
    public let showChartButton: Bool
    public let showProfileButton: Bool
    public let accentColor: Color?
    public let title: String?
    public let onBack: (() -> Void)?
    public let onHome: (() -> Void)?
    public let onChart: (() -> Void)?
    public let onProfile: (() -> Void)?
    public let warnOnBack: Bool
    public let warnOnFlowNavigation: Bool
    
    public init(
        showBackButton: Bool = true,
        showHomeButton: Bool = true,
        showChartButton: Bool = true,
        showProfileButton: Bool = true,
        accentColor: Color? = nil,
        title: String? = nil,
        onBack: (() -> Void)? = nil,
        onHome: (() -> Void)? = nil,
        onChart: (() -> Void)? = nil,
        onProfile: (() -> Void)? = nil,
        warnOnBack: Bool = true,
        warnOnFlowNavigation: Bool = true
    ) {
        self.showBackButton = showBackButton
        self.showHomeButton = showHomeButton
        self.showChartButton = showChartButton
        self.showProfileButton = showProfileButton
        self.accentColor = accentColor
        self.title = title
        self.onBack = onBack
        self.onHome = onHome
        self.onChart = onChart
        self.onProfile = onProfile
        self.warnOnBack = warnOnBack
        self.warnOnFlowNavigation = warnOnFlowNavigation
    }
    
    public var body: some View {
        HStack(alignment: .center) {
            // Left Button Cluster (Back and Home)
            HStack(spacing: 8) {
                if showBackButton {
                    CircularNavIconButton(
                        icon: .back,
                        accentColor: accentColor,
                        action: {
                            if isQuizRoute && warnOnBack {
                                navigateWithProgressWarning { if let onBack { onBack() } else { router?.pop() } }
                            } else if let onBack { onBack() }
                            else { router?.pop() }
                        }
                    )
                }
                
                if showHomeButton {
                    CircularNavIconButton(
                        icon: .home,
                        accentColor: accentColor,
                        action: {
                            navigateWithProgressWarning { if let onHome { onHome() } else { router?.popToRoot() } }
                        }
                    )
                }
                
            }
            
            Spacer()
            
            // Optional Center Title
            if let title = title {
                Text(title)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Right Button Cluster (Past Results Chart and Profile)
            HStack(spacing: 8) {
                if showChartButton {
                    CircularNavIconButton(
                        icon: .chart,
                        accentColor: accentColor,
                        action: {
                            navigateWithProgressWarning { if let onChart { onChart() } else if router?.currentRoute != .pastResults { router?.navigate(to: .pastResults) } }
                        }
                    )
                }
                
                
                if showProfileButton {
                    CircularNavIconButton(
                        icon: .profile,
                        accentColor: accentColor,
                        action: {
                            navigateWithProgressWarning { if let onProfile { onProfile() } else if router?.currentRoute != .profile { router?.navigate(to: .profile) } }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 3.3)
        .padding(.bottom, 3.3)
        .frame(height: 50.6)
        .padding(.top, -3)
        .background(
            Theme.Colors.background
                .ignoresSafeArea(edges: .top)
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: "#E2E8F0").opacity(0.8))
                .frame(height: 0.5)
        }
        .fullScreenCover(isPresented: $showProgressWarning) {
            CancelChangesConfirmationView(
                onKeepEditing: { showProgressWarning = false; pendingNavigation = nil },
                onCancelWithoutSaving: {
                    showProgressWarning = false
                    let action = pendingNavigation
                    pendingNavigation = nil
                    action?()
                },
                title: isExerciseRoute ? "Leave this exercise?" : "Leave this quiz?",
                message: draftSaveFailed
                    ? "Your latest changes could not be saved. Keep editing and retry, or leave without those changes."
                    : "Your progress is saved on this device. You can come back and continue where you left off.",
                primaryTitle: "Keep Editing",
                secondaryTitle: draftSaveFailed ? "Leave Without Changes" : (isExerciseRoute ? "Leave Exercise" : "Leave Quiz")
            )
            .presentationBackground(.clear)
        }
    }

    private var isExerciseRoute: Bool {
        switch router?.currentRoute {
        case .watchFunny, .keepPhoto, .belongingList, .shareSomethingSmall,
             .mirrorEmotion, .mirrorLovedOne, .shareSomethingNew, .connectionCountdown:
            return true
        default: return false
        }
    }

    private var isQuizRoute: Bool {
        if case .educationQuiz = router?.currentRoute { return true }
        return false
    }

    private var draftSaveFailed: Bool {
        guard let route = router?.currentRoute, let store = appEnvironment?.draftStore else { return false }
        if case let .educationQuiz(topic) = route { return store.failedQuizSaves.contains(topic.slug) }
        let id: String? = switch route {
        case .watchFunny: "watch-something-funny"
        case .keepPhoto: "keep-photo-close"
        case .belongingList: "belonging-list"
        case .shareSomethingSmall: "share-something-small"
        case .mirrorEmotion: "mirror-emotion"
        case .mirrorLovedOne: "mirror-loved-one"
        case .shareSomethingNew: "share-something-new"
        case .connectionCountdown: "connection-countdown"
        default: nil
        }
        return id.map { store.failedExerciseSaves.contains($0) } ?? false
    }

    private func navigateWithProgressWarning(_ action: @escaping () -> Void) {
        guard warnOnFlowNavigation && (isExerciseRoute || isQuizRoute) else { action(); return }
        pendingNavigation = action
        showProgressWarning = true
    }
}

// MARK: - 36x36 Standardized Circular Navigation Button
public struct CircularNavIconButton: View {
    public let icon: AppIcon
    public let accentColor: Color?
    public let action: () -> Void
    
    public init(icon: AppIcon, accentColor: Color? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.accentColor = accentColor
        self.action = action
    }
    
    // Backwards compatibility initializer
    public init(iconName: String, isSystemImage: Bool = false, action: @escaping () -> Void) {
        if iconName.contains("home") {
            self.icon = .home
        } else if iconName.contains("chart") {
            self.icon = .chart
        } else if iconName.contains("profile") || iconName.contains("person") {
            self.icon = .profile
        } else if iconName.contains("chevron") || iconName.contains("back") {
            self.icon = .back
        } else {
            self.icon = .custom(systemName: iconName)
        }
        self.accentColor = nil
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Circle()
                .fill(accentColor?.opacity(0.08) ?? Theme.Colors.surfaceSecondary)
                .frame(width: 36, height: 36)
                .overlay(
                    icon.view(size: 15.5, weight: .semibold, color: accentColor ?? Theme.Colors.primary)
                )
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityIdentifier(icon.identifier)
        .accessibilityLabel(icon.accessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Previews
#Preview("Header Navigation Variants") {
    VStack(spacing: 20) {
        HeaderNavBar(showBackButton: true, showHomeButton: true, showChartButton: true, showProfileButton: true)
        HeaderNavBar(showBackButton: false, showHomeButton: true, showChartButton: true, showProfileButton: true)
    }
    .background(Theme.Colors.surfaceSecondary)
}
