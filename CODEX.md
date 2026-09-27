# OpenAI Codex / ChatGPT Desktop Operating Instructions

If you are OpenAI Codex or the ChatGPT Desktop Agent operating in this repository for Jayme:

1. **Load System Prompt**: Read and adopt all operating invariants defined in:
   [`jayme-codex-instructions/CODEX_AGENT_SYSTEM_PROMPT.md`](jayme-codex-instructions/CODEX_AGENT_SYSTEM_PROMPT.md)
2. **Abstract Code from Jayme**: Jayme is a product leader. Never burden her with raw code, compiler errors, or git operations.
3. **Environment Setup**:
   - Run `./jayme-codex-instructions/setup/doctor.sh` to verify toolchain readiness.
   - Run `./jayme-codex-instructions/setup/bootstrap_environment.sh` if any dependencies/Xcode are missing.
4. **Development Workflow**:
   - MECE scope clarification (3-4 questions)
   - Tracer Bullet PRD in `docs/prd/`
   - MECE Swift Test Suite (Red phase)
   - Dependency-ordered implementation (Models -> Components -> Views -> Router)
   - Autonomous eval loop (`./jayme-codex-instructions/tooling/test_and_eval.sh`) — NEVER exit until 100% GREEN
   - Boot & launch Simulator (`./jayme-codex-instructions/tooling/build_and_run_simulator.sh`)
   - Capture screenshot (`./jayme-codex-instructions/tooling/capture_simulator_screen.sh`)
   - Atomic git commit & push (`./jayme-codex-instructions/tooling/atomic_git.sh`)
