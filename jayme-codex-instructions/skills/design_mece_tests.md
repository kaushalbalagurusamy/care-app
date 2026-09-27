# Skill: MECE Test Ladder Designer

## Objective
Author deterministic, hermetic test suites using Apple's Swift Testing framework (`import Testing`) to cover all acceptance criteria in the PRD before writing production code.

## Guidelines
1. **Never write implementation first**: Tests must be authored and confirmed red first.
2. **Four Layers**:
   - Model Invariants (`DomainModelAndScoringTests.swift` or dedicated file).
   - Component Render & Actions (`AtomicComponentTests.swift`).
   - Router Navigation (`AppRouterTests.swift`).
   - Screen State & Binding.
3. **Execution**: Verify via `./jayme-codex-instructions/tooling/test_and_eval.sh`.
