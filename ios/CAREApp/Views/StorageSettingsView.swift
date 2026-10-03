import SwiftUI

// MARK: - User Storage & Data Privacy Management View
public struct StorageSettingsView: View {
    public let onDataCleared: (String) -> Void
    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(ProfileSettingsStore.self) private var profileSettings
    @Environment(\.dismiss) private var dismiss
    
    @State private var assessmentCount: Int = 0
    @State private var contactCount: Int = 0
    @State private var isRemindersEnabled: Bool = false
    @State private var isAppLockToggle: Bool = false
    @State private var isShowingPurgeConfirmation: Bool = false
    @State private var isShowingResetContactsConfirmation: Bool = false
    @State private var storageError: String?
    
    public init(onDataCleared: @escaping (String) -> Void = { _ in }) { self.onDataCleared = onDataCleared }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.large) {
                        // Section 1: Storage & Capacity Metrics
                        storageMetricsCard
                        
                        // Section 2: Bi-Weekly Local Reminders
                        notificationsCard
                        
                        // Section 3: App Security & Biometric Lock
                        appSecurityCard
                        
                        // Section 4: Privacy & Sync Info
                        privacyInfoCard
                        
                        // Section 5: Data Management & Erasure Actions
                        dataManagementCard
                    }
                    .padding(.horizontal, Theme.Spacing.large)
                    .padding(.vertical, Theme.Spacing.medium)
                }
            }
            .navigationTitle("Storage & Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.primary)
                }
            }
            .task {
                await refreshStorageMetrics()
            }
            .confirmationDialog(
                "Delete All Assessment History?",
                isPresented: $isShowingPurgeConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All History", role: .destructive) {
                    Task {
                        do {
                            try appEnvironment.draftStore.deleteAssessments()
                            AssessmentSessionState.clearDraft()
                            onDataCleared("assessments")
                            await refreshStorageMetrics()
                        } catch { storageError = "Assessment history could not be cleared. Please try again." }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes assessment history and the current draft on this device. iCloud sync is not enabled.")
            }
            .confirmationDialog(
                "Delete Saved Contacts?",
                isPresented: $isShowingResetContactsConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Saved Contacts", role: .destructive) {
                    Task {
                        do {
                            try appEnvironment.draftStore.deleteRelationships()
                            AssessmentSessionState.clearDraft()
                            onDataCleared("relationships")
                            await refreshStorageMetrics()
                        } catch {
                            storageError = "Some relationships could not be deleted. Please try again."
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This deletes saved contacts and their app-stored photos. Names in past assessment results remain until you also delete assessment history or clear all data.")
            }
            .alert("Storage update failed", isPresented: Binding(get: { storageError != nil }, set: { if !$0 { storageError = nil } })) {
                Button("OK", role: .cancel) { storageError = nil }
            } message: { Text(storageError ?? "") }
        }
    }
    
    // MARK: - Storage Metrics Card
    private var storageMetricsCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            HStack {
                Image(systemName: "internaldrive.fill")
                    .foregroundColor(Theme.Colors.primary)
                Text("Device Storage & Limits")
                    .font(Theme.Typography.cardTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            Divider()
            
            VStack(spacing: Theme.Spacing.small) {
                metricRow(
                    title: "Saved data",
                    value: "On this device",
                    icon: "chart.bar.xaxis"
                )
                metricRow(
                    title: "Stored Assessments",
                    value: "\(assessmentCount) saved",
                    icon: "list.bullet.clipboard"
                )
                metricRow(
                    title: "Saved Contacts",
                    value: "\(contactCount) / 50 max",
                    icon: "person.2.fill"
                )
            }
        }
        .padding(Theme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.Colors.cardSurface)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Bi-Weekly Local Notifications Card
    private var notificationsCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            HStack {
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(Theme.Colors.primary)
                Text("Check-In Reminders")
                    .font(Theme.Typography.cardTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            Divider()
            
            Toggle(isOn: $isRemindersEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bi-Weekly Assessment")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text("Every 2nd Sunday at 7:00 PM")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .tint(Theme.Colors.primary)
            .onChange(of: isRemindersEnabled) { _, newValue in
                Task {
                    if newValue {
                        let granted = try? await appEnvironment.notificationScheduler.requestAuthorization()
                        if granted == true {
                            try? await appEnvironment.notificationScheduler.scheduleAssessmentReminder(frequency: profileSettings.frequency)
                        } else {
                            isRemindersEnabled = false
                        }
                    } else {
                        try? await appEnvironment.notificationScheduler.cancelReminders()
                    }
                }
            }
        }
        .padding(Theme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.Colors.cardSurface)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - App Security & Biometric Lock Card
    private var appSecurityCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(Theme.Colors.primary)
                Text("App Security & Lock")
                    .font(Theme.Typography.cardTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            Divider()
            
            Toggle(isOn: $isAppLockToggle) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Require \(appEnvironment.appLockManager.biometricService.biometricType.rawValue)")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text("Lock immediately when app enters background")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .tint(Theme.Colors.primary)
            .onChange(of: isAppLockToggle) { _, newValue in
                guard newValue != appEnvironment.appLockManager.isAppLockEnabled else { return }
                Task {
                    do {
                        let success = try await appEnvironment.appLockManager.setAppLockEnabled(newValue)
                        if !success {
                            isAppLockToggle = appEnvironment.appLockManager.isAppLockEnabled
                        }
                    } catch {
                        isAppLockToggle = appEnvironment.appLockManager.isAppLockEnabled
                    }
                }
            }
        }
        .padding(Theme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.Colors.cardSurface)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Privacy Info Card
    private var privacyInfoCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(Theme.Colors.Safety.lowRisk)
                Text("Local Data & Privacy")
                    .font(Theme.Typography.cardTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            Divider()
            
            Text("Your profile, contacts, assessments, and progress are saved on this device. CARE does not sync them across devices. Embedded YouTube videos connect to Google when you play them.")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(3)

            NavigationLink {
                PrivacyDetailsView()
            } label: {
                HStack {
                    Text("How CARE uses your data")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.primary)
                .frame(minHeight: 44)
            }
            .accessibilityIdentifier("PrivacyDetailsLink")
        }
        .padding(Theme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.Colors.cardSurface)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Data Management & Purge Card
    private var dataManagementCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            HStack {
                Image(systemName: "externaldrive.fill.badge.xmark")
                    .foregroundColor(Theme.Colors.Safety.highRisk)
                Text("Data Management & Erasure")
                    .font(Theme.Typography.cardTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            Divider()
            
            Button(action: {
                isShowingPurgeConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear All Assessment History")
                    Spacer()
                }
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.Safety.highRisk)
                .frame(minHeight: 44)
            }
            
            Divider()
            
            Button(action: {
                isShowingResetContactsConfirmation = true
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Delete Saved Contacts")
                    Spacer()
                }
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.primary)
                .frame(minHeight: 44)
            }
        }
        .padding(Theme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.Colors.cardSurface)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    private func metricRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.textMuted)
                .frame(width: 20)
            Text(title)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .frame(minHeight: 32)
    }
    
    private func refreshStorageMetrics() async {
        let history = (try? await appEnvironment.assessmentRepo.fetchHistoryCount()) ?? 0
        let contacts = (try? await appEnvironment.contactsRepo.fetchContactCount()) ?? 0
        let scheduled = (try? await appEnvironment.notificationScheduler.isReminderScheduled()) ?? false
        assessmentCount = history
        contactCount = contacts
        isRemindersEnabled = scheduled
        isAppLockToggle = appEnvironment.appLockManager.isAppLockEnabled
    }
}

