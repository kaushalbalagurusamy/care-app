# Workflow 04: Autonomous Evaluation Loop & Rollback Mandate

This workflow governs how Codex verifies code autonomously and resolves regressions without involving Jayme in debugging.

---

## 1. The Autonomous Evaluation Loop

```
┌────────────────────────────────────────────────────────┐
│ Run: ./jayme-codex-instructions/tooling/test_and_eval.sh│
└──────────────────────────┬─────────────────────────────┘
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
      [ Tests Green ✓ ]           [ Tests Red ✗ ]
             │                           │
             ▼                           ▼
[ Exit Implementation Loop ]      [ Check Strike Count ]
• Build for simulator                    │
• Capture screenshot              ┌──────┴──────┐
• Handoff to Jayme                ▼             ▼
                           [ Strike 1 ]   [ Strike >= 2 ]
                           • Minimal      • Rollback Mandate:
                             diff fix       ./atomic_git.sh rollback
                           • Re-eval      • Formulate new hypothesis
```

---

## 2. Invariants & Rules

### Rule 1: The Green-State Gate
* Codex **MUST NEVER** exit the implementation loop or tell Jayme "I'm done" until `./jayme-codex-instructions/tooling/test_and_eval.sh` returns exit code 0 (`EVALUATION PASSED`).

### Rule 2: The 2-Strike Diagnostic Gate
* If a test fails twice consecutively with the same error:
  1. **Immediately halt further file modifications.**
  2. Inspect the failure trace in `/tmp/care_app_test_eval.log`.
  3. Analyze whether the issue is a type mismatch, observation failure (`@Observable`), or navigation stack lifecycle issue.

### Rule 3: The Rollback Mandate
* If an attempted fix causes new regressions or breaks previously green tests:
  ```bash
  ./jayme-codex-instructions/tooling/atomic_git.sh rollback
  ```
* Roll back to the last clean checkpoint before testing an alternative hypothesis. Never allow broken patches to compound on top of each other.
