import SwiftUI

// MARK: - Screen: Add Relationship (Figma Frame 281:4 & Node 239:8)
public struct AddRelationshipView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(AppEnvironment.self) private var environment: AppEnvironment?
    
    @State private var fullName: String = ""
    @State private var age: String = ""
    @State private var selectedRelationshipType: String = "Friend"
    @State private var showCancelConfirmation: Bool = false
    
    public let relationshipTypes = [
        "Partner", "Parent / Guardian", "Sibling", "Child",
        "Friend", "Coworker", "Cousin", "Other Relative",
        "Mentor / Teacher", "Roommate", "Neighbor", "Other"
    ]
    
    public init() {}
    
    private var hasUnsavedEdits: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty || !age.isEmpty
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderNavBar(
                    showBackButton: true,
                    showHomeButton: true,
                    showSparkleButton: true,
                    showChartButton: true,
                    showProfileButton: true,
                    onBack: { handleBackOrCancel() }
                )
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Title Section
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Add Relationship")
                                .font(Theme.Typography.poppins(.bold, size: 28))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Text("Add someone you'd like to reflect on in your C.A.R.E. assessment.")
                                .font(Theme.Typography.poppins(.regular, size: 14))
                                .foregroundColor(Theme.Colors.textSecondary)
                                .lineSpacing(2)
                        }
                        .padding(.top, Theme.Spacing.headerTitleSpacing)
                        
                        // Photo Upload Trigger (Dashed Circle)
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                    .foregroundColor(Theme.Colors.primary.opacity(0.8))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Theme.Colors.primary.opacity(0.7))
                                
                                ZStack {
                                    Circle()
                                        .fill(Theme.Colors.primary)
                                        .frame(width: 24, height: 24)
                                    Image(systemName: "plus")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: 28, y: 28)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Upload Photo")
                                    .font(Theme.Typography.poppins(.semiBold, size: 15))
                                    .foregroundColor(Theme.Colors.primary)
                                
                                Text("An avatar helps personalize your relational journey.")
                                    .font(Theme.Typography.poppins(.regular, size: 12.5))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .lineSpacing(2)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Form Fields
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Full Name")
                                .font(Theme.Typography.poppins(.semiBold, size: 14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            TextField("e.g., Alex Johnson", text: $fullName)
                                .font(Theme.Typography.poppins(.regular, size: 15))
                                .padding(.horizontal, 16)
                                .frame(height: 52)
                                .background(Color(hex: "#F1F5F9"))
                                .cornerRadius(14)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Age")
                                .font(Theme.Typography.poppins(.semiBold, size: 14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            TextField("e.g., 28", text: $age)
                                .font(Theme.Typography.poppins(.regular, size: 15))
                                .keyboardType(.numberPad)
                                .padding(.horizontal, 16)
                                .frame(height: 52)
                                .background(Color(hex: "#F1F5F9"))
                                .cornerRadius(14)
                        }
                        
                        // Relationship to You
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Relationship to You")
                                .font(Theme.Typography.poppins(.semiBold, size: 14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            // Wrapping Pills Grid
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                                ForEach(relationshipTypes, id: \.self) { type in
                                    Button(action: {
                                        selectedRelationshipType = type
                                    }) {
                                        Text(type)
                                            .font(Theme.Typography.poppins(.medium, size: 13))
                                            .foregroundColor(selectedRelationshipType == type ? .white : Theme.Colors.textPrimary)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .frame(minHeight: 36)
                                            .background(selectedRelationshipType == type ? Theme.Colors.primary : Color(hex: "#EFF6FF"))
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                
                // Pinned Bottom Actions
                VStack(spacing: 8) {
                    PrimaryButton(
                        title: "Save Relationship",
                        isEnabled: !fullName.trimmingCharacters(in: .whitespaces).isEmpty,
                        action: {
                            saveRelationship()
                        }
                    )
                    
                    Button(action: {
                        handleBackOrCancel()
                    }) {
                        Text("Cancel")
                            .font(Theme.Typography.poppins(.medium, size: 15))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white.ignoresSafeArea(edges: .bottom))
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            
            // Cancel Changes Modal
            if showCancelConfirmation {
                CancelChangesConfirmationView(
                    onKeepEditing: {
                        showCancelConfirmation = false
                    },
                    onCancelWithoutSaving: {
                        showCancelConfirmation = false
                        router?.pop()
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showCancelConfirmation)
    }
    
    private func handleBackOrCancel() {
        if hasUnsavedEdits {
            showCancelConfirmation = true
        } else {
            router?.pop()
        }
    }
    
    private func saveRelationship() {
        let trimmedName = fullName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let parsedAge = Int(age) ?? 30
        let names = trimmedName.split(separator: " ")
        let initials = names.compactMap { $0.first.map(String.init) }.joined().uppercased()
        let cat: RelationshipCategory
        switch selectedRelationshipType {
        case "Partner": cat = .partner
        case "Friend": cat = .friend
        case "Sibling": cat = .sibling
        case "Parent / Guardian": cat = .parent
        case "Coworker": cat = .colleague
        case "Cousin", "Other Relative": cat = .extendedFamily
        default: cat = .custom
        }
        let newPerson = Person(
            id: UUID(),
            name: trimmedName,
            initials: initials.isEmpty ? "C" : initials,
            category: cat,
            customCategoryName: cat == .custom ? selectedRelationshipType : nil,
            age: parsedAge
        )
        
        Task { @MainActor in
            try? await environment?.contactsRepo.createContact(newPerson)
            router?.pop()
        }
    }
}

#Preview {
    AddRelationshipView()
}
