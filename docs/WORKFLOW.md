# Flujo de trabajo AI Agents — de 0 a 100

> Cómo hacer funcionar el workflow **planner → executors → integrator → auditor**
> sobre este repositorio. La versión normativa vive en `AGENTS.md` +
> `.workflow/`; este documento es el manual de operación humana.
> Si este repo nació del template: ya tienes todo. Si es un repo viejo que
> estás actualizando: `./scripts/apply-workflow.sh /ruta/al/repo` (del template).

---

## 0. Conceptos base

1. **Nada de esto es un MCP ni un servicio.** No hay servidores ni
   instalación. Todo el flujo es: `AGENTS.md` (reglas que el agente lee en
   cada sesión), `.workflow/` (estado del proyecto en archivos commiteados) y
   `skills/` (instrucciones markdown que se cargan solo cuando se usan).
2. **Las skills son markdown con frontmatter.** Su `description` es el
   trigger: el agente carga el `SKILL.md` cuando tu petición coincide.
   Cuestan 0 tokens hasta que se invocan.
3. **El harness ya lo tienes:** tu agente de código (OpenCode, Claude Code,
   Cursor, Codex...) ya ejecuta skills, lee AGENTS.md y corre modelos. El
   flujo aporta la disciplina de proceso, no herramientas nuevas.
4. **El flujo no es automático.** El humano dispara cada fase. Cada fase es
   una instancia/sesión con un rol. Las sesiones son desechables; los
   archivos de `.workflow/` son la memoria real.
5. **Modelos:** rol fuerte para planificar y auditar, rol barato para
   ejecutar con brief escrito. Quemar tokens en trabajo real es legítimo;
   quemarlos re-explorando y narrando es lo que este flujo elimina.

---

## 1. El ciclo completo

```
FASE 0  Crear/actualizar el repo (template o scripts/apply-workflow.sh)
FASE 1  PLANIFICAR   → agente planner  → plan.md + briefs de la ola 1
FASE 2  EJECUTAR     → N executors paralelos, cada uno en su worktree/rama
FASE 3  INTEGRAR     → agente integrator   → merge de ramas a main + build/tests
FASE 4  AUDITAR      → agente auditor  → checklist sobre el árbol integrado
        ↳ APPROVED → siguiente ola (FASE 1, plan rodante)
        ↳ REJECTED → fixes + re-auditar
FASE 5  RELEASE      → skills/security-audit → 0 CRITICAL/HIGH → distribuir
```

---

## 2. FASE 0 — Preparar el repo

**Nuevo:** clona el template (o "Use this template" en GitHub), vacía
`.workflow/plan.md`, ajusta README, listo.

**Repo viejo:** ejecuta el script del template:

```bash
git clone <tu-template> /tmp/wf-updater
/tmp/wf-updater/scripts/apply-workflow.sh /ruta/al/repo-que-quieres-actualizar
cd /ruta/al/repo-que-quieres-actualizar
git add -A && git commit -m "feat: adopt AI wave workflow (planner/executors/auditor)"
```

El script es idempotente: copia `.workflow/` y `skills/` solo si faltan,
añade la sección de workflow a `AGENTS.md` y el bloque anti-fuga a
`.gitignore` sin pisar nada existente.

---

## 3. FASE 1 — Planificar (rol PLANNER)

Instancia nueva, modelo fuerte, sesión limpia. Dile la idea del proyecto y el
planner hace todo lo demás:

```
<pega la idea del proyecto: qué problema resuelve, para quién,
 qué hace la v1, qué NO hace>
```

El planner investiga el repo y escribe:
- `.workflow/plan.md` — Goal, stack, lista de olas (solo la siguiente detallada)
- `.workflow/briefs/wave1-executor-K.md` — un brief por executor (tarea,
  archivos que posee, archivos prohibidos, comando de verify, rama)

TÚ lees el plan, ajustas lo que quieras, apruebas la ola 1.

---

## 4. FASE 2 — Ejecutar (rol EXECUTOR)

Una instancia por brief, todas en paralelo, cada una en su worktree:

```bash
cd <repo>
git worktree add ../<repo>-wt-1 wave1-executor-1
cd ../<repo>-wt-1
# abre tu agente, cambia al rol EXECUTOR y escribe:
```

