# Brief: Wave <N> · Executor <K>

> Copy this template per executor. The planner fills every section. The
> executor never touches a file it doesn't own, even "obviously". Deviations
> go back to the planner via the decision log in `.workflow/plan.md`.

## Task

<What to do, one paragraph. Unambiguous outcome. The ponytail ladder applies:
if this can be one line, it is one line.>

## Definition of done

- <verifiable bullets>
- The verify command below passes.

## Files you own

- <exact paths or globs — the ONLY files you may create or edit>

## Files forbidden

- <exact paths or globs — never touch, even if you think they need fixing;
  report it to the planner instead>

## Read first

- <key files to understand before editing — pointers that save re-exploration>

## Verify command

```bash
<the one command that proves this task works; run it before every commit>
```

## Commit

- MANDATORY: conventional commits, short summary, imperative, one line
  (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `perf:`,
  `style:`, `build:`, `ci:`, `revert:`, optional `(scope)`). Under ~72 chars.
  No AI attribution, no trailers.
- One logical change per commit. One commit per task.
- Commit ONLY your owned files.

## Report back

- <what to report: files changed, verify output, deviations, open questions>