/// App-owned privacy information with a link to CARE's public policy.
public struct PrivacyDetailsView: View {
    public static let policyURL = URL(string: "https://care-app-privacy.vercel.app/")!

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                Link("Read CARE Privacy Policy", destination: Self.policyURL)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.primary)
                    .accessibilityIdentifier("CAREPrivacyPolicyLink")

                section(
                    "What stays on your device",
                    "CARE saves your profile name and photo, saved contacts and their photos, assessment answers and results, unfinished quiz and exercise answers, and exercise completion history on this device. CARE does not upload this information to a CARE account or sync it across devices. Your device's own backup settings are managed by iOS."
                )

                section(
                    "Photos and videos",
                    "You choose media with Apple's photo picker. Profile and contact photos are resized and saved in CARE's local data. For unfinished exercises, CARE saves a reference to a selected photo or video when available; the original remains in your Photos library. A selected video may be copied temporarily on this device for playback."
                )

                section(
                    "When you use other services",
                    "Playing an embedded YouTube video loads Google's player, which may receive device, network, and playback information under Google's policies. If you choose to share an exercise by text, iOS opens Messages with the content you selected; you decide whether to send it. Opening an outside link also takes you to that provider."
                )

                Link("Read Google's Privacy Policy", destination: URL(string: "https://policies.google.com/privacy")!)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.primary)
                    .accessibilityIdentifier("GooglePrivacyLink")

                section(
                    "Your choices and deletion",
                    "Photo selection and messaging are optional. You can manage photo access, notifications, and Face ID in iOS Settings. CARE keeps local records until you delete them. Completed exercises keep dates and counts, not your written answers. In Profile → Privacy you can clear profile information, saved contacts, assessment data, or all CARE data. Clearing saved contacts alone leaves their names in past assessment results; also clear assessments or all data to remove those names from this device."
                )
            }
            .padding(Theme.Spacing.large)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .navigationTitle("Privacy & Data Use")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text(title)
                .font(Theme.Typography.cardTitle)
                .foregroundColor(Theme.Colors.textPrimary)
            Text(text)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.large)
        .background(Theme.Colors.cardSurface, in: RoundedRectangle(cornerRadius: 16))
    }
}