```
Soy el executor 1 de la ola 1. Lee mi brief y ejecuta.
```

El executor lee su brief, implementa, corre su verify, commitea y pushea
SOLO a su rama. Nunca toca archivos que no posee. Nunca toca main.

---

## 5. FASE 3 — Integrar (rol INTEGRATOR)

Instancia nueva en el repo principal:

```
Mergea la ola 1 siguiendo el plan de integración.
```

El integrator: lee el plan, mergea las ramas en orden (`--no-ff`), corre
build/tests, pushea main. Ante un conflicto: PARA y reporta (nunca resuelve
con criterio propio). Después: `git worktree remove` de los worktrees usados.

---

## 6. FASE 4 — Auditar (rol AUDITOR)

Instancia NUEVA (nunca la del planner), modelo fuerte:

```
Audita la ola 1 sobre el árbol integrado.
```

El auditor corre `.workflow/audit-checklist.md` completo con EVIDENCIA
(cada check es un comando y su salida; "lo probé" sin comando = fallo) y
escribe el veredicto en `.workflow/audits/wave1.md`:
- **APPROVED** → siguiente ola
- **EXCEPTIONS** → decides tú
- **REJECTED** → fixes (briefs de fix) → re-auditar. Nunca avanzas así.

---

## 7. FASE 5 — Release (gate de seguridad)

Antes de distribuir CUALQUIER cosa:

```
Security audit this codebase. Output to <dir>. Usa el skill security-audit.
```

El skill de Cloudflare hace 6 fases solo: recon → hunt paralelo → validación
adversarial → reporte → salida estructurada → verificación independiente.
Criterio: 0 CRITICAL/HIGH o excepciones documentadas con dueño y fecha en
`.workflow/plan.md`.

---

## 8. Cómo empezar cada rol (cheat sheet)

| Rol | Dónde abres | Qué escribes |
|-----|-------------|--------------|
| Planner | repo principal | la idea del proyecto |
| Executor | su worktree | "Soy el executor K de la ola N. Lee mi brief y ejecuta." |
| Integrator | repo principal | "Mergea la ola N siguiendo el plan de integración." |
| Auditor | repo principal (sesión nueva) | "Audita la ola N sobre el árbol integrado." |
| Security | repo principal | "Security audit this codebase. Output a <dir>." |

Si tu agente soporta agentes configurables (Tab), los roles vienen con
prompt y modelo cargados; si no, copia los prompts de la sección 3-7 como
primer mensaje.

---

## 9. Skills activables

| Skill | Trigger (lo que pides) | Qué hace |
|-------|------------------------|----------|
| `security-audit` | "security audit this codebase", "find vulnerabilities", "pen-test" | Auditoría de seguridad completa de 6 fases (requerida en release) |
| `ponytail` | "ponytail", "be lazy", "yagni", "do less" | Refuerza el modo lazy senior (ligero/medio/ultra) |
| `ponytail-review` | "review for over-engineering", "what can we delete", "simplify" | Revisa un diff cazando sobre-ingeniería: `L<linea>: <tag> <qué cortar>. <reemplazo>.` |
| `ponytail-audit` | "audit this codebase", "find bloat", "audit for over-engineering" | Lo mismo pero repo completo, ranked por corte mayor |
| `ponytail-debt` | "ponytail debt", "list the shortcuts", "debt ledger" | Recolecta todos los comentarios `ponytail:` en un ledger |
| `ponytail-gain` | "ponytail gain", "what does ponytail save" | Scoreboard del impacto medido de ponytail |
| `ponytail-help` | "ponytail help" | Tarjeta de referencia rápida |

Nada que instalar: las skills se cargan solas al pedir el trigger.

---

## 10. Reglas de oro

- El plan vive en `.workflow/plan.md`, commiteado. Nunca solo en el chat.
- Un rol por sesión. El auditor SIEMPRE en sesión nueva.
- Propiedad de archivos disjunta por ola (nadie toca archivos ajenos).
- Solo se audita el árbol integrado (main tras el merge), nunca ramas sueltas.
- Evidencia sobre narración: comando + salida, o no existe.
- Nada se distribuye sin pasar el gate de security-audit.
- Commits conventional, cortos, una línea; executors solo a su rama.
