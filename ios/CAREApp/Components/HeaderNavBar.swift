import SwiftUI

// MARK: - Navigation Bar Configuration Modes
public enum HeaderNavMode {
    case home(userName: String, streakCount: Int)
    case detail(title: String, progress: Double? = nil, onBack: () -> Void)
    case modal(title: String, onClose: () -> Void)
}

// MARK: - Reusable Header Navigation Bar (Figma Frames 5:4, 11:4, 13:4, etc.)
public struct HeaderNavBar: View {
    public let mode: HeaderNavMode
    
    public init(mode: HeaderNavMode) {
        self.mode = mode
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                switch mode {
                case .home(let userName, let streakCount):
                    HStack(spacing: 12) {
                        // User Avatar Icon Circle
                        Circle()
                            .fill(Theme.Colors.surfaceSecondary)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Theme.Colors.primary)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Welcome Back")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            Text(userName)
                                .font(Theme.Typography.cardTitle)
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                    }
                    
                    Spacer()
                    
                    // Streak Pill
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.Colors.Safety.moderateRisk)
                        Text("\(streakCount) Days")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.Colors.Safety.moderateRiskBackground)
                    .clipShape(Capsule())
                    
                case .detail(let title, _, let onBack):
                    Button(action: onBack) {
                        Circle()
                            .fill(Theme.Colors.surfaceSecondary)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Theme.Colors.primary)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(title)
                        .font(Theme.Typography.cardTitle)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Spacer balancing circle button
                    Color.clear
                        .frame(width: 36, height: 36)
                    
                case .modal(let title, let onClose):
                    Spacer()
                    
                    Text(title)
                        .font(Theme.Typography.cardTitle)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: onClose) {
                        Circle()
                            .fill(Theme.Colors.surfaceSecondary)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 56)
            
            // Optional Linear Progress Bar
            if case .detail(_, let progress?, _) = mode {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Theme.Colors.dividerSubtle)
                            .frame(height: 3)
                        
                        Rectangle()
                            .fill(Theme.Colors.primary)
                            .frame(width: max(geo.size.width * CGFloat(progress), 0), height: 3)
                            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 3)
            }
        }
        .background(Theme.Colors.background)
    }
}

// MARK: - Previews
#Preview("Header Nav Bar Modes") {
    VStack(spacing: 24) {
        HeaderNavBar(mode: .home(userName: "Sarah Mitchell", streakCount: 5))
        HeaderNavBar(mode: .detail(title: "Survey Instructions", progress: 0.45, onBack: {}))
        HeaderNavBar(mode: .modal(title: "About Risk Groups", onClose: {}))
    }
    .background(Theme.Colors.surfaceSecondary)
}
