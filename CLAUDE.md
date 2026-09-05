# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Snoopy is a personal app built **spec-first**: `spec/` describes intended
behavior, code is the compiled output of that spec, and the two are kept in
sync through two custom skills rather than ad-hoc coding requests. As of now
the repo contains only the spec-first scaffolding — no application code,
build system, or tests exist yet. `spec/000-overview.md` is still a draft
template with no domains defined and no tech stack chosen.

## The spec-first workflow

This is the core thing to understand before doing anything else in this repo:

- **`spec/`** holds living documents describing what the app *currently*
  should do — present-tense intended behavior, not a changelog or backlog.
  When intent changes, the relevant section is edited in place; git history
  is the changelog.
- **Code + tests** are the compiled output. Every acceptance criterion in a
  spec file should correspond to a real, passing test. A feature isn't done
  if it lacks one, regardless of what the code appears to do.

The loop: write/revise a spec file (`/spec-new`) → reconcile code with it
(`/spec-sync`) → review + commit → repeat.

### `/spec-new <domain>`
Planning only, never touches code. Interviews the user section-by-section
(Purpose, Behavior, Acceptance criteria, Non-goals, Open questions) to write
or revise `spec/<domain>.md`, following the shape in `spec/_template.md`.
Pushes for testable specifics ("if the import file is malformed, show an
error and leave existing data untouched", not "handle errors gracefully").
Genuinely undecided points go into that file's **Open questions** section
instead of being guessed at. Updates the domain list in
`spec/000-overview.md` when adding a new domain.

### `/spec-sync [domain] [--check]`
The "compile" step. Reads `spec/` (optionally scoped to one file) and
reconciles code with it in both directions:
- **Spec → missing code**: implements behavior the spec describes but the
  code doesn't do yet, and writes a test for every acceptance criterion.
- **Code → missing spec**: code that does something no spec file documents
  is flagged and asked about — never silently absorbed as correct or quietly
  removed, unless trivially obvious (e.g. a typo fix).
- **Open questions**: unresolved items block only the part of the spec they
  affect; everything else still gets implemented, and the blockers are
  surfaced directly rather than guessed at.

`--check` (aliases `--report-only`, `--audit`) reports drift without
changing any files — use it after manual code edits, or as a preview before
a full sync.

## Ground rules for working in this repo

- Don't make one-off code changes for anything that represents lasting
  intended behavior — update the relevant `spec/*.md` file first, then run
  `/spec-sync`. One-off asks are fine only for genuinely throwaway things
  (a debugging script, a one-time data migration) that don't belong in
  `spec/` at all.
- Spec files describe *behavior*, not implementation — use engineering
  judgment on code structure, libraries, naming, etc. unless
  `spec/000-overview.md` states a real constraint (tech stack, platform,
  things off the table).
- If code and spec disagree and it's unclear which is right, run
  `/spec-sync --check` rather than assuming.
- Spec and code changes for the same feature should generally land in the
  same commit.

## Current structure

```
spec/
  000-overview.md   project-level context: what the app is, constraints,
                    the list of domains/features it's broken into
  _template.md      shape every other spec file follows
  <domain>.md       one file per feature/domain area (none yet)
.claude/skills/
  spec-new/         scaffolds or revises a spec file, via an interview
  spec-sync/        the "compile" step — code/tests to match spec
```

No source directories, package manifest, or test runner exist yet — the
tech stack and constraints are still to be decided in
`spec/000-overview.md`. Don't assume a stack (the `.gitignore` is a generic
Xcode/Swift template and should not be read as a firm decision) — check
`spec/000-overview.md` first, and if it's still blank, that's a sign the
next step is filling it in (via `/spec-new` or by hand), not writing code.
