import SwiftUI

// MARK: - Screen 4: Survey Instructions & Onboarding (Figma Frame 13:4)
public struct SurveyOverviewView: View {
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
                showChartButton: true,
                showProfileButton: true,
                onBack: { router.pop() },
                onHome: { router.popToRoot() },
                onChart: { router.navigate(to: .pastResults) },
                onProfile: {}
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    
                    // Title Section
                    Text("Survey Instructions")
                        .font(Theme.Typography.poppins(.bold, size: 30))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, 8)
                    
                    // DO Section
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Do:")
                            .font(Theme.Typography.poppins(.bold, size: 22))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        InstructionItemRow(
                            iconName: "checkmark",
                            iconColor: Color(hex: "#2EAA55"),
                            iconBgColor: Color(hex: "#E8F8EF"),
                            title: "Complete while regulated:",
                            description: "Choose a time when you feel calm and balanced, avoiding acute emotional distress."
                        )
                        
                        InstructionItemRow(
                            iconName: "checkmark",
                            iconColor: Color(hex: "#2EAA55"),
                            iconBgColor: Color(hex: "#E8F8EF"),
                            title: "Choose 5 relationships:",
                            description: "Select the five relationships that occupy the most of your time (both mental and physical), regardless of connection quality."
                        )
                        
                        InstructionItemRow(
                            iconName: "checkmark",
                            iconColor: Color(hex: "#2EAA55"),
                            iconBgColor: Color(hex: "#E8F8EF"),
                            title: "Reflect bodily and mentally:",
                            description: "Imagine recent interactions with each person, noting your physiological and mental responses as you answer."
                        )
                    }
                    
                    // DON'T Section
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Don't:")
                            .font(Theme.Typography.poppins(.bold, size: 22))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .padding(.top, 4)
                        
                        InstructionItemRow(
                            iconName: "xmark",
                            iconColor: Color(hex: "#E04848"),
                            iconBgColor: Color(hex: "#FDEAEB"),
                            title: "Include minor children:",
                            description: "Exclude any children under 20 years old."
                        )
                        
                        InstructionItemRow(
                            iconName: "xmark",
                            iconColor: Color(hex: "#E04848"),
                            iconBgColor: Color(hex: "#FDEAEB"),
                            title: "Default to closest connections:",
                            description: "Avoid listing your favorite or closest relationships unless they are genuinely the ones where you spend the most time."
                        )
                        
                        InstructionItemRow(
                            iconName: "xmark",
                            iconColor: Color(hex: "#E04848"),
                            iconBgColor: Color(hex: "#FDEAEB"),
                            title: "Overanalyze:",
                            description: "Complete the assessment instinctively without overthinking your answers."
                        )
                    }
                    
                    // Action Button (Matching Figma Frame 4 "Next")
                    Button(action: {
                        router.navigate(to: .chooseRelationships)
                    }) {
                        Text("Next")
                            .font(Theme.Typography.poppins(.semiBold, size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Theme.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Theme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Instruction Item Row (Figma Frame 13:4)
struct InstructionItemRow: View {
    let iconName: String
    let iconColor: Color
    let iconBgColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(iconBgColor)
                .frame(width: 26, height: 26)
                .overlay(
                    Image(systemName: iconName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(iconColor)
                )
                .padding(.top, 1)
            
            (
                Text("\(title) ")
                    .font(Theme.Typography.poppins(.bold, size: 15))
                    .foregroundColor(Theme.Colors.textPrimary)
                +
                Text(description)
                    .font(Theme.Typography.poppins(.regular, size: 15))
                    .foregroundColor(Theme.Colors.textSecondary)
            )
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Previews
#Preview("Survey Overview View") {
    SurveyOverviewView(router: AppRouter())
}
