import SwiftUI

// MARK: - Screen 3: Assessment Overview & Domain Intro (Figma Frame 11:4)
public struct AssessmentOverviewView: View {
    public let router: AppRouter
    @State private var hasScrolledToBottom: Bool = false
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HeaderNavBar()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Title Section (Two lines matching Figma Frame 3)
                    Text("C.A.R.E. Assessment\nOverview")
                        .font(Theme.Typography.poppins(.bold, size: 30))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineSpacing(2)
                        .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Introductory Body Paragraph matching Figma
                    Text("The C.A.R.E. Assessment is a 20 question survey that assesses the quality of your everyday relationships. Rooted in the science of Relational-Cultural Theory, relational neuroscience, and neuroplasticity, this assessment helps you evaluate and strengthen the four neural pathways your brain uses to form meaningful connections.")
                        .font(Theme.Typography.poppins(.regular, size: 15))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineSpacing(4)
                    
                    // Section Subheading
                    Text("What is C.A.R.E.?")
                        .font(Theme.Typography.poppins(.bold, size: 22))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, 4)
                    
                    // 4 Individual Acronym Breakdown Cards (Each having its own bubble container matching Figma)
                    VStack(spacing: 12) {
                        ForEach(CAREDomain.allCases, id: \.self) { domain in
                            HStack(alignment: .top, spacing: 16) {
                                // White Circular Letter Badge with bold blue letter
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Text(domain.letter)
                                            .font(Theme.Typography.poppins(.bold, size: 20))
                                            .foregroundColor(Theme.Colors.primary)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(domain.subtitle)
                                        .font(Theme.Typography.poppins(.bold, size: 16))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    
                                    Text(domain.explanation)
                                        .font(Theme.Typography.poppins(.regular, size: 13.5))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .lineSpacing(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.Colors.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                    
                    // Bottom Sentinel to detect reaching bottom of overview
                    ScrollBottomSentinel(spaceName: "AssessmentOverviewScroll")
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .trackScrollBottom(isUnlocked: $hasScrolledToBottom, spaceName: "AssessmentOverviewScroll")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Pinned Bottom Action Bar (Visible from start, scroll-gated)
            VStack(spacing: 0) {
                Divider()
                    .background(Theme.Colors.dividerSubtle)
                
                PrimaryButton(
                    title: "Begin the Survey",
                    isEnabled: hasScrolledToBottom,
                    action: {
                        router.navigate(to: .surveyOverview)
                    }
                )
                .accessibilityIdentifier("AssessmentOverviewBeginButton")
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 10)
            }
            .background(Theme.Colors.background)
        }
        .background(Theme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Previews
#Preview("Assessment Overview View") {
    AssessmentOverviewView(router: AppRouter())
}
