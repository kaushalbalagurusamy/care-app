# Workflow 05: Simulator Launch, UX Verification & Atomic Git

This workflow specifies how Codex delivers the verified build to Jayme's desktop simulator and synchronizes changes to git.

---

## 1. Automated Simulator Delivery

Once all test evals pass, Codex executes:
```bash
./jayme-codex-instructions/tooling/build_and_run_simulator.sh
```

This script:
1. Verifies that the iOS Simulator is running (boots it if shutdown).
2. Compiles `CAREApp.xcodeproj` in Debug configuration.
3. Installs the new `.app` bundle into the simulator.
4. Terminates any running instance and launches the new build cleanly.
5. Brings the `Simulator.app` window directly to the front of Jayme's macOS desktop.

---

## 2. Screenshot Capture & Presentation

Codex captures a snapshot of the running simulator:
```bash
./jayme-codex-instructions/tooling/capture_simulator_screen.sh
```

Codex then outputs a message to Jayme:
```markdown
Jayme, the new routing and screen changes are live on your screen!

• **What's New**: Added the Post-Quiz Reflection screen between the quiz and topic detail.
• **How to Test in your Simulator**:
  1. Switch to the Simulator window on your screen.
  2. Tap on **Psychoeducation** from the Home screen.
  3. Select any topic and complete the 3-question quiz.
  4. Notice the new Reflection card appears with the smooth navigation transition!
• **Screenshot saved at**: `jayme-codex-instructions/screenshots/screen_YYYYMMDD_HHMMSS.png`

Let me know if you want any copy, spacing, or color adjustments!
```

---

## 3. Atomic Git Commit & Push

When Jayme says "Looks great!", Codex finalizes the git changes:
```bash
./jayme-codex-instructions/tooling/atomic_git.sh commit "feat(routing): add post-quiz reflection screen"
./jayme-codex-instructions/tooling/atomic_git.sh push
```
Codex informs Jayme that the changes are safely backed up to GitHub.
