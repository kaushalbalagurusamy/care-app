# CARE App — Jayme's Product & Codex Autonomous Engineering Hub

Welcome, Jayme! This folder contains everything needed for you to develop, test, and ship product improvements and routing changes to the **CARE App** directly from **ChatGPT Desktop** on your Mac.

You don't need to write Swift code, configure Xcode project files, manage git branches, or debug compiler errors. **Codex operates as your dedicated AI Mobile Staff Engineer**, translating your product vision into production-grade SwiftUI code, running exhaustive test suites, booting the iOS Simulator on your desktop, and taking care of version control.

---

## 🚀 Quickstart: Your First 60 Seconds

1. **Open ChatGPT Desktop** on your Mac.
2. Open or attach the `care-app` repository folder.
3. Paste or type this prompt:
   > *"Hi Codex! I'm ready to work on the CARE App. Please read `/jayme-codex-instructions/CODEX_AGENT_SYSTEM_PROMPT.md`, check my system readiness, and get my simulator ready."*
4. Codex will:
   - Run the automated environment doctor (`./jayme-codex-instructions/setup/doctor.sh`).
   - Confirm your tools (or guide you through installing Xcode / Command Line Tools if you're on a brand-new Mac).
   - Boot up the **iOS Simulator** right on your Mac desktop and launch CARE App!

---

## 💡 How to Make Routing & Product Changes

You can communicate with Codex in natural, product-first language. Here are real examples:

### Example A: Inserting a New Screen in a Flow
> *"Codex, I want to insert a new 'Post-Quiz Reflection' screen right after a user finishes an education quiz and before they see the topic detail view. Let's ask them 1 question about how they feel."*

### Example B: Reordering Navigation Paths
> *"Codex, let's update the assessment routing: after the user finishes Question 20, let's take them straight to Survey Results V2 instead of the old Results screen."*

### Example C: Adding a New Tab or Entry Point
> *"Codex, I want to add a quick-access 'Crisis & Support Resources' button in the header navigation that pops up a modal sheet from any screen."*

---

## 🔄 The 5-Step Autonomous Engine

Whenever you propose a change, Codex autonomously executes this 5-stage loop:

```
┌────────────────────────────────────────────────────────┐
│ 1. MECE Scope Clarification                            │
│    Codex asks you 3-4 structured multiple-choice       │
│    questions to clarify edge cases, back buttons & UX. │
└──────────────────────────┬─────────────────────────────┘
                           ▼
┌────────────────────────────────────────────────────────┐
│ 2. Tracer Bullet PRD                                   │
│    Codex synthesizes a lean 1-page spec defining the   │
│    user journey, route names, and acceptance criteria. │
└──────────────────────────┬─────────────────────────────┘
                           ▼
┌────────────────────────────────────────────────────────┐
│ 3. MECE Test Suite Design (TDD)                        │
│    Codex writes automated unit & navigation tests in   │
│    Swift to verify the exact behavior before coding.   │
└──────────────────────────┬─────────────────────────────┘
                           ▼
┌────────────────────────────────────────────────────────┐
│ 4. Dependency-Ordered Implementation & Autonomous Eval │
│    Codex writes the code in strict order (Models ➔     │
│    Components ➔ Views ➔ Router) and runs test evals    │
│    until 100% GREEN.                                   │
└──────────────────────────┬─────────────────────────────┘
                           ▼
┌────────────────────────────────────────────────────────┐
│ 5. Simulator Launch & Hands-on UX Testing              │
│    Codex installs the build into your iOS Simulator,   │
│    captures a screenshot for chat, and lets you tap!   │
└────────────────────────────────────────────────────────┘
```

---

## 📱 Testing Your Changes in the Simulator

* When Codex finishes an implementation, it compiles the app and launches it in the **iOS Simulator** window on your Mac screen.
* You can click, swipe, scroll, and test animations directly in the simulator just like on a real iPhone.
* If you want to tweak spacing, colors, or copy, just tell Codex:
  > *"Looks great! Can we make the submit button green and increase the top padding by 8pt?"*

---

## 🗂️ What’s in this Folder?

| Directory / File | Description |
| :--- | :--- |
| **`CODEX_AGENT_SYSTEM_PROMPT.md`** | The complete system prompt and operating protocol for Codex. |
| **`JAYME_QUICKSTART_CARD.md`** | 1-page cheat sheet for Jayme on prompt formulas and routing syntax. |
| **`setup/`** | Automated scripts: `bootstrap_environment.sh`, `doctor.sh`, `setup_simulator.sh`. |
| **`tooling/`** | Autonomous helper scripts: `test_and_eval.sh`, `build_and_run_simulator.sh`, `capture_simulator_screen.sh`, `atomic_git.sh`. |
| **`routing_guide/`** | Visual documentation of all routes, the router architecture, and common routing recipes. |
| **`workflows/`** | Detailed step-by-step specifications for PRD creation, TDD design, and topological coding. |
| **`templates/`** | PRD templates, test templates, and SwiftUI screen boilerplates. |
| **`skills/`** | Reusable Codex prompt modules for MECE questions, PRD synthesis, and simulator management. |

---

## 🛠️ Fresh Mac Setup FAQ

**What if I don't have Xcode installed yet?**
* Full Xcode is needed for the Apple iOS Simulator.
* If you don't have it, tell Codex: *"Run the bootstrap script"*.
* Codex will execute `./jayme-codex-instructions/setup/bootstrap_environment.sh`, which will open the Mac App Store page for Xcode (`id497799835`).
* While Xcode downloads in the background, you and Codex can already collaborate on PRDs, design routing flows, and write test specs! Once Xcode finishes, Codex will boot the simulator and build the app.
