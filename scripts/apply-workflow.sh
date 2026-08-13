#!/usr/bin/env bash
# Aplica el flujo de trabajo AI Agents de este template a un repo existente.
# Idempotente: copia .workflow/ y skills/ solo si no existen, y añade la
# seccion de workflow a AGENTS.md / el bloque anti-fuga a .gitignore solo si
# faltan. Uso:
#   ./scripts/apply-workflow.sh /ruta/al/repo-destino
set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"

if [ -z "$TARGET" ] || [ ! -d "$TARGET/.git" ]; then
    echo "Uso: $0 /ruta/al/repo-destino (debe ser un repo git)" >&2
    exit 1
fi
if [ "$TARGET" = "$TEMPLATE_DIR" ]; then
    echo "El destino es el propio template; nada que hacer." >&2
    exit 1
fi

echo "==> Aplicando flujo a: $TARGET"

# 1) .workflow/ — solo si no existe (nunca pisa un plan en curso)
if [ ! -d "$TARGET/.workflow" ]; then
    cp -r "$TEMPLATE_DIR/.workflow" "$TARGET/.workflow"
    echo "    + .workflow/ copiado"
else
    echo "    - .workflow/ ya existe, se conserva (revisa .workflow/briefs/_template.md a mano)"
    if [ ! -f "$TARGET/.workflow/briefs/_template.md" ]; then
        cp "$TEMPLATE_DIR/.workflow/briefs/_template.md" "$TARGET/.workflow/briefs/_template.md"
        echo "    + briefs/_template.md añadido"
    fi
    if [ ! -f "$TARGET/.workflow/audit-checklist.md" ]; then
        cp "$TEMPLATE_DIR/.workflow/audit-checklist.md" "$TARGET/.workflow/audit-checklist.md"
        echo "    + audit-checklist.md añadido"
    fi
fi

# 2) skills/ — solo si no existe (nunca pisa skills del repo)
if [ ! -d "$TARGET/skills" ]; then
    cp -r "$TEMPLATE_DIR/skills" "$TARGET/skills"
    echo "    + skills/ copiado (security-audit + ponytail-*)"
else
    for s in security-audit ponytail ponytail-review ponytail-audit ponytail-debt ponytail-gain ponytail-help; do
        if [ ! -d "$TARGET/skills/$s" ]; then
            cp -r "$TEMPLATE_DIR/skills/$s" "$TARGET/skills/"
            echo "    + skills/$s añadido"
        fi
    done
fi

# 3) AGENTS.md — añade la seccion de workflow si falta (respeta lo existente)
if [ -f "$TARGET/AGENTS.md" ]; then
    if ! grep -q "AI Workflow: planner" "$TARGET/AGENTS.md"; then
        cat >> "$TARGET/AGENTS.md" << 'EOF'

---

# AI Workflow: planner → executors → auditor

This repo runs a multi-instance wave workflow. The plan and every handoff live in committed files under `.workflow/` — never only in a chat context. Sessions are disposable; the files are the memory.

## Roles

