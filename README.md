# snoopy

Personal app, built spec-first with Claude Code instead of by incremental
"vibe coding" instructions.

## How this works

There are two artifacts that matter, and one loop between them:

- **`spec/`** — living documents describing what the app *currently* should
  do. Not a changelog, not a pile of feature requests: each file always
  describes present-tense intended behavior. When you change your mind, you
  edit the relevant section in place. Git history is the changelog, so
  nothing is lost by editing rather than appending.
- **Code + tests** — the "compiled" output. Every acceptance criterion in a
  spec file should correspond to a real test. If it doesn't, the feature
  isn't done, no matter what the code appears to do.

The loop:

```
  write/revise a spec file  →  /spec-sync  →  review + commit  →  repeat
        (/spec-new)             ("compile")
```

You almost never hand Claude a one-off instruction like "add a dark mode
toggle." Instead you update `spec/ui.md` (or wherever it belongs) to describe
dark mode as part of the app's intended behavior, then run `/spec-sync` to
bring the code up to date with it.

## Folder layout

```
spec/
  000-overview.md   project-level context: what the app is, constraints,
                    the list of domains/features it's broken into
  _template.md      shape every other spec file follows
  <domain>.md       one file per feature/domain area, e.g. auth.md,
                    recipe-import.md, sync-engine.md
.claude/skills/
  spec-new/         scaffolds or revises a spec file, via an interview
  spec-sync/        the "compile" step — code/tests to match spec
```

## The two commands

### `/spec-new <domain>`

Planning only — never touches code. Interviews you about a feature/domain
area and writes (or revises) `spec/<domain>.md`. Use it:

- When starting a new feature area for the first time.
- When your intent for an existing area has changed and the spec needs to
  catch up *before* the code does.

It pushes for specifics — "handle errors gracefully" isn't good enough,
"if the import file is malformed, show an error and leave existing data
untouched" is. Anything you're genuinely undecided about goes into that
file's **Open questions** section instead of being guessed at.

### `/spec-sync [domain] [--check]`

The compile step. Reads `spec/` (or one file, if you scope it) and
reconciles code with it:

- Implements anything the spec describes that the code doesn't do yet, and
  writes a test for every acceptance criterion.
- Flags anything the *code* does that no spec file mentions, instead of
  silently absorbing it — you decide whether that's undocumented-but-correct
  (update the spec) or drift (remove it).
- Skips and asks about anything blocked on an unresolved "Open question"
  rather than guessing.

Run it with `--check` to get a report only (nothing changes) — useful after
you've made a manual code tweak and want to know whether the spec still
describes reality, or as a preview before a full sync.

## Starting out

1. Fill in `spec/000-overview.md` (what the app is, any hard constraints) —
   run `/spec-new` to do this as an interview, or edit it directly.
2. Run `/spec-new <first-feature>` for the first thing you want to build.
3. Run `/spec-sync` to build it.
4. Review the diff, commit. Spec and code changes for the same feature
   should generally land in the same commit — that keeps `git log` readable
   as the project's real history, which is the only "point in time" record
   you need.
5. Next feature or next change of mind: back to step 2 or a revision via
   `/spec-new`, then `/spec-sync` again.

## Ground rules

- Don't ask Claude for incremental one-off code changes outside this loop
  for anything that represents lasting intended behavior — update the spec
  instead, even if it feels slower. One-off asks are fine for genuinely
  throwaway things (a debugging script, a one-time data migration) that
  don't belong in `spec/` at all.
- If code and spec disagree and you're not sure which is right, that's
  exactly what `/spec-sync --check` is for — run it before making assumptions.
- Spec files describe *behavior*, not implementation. Let Claude use
  judgment on code structure, libraries, naming, etc. unless you have a real
  constraint — put real constraints in `spec/000-overview.md`.
