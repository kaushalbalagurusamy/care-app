import SwiftUI

// MARK: - Screen 21: Unlock Personalized Action Plan View (Figma Frame 215:5)
public struct PersonalizedActionPlanView: View {
    public let router: AppRouter
    public let result: AssessmentResult
    @State private var isShowingComingSoon = false
    
    public init(router: AppRouter, result: AssessmentResult) {
        self.router = router
        self.result = result
    }

    private var focusDomain: CAREDomain {
        CAREDomain.allCases.min {
            (result.domainScores[$0]?.percentage ?? 1) < (result.domainScores[$1]?.percentage ?? 1)
        } ?? .resonant
    }

    private func scoreLabel(for domain: CAREDomain) -> String {
        guard let score = result.domainScores[domain] else { return "—/125" }
        return "\(Int(score.earnedPoints.rounded()))/\(Int(score.maxPossiblePoints.rounded()))"
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar (Explicitly NO sparkle icon on Frame 21)
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showSparkleButton: false,
                title: nil
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Eyebrow and Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("EXCLUSIVE SCIENCE-BACKED GUIDE")
                            .font(Theme.Typography.poppins(.bold, size: 12))
                            .foregroundColor(Theme.Colors.primary)
                            .tracking(1.2)
                        
                        Text("Unlock Your Personalized Action Plan")
                            .font(Theme.Typography.poppins(.bold, size: 26))
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // C.A.R.E. Pathways Map Card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(Theme.Colors.primary)
                            
                            Text("Your C.A.R.E. Pathways Map")
                                .font(Theme.Typography.poppins(.semiBold, size: 16))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Text("TAILORED")
                                .font(Theme.Typography.poppins(.bold, size: 11))
                                .foregroundColor(Theme.Colors.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Theme.Colors.primary.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        
                        // 4 Score Badges
                        HStack(spacing: 8) {
                            PathScoreBadge(title: "Calm", score: scoreLabel(for: .calm), isHighlighted: focusDomain == .calm)
                            PathScoreBadge(title: "Accepted", score: scoreLabel(for: .accepted), isHighlighted: focusDomain == .accepted)
                            PathScoreBadge(title: "Resonant", score: scoreLabel(for: .resonant), isHighlighted: focusDomain == .resonant)
                            PathScoreBadge(title: "Energetic", score: scoreLabel(for: .energetic), isHighlighted: focusDomain == .energetic)
                        }
                        
                        // Focus Highlight Callout
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(Color(hex: "#D97706"))
                                .font(.system(size: 14))
                                .padding(.top, 2)
                            
                            Text("Focus Highlight: Your personalized plan places special emphasis on strengthening your \(focusDomain.title) Pathway based on your latest assessment.")
                                .font(Theme.Typography.poppins(.regular, size: 13))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .lineSpacing(2)
                        }
                        .padding(12)
                        .background(Color(hex: "#FEF3C7").opacity(0.6))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#F2B84B"), lineWidth: 1.5))
                    }
                    .padding(16)
                    .background(Theme.Colors.cardSurface)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
                    )
                    
                    // Book Description Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 4) {
                            Text("Based on")
                                .font(Theme.Typography.poppins(.semiBold, size: 16))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Link(destination: URL(string: "https://www.penguinrandomhouse.com/books/318700/wired-to-connect-by-amy-banks-md-with-leigh-ann-hirschman/")!) {
                                Text("Wired to Connect")
                                    .font(Theme.Typography.poppins(.semiBold, size: 16))
                                    .foregroundColor(Theme.Colors.primary)
                                    .underline()
                            }
                            .accessibilityIdentifier("wiredToConnectBookLink")
                        }
                        
                        Text("Created in collaboration with Dr. Amy Banks, this tailored action plan provides specific daily exercises calibrated directly from your neural pathway scores.")
                            .font(Theme.Typography.poppins(.regular, size: 13))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(3)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Theme.Colors.Safety.lowRisk)
                            Text("Includes 28 neuro-relational exercises & reflection prompts")
                                .font(Theme.Typography.poppins(.medium, size: 12))
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(Theme.Colors.cardSurface)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Pinned Bottom Actions
            VStack(spacing: 10) {
                Divider()
                    .background(Theme.Colors.dividerSubtle)
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    isShowingComingSoon = true
                }) {
                    Text("Coming Soon")
                    .font(Theme.Typography.buttonLabel)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Theme.Colors.primary)
                    .cornerRadius(28)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .accessibilityIdentifier("ComingSoonPlanButton")
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    if router.currentRoute != .exercises {
                        router.navigate(to: .exercises)
                    } else {
                        router.pop()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left")
                        Text("Return to Exercises")
                    }
                    .font(Theme.Typography.buttonLabel)
                    .foregroundColor(Theme.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Theme.Colors.primary.opacity(0.4), lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .accessibilityIdentifier("ReturnToExercisesButton")
            }
            .background(Theme.Colors.background)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
        .alert("Coming soon", isPresented: $isShowingComingSoon) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This feature is coming soon.")
        }
    }
}

// MARK: - Pathway Score Badge Component
private struct PathScoreBadge: View {
    let title: String
    let score: String
    let isHighlighted: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(Theme.Typography.poppins(.medium, size: 11))
                .foregroundColor(isHighlighted ? Theme.Colors.primary : Theme.Colors.textSecondary)
                .lineLimit(1)
            
            Text(score)
                .font(Theme.Typography.poppins(.bold, size: 13))
                .foregroundColor(isHighlighted ? Theme.Colors.primary : Theme.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(isHighlighted ? Theme.Colors.primary.opacity(0.12) : Theme.Colors.surfaceSecondary)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isHighlighted ? Theme.Colors.primary : Color.clear, lineWidth: 1.5)
        )
    }
}

// MARK: - Previews
#Preview("Personalized Action Plan View") {
    PersonalizedActionPlanView(router: AppRouter(), result: .figmaMockResult)
}
