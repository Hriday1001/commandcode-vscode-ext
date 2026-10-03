# Command Code VS Code Extension — v1 decisions & challenges

Lightweight companion for Command Code (vs. the Cline extension). Goal: view the
current plan as a file, and see the agent's changes as diffs, without the bloat.

## v1 decisions (locked)

- Repo branch `session` is checked out; the agent mutates it.
- `Stop` hook commits per turn onto `session` (turn baseline).
- Primary diff view = **worktree vs HEAD** (native Source Control "Changes" list).
  This is per-turn — it resets on every Stop commit.
- Integration into `main` = `git merge --squash session`.
  Squash is required to keep `main`'s log clean; fast-forward would drag every
  machine Stop-commit into `main`'s history.
- Plan view = open the last entry of `~/.commandcode/plans-index.json` via keybinding.
- No custom SCM/change-tracking in v1 — rely on native VS Code git.

## Known v1 gaps (accept or fix now)

- **Human edits between turns are indistinguishable from the agent's** in the
  worktree-vs-HEAD view. The write-scoped `PreToolUse` safeguard absorbs them
  before the agent's first write, gated by a per-turn counter so it runs exactly
  once per turn and never fragments a multi-write turn.
  - The counter lives on disk (session-scoped) and is reset at turn end by `Stop`.
  - **Reset dependency**: an aborted turn never fires `Stop`, so the counter can
    stay "already fired" and the gate silently stays closed for the next turn.
    The counter needs its own reset/expiry (e.g. keyed on `session_id` + turn) to
    be robust to aborts.
- **Aborted turns**: `Stop` never fires, so the baseline never advances and that
  turn's edits leak into the next turn's diff.
- **Past-turn diffs aren't free**: the Changes list resets each Stop commit;
  revisiting an earlier turn requires the branches Compare view, not the Changes list.

## Deferred challenges (future)

- **main moves mid-session** (teammate push / `git pull`):
  - `--ff-only` fails once branches diverge.
  - Rebase rewrites Stop-commit SHAs, so "the diff of turn 5" loses identity.
  - Shared-file edits conflict at squash time.
  Deferred by choice — v1 targets a single user.
- **Stop-hook operational constraints**:
  - Must never `exit 2` (that forces a turn retry, capped at 3).
  - Default 30s timeout → SIGTERM on large repos; keep the commit fast.
  - Hooks run as isolated processes and cannot share state with each other;
    coordination only via git state on disk.
- **Plan mode suspends all hooks** — irrelevant for a read-only plan file, but
  relevant if code diffs are ever wanted *during* plan mode.
- **`.gitignore` correctness** so per-turn commits don't sweep build artifacts
  into `session`.

