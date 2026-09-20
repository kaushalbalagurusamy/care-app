# ADR 0010: Navigation Button Positioning, Horizontal Padding & Border Standardization Audit

* **Status**: Proposed / Pending Design Handoff (Awaiting updated Figma button content & new Education frames)
* **Date**: 2026-09-18
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Context & Motivation

During a design system and ergonomic audit on the iOS Simulator, critical visual and structural discrepancies were identified across both **Core Assessment (Figma Page 1)** and **Psychoeducation & Clinical Neuroscience (Figma Page 2)** workflows:

1. **Ergonomic Floating Button Defect**:
   * On **Screen 5: Choose Relationships** (`Figma Frame 17:4`, [`ChooseRelationshipsView.swift`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Views/ChooseRelationshipsView.swift)), the primary **"Next"** CTA is placed inside the `ScrollView` directly underneath the contact list. On standard iPhone viewports (e.g., iPhone 16 Pro, 852 pt height), this leaves **~180 pt of dead background space** beneath the button, causing it to float mid-screen.
   * On the immediately subsequent screen, **Screen 6: Relationship Frequency** (`Figma Frame 41:4`, [`RelationshipFrequencyView.swift`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Views/RelationshipFrequencyView.swift)), the **"Next"** CTA is anchored to the **very bottom edge** above the home indicator. Moving between adjacent screens causes the user's primary thumb tap target to jump abruptly.
   * On Education lesson detail screens ([`TopicDetailView.swift`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Views/Education/TopicDetailView.swift)), the primary CTA (**"Test Your Understanding"**) is similarly trapped at the bottom of a lengthy scroll body, requiring users to scroll through hundreds of vertical points before seeing any navigational action.
2. **Horizontal Padding & Screen Gutter Drift**:
   * While `HeaderNavBar` and core screens enforce a **20 pt** horizontal screen margin, utility and settings views ([`StorageSettingsView`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Views/StorageSettingsView.swift), [`AppLockView`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Views/AppLockView.swift)) diverge to **24 pt** (`Theme.Spacing.large`), causing content boundaries and card edges to pull inward by 4 pt.
   * `Theme.Spacing` contains tokens for 16 pt (`medium`) and 24 pt (`large`), but lacks a formal `20 pt` design token, creating an architectural gap between tokens and screen implementations.
3. **Card Border ("Broder") & Container Styling Inconsistencies**:
   * Certain screens display crisp, subtle 1 pt borders ([`EducationTopicCard`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Components/Education/EducationTopicCard.swift), [`BubbleCardContainer`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Components/BubbleCardContainer.swift)), while others show completely borderless cards with flat backgrounds ([`ChooseRelationshipsView`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Views/ChooseRelationshipsView.swift) contact cards, [`AssessmentOverviewView`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Views/AssessmentOverviewView.swift) domain cards).
   * Inside Education lesson screens ([`TopicDetailView`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Views/Education/TopicDetailView.swift)), adjacent cards rendered on the exact same page use conflicting internal horizontal padding (**20 pt** vs. **18 pt**), causing section headings, body paragraphs, and icons to visually misalign.

### Scope & Hold Notice
The design team is currently updating Figma frames with revised button content/copy across the assessment funnel, as well as introducing additional education module frames. **Implementation of code changes is held pending the completion of those Figma updates.** This document serves as the single source of truth and comprehensive audit covering both the **10 Assessment frames** and all **8 Education frames** to guide unified implementation upon design handoff.

---

## 2. Audit Domain 1: Primary Navigation & Action Button Positioning

### Master Cross-Frame Navigation Button Matrix

