import SwiftUI

// MARK: - User Storage & Data Privacy Management View
public struct StorageSettingsView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(\.dismiss) private var dismiss
    
    @State private var assessmentCount: Int = 0
    @State private var contactCount: Int = 0
    @State private var approximateStorageKB: Int = 30
    @State private var isRemindersEnabled: Bool = false
    @State private var isAppLockToggle: Bool = false
    @State private var isShowingPurgeConfirmation: Bool = false
    @State private var isShowingResetContactsConfirmation: Bool = false
    
    public init() {}
    
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
                        try? await appEnvironment.assessmentRepo.clearAllHistory()
                        await refreshStorageMetrics()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action will permanently delete all historical assessment sessions and participant scores across this device and iCloud. This cannot be undone.")
            }
            .confirmationDialog(
                "Reset Contacts to Defaults?",
                isPresented: $isShowingResetContactsConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset Contacts", role: .destructive) {
                    Task {
                        let existing = try? await appEnvironment.contactsRepo.fetchContacts()
                        for c in existing ?? [] {
                            try? await appEnvironment.contactsRepo.deleteContact(id: c.id)
                        }
                        for p in Person.mockFigmaContacts {
                            _ = try? await appEnvironment.contactsRepo.createContact(p)
                        }
                        await refreshStorageMetrics()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will restore the contact rolodex to default sample contacts.")
            }
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
                    title: "Estimated Data Footprint",
                    value: "\(approximateStorageKB) KB / 500 KB limit",
                    icon: "chart.bar.xaxis"
                )
                metricRow(
                    title: "Stored Assessments",
                    value: "\(assessmentCount) / 50 max",
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
                            try? await appEnvironment.notificationScheduler.scheduleBiWeeklyReminder(preferredHour: 19, preferredWeekday: 1)
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
                Text("Zero-Knowledge Security")
                    .font(Theme.Typography.cardTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            Divider()
            
            Text("All relational safety scores are hardware-encrypted (AES-256) on your device and synchronized exclusively through your Private iCloud Container with End-to-End Encryption. No third-party servers ever receive your data.")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(3)
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
                    Text("Reset Contacts to Defaults")
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
        approximateStorageKB = max(30, (history * 3) + (contacts * 1) + 20)
    }
}
