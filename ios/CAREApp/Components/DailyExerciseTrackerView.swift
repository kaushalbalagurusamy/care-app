import SwiftUI

// MARK: - Daily Exercise Activity Tracker (Figma Frame 5:4 Updated & Node 239:8)
public struct DailyExerciseTrackerView: View {
    public let completedDaysCount: Int
    public let totalDaysCount: Int
    public let days: [DayStatus]
    
    public struct DayStatus: Identifiable, Sendable {
        public let id: Int
        public let label: String
        public let isCompleted: Bool
        public let isCurrent: Bool
        
        public init(id: Int, label: String, isCompleted: Bool, isCurrent: Bool = false) {
            self.id = id
            self.label = label
            self.isCompleted = isCompleted
            self.isCurrent = isCurrent
        }
    }
    
    public init(
        completedDaysCount: Int = 0,
        totalDaysCount: Int = 7,
        days: [DayStatus]? = nil
    ) {
        self.completedDaysCount = completedDaysCount
        self.totalDaysCount = totalDaysCount
        if let days = days {
            self.days = days
        } else {
            // Empty Monday-first week before the first completed exercise.
            self.days = [
                DayStatus(id: 0, label: "M", isCompleted: false),
                DayStatus(id: 1, label: "T", isCompleted: false),
                DayStatus(id: 2, label: "W", isCompleted: false),
                DayStatus(id: 3, label: "T", isCompleted: false),
                DayStatus(id: 4, label: "F", isCompleted: false),
                DayStatus(id: 5, label: "S", isCompleted: false),
                DayStatus(id: 6, label: "S", isCompleted: false)
            ]
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Title, subtitle & "5 / 7 done" pill
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Exercise")
                        .font(Theme.Typography.poppins(.bold, size: 16))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("This week's activity")
                        .font(Theme.Typography.poppins(.regular, size: 12))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                Text("\(completedDaysCount) / \(totalDaysCount) done")
                    .font(Theme.Typography.poppins(.semiBold, size: 12))
                    .foregroundColor(Theme.Colors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#EFF6FF"))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Theme.Colors.primary.opacity(0.4), lineWidth: 1)
                    )
            }
            
            // 7 Days Circles Row
            HStack(spacing: 0) {
                ForEach(days) { day in
                    VStack(spacing: 6) {
                        Text(day.label)
                            .font(Theme.Typography.poppins(.medium, size: 11))
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        if day.isCompleted {
                            ZStack {
                                Circle()
                                    .fill(Theme.Colors.primary)
                                    .frame(width: 32, height: 32)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        } else if day.isCurrent {
                            ZStack {
                                Circle()
                                    .stroke(Theme.Colors.primary, lineWidth: 2)
                                    .background(Circle().fill(Color.white))
                                    .frame(width: 32, height: 32)
                                Circle()
                                    .fill(Theme.Colors.primary)
                                    .frame(width: 8, height: 8)
                            }
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#E0E7FF").opacity(0.6))
                                    .frame(width: 32, height: 32)
                                Circle()
                                    .fill(Color(hex: "#94A3B8").opacity(0.4))
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Track bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(hex: "#E2E8F0"))
                        .frame(height: 4)
                    
                    let ratio = totalDaysCount > 0 ? CGFloat(completedDaysCount) / CGFloat(totalDaysCount) : 0
                    Capsule()
                        .fill(Theme.Colors.primary)
                        .frame(width: geo.size.width * min(max(ratio, 0), 1), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: "#F8FAFC"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                )
        )
    }
}

#Preview {
    DailyExerciseTrackerView()
        .padding()
}