- **Planner** (fresh session, strongest available model): reads the project idea and this repo, writes `.workflow/plan.md` with the wave list and the file-ownership map, and writes one brief per executor under `.workflow/briefs/`. Details ONLY the next wave (rolling plan).
- **Executor** (one per brief, cheaper model): `git worktree add` its own branch, reads its brief, implements, runs the brief's verify command, commits. Touches only the files it owns.
- **Integrator** (medium model): merges the wave branches into `main` in the order of the plan's integration plan, runs build + tests on the integrated tree, pushes `main`. On conflict: STOPS and reports — never resolves conflicts with its own criteria.
- **Auditor** (fresh session — never the planner's session — strongest model): reviews the INTEGRATED tree (merged worktrees) against `.workflow/audit-checklist.md`. Evidence over narration: every check is a command it runs; a claim without output is a failed check.

## Wave rules

1. A wave = parallel executors with disjoint file ownership. Two executors never own the same file in the same wave; if they need it, sequence them.
2. Every wave ends with: integration (the integrator merges the wave branches into main, then build + tests) → audit. The next wave starts only after the audit passes or records explicit exceptions in `.workflow/plan.md`.
3. Rolling plan: only the next wave is detailed. After each audit the planner re-plans the next wave from the decision log.
4. Release gate: anything that will be distributed runs `skills/security-audit` first. Zero CRITICAL/HIGH findings, or documented exceptions. Never skip it.
5. Lazy rules apply to everyone, including the auditor: the best audit is the smallest audit that catches the real failure.

## Commit rules (mandatory)

- Every commit uses conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `perf:`, `style:`, `build:`, `ci:`, `revert:`. Scope optional: `feat(core):`.
- Short summary: imperative, lowercase, one line, under ~72 chars. No AI attribution, no trailers, no prose.
- One logical change per commit. `feat:`/`fix:` change behavior; `chore:` doesn't.
- Executors commit ONLY their owned files, one commit per task.
- **Branch isolation (mandatory):** every executor commits AND pushes ONLY to its own worktree branch. Never push to `main` or to another executor's branch; never merge, rebase, or fast-forward anyone else's branch. `git push origin <your-branch>` after each commit, so the work survives the session without touching parallel instances.
- **Territory (mandatory):** an executor never leaves its worktree (`cd`) and never runs `git checkout`, `git switch`, `git branch`, `git worktree`, or `git stash`. It works on the branch its worktree was created with, and on no other — it does not invent or switch branches. Git itself blocks checking out a branch already used by another worktree; treat that error as "report, don't retry".
- Committing is not a reward: if the diff can't be described in one short line, split it.

## Skills in this repo

- `skills/security-audit` — Cloudflare 6-phase security audit (recon → parallel hunt → adversarial validation → report → structured output → independent verification). Trigger: "security audit", "find vulnerabilities", "pen-test". Required at release gates.
- `skills/ponytail-review` — diff review that hunts over-engineering. Trigger: "review for over-engineering", "what can we delete".
- `skills/ponytail-audit` — repo-wide over-engineering scan. Trigger: "audit this codebase", "find bloat".
- `skills/ponytail-debt` — harvests every `ponytail:` comment into a debt ledger. Trigger: "ponytail debt", "list the shortcuts".
- `skills/ponytail-gain` / `skills/ponytail-help` — ponytail impact scoreboard and reference card.
EOF
        echo "    + seccion de workflow añadida a AGENTS.md"
    else
        echo "    - AGENTS.md ya tiene la seccion de workflow"
    fi
else
    cp "$TEMPLATE_DIR/AGENTS.md" "$TARGET/AGENTS.md"
    echo "    + AGENTS.md copiado (no existia)"
fi

# 4) .gitignore — bloque anti-fuga si falta
if [ -f "$TARGET/.gitignore" ]; then
    if ! grep -q "Agentes IA" "$TARGET/.gitignore"; then
        cat >> "$TARGET/.gitignore" << 'EOF'

# --- Agentes IA: memorias y estado local (NUNCA al repo) ---
.serena/
.engram/
.opencode/
.aider/
.aider*

# --- Secretos y credenciales ---
.env
.env.*
!.env.example
*.pem
*.key
*.p12
*.pfx
*.p8
*.crt
*.keystore
id_rsa
id_ed25519
id_ecdsa
credentials
secrets/
*.secret
EOF
        echo "    + bloque anti-fuga añadido a .gitignore"
    else
        echo "    - .gitignore ya tiene el bloque anti-fuga"
    fi
else
    cp "$TEMPLATE_DIR/.gitignore" "$TARGET/.gitignore"
    echo "    + .gitignore copiado (no existia)"
fi

echo ""
echo "==> Listo. Revisa con: git -C $TARGET status"
echo "    Manual completo: docs/WORKFLOW.md (del template)"
