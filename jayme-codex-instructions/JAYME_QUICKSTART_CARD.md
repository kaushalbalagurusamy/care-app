# Jayme's 2-Minute Quickstart Cheat Sheet

Keep this card handy when working in ChatGPT Desktop with Codex!

---

## 💬 3 Magic Prompts to Kick Off

### 1. Daily Check-in & Simulator Start
> *"Codex, let's start today's session on CARE App. Run the environment doctor, make sure my simulator is booted, and confirm what git branch we're on."*

### 2. Requesting a Routing or Screen Change
> *"Codex, I want to make a routing change: [Describe the user flow in plain English]. Please ask me your MECE follow-up questions to nail down scope, draft the tracer bullet PRD, and implement it."*

### 3. Reviewing & Iterating Live
> *"Codex, launch the latest build on the simulator and take a screenshot so I can see it. Then I'll test it myself on my Mac screen."*

---

## 🧭 How to Describe Routing Changes

Codex understands natural language descriptions of user flows:

| What you want to say | Example prompt for Codex |
| :--- | :--- |
| **Insert a Screen** | *"Insert a new 'Post-Assessment Breathing Exercise' screen between Survey Question 20 and the Results screen."* |
| **Reorder Screens** | *"When a user taps 'Start Assessment', take them directly to Question 1 instead of showing the Overview view first."* |
| **Add a Modal / Sheet** | *"Add a 'Cancel Assessment Confirmation' bottom sheet if the user taps the back button during the survey."* |
| **Conditional Route** | *"If the user has completed less than 5 questions, go back to Home; if they completed more than 5, prompt to save draft."* |
| **New Tab / Hub Entry** | *"Add a 'Daily Micro-Practices' card on the Home dashboard that routes directly to the Exercises view."* |

---

## 🎯 How Codex Collaborates With You

1. **You ask for a feature.**
2. **Codex will reply with 3–4 multiple choice questions** (e.g., Option A vs. Option B). You just reply: *"Option A for #1, Option B for #2, and keep defaults for the rest."*
3. **Codex produces a 1-page Tracer Bullet PRD.** You review the acceptance criteria.
4. **Codex authors the tests and code autonomously.** You don't have to watch or debug code.
5. **Codex launches the iOS Simulator on your desktop.** You test the new flow with your mouse/trackpad.
6. **Codex commits and pushes to GitHub** when you give the thumbs up!
