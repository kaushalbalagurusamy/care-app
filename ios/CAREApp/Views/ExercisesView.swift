import SwiftUI

// MARK: - Screen 20: Exercises Hub View (Figma Frame 214:4)
public struct ExercisesView: View {
    public let router: AppRouter
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showSparkleButton: true,
                sparklePlacement: .right,
                title: nil
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Title & Subtitle Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Exercises")
                            .font(Theme.Typography.screenTitle)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Strengthen your relational neural pathways")
                            .font(Theme.Typography.poppins(.regular, size: 15))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // 4 Pathway Cards
                    VStack(spacing: 12) {
                        ExercisePathwayCard(
                            letter: "C",
                            title: "Calm",
                            description: "Fosters down-regulation of stress systems, developing neural pathways toward safety and emotional grounding.",
                            color: Theme.Colors.Domains.calm
                        )
                        
                        ExercisePathwayCard(
                            letter: "A",
                            title: "Accepted",
                            description: "Feeling valued, validated, and safely connected within healthy, supportive relationship cultures.",
                            color: Theme.Colors.Domains.accepted
                        )
                        
                        ExercisePathwayCard(
                            letter: "R",
                            title: "Resonant",
                            description: "Activating mirror neurons to sense and dynamically align with another's emotional state without losing yourself.",
                            color: Theme.Colors.Domains.resonant
                        )
                        
                        ExercisePathwayCard(
                            letter: "E",
                            title: "Energetic",
                            description: "The vitalizing emotional flow and neurochemical boost generated through growth-fostering, mutual bonds.",
                            color: Theme.Colors.Domains.energetic
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Bottom Action: Pinned "Unlock Full Book Exercises" Button
            VStack(spacing: 0) {
                Divider()
                    .background(Theme.Colors.dividerSubtle)
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    router.navigate(to: .personalizedActionPlan)
                }) {
                    Text("Unlock Full Book Exercises")
                        .font(Theme.Typography.buttonLabel)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "#1E293B"))
                        .cornerRadius(28)
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 10)
                .accessibilityIdentifier("UnlockFullBookExercisesButton")
            }
            .background(Theme.Colors.background)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }
}

// MARK: - Exercise Pathway Card Component
public struct ExercisePathwayCard: View {
    public let letter: String
    public let title: String
    public let description: String
    public let color: Color
    
    public init(letter: String, title: String, description: String, color: Color) {
        self.letter = letter
        self.title = title
        self.description = description
        self.color = color
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Circular Letter Badge (44x44)
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Text(letter)
                    .font(Theme.Typography.poppins(.bold, size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Typography.poppins(.semiBold, size: 17))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(description)
                    .font(Theme.Typography.poppins(.regular, size: 13))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineSpacing(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.Colors.textSecondary.opacity(0.6))
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
}

// MARK: - Previews
#Preview("Exercises Hub View") {
    ExercisesView(router: AppRouter())
}
