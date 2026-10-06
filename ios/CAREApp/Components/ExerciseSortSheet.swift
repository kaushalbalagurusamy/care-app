import SwiftUI

// MARK: - Exercise Sort Sheet (Figma Frame 427:98)
public struct ExerciseSortSheet: View {
    @Binding public var selectedOption: ExerciseSortOption
    @Binding public var participationFilter: ExerciseParticipationFilter
    @Binding public var prmOnly: Bool
    public let onApply: (ExerciseSortOption) -> Void
    public let onCancel: () -> Void
    public let accent: Color
    
    @State private var tempOption: ExerciseSortOption
    @State private var tempParticipationFilter: ExerciseParticipationFilter
    @State private var tempPRMOnly: Bool
    
    public init(
        selectedOption: Binding<ExerciseSortOption>,
        participationFilter: Binding<ExerciseParticipationFilter>,
        prmOnly: Binding<Bool>,
        onApply: @escaping (ExerciseSortOption) -> Void,
        onCancel: @escaping () -> Void,
        accent: Color = Theme.Colors.primary
    ) {
        self._selectedOption = selectedOption
        self._participationFilter = participationFilter
        self._prmOnly = prmOnly
        self._tempOption = State(initialValue: selectedOption.wrappedValue)
        self._tempParticipationFilter = State(initialValue: participationFilter.wrappedValue)
        self._tempPRMOnly = State(initialValue: prmOnly.wrappedValue)
        self.onApply = onApply
        self.onCancel = onCancel
        self.accent = accent
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Drag grabber
            Capsule()
                .fill(Color(hex: "#CBD5E1"))
                .frame(width: 36, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
            
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Sort exercises")
                    .font(Theme.Typography.poppins(.bold, size: 20))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Choose an order and the exercises you want to see.")
                    .font(Theme.Typography.poppins(.regular, size: 14))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.horizontal, 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(spacing: 0) {
                        ForEach(ExerciseSortOption.allCases) { option in
                            Button { tempOption = option } label: {
                                HStack {
                                    Text(option.rawValue)
                                        .font(Theme.Typography.poppins(tempOption == option ? .semiBold : .regular, size: 15))
                                        .foregroundColor(tempOption == option ? accent : Theme.Colors.textPrimary)
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .stroke(tempOption == option ? accent : Color(hex: "#CBD5E1"), lineWidth: 2)
                                            .frame(width: 22, height: 22)
                                        if tempOption == option {
                                            Circle().fill(accent).frame(width: 12, height: 12)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(tempOption == option ? accent.opacity(0.09) : Color.clear)
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            if option != ExerciseSortOption.allCases.last {
                                Divider().padding(.horizontal, 16)
                            }
                        }
                    }
                    .background(Color(hex: "#F8FAFC"))
                    .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Show exercises")
                            .font(Theme.Typography.poppins(.semiBold, size: 15))
                            .foregroundColor(Theme.Colors.textPrimary)
                        HStack(spacing: 8) {
                            ForEach(ExerciseParticipationFilter.allCases) { filter in
                                Button { tempParticipationFilter = filter } label: {
                                    Text(filter.rawValue)
                                        .font(Theme.Typography.poppins(.semiBold, size: 12))
                                        .foregroundStyle(tempParticipationFilter == filter ? .white : accent)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 34)
                                        .background(tempParticipationFilter == filter ? accent : accent.opacity(0.09), in: Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        Toggle(isOn: $tempPRMOnly) {
                            Text("Positive Relational Moment (PRM)")
                                .font(Theme.Typography.poppins(.medium, size: 13))
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                        .tint(accent)
                    }
                    .padding(16)
                    .background(Color(hex: "#F8FAFC"), in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20)
            }
            
            // Actions
            VStack(spacing: 10) {
                Button {
                    selectedOption = tempOption
                    participationFilter = tempParticipationFilter
                    prmOnly = tempPRMOnly
                    onApply(tempOption)
                } label: {
                    Text("Apply")
                        .font(Theme.Typography.poppins(.semiBold, size: 15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(accent, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(Theme.Typography.poppins(.medium, size: 15))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .presentationDetents([.height(690), .large])
        .presentationCornerRadius(30)
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    Text("Host")
        .sheet(isPresented: .constant(true)) {
            ExerciseSortSheet(
                selectedOption: .constant(.mostRecentlyCompleted),
                participationFilter: .constant(.any),
                prmOnly: .constant(false),
                onApply: { _ in },
                onCancel: {}
            )
        }
}
