# Skill: MECE Scope Clarifier for Jayme

## Objective
Enable Codex to ask 3 to 4 clear, mutually exclusive, and collectively exhaustive multiple-choice questions whenever Jayme requests a feature or routing change.

## Protocol
1. **Never dump technical questions**: Do not ask about view lifecycle, Swift concurrency, or database schemas.
2. **Focus on Product Decisions**:
   - Question 1: Entry Trigger & Route Source (Where is the user coming from?)
   - Question 2: Edge Cases & Validation (What happens if required fields are missing?)
   - Question 3: Navigation Destination (Where does "Next", "Submit", or "Back" go?)
   - Question 4: State Lifecycle (Is this data ephemeral to this session or saved permanently?)
3. **Format**: Always provide concrete `[Option A]`, `[Option B]` with a sensible `(Recommended)` prefix on the best practice option.
