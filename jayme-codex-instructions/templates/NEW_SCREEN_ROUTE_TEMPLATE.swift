//
//  NewScreenTemplate.swift
//  CAREApp
//
//  Created for Jayme's Product Workflow
//

import SwiftUI

/// Standard Screen View Template adhering to CARE App Design System & Router Standards
public struct NewScreenTemplateView: View {
    @Environment(AppRouter.self) private var router
    
    // MARK: - Local View State
    @State private var textInput: String = ""
    @State private var isProcessing: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // 1. Navigation Header
            HeaderNavBar(
                title: "Screen Title",
                onBack: {
                    router.pop()
                }
            )
            
            // 2. Scrollable Body Content
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("Headline Description")
                        .font(Typography.headingMedium)
                        .foregroundColor(Colors.textPrimary)
                    
                    Text("Supportive guidance explaining the exercise or relational principle.")
                        .font(Typography.bodyLarge)
                        .foregroundColor(Colors.textSecondary)
                    
                    // Card or interactive area
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Reflection Prompt")
                            .font(Typography.labelMedium)
                            .foregroundColor(Colors.textPrimary)
                        
                        TextField("Type your thoughts...", text: $textInput, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(Spacing.md)
                            .background(Colors.surfaceSecondary)
                            .cornerRadius(12)
                    }
                    .padding(Spacing.md)
                    .background(Colors.cardBackground)
                    .cornerRadius(16)
                    .shadow(color: Colors.cardShadow, radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.xxl * 2)
            }
            
            // 3. Pinned Sticky Action Bar
            VStack {
                Divider()
                    .background(Colors.divider)
                
                PrimaryButton(
                    title: "Continue",
                    isEnabled: !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ) {
                    // Navigate to next route
                    router.navigate(to: .home)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.md)
            }
            .background(Colors.surfaceBackground)
        }
        .background(Colors.surfaceBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NewScreenTemplateView()
        .environment(AppRouter())
}