| Module / Scope | Screen / Frame Name | Figma Frame ID | Button Title / Label | Layout Hierarchy | Component Used | Height | Typography Token | Margins & Padding | Haptics | Viewport Behavior |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: | :--- | :--- | :---: | :--- |
| **Assessment** | **Assessment Overview** | `11:4` | "Begin the Survey" | Inside `ScrollView` (end of content) | Raw `Button` | 56 pt | `Poppins-SemiBold` 17pt | Top: 8, Bottom: 24, Horiz: 20 | ❌ None | Content overflows screen; user scrolls down to reach button |
| **Assessment** | **Survey Overview** | `13:4` | "Next" | Inside `ScrollView` (end of content) | Raw `Button` | 56 pt | `Poppins-SemiBold` 17pt | Top: 12, Bottom: 24, Horiz: 20 | ❌ None | Content overflows screen; rests at bottom after scrolling |
| **Assessment** | **Choose Relationships** *(Target)* | `17:4` | "Next" | Inside `ScrollView` (end of content) | Raw `Button` | 56 pt | `Poppins-SemiBold` 17pt | Top: 12, Bottom: 24, Horiz: 20 | ❌ None | ⚠️ **Floats in mid-screen** (~180 pt dead space below on iPhone 16 Pro) |
| **Assessment** | **Relationship Frequency** *(Adjacent)* | `41:4` | "Next" | Outside `ScrollView`, pinned in `VStack` | Raw `Button` | **54 pt** | `Poppins-SemiBold` 17pt | Bottom: 12, Horiz: 20 | ❌ None | **Anchored to bottom edge** (bubble takes `maxHeight: .infinity`) |
| **Assessment** | **Survey Question** | `25:4` | "Next" / "Complete Assessment" | Inside `ScrollView` (end of content) | Raw `Button` | **54 pt** | `Poppins-SemiBold` 17pt | Top: 10, Bottom: 24, Horiz: 20 | ❌ None | Position shifts depending on question text & screen height |
| **Assessment** | **Survey Results** | `29:4` | "View Past Results" & "Return to Home" | Inside `ScrollView` (end of content) | `PrimaryButton` & `SecondaryButton` | 56 pt | `Poppins-Bold` 16pt (`cardTitle`) | Top: 8, Bottom: 16 (container), Horiz: 20 | ✅ Medium | Sits at bottom of long dashboard content |
| **Assessment** | **Survey Results Expanded** | `58:3` | "Back to Results" | Inside `ScrollView` (end of content) | `PrimaryButton` | 56 pt | `Poppins-Bold` 16pt (`cardTitle`) | Top: 6, Bottom: 12 (container), Horiz: 20 | ✅ Medium | Floats below 3 static cards on tall viewports |
| **Assessment** | **Past Results** | `95:2` | *(None - Header Nav)* | Header only (`HeaderNavBar`) | N/A | N/A | N/A | N/A | N/A | No bottom button; navigation via header icons |
| **Education** | **Education Topics (Hub)** | `122:4` | *(None - In-card Navigation)* | Inside `ScrollView` (list of topics) | `EducationTopicCard` | N/A | N/A | Bottom: 24, Horiz: 20 | ❌ None | Tapping any topic card routes to detail screen |
| **Education** | **Relational Neuroscience Detail** | `146:5` | "Test Your Understanding" | Inside `ScrollView` (end of content) | `PrimaryButton` | 56 pt | `Poppins-Bold` 16pt (`cardTitle`) | Top: 8, Bottom: 28, Horiz: 20 | ✅ Medium | Trapped at end of 1459 pt long scroll body |
| **Education** | **Relational-Cultural Theory Detail** | `156:4` | "Test Your Understanding" | Inside `ScrollView` (end of content) | `PrimaryButton` | 56 pt | `Poppins-Bold` 16pt (`cardTitle`) | Top: 8, Bottom: 28, Horiz: 20 | ✅ Medium | Trapped at end of 2418 pt long scroll body |
| **Education** | **Neuroplasticity Detail** | `176:2` | "Test Your Understanding" | Inside `ScrollView` (end of content) | `PrimaryButton` | 56 pt | `Poppins-Bold` 16pt (`cardTitle`) | Top: 8, Bottom: 28, Horiz: 20 | ✅ Medium | Trapped at end of 1460 pt long scroll body |
| **Education** | **Brain Healthy Relationships Detail** | `176:70` | "Test Your Understanding" | Inside `ScrollView` (end of content) | `PrimaryButton` | 56 pt | `Poppins-Bold` 16pt (`cardTitle`) | Top: 8, Bottom: 28, Horiz: 20 | ✅ Medium | Trapped at end of 1565 pt long scroll body |
| **Education** | **Power-Over vs Power-With Detail** | `176:138` | "Test Your Understanding" | Inside `ScrollView` (end of content) | `PrimaryButton` | 56 pt | `Poppins-Bold` 16pt (`cardTitle`) | Top: 8, Bottom: 28, Horiz: 20 | ✅ Medium | Trapped at end of 1439 pt long scroll body |
| **Education** | **Impact of Relationships Detail** | `176:206` | "Test Your Understanding" | Inside `ScrollView` (end of content) | `PrimaryButton` | 56 pt | `Poppins-Bold` 16pt (`cardTitle`) | Top: 8, Bottom: 28, Horiz: 20 | ✅ Medium | Trapped at end of 1418 pt long scroll body |
| **Education** | **Knowledge Check Quiz (Stepper)** | `201:4` | "Next Question" / "View Results" / "Return" | Inside `ScrollView` (end of content) | `PrimaryButton` & `SecondaryButton` | 56 pt | `Poppins-Bold` 16pt (`cardTitle`) | Top: 8, Bottom: 28, Horiz: 20 | ✅ Medium | Vertical coordinate jumps as explanation box expands |
| **Education** | **Knowledge Check Quiz (Results)** | `201:4` | "Keep Going" / "Try Again" & "Return to Home" | Inside `ScrollView` (end of content) | `PrimaryButton` & `SecondaryButton` | 56 pt | `Poppins-Bold` 16pt (`cardTitle`) | Top: 12, Bottom: 28, Horiz: 20 | ✅ Medium | Stacked dual buttons at base of results scorecard |
| **System** | **Home Dashboard** | `5:4` | *(Card Actions + Daily Streak)* | Non-scrolling `VStack` (flexible height) | `ActionCardView` & `StreakBadgeView` | 40 pt (streak) | `Poppins-SemiBold` 13pt (`menuLabel`) | Bottom: 2, Horiz: 20 | ✅ Light | Streak anchored at base; cards spaced uniformly |
| **System** | **App Lock Screen** | Custom | "Unlock with Face ID / Passcode" | Non-scrolling `VStack` (`Spacer()` based) | Raw `Button` | 56 pt | `Poppins-SemiBold` 18pt (`headline`) | Bottom: 24 (`Spacing.large`), Horiz: 24 | ❌ None | **Anchored to bottom edge** |

