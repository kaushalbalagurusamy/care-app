# Workflow 01: MECE Scope Clarification & Tracer Bullet PRD

This workflow guides Codex through clarifying Jayme's product requests using **MECE (Mutually Exclusive, Collectively Exhaustive)** principles and generating a **Tracer Bullet PRD**.

---

## 1. The MECE Clarification Protocol

When Jayme describes a new feature or routing update, her mental model is focused on the user experience. Unaddressed edge cases or ambiguous navigation transitions cause compounding code rework.

Codex must **immediately pause** before writing code and ask **3 to 4 MECE questions** structured as distinct options.

### The 4 MECE Clarification Pillars:

```
                  ┌─────────────────────────────────────────┐
                  │        4 PILLARS OF MECE SCOPE          │
                  └─────────────────────────────────────────┘
                                       │
     ┌──────────────────┬──────────────┴─────┬──────────────────┐
     ▼                  ▼                    ▼                  ▼
[ 1. Trigger / Entry ] [ 2. Experience/State ] [ 3. Exit / Route ] [ 4. Persistence ]
• Where from?         • Default values?      • Where next?      • Persist to DB?
• Context passed?     • Empty states?        • Back behavior?   • Transient session?
```

### Example Question Format:
```markdown
Jayme, to make sure we build this exact flow, I have 3 quick questions:

1. **Entry Point**: Where should the user encounter this reflection screen?
   - [Option A]: Automatically right after finishing Question 20, before the results.
   - [Option B]: As a banner on the Survey Results screen that they can choose to tap.

2. **Back Button Behavior**: If the user taps "Back" on this screen:
   - [Option A]: Return to Question 20 (allowing them to review answers).
   - [Option B]: Return to Home dashboard and prompt to save draft.

3. **Data Storage**: Should their reflection note be saved to their permanent history?
   - [Option A]: Yes, encrypt and save to device local storage.
   - [Option B]: No, keep it as a momentary mindful reflection for this session only.
```

---

## 2. Generating the Tracer Bullet PRD

Once Jayme provides feedback (e.g., *"Option A for 1, Option A for 2, Option B for 3"*):
1. Create a markdown file: `docs/prd/PRD_<feature_slug>.md`.
2. Follow `jayme-codex-instructions/templates/TRACER_BULLET_PRD_TEMPLATE.md`.
3. Include:
   - **Executive Summary**: 2 sentences explaining the user benefit.
   - **User Story**: As a user... I want to... so that...
   - **Route Contract**: Exact `AppRoute` enum name and parameters.
   - **Acceptance Criteria (Gherkin style)**: Given... When... Then...
   - **Out of Scope**: Explicit boundary conditions.
4. Present a quick 3-bullet summary of the PRD to Jayme and proceed directly to test design!
