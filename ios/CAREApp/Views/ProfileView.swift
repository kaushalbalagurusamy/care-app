import SwiftUI
import PhotosUI

// MARK: - Screen 22: Profile Page View (Figma Frame 218:4)
public struct ProfileView: View {
    public let router: AppRouter
    @Environment(ProfileSettingsStore.self) private var settings: ProfileSettingsStore
    @Environment(AppEnvironment.self) private var environment: AppEnvironment
    @Environment(ExerciseProgressStore.self) private var exerciseProgress: ExerciseProgressStore
    public let onDataCleared: (String) -> Void
    
    @State private var fullName: String = ""
    @State private var selectedFrequency: String = "biweekly"
    @State private var selectedTab: String = "My Information"
    @State private var showCancelConfirmation = false
    @State private var showStorageSettings = false
    @State private var showPrivacyDetails = false
    @State private var remindersEnabled = false
    @State private var photoSelection: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var deletionScope: String?
    @State private var deletionError: String?
    @State private var editLoaded = false

    private var editSnapshot: ProfileEditDraft {
        ProfileEditDraft(name: fullName, frequency: selectedFrequency, photoData: photoData)
    }
    
    let frequencies = [
        "2x/week",
        "1x/week",
        "biweekly",
        "monthly",
        "every 3 months"
    ]
    
    public init(router: AppRouter, onDataCleared: @escaping (String) -> Void = { _ in }) {
        self.router = router
        self.onDataCleared = onDataCleared
    }
    
