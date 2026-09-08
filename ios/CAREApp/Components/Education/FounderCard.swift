import SwiftUI

// MARK: - Founder Card (Figma Frame 13: 156:4 / Node 160:3)
public struct FounderCard: View {
    public let founder: FounderProfile
    public let showDivider: Bool
    
    public init(founder: FounderProfile, showDivider: Bool = false) {
        self.founder = founder
        self.showDivider = showDivider
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                // Founder Portrait Avatar
                Group {
                    if let imageAsset = founder.imageAsset,
                       UIImage(named: imageAsset) != nil {
                        Image(imageAsset)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 54, height: 54)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Theme.Colors.dividerSubtle, lineWidth: 1.5)
                            )
                    } else {
                        Circle()
                            .fill(Theme.Colors.buttonSurfaceMuted)
                            .frame(width: 54, height: 54)
                            .overlay(
                                Text(String(founder.name.prefix(1)))
                                    .font(Theme.Typography.poppins(.bold, size: 20))
                                    .foregroundColor(Theme.Colors.primary)
                            )
                    }
                }
                .frame(width: 54, height: 54)
                
                // Name, Title & Biography Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(founder.name)
                        .font(Theme.Typography.poppins(.bold, size: 16))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(founder.titleAndDegrees)
                        .font(Theme.Typography.poppins(.medium, size: 12.5))
                        .foregroundColor(Theme.Colors.primary)
                    
                    Text(founder.biography)
                        .font(Theme.Typography.poppins(.regular, size: 13.5))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineSpacing(3)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if showDivider {
                Divider()
                    .background(Theme.Colors.dividerSubtle)
                    .padding(.top, 4)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(founder.name), \(founder.titleAndDegrees). \(founder.biography)")
    }
}

// MARK: - Previews
#Preview("Founder Card Matrix") {
    VStack(spacing: 16) {
        FounderCard(
            founder: FounderProfile(
                id: "founder-1",
                name: "Jean Baker Miller, MD",
                titleAndDegrees: "Psychiatrist & Author",
                biography: "The pioneering psychiatrist and author of Toward a New Psychology of Women who challenged patriarchal psychological paradigms.",
                imageAsset: "avatar_jean_baker_miller"
            ),
            showDivider: true
        )
        
        FounderCard(
            founder: FounderProfile(
                id: "founder-2",
                name: "Judith V. Jordan, PhD",
                titleAndDegrees: "Founding Scholar & Director",
                biography: "The founding scholar of RCT and Director of the Jean Baker Miller Training Institute.",
                imageAsset: "avatar_judith_jordan"
            ),
            showDivider: false
        )
    }
    .padding(20)
    .background(Theme.Colors.background)
}
