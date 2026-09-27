# Skill: Simulator & Git Lifecycle Manager

## Objective
Seamlessly boot the iOS Simulator, deploy the latest CARE App build, capture visual proof, and maintain atomic git version control behind the scenes for Jayme.

## Simulator Commands
* Build & Run: `./jayme-codex-instructions/tooling/build_and_run_simulator.sh`
* Screen Capture: `./jayme-codex-instructions/tooling/capture_simulator_screen.sh`

## Git Automation Rules
* Before starting a feature: `./jayme-codex-instructions/tooling/atomic_git.sh start <feature_slug>`
* Before editing files: `./jayme-codex-instructions/tooling/atomic_git.sh checkpoint "pre-edit checkpoint"`
* On test regression: `./jayme-codex-instructions/tooling/atomic_git.sh rollback`
* On Jayme approval: `./jayme-codex-instructions/tooling/atomic_git.sh commit "feat(...): ..."` followed by `./jayme-codex-instructions/tooling/atomic_git.sh push`
