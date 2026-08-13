## 🤖 AI Agent Workflow

This template is optimized for AI-agent-driven development. Everything an agent needs to work here is in the repo — no external tooling required.

- **`AGENTS.md`** — the operating manual every agent reads on session start: the ponytail lazy-senior-dev ruleset plus the planner → executors → auditor wave workflow.
- **`.workflow/`** — the workflow state, committed so sessions are disposable:
  - `plan.md` — rolling plan (only the next wave is detailed) + file-ownership map + decision log
  - `briefs/_template.md` — per-executor handoff brief (task, owned files, forbidden files, verify command)
  - `audit-checklist.md` — what the auditor verifies on the integrated tree

### Commit convention (mandatory)

Every commit in this repo follows conventional commits with a short one-line summary:

- `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `perf:`, `style:`, `build:`, `ci:`, `revert:` — optional `(scope)`, imperative, lowercase, under ~72 chars.
- One logical change per commit. No AI attribution, no trailers.
- `feat:`/`fix:` change behavior; `chore:` doesn't.

### Skills
- **`skills/`** — on-demand skills, loaded only when triggered:
  - `security-audit` (Cloudflare) — 6-phase security audit; required at release gates
  - `ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help`

The workflow in one line: **planner plans one wave → parallel executors in worktrees → integrate → auditor checks the integrated tree → next wave**. See `AGENTS.md` for the full protocol.

## 📜 Project Licenses

This repository uses a multi-license model to protect different types of assets:

* **Source Code (`/src`, `/scripts`):** Licensed under **Apache 2.0** - See [`LICENSE-SOFTWARE`](LICENSE-SOFTWARE).
* **Hardware Designs (`/hardware`, `/kicad`):** Licensed under **CERN-OHL-P v2** - See [`LICENSE-HARDWARE`](LICENSE-HARDWARE).
* **Documentation & Media (`/docs`, LaTeX, Renders):** Licensed under **CC BY 4.0** - See [`LICENSE-MEDIA`](LICENSE-MEDIA).