### Key Navigation Inconsistencies & Failure Modes

1. **Competing Placement Paradigms**:
   * **Inline in `ScrollView`**: On `ChooseRelationshipsView`, `SurveyResultsExpandedView`, and short quiz steps, content under-fills the screen, leaving the button floating mid-screen with dead space beneath. On lesson screens (`TopicDetailView`), content severely over-fills the screen (1400–2400 pt), requiring excessive scrolling to discover or tap the CTA.
   * **Pinned in Non-Scrolling `VStack`**: `RelationshipFrequencyView` and `AppLockView` pin their buttons at the base, but cannot scroll if dynamic type or smaller screens (iPhone SE) cause text overflow.
2. **Component Fragmentation**:
   * [`PrimaryButton`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Components/Buttons.swift#L4-L64) with built-in Apple HIG touch compliance ($\ge 44\text{ pt}$), haptic feedback (`UIImpactFeedbackGenerator`), and standardized styling is consumed by Education detail, Quiz, and Survey Results views.
   * In contrast, all 5 core assessment funnel screens (`AssessmentOverviewView`, `SurveyOverviewView`, `ChooseRelationshipsView`, `RelationshipFrequencyView`, `SurveyQuestionView`) duplicate raw `Button` elements, omitting haptics and diverging in styling.
3. **Metric Drift**:
   * **Height**: 54 pt in `RelationshipFrequencyView` and `SurveyQuestionView` vs. 56 pt elsewhere.
   * **Typography**: Screens using raw buttons use `Poppins-SemiBold` at **17 pt**, whereas `PrimaryButton` uses `Poppins-Bold` at **16 pt** (`Theme.Typography.cardTitle`).
   * **Bottom Margin**: Arbitrarily varies between 12 pt, 16 pt, 24 pt, and 28 pt.

---

## 3. Audit Domain 2: Horizontal Padding & Screen Gutter Consistency

### Master Gutter & Margin Matrix

The [`HeaderNavBar`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Components/HeaderNavBar.swift#L114) defines a fixed **20 pt** horizontal padding (`.padding(.horizontal, 20)`). Visual harmony requires all views to share this exact 20 pt screen margin so header icons, title text, and content cards share a clean vertical alignment edge.

| Module | Screen / View Name | Outer Horizontal Padding | Alignment with Header Bar | Margin Status |
| :--- | :--- | :---: | :---: | :--- |
| **System** | **Home Dashboard** (`HomeView`) | **20 pt** | ✅ Aligned (20 pt) | Action cards and streak pill align flush with header icons |
| **Assessment** | **Assessment Overview** (`AssessmentOverviewView`) | **20 pt** | ✅ Aligned (20 pt) | Domain cards align flush with header icons |
| **Assessment** | **Survey Overview** (`SurveyOverviewView`) | **20 pt** | ✅ Aligned (20 pt) | Instruction rows align flush with header icons |
| **Assessment** | **Choose Relationships** (`ChooseRelationshipsView`) | **20 pt** | ✅ Aligned (20 pt) | Contact cards and Add Person button align flush |
| **Assessment** | **Relationship Frequency** (`RelationshipFrequencyView`) | **20 pt** | ✅ Aligned (20 pt) | Allocation bubble aligns flush with header icons |
| **Assessment** | **Survey Question** (`SurveyQuestionView`) | **20 pt** | ✅ Aligned (20 pt) | Progress bar and Likert cards align flush |
| **Assessment** | **Survey Results** (`SurveyResultsView`) | **20 pt** | ✅ Aligned (20 pt) | Bubble containers align flush with header icons |
| **Assessment** | **Survey Results Expanded** (`SurveyResultsExpandedView`) | **20 pt** | ✅ Aligned (20 pt) | Risk tier cards align flush with header icons |
| **Assessment** | **Past Results** (`PastResultsView`) | **20 pt** | ✅ Aligned (20 pt) | Trend charts and individual card containers align flush |
| **Education** | **Education Topics Hub** (`EducationTopicsView`) | **20 pt** | ✅ Aligned (20 pt) | Topic cards align flush with header icons |
| **Education** | **Lesson Detail Views** (`TopicDetailView`) | **20 pt** | ✅ Aligned (20 pt) | All modular sections align flush with header icons |
| **Education** | **Knowledge Check Quiz** (`EducationQuizView`) | **20 pt** | ✅ Aligned (20 pt) | Progress segment bar and quiz cards align flush |
| **System** | **Storage & Privacy** (`StorageSettingsView`) | ⚠️ **24 pt** (`Theme.Spacing.large`) | ❌ **Misaligned (-4 pt)** | Entire page is 4 pt narrower; cards indent inward |
| **System** | **App Lock Screen** (`AppLockView`) | ⚠️ **24 pt** (`Theme.Spacing.large`) | ❌ **Misaligned (-4 pt)** | Unlock button and body text indent 4 pt inward |

### Token Architecture Gap in `Theme/Spacing.swift`
In [`Theme/Spacing.swift`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Theme/Spacing.swift):
```swift
public static let medium: CGFloat = 16  // Default view padding & vertical component spacing
public static let large: CGFloat = 24   // Section gaps & card vertical padding
```
* **No token exists for 20 pt**. 
* The Assessment and Education screens hardcoded `.padding(.horizontal, 20)`.
* Developers authoring `StorageSettingsView` and `AppLockView` adhered to token usage and selected `Theme.Spacing.large` (24 pt), inadvertently creating the 4 pt visual indent.

---

## 4. Audit Domain 3: Card Border ("Broder") & Container Styling Consistency

### Master Card & Container Border Matrix

Card outlines across the design system exhibit wide divergence, ranging from borderless shapes to subtle borders, heavy accent strokes, and drop shadows:

| Module | Component / Element | Surface Fill | Border Stroke Width | Border Stroke Color | Corner Radius | Visual Description |
| :--- | :--- | :--- | :---: | :--- | :---: | :--- |
| **Shared** | **`BubbleCardContainer`** *(Results, Past Results, Lessons)* | `cardSurface` (`#EFF5FC`) | **1.0 pt** | `Theme.Colors.dividerSubtle` | 18 pt | Crisp subtle outline |
| **Education** | **`EducationTopicCard`** *(Topics Hub)* | `cardSurface` (`#EFF5FC`) | **1.0 pt** | `Theme.Colors.dividerSubtle` | 18 pt | Crisp subtle outline |
| **Education** | **`NeurobiologyPathwayCard`** *(Lesson Detail)* | `cardSurface` (`#EFF5FC`) | **1.0 pt** | `Theme.Colors.dividerSubtle` | 18 pt | Crisp subtle outline |
| **Education** | **`IllustrationParagraph`** *(Lesson Detail)* | `cardSurface` (`#EFF5FC`) | **1.0 pt** | `Theme.Colors.dividerSubtle` | 18 pt | Crisp subtle outline |
| **Education** | **`KeyTakeawaysCard`** *(Lesson Detail)* | `cardSurface` (`#EFF5FC`) | **1.0 pt** | `Theme.Colors.dividerSubtle` | 18 pt | Crisp subtle outline |
| **Education** | **`QuizOptionCard`** *(Quiz Stepper)* | State-dependent fill | **1.0 pt / 1.8 pt** | `state.borderColor` | 16 pt | 1 pt subtle unselected; 1.8 pt green/red feedback |
| **Education** | **`FounderCard`** *(Lesson Detail)* | Transparent (in-container) | ❌ **None** | None | N/A | Contained within `BubbleCardContainer` |
| **Education** | **`FiveGoodThingsCard`** *(Lesson Detail)* | Transparent (in-container) | ❌ **None** | None | N/A | Contained within `BubbleCardContainer` |
| **Assessment** | **Contact Cards** (`ChooseRelationshipsView`) | `cardSurface` (`#EFF5FC`) | ❌ **None** | None (pure background fill) | 18 pt | ⚠️ **Borderless** (blends into page on lower contrast) |
| **Assessment** | **Add Person Button** (`ChooseRelationshipsView`) | `Color.white` | **1.5 pt** | `Theme.Colors.primary` (Blue) | 18 pt | Outlined blue accent button |
| **Assessment** | **Domain Cards** (`AssessmentOverviewView`) | `cardSurface` (`#EFF5FC`) | ❌ **None** | None (pure background fill) | 18 pt | ⚠️ **Borderless** |
| **Assessment** | **`VerticalTimeAllocationBubble`** (`Frequency`) | `cardSurface` (`#EFF5FC`) | **1.5 pt** | Hardcoded `#94A2B8` (Slate) | 16 pt | ⚠️ Thicker, darker outline than standard cards |
| **Assessment** | **Likert Option Cards** (`SurveyQuestionView`) | `cardSurface` (`#EFF5FC`) | **2.0 pt** *(selected)* | `Theme.Colors.primary` (Clear when unselected) | 18 pt | Borderless unselected; 2 pt blue outline selected |
| **Assessment** | **`IndividualResultCard`** (`SurveyResultsView`) | Transparent | **1.5 pt** | `Theme.Colors.primary` (Blue) | 18 pt | Outlined blue accent card nested inside bubble |
| **Assessment** | **`RelationalRiskTierCard`** (`Results Expanded`) | `Color.white` | **1.0 pt** | `Theme.Colors.dividerSubtle` | 18 pt | Crisp subtle outline with white surface |
| **System** | **Action Cards** (`HomeView`) | 3D Render Art | ❌ **None** | Drop shadow (`radius: 8, y: 4, opacity: 0.08`) | 22 pt | Shadowed floating cards; 22 pt radius |
| **System** | **`StreakBadgeView`** (`HomeView`) | `cardSurface` (`#EFF5FC`) | **1.0 pt** | `Theme.Colors.dividerSubtle` | Capsule | Crisp subtle outline |
| **System** | **Storage Cards** (`StorageSettingsView`) | `cardSurface` (`#EFF5FC`) | ❌ **None** | Drop shadow (`radius: 8, y: 2, opacity: 0.04`) | 16 pt | ⚠️ Shadowed rather than stroked |

### Intra-Page Inconsistencies
* **`ChooseRelationshipsView`**: The **"+ Add Person"** card has a prominent `1.5 pt` blue stroke border, while the 5 contact cards directly below it have **zero border**.
* **`AssessmentOverviewView` vs. `TopicDetailView`**: Both screens explain Dr. Amy Banks's 4 C.A.R.E. neural pathways (Calm, Accepted, Resonant, Energetic). On Assessment Overview, the cards are borderless with `16 pt` padding; on Topic Detail, the pathway cards have a `1.0 pt dividerSubtle` border with `18 pt` padding.

---

## 5. Audit Domain 4: Internal Card Horizontal Insets (Content Padding)

When cards are stacked vertically on the same screen, divergent internal padding causes headers, text baselines, and icons to appear staggered:

```
Screen Margins: 20 pt
│
├─ BubbleCardContainer (Overview) ─────── Inset: 20 pt ────► [ Title text starts at X = 40 ]
│
├─ NeurobiologyPathwayCard (Pathway) ──── Inset: 18 pt ────► [ Title text starts at X = 38 ] (2 pt stagger)
│
├─ KeyTakeawaysCard ──────────────────── Inset: 18 pt ────► [ Bullet starts at X = 38 ]
│
└─ EducationTopicCard (Hub) ──────────── Inset: 16 pt ────► [ Title starts at X = 36 ] (4 pt stagger)
```

### Complete Inset Distribution Across All Codebase Components

| Internal Inset | Components & Views Using This Inset |
| :---: | :--- |
| **14 pt** | `VerticalTimeAllocationBubble.swift` partition row items (`.padding(.horizontal, 14)`) |
| **16 pt** | • `ChooseRelationshipsView.swift` contact cards (`.padding(.horizontal, 16)`)<br>• `AssessmentOverviewView.swift` domain cards (`.padding(.horizontal, 16)`)<br>• `EducationTopicCard.swift` (`.padding(.horizontal, 16)`)<br>• `QuizOptionCard.swift` (`.padding(.horizontal, 16)`)<br>• `IndividualResultCard.swift` (`.padding(.horizontal, 16)`) |
| **18 pt** | • `NeurobiologyPathwayCard.swift` (`.padding(18)`)<br>• `KeyTakeawaysCard.swift` (`.padding(18)`)<br>• `IllustrationParagraph` in `TopicDetailView.swift` (`.padding(18)`)<br>• `SurveyQuestionView.swift` Likert cards (`.padding(.horizontal, 18)`)<br>• `SurveyResultsExpandedView.swift` tier cards (`.padding(.horizontal, 18)`)<br>• `StreakBadgeView.swift` on Home (`.padding(.horizontal, 18)`) |
| **20 pt** | • `BubbleCardContainer.swift` all modular bubble cards (`.padding(20)`) |
| **24 pt** | • `ActionCardView.swift` Home module cards (`.padding(.horizontal, 24)`)<br>• `StorageSettingsView.swift` card containers (`.padding(Theme.Spacing.large)`) |

---

## 6. Unified Architectural Standardization Blueprint

When Figma design updates and new education frames are ready for implementation, the following three architectural patterns will be applied across the entire codebase:

### Pattern 1: Pinned "Sticky Bottom Action Bar" Architecture

Replaces inline scroll buttons and non-scrolling full-height hacks with a single, universally responsive bottom bar pattern:

```swift
VStack(spacing: 0) {
    // 1. Standardized Top Navigation
    HeaderNavBar(...)
    
    // 2. Freely Scrollable Content Canvas
    ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 18) {
            // Screen-specific content cards, questions, or lessons
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24) // Ensures lowest content scrolls well above pinned bar
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    
    // 3. Pinned Bottom Action Bar (Anchored above Home Indicator)
    VStack(spacing: 8) {
        PrimaryButton(
            title: ctaTitle,
            isEnabled: canProceed,
            isLoading: isSubmitting,
            action: {
                handleProceed()
            }
        )
        
        if let secondaryTitle = secondaryTitle {
            SecondaryButton(
                title: secondaryTitle,
                action: {
                    handleSecondaryAction()
                }
            )
        }
    }
    .padding(.horizontal, 20)
    .padding(.top, 12)
    .padding(.bottom, 12)
    .background(
        Theme.Colors.background
            .ignoresSafeArea(edges: .bottom)
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: -3)
    )
}
```

* **Eliminates Floating Buttons**: On `ChooseRelationshipsView`, the "Next" button will always rest at the base of the screen regardless of whether the user has 1 or 10 contacts.
* **Persistent Discoverability**: On long education lesson screens (`TopicDetailView`), users will immediately see the "Test Your Understanding" button anchored at the bottom without needing to scroll through 2000+ points of text first.
* **Uniform 56 pt Touch Height**: Standardizes all actions onto [`PrimaryButton`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Components/Buttons.swift#L4-L64) with native medium impact haptics.

### Pattern 2: Design Token Harmonization (`Theme/Spacing.swift`)

Add formal design tokens to eliminate hardcoded numbers and align system views:

```swift
extension Theme.Spacing {
    /// 20pt - Universal screen gutter margin across all views
    public static let screenGutter: CGFloat = 20
    
    /// 16pt - Standard internal content inset for cards and pills
    public static let cardInsetCompact: CGFloat = 16
    
    /// 20pt - Standard internal content inset for major bubble containers
    public static let cardInsetComfortable: CGFloat = 20
}
```

* Update `StorageSettingsView` and `AppLockView` from 24 pt to `Theme.Spacing.screenGutter` (20 pt) to unify application-wide screen borders.

### Pattern 3: Standardized Card & Border Treatment

Establish three explicit container styles across the design system:

1. **Standard Content Card**:
   * Corner radius: `18 pt` (`continuous`)
   * Border stroke: `1.0 pt` with `Theme.Colors.dividerSubtle`
   * Surface fill: `Theme.Colors.cardSurface` (`#EFF5FC`)
   * Internal padding: `16 pt` uniform
   * *Applies to*: `ChooseRelationshipsView` contact cards, `AssessmentOverviewView` domain cards, `EducationTopicCard`, `NeurobiologyPathwayCard`, `KeyTakeawaysCard`.
2. **Composite Bubble Container**:
   * Corner radius: `18 pt` (`continuous`)
   * Border stroke: `1.0 pt` with `Theme.Colors.dividerSubtle`
   * Surface fill: `Theme.Colors.cardSurface`
   * Internal padding: `20 pt` uniform
   * *Applies to*: `BubbleCardContainer` across results, past trends, and lesson founder grids.
3. **Interactive / Selectable Cards**:
   * Corner radius: `16 pt` or `18 pt`
   * Unselected: `1.0 pt` border with `Theme.Colors.dividerSubtle`
   * Selected: `1.5 pt` to `2.0 pt` border with `Theme.Colors.primary`
   * *Applies to*: `QuizOptionCard`, `SurveyQuestionView` Likert cards, `RelationshipSelectionPill`.

---

## 7. Pre-Implementation Checklist (For Design Handoff)

When resuming implementation once Figma button copy updates and new Education frames arrive:

- [ ] **Figma Design Ingestion**:
  - [ ] Extract revised button titles and copy across all Assessment screens.
  - [ ] Extract layout frames and section hierarchies for newly introduced Education module lessons.
- [ ] **Navigation & Button Standardization**:
  - [ ] Convert `ChooseRelationshipsView` to use the pinned bottom action bar pattern with `PrimaryButton`.
  - [ ] Convert `AssessmentOverviewView`, `SurveyOverviewView`, `RelationshipFrequencyView`, and `SurveyQuestionView` to use the pinned bottom bar.
  - [ ] Pin "Test Your Understanding" at the bottom of `TopicDetailView` (Education lessons).
  - [ ] Replace all raw `Button` instances in the assessment funnel with `PrimaryButton` (56 pt height, haptic feedback).
- [ ] **Padding & Border Harmonization**:
  - [ ] Add `Theme.Spacing.screenGutter = 20` to `Theme/Spacing.swift`.
  - [ ] Refactor `StorageSettingsView` and `AppLockView` outer horizontal padding from 24 pt to 20 pt.
  - [ ] Add standard `1.0 pt dividerSubtle` stroke borders to contact cards in `ChooseRelationshipsView` and domain cards in `AssessmentOverviewView`.
  - [ ] Align internal card padding across `TopicDetailView` components to eliminate the 18 pt vs. 20 pt text stagger.
- [ ] **Test & Quality Verification**:
  - [ ] Run `CAREAppTests` (Component, Screen, and Theme test suites).
  - [ ] Run `CAREAppUITests` on iPhone 16 Pro simulator to verify all button tap coordinates, screen transitions, and layout bounds remain 100% green.

---

## 8. Appendix: Live Figma Extraction — Jayme's Canvas UI Directives (Node `211:59`)

Directly extracted from the live Figma canvas (`File Key: 4uqL8l0VygkDoFQeXP7VeL`, Page: `[Done] Assessment & Homepage`, Node: `211:59`):

### 12 Concrete UI Optimizations Commented on the Canvas:
1. **Assessment Interval Counter**: Change `"Daily Streak: X Days Active"` to `"Days until next assessment"`.
2. **Calendar Icon Replacement**: Change the streak icon on the homepage from sparkles to a **calendar icon**, and horizontally center the text inside the pill bubble.
3. **Upper Header Bar Sparkle Icon**: Add a **sparkle icon** (`.actionPlan` / `action-plan-button`) to the top `HeaderNavBar` on all pages (except the Loading Screen and Personalized Action Plan screen).
4. **Header Formatting Parity**: Ensure the page title heading for **Survey Results** is formatted identically to the **Past Results** page.
5. **Forward Arrows on Primary CTAs**: Add right-facing forward arrows (`arrow.right`) inside each of the blue **"Next"** primary action buttons.
6. **Return / Back Button Icon Parity**: Add the matching return icon (from the "Return to Exercises" button) to the **"Back to Results"** button.
7. **Centered Button Text**: Ensure the text inside the blue "Back to Results" button is strictly centered.
8. **Universal Pinned Bottom Buttons**: Move all bottom action buttons to the bottom of the page (matching the layout established in `profile-page` [Node `218:4`], `exercises-screen` [Node `214:4`], and `welcome-account-setup` [Node `213:4`]) for:
   * `survey-overview` (Frame `13:4`)
   * `choose-relationships` (Frame `17:4`)
   * `relationship-frequency` (Frame `41:4`)
   * `survey-question` (Frame `25:4`)
9. **Return to Home CTA on Past Results**: Add a **"Return to Home"** secondary button at the bottom of the Past Results screen matching the Survey Results visual specification.
10. **Top Bar Back Button on Past Results**: Add a **back button** (`.back`) to the `HeaderNavBar` on the Past Results screen.
11. **1-Line Subtitle Descriptions**: Add a concise 1-line subtitle under the **Survey Results** and **Past Results** page headings explaining the screen's intended purpose (matching the formatting used on `exercises-screen`).
12. **1-to-2-Line Purpose Descriptions**: Add up to a 2-line subtitle description of the intended purpose on:
    * `choose-relationships`
    * `survey-overview`
    * `survey-question`

### New Frames Introduced in Figma File:
* `welcome-account-setup` (`Node 213:4`)
* `exercises-screen` (`Node 214:4`)
* `personalized-action-plan` (`Node 215:5`)
* `profile-page` (`Node 218:4`)

