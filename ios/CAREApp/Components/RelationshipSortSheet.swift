import SwiftUI

// MARK: - Relationship Sort Sheet (Figma Frame 422:905)
public struct RelationshipSortSheet: View {
    @Binding public var selectedOption: RelationshipSortOption
    public let onApply: (RelationshipSortOption) -> Void
    public let onCancel: () -> Void
    
    @State private var tempOption: RelationshipSortOption
    
    public init(
        selectedOption: Binding<RelationshipSortOption>,
        onApply: @escaping (RelationshipSortOption) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self._selectedOption = selectedOption
        self._tempOption = State(initialValue: selectedOption.wrappedValue)
        self.onApply = onApply
        self.onCancel = onCancel
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
                Text("Sort relationships")
                    .font(Theme.Typography.poppins(.bold, size: 20))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Choose how relationships are organized.")
                    .font(Theme.Typography.poppins(.regular, size: 14))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.horizontal, 20)
            
            // Options List
            VStack(spacing: 0) {
                ForEach(RelationshipSortOption.allCases) { option in
                    Button(action: {
                        tempOption = option
                    }) {
                        HStack {
                            Text(option.rawValue)
                                .font(Theme.Typography.poppins(tempOption == option ? .semiBold : .regular, size: 15))
                                .foregroundColor(tempOption == option ? Theme.Colors.primary : Theme.Colors.textPrimary)
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .stroke(tempOption == option ? Theme.Colors.primary : Color(hex: "#CBD5E1"), lineWidth: 2)
                                    .frame(width: 22, height: 22)
                                
                                if tempOption == option {
                                    Circle()
                                        .fill(Theme.Colors.primary)
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(tempOption == option ? Color(hex: "#EFF6FF") : Color.clear)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    if option != RelationshipSortOption.allCases.last {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color(hex: "#F8FAFC"))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Actions
            VStack(spacing: 10) {
                PrimaryButton(
                    title: "Apply",
                    action: {
                        selectedOption = tempOption
                        onApply(tempOption)
                    }
                )
                
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    Text("Host")
        .sheet(isPresented: .constant(true)) {
            RelationshipSortSheet(
                selectedOption: .constant(.mostRecent),
                onApply: { _ in },
                onCancel: {}
            )
        }
}
