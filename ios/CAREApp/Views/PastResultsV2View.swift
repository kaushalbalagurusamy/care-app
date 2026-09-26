import SwiftUI

// MARK: - Screen: Past Results V2 (Figma Frame 335:4 & Node 239:8)
public struct PastResultsV2View: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    
    @State private var searchText: String = ""
    @State private var selectedSortOption: RelationshipSortOption = .mostRecent
    @State private var isShowingSortSheet: Bool = false
    @State private var expandedCategories: Set<String> = ["Calm"]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showSparkleButton: true,
                showChartButton: false,
                showProfileButton: true,
                onBack: { router?.pop() }
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ASSESSMENT HISTORY")
                            .font(Theme.Typography.poppins(.bold, size: 12))
                            .foregroundColor(Theme.Colors.primary)
                            .tracking(0.8)
                        
                        Text("Past Results")
                            .font(Theme.Typography.poppins(.bold, size: 28))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Compare results across your C.A.R.E. assessments")
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, 4)
                    
                    // Total Score Trends Blue Card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Total Score Trends")
                                .font(Theme.Typography.poppins(.bold, size: 16))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("OVERALL")
                                .font(Theme.Typography.poppins(.bold, size: 10))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        
                        // Score Summary Row
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("LATEST")
                                    .font(Theme.Typography.poppins(.medium, size: 11))
                                    .foregroundColor(Color.white.opacity(0.8))
                                Text("280/500")
                                    .font(Theme.Typography.poppins(.bold, size: 20))
                                    .foregroundColor(.white)
                                Text("+8% vs last")
                                    .font(Theme.Typography.poppins(.medium, size: 11))
                                    .foregroundColor(Color(hex: "#86EFAC"))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("PEAK SCORE")
                                    .font(Theme.Typography.poppins(.medium, size: 11))
                                    .foregroundColor(Color.white.opacity(0.8))
                                Text("410/500")
                                    .font(Theme.Typography.poppins(.bold, size: 20))
                                    .foregroundColor(.white)
                                Text("On May 25")
                                    .font(Theme.Typography.poppins(.regular, size: 11))
                                    .foregroundColor(Color.white.opacity(0.8))
                            }
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(12)
                        
                        // Historical Line Trend Chart
                        CARETrendChart()
                            .frame(height: 160)
                    }
                    .padding(18)
                    .background(Theme.Colors.primary)
                    .cornerRadius(20)
                    .shadow(color: Theme.Colors.primary.opacity(0.25), radius: 12, x: 0, y: 6)
                    
                    // C.A.R.E. Category Details Card with (i)
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("C.A.R.E. Category Details")
                                .font(Theme.Typography.poppins(.bold, size: 16))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                router?.navigate(to: .careInfo)
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 18))
                                    .foregroundColor(Theme.Colors.primary)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        VStack(spacing: 8) {
                            categoryTrendRow(name: "Calm", percent: "82%", color: Color(hex: "#3B82F6"))
                            categoryTrendRow(name: "Accepted", percent: "72%", color: Color(hex: "#10B981"))
                            categoryTrendRow(name: "Resonant", percent: "60%", color: Color(hex: "#8B5CF6"))
                            categoryTrendRow(name: "Energetic", percent: "88%", color: Color(hex: "#F97316"))
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                    )
                    
                    // Relational Safety Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Relational Safety")
                                .font(Theme.Typography.poppins(.bold, size: 16))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Spacer()
                            Button(action: {
                                router?.navigate(to: .surveyResultsExpanded)
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(Theme.Colors.primary)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        HStack(spacing: 8) {
                            Text("Safe: 21%")
                                .font(Theme.Typography.poppins(.medium, size: 12))
                                .foregroundColor(Color(hex: "#10B981"))
                            Text("•")
                            Text("Moderate: 39%")
                                .font(Theme.Typography.poppins(.medium, size: 12))
                                .foregroundColor(Color(hex: "#F59E0B"))
                            Text("•")
                            Text("High Risk: 40%")
                                .font(Theme.Typography.poppins(.medium, size: 12))
                                .foregroundColor(Color(hex: "#EF4444"))
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                    )
                    
                    // Relationship Breakdown Card with Sort and Search
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Relationship Breakdown")
                            .font(Theme.Typography.poppins(.bold, size: 16))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        HStack(spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Theme.Colors.textSecondary)
                                TextField("Search relationships...", text: $searchText)
                                    .font(Theme.Typography.poppins(.regular, size: 13.5))
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 40)
                            .background(Color(hex: "#F1F5F9"))
                            .cornerRadius(10)
                            
                            Button(action: {
                                isShowingSortSheet = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "#F1F5F9"))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "arrow.up.arrow.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        
                        VStack(spacing: 8) {
                            contactHistoryRow(name: "Sarah Mitchell", initials: "SM", score: "83", date: "5/29")
                            contactHistoryRow(name: "James Rivera", initials: "JR", score: "67", date: "5/29")
                            contactHistoryRow(name: "Emily Chen", initials: "EC", score: "74", date: "5/25")
                            contactHistoryRow(name: "David Thompson", initials: "DT", score: "88", date: "5/25")
                            contactHistoryRow(name: "Anya Patel", initials: "AP", score: "91", date: "5/16")
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Pinned Bottom Actions
            VStack(spacing: 6) {
                SecondaryButton(
                    title: "Return to Home",
                    icon: "house.fill",
                    action: {
                        router?.popToRoot()
                    }
                )
                
                Text("Your plan updates as you grow. Retake assessment anytime.")
                    .font(Theme.Typography.poppins(.regular, size: 11))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
        .sheet(isPresented: $isShowingSortSheet) {
            RelationshipSortSheet(
                selectedOption: $selectedSortOption,
                onApply: { _ in isShowingSortSheet = false },
                onCancel: { isShowingSortSheet = false }
            )
        }
    }
    
    @ViewBuilder
    private func categoryTrendRow(name: String, percent: String, color: Color) -> some View {
        HStack {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(name)
                .font(Theme.Typography.poppins(.medium, size: 14))
                .foregroundColor(Theme.Colors.textPrimary)
            Spacer()
            Text(percent)
                .font(Theme.Typography.poppins(.semiBold, size: 14))
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(hex: "#F8FAFC"))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func contactHistoryRow(name: String, initials: String, score: String, date: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color(hex: "#EFF6FF")).frame(width: 34, height: 34)
                Text(initials)
                    .font(Theme.Typography.poppins(.bold, size: 12))
                    .foregroundColor(Theme.Colors.primary)
            }
            
            Text(name)
                .font(Theme.Typography.poppins(.medium, size: 13.5))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 1) {
                Text(score)
                    .font(Theme.Typography.poppins(.bold, size: 13.5))
                    .foregroundColor(Theme.Colors.textPrimary)
                Text(date)
                    .font(Theme.Typography.poppins(.regular, size: 11))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PastResultsV2View()
}
