## 🤖 AI Agent Workflow

This template is optimized for AI-agent-driven development. Everything an agent needs to work here is in the repo — no external tooling required.

- **`AGENTS.md`** — the operating manual every agent reads on session start: the ponytail lazy-senior-dev ruleset plus the planner → executors → auditor wave workflow.
- **`.workflow/`** — the workflow state, committed so sessions are disposable:
  - `plan.md` — rolling plan (only the next wave is detailed) + file-ownership map + decision log
  - `briefs/_template.md` — per-executor handoff brief (task, owned files, forbidden files, verify command)
  - `audit-checklist.md` — what the auditor verifies on the integrated tree
- **`skills/`** — on-demand skills, loaded only when triggered (no installation, no MCP):
  - `security-audit` (Cloudflare) — 6-phase security audit; **required at release gates**
  - `ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help`
- **`docs/WORKFLOW.md`** — the full human operating manual (phases 0-5, prompts, cheat sheet).
- **`scripts/apply-workflow.sh`** — idempotent script to apply this workflow to an existing repo: `./scripts/apply-workflow.sh /path/to/repo`.

### Getting started

1. Clone this template (or "Use this template") and push to your remote.
2. Empty `.workflow/plan.md` (keep the structure), set your README.
3. Open your AI agent in the repo and switch to the **planner** role (in OpenCode: `Tab`), then paste your project idea. The planner writes the plan and the wave-1 briefs.
4. Review `plan.md`, approve wave 1, then launch one **executor** per brief in its own `git worktree`.
5. Integrate with the **integrator** role, audit with the **auditor** role (fresh session), repeat per wave.
6. Before distributing anything: run the **security-audit** skill.

Roles in OpenCode (if you use it): switch with `Tab` — `planner`, `executor`, `integrator`, `auditor` — each with its own model and prompt already loaded. Full details in [`docs/WORKFLOW.md`](docs/WORKFLOW.md).

### Commit convention (mandatory)

Every commit in this repo follows conventional commits with a short one-line summary:

- `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `perf:`, `style:`, `build:`, `ci:`, `revert:` — optional `(scope)`, imperative, lowercase, under ~72 chars.
- One logical change per commit. No AI attribution, no trailers.
- `feat:`/`fix:` change behavior; `chore:` doesn't.
- **Executors:** commit and push ONLY to your own worktree branch (`git push origin <your-branch>`). Never touch `main` or another executor's branch — parallel instances must never be affected.

### Skills (activation cheat sheet)

| Skill | Ask for... | What it does |
|-------|------------|--------------|
| `security-audit` | "security audit this codebase" / "find vulnerabilities" / "pen-test" | Full 6-phase security audit (recon → hunt → adversarial validation → report → structured output → verify). Required at release. |
| `ponytail` | "ponytail" / "be lazy" / "yagni" / "do less" | Reinforces lazy-senior mode (lite/full/ultra). |
| `ponytail-review` | "review for over-engineering" / "what can we delete" | Diff review hunting over-engineering; one line per finding. |
| `ponytail-audit` | "audit this codebase" / "find bloat" | Repo-wide over-engineering scan, ranked by biggest cut. |
| `ponytail-debt` | "ponytail debt" / "list the shortcuts" | Harvests every `ponytail:` comment into a debt ledger. |
| `ponytail-gain` | "ponytail gain" | Ponytail impact scoreboard. |
| `ponytail-help` | "ponytail help" | Quick reference card. |

Skills load automatically when you ask for the trigger — zero setup.

The workflow in one line: **planner plans one wave → parallel executors in worktrees → integrator integrates → auditor checks the integrated tree → next wave**. See `docs/WORKFLOW.md` for the full protocol.

## 📜 Project Licenses

This repository uses a multi-license model to protect different types of assets:

* **Source Code (`/src`, `/scripts`):** Licensed under **Apache 2.0** - See [`LICENSE-SOFTWARE`](LICENSE-SOFTWARE).
* **Hardware Designs (`/hardware`, `/kicad`):** Licensed under **CERN-OHL-P v2** - See [`LICENSE-HARDWARE`](LICENSE-HARDWARE).
* **Documentation & Media (`/docs`, LaTeX, Renders):** Licensed under **CC BY 4.0** - See [`LICENSE-MEDIA`](LICENSE-MEDIA).