    public var body: some View {
        ZStack {
        VStack(spacing: 0) {
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                title: nil
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("My Profile")
                            .font(Theme.Typography.screenTitle)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Manage your personal details and assessment schedule")
                            .font(Theme.Typography.screenSubtitle)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)

                    NoHorizontalBounceScrollView(showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["My Information", "Security", "Notifications", "Privacy"], id: \.self) { tab in
                                Button { selectedTab = tab } label: {
                                    Text(tab)
                                        .font(Theme.Typography.poppins(.medium, size: 13))
                                        .padding(.horizontal, 14).frame(height: 38)
                                        .foregroundStyle(selectedTab == tab ? .white : Theme.Colors.textPrimary)
                                        .background(selectedTab == tab ? Theme.Colors.primary : Theme.Colors.cardSurface)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if selectedTab == "My Information" {
                    
                    // Profile Photo
                    PhotosPicker(selection: $photoSelection, matching: .images) {
                    VStack(spacing: 8) {
                        Circle()
                            .fill(Theme.Colors.primary.opacity(0.12))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Group {
                                    if let photoData, let image = UIImage(data: photoData) {
                                        Image(uiImage: image).resizable().scaledToFill()
                                    } else {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 36))
                                            .foregroundColor(Theme.Colors.primary)
                                    }
                                }
                                .frame(width: 80, height: 80).clipShape(Circle())
                            )
                        
                        Text("Change Profile Photo")
                            .font(Theme.Typography.poppins(.medium, size: 13))
                            .foregroundColor(Theme.Colors.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    
                    // Form Fields
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Full Name")
                                .font(Theme.Typography.poppins(.semiBold, size: 14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            TextField("Full Name", text: $fullName)
                                .font(Theme.Typography.poppins(.regular, size: 15))
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(Theme.Colors.surfaceSecondary)
                                .cornerRadius(12)
                        }
                        
                    }
                    
                    // Assessment Frequency
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Target Assessment Frequency")
                            .font(Theme.Typography.poppins(.semiBold, size: 14))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        HStack(spacing: 8) {
                            ForEach(frequencies.prefix(3), id: \.self) { freq in
                                frequencyPill(freq)
                            }
                        }
                        HStack(spacing: 8) {
                            ForEach(frequencies.suffix(2), id: \.self) { freq in
                                frequencyPill(freq)
                            }
                        }
                    }
                    } else if selectedTab == "Notifications" {
                        Text("Assessment reminders")
                            .font(Theme.Typography.poppins(.semiBold, size: 17))
                        Toggle("Remind me to check in", isOn: $remindersEnabled)
                            .tint(Theme.Colors.primary)
                        Text("Assessment frequency")
                            .font(Theme.Typography.poppins(.semiBold, size: 14))
                        HStack(spacing: 8) {
                            ForEach(frequencies.prefix(3), id: \.self) { frequencyPill($0) }
                        }
                        HStack(spacing: 8) {
                            ForEach(frequencies.suffix(2), id: \.self) { frequencyPill($0) }
                        }
                        Text("Your selected schedule is saved with your profile.")
                            .font(Theme.Typography.poppins(.regular, size: 13))
                            .foregroundStyle(Theme.Colors.textSecondary)
                    } else {
                        Text(selectedTab == "Security" ? "Protect your account" : "Your data and privacy")
                            .font(Theme.Typography.poppins(.semiBold, size: 17))
                        Text(selectedTab == "Security" ? "Manage biometric app lock and device protection." : "Review local storage and manage your saved information.")
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundStyle(Theme.Colors.textSecondary)
                        Button(selectedTab == "Security" ? "Open Security Settings" : "Open Privacy Settings") {
                            showStorageSettings = true
                        }
                        .font(Theme.Typography.poppins(.semiBold, size: 15))
                        .foregroundStyle(Theme.Colors.primary)
                        if selectedTab == "Privacy" {
                            VStack(alignment: .leading, spacing: 12) {
                                Button("How CARE uses your data") {
                                    showPrivacyDetails = true
                                }
                                .font(Theme.Typography.poppins(.semiBold, size: 15))
                                .foregroundStyle(Theme.Colors.primary)
                                .frame(minHeight: 44)
                                .accessibilityIdentifier("ProfilePrivacyDetailsButton")

                                Text("Manage Your Data")
                                    .font(Theme.Typography.poppins(.semiBold, size: 17))
                                dataButton("Clear Profile Information", scope: "profile")
                                dataButton("Clear Saved Contacts", scope: "relationships")
                                dataButton("Clear Assessment Data", scope: "assessments")
                                dataButton("Clear All Data", scope: "all")
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.Colors.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Bottom Stacked Actions
            if selectedTab == "My Information" || selectedTab == "Notifications" {
            VStack(spacing: 10) {
                Divider()
                    .background(Theme.Colors.dividerSubtle)
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    do { try settings.save(name: fullName, frequency: selectedFrequency, photoData: photoData) }
                    catch { deletionError = "Your profile could not be saved. Please try again."; return }
                    if remindersEnabled {
                        Task { try? await environment.notificationScheduler.scheduleAssessmentReminder(frequency: selectedFrequency) }
                    }
                    router.pop()
                }) {
                    Text("Save Changes")
                        .font(Theme.Typography.buttonLabel)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Theme.Colors.primary)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .accessibilityIdentifier("SaveChangesButton")
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    showCancelConfirmation = true
                }) {
                    Text("Cancel")
                        .font(Theme.Typography.poppins(.medium, size: 16))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .accessibilityIdentifier("ProfileCancelButton")
            }
            .background(Theme.Colors.background)
            }
        }
        if showCancelConfirmation {
            CancelChangesConfirmationView(onKeepEditing: { showCancelConfirmation = false }, onCancelWithoutSaving: {
                do { try environment.draftStore.removeValue(key: "profile-edit") }
                catch { deletionError = "Your draft could not be discarded. Please try again."; return }
                showCancelConfirmation = false
                router.pop()
            })
        }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
        .task {
            let draft = try? environment.draftStore.loadValue(ProfileEditDraft.self, key: "profile-edit")
            fullName = draft?.name ?? settings.name
            selectedFrequency = draft?.frequency ?? settings.frequency
            photoData = draft?.photoData ?? settings.photoData
            remindersEnabled = (try? await environment.notificationScheduler.isReminderScheduled()) ?? false
            editLoaded = true
        }
        .onChange(of: editSnapshot) { _, snapshot in
            guard editLoaded else { return }
            do { try environment.draftStore.saveValue(snapshot, key: "profile-edit") }
            catch { deletionError = "Your profile edits could not be saved. Please try again before leaving." }
        }
        .onChange(of: photoSelection) { _, selection in
            Task {
                guard let data = try? await selection?.loadTransferable(type: Data.self) else { return }
                photoData = ProfilePhotoProcessor.compactJPEG(data)
            }
        }
        .onChange(of: remindersEnabled) { _, enabled in
            Task {
                if enabled {
                    if (try? await environment.notificationScheduler.requestAuthorization()) == true {
                        try? await environment.notificationScheduler.scheduleAssessmentReminder(frequency: selectedFrequency)
                    } else { remindersEnabled = false }
                } else { try? await environment.notificationScheduler.cancelReminders() }
            }
        }
        .sheet(isPresented: $showStorageSettings) { StorageSettingsView(onDataCleared: onDataCleared) }
        .sheet(isPresented: $showPrivacyDetails) {
            NavigationStack {
                PrivacyDetailsView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showPrivacyDetails = false }
                        }
                    }
            }
        }
        .confirmationDialog(deletionScope == "relationships" ? "Clear saved contacts?" : "Clear \(deletionScope == "all" ? "all data" : deletionScope ?? "data")?", isPresented: Binding(get: { deletionScope != nil }, set: { if !$0 { deletionScope = nil } }), titleVisibility: .visible) {
            Button("Clear Data", role: .destructive) {
                guard let scope = deletionScope else { return }
                deletionScope = nil
                Task { await clearData(scope) }
            }
            Button("Keep Data", role: .cancel) { deletionScope = nil }
        } message: {
            Text(deletionScope == "relationships"
                 ? "This removes saved contacts and their app-stored photos. Names in past assessment results remain until you also clear assessment data or all data."
                 : "This permanently removes the selected information from this device. It cannot be undone.")
        }
        .alert("Could not clear data", isPresented: Binding(get: { deletionError != nil }, set: { if !$0 { deletionError = nil } })) {
            Button("OK") { deletionError = nil }
        } message: { Text(deletionError ?? "") }
    }
    
    @ViewBuilder
    private func frequencyPill(_ freq: String) -> some View {
        Button(action: {
            selectedFrequency = freq
        }) {
            Text(freq)
                .font(Theme.Typography.poppins(.medium, size: 13))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundColor(selectedFrequency == freq ? .white : Theme.Colors.textPrimary)
                .background(selectedFrequency == freq ? Theme.Colors.primary : Theme.Colors.cardSurface)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(selectedFrequency == freq ? Theme.Colors.primary : Theme.Colors.dividerSubtle, lineWidth: 1)
                )
        }
    }

    private func dataButton(_ title: String, scope: String) -> some View {
        Button { deletionScope = scope } label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(Theme.Typography.poppins(.medium, size: 14))
            .foregroundStyle(.red)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    private func clearData(_ scope: String) async {
        do {
            if scope == "all" {
                try environment.draftStore.eraseAllUserData()
                exerciseProgress.resetAfterErasure()
                settings.resetAfterErasure()
                environment.appLockManager.resetAfterErasure()
                AssessmentSessionState.clearDraft()
            }
            if scope == "relationships" {
                try environment.draftStore.deleteRelationships()
            }
            if scope == "assessments" {
                try environment.draftStore.deleteAssessments()
                AssessmentSessionState.clearDraft()
            }
            if scope == "profile" {
                try settings.clearProfile()
            }
            if scope == "profile" || scope == "all" {
                fullName = ""
                selectedFrequency = "biweekly"
                photoData = nil
            }
            onDataCleared(scope)
            if scope == "all" { router.popToRoot() }
            if scope == "all" {
                do { try await environment.notificationScheduler.cancelReminders() }
                catch { deletionError = "Your data was cleared, but a reminder could not be canceled. Check notification settings." }
            }
        } catch { deletionError = error.localizedDescription }
    }
}

// MARK: - Previews
#Preview("Profile View") {
    ProfileView(router: AppRouter())
}
