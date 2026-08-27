import SwiftUI

// MARK: - Individual Contact Result Card (Figma Frame 29:4 "Results by Individual")
public struct IndividualResultCard: View {
    public let result: IndividualResult
    
    public init(result: IndividualResult) {
        self.result = result
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            // Initials Avatar Circle
            Circle()
                .fill(Color(hex: "#EFF5FC"))
                .frame(width: 46, height: 46)
                .overlay(
                    Text(result.participant.person.initials)
                        .font(Theme.Typography.poppins(.bold, size: 16))
                        .foregroundColor(Theme.Colors.primary)
                )
            
            // Name & Score
            VStack(alignment: .leading, spacing: 3) {
                Text(result.participant.person.name)
                    .font(Theme.Typography.poppins(.bold, size: 16))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("\(Int(result.normalizedScore))/100")
                    .font(Theme.Typography.poppins(.medium, size: 13.5))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Safety Tier Pill Badge (Figma Frame 29:4)
            Text(result.safetyTier.rawValue)
                .font(Theme.Typography.poppins(.bold, size: 12.5))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(hex: "#38B969"))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.Colors.primary, lineWidth: 1.5)
        )
    }
}

// MARK: - Previews
#Preview("Individual Contact Card") {
    let person = Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32)
    let participant = AssessmentParticipant(person: person, percentTimeSpent: 0.30)
    let result = IndividualResult(
        participant: participant,
        normalizedScore: 80.0,
        safetyTier: .healthy,
        domainBreakdown: [.calm: 18, .accepted: 20, .resonant: 15, .energetic: 22]
    )
    
    IndividualResultCard(result: result)
        .padding(20)
        .background(Theme.Colors.surfaceSecondary)
}
