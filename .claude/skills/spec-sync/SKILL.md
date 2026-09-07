---
name: spec-sync
description: Reconcile the codebase with the current state of spec/. Implements what the spec describes but the code doesn't do yet, writes/updates tests from acceptance criteria, and flags any drift instead of silently resolving it. Pass --check to only report drift without changing code.
---

# spec-sync

This is the "compile" step: it turns `spec/*.md` into working code and tests.
It also runs in the other direction — surfacing places where the code already
does something the spec doesn't mention, so drift never goes unnoticed.

## Arguments

`args` may contain:
- a domain name / filename fragment to scope the sync to one `spec/*.md` file
  (default: all spec files)
- `--check` (or `--report-only`, `--audit`) — diff and report only, make no
  code or test changes. Use this after manual code edits to see whether the
  spec still describes reality, or before a full sync to preview scope.

## Steps

1. **Load context.** Read `spec/000-overview.md` for project-wide constraints,
   then the target spec file(s). If none exist yet, tell the user to run
   `/spec-new` first.

2. **Survey current code** relevant to each spec file's domain (structure,
   existing tests, related modules). Use Explore/Grep as needed rather than
   assuming from the spec alone.

3. **Diff spec against code**, per spec file, in both directions:
   - **Spec → missing code**: behavior or acceptance criteria described but
     not implemented (or not correctly implemented). This is the bulk of the
     work: implement it, and turn each acceptance criterion into a real test
     (unit/integration, whatever fits the stack). A criterion without a
     corresponding test is not done yet.
   - **Code → missing spec**: code does something no spec file documents, or
     contradicts what one says. Do **not** silently fix this by guessing.
     List it plainly and ask the user whether the spec should be updated to
     document it, or whether the code is unintended drift to remove — unless
     it's trivially obvious (e.g. a typo fix), in which case say what you did.
   - **Open questions**: if a spec file has unresolved items in its "Open
     questions" section that block implementing part of it, skip that part,
     implement everything else, and ask about the blockers directly rather
     than guessing and moving on.

4. **If `--check` was passed, stop here** and give the user a structured
   report: implemented-and-matching, missing-in-code, missing-in-spec,
   blocked-on-open-questions. No files change.

5. **Otherwise, implement.** Make the code and test changes identified above.
   Follow existing project conventions (see CLAUDE.md / existing code) for
   style, structure, and tooling — the spec describes *behavior*, not
   implementation details, so use your judgment on the "how."

6. **Run the test suite** (including the tests you just added) and fix
   failures before reporting back.

7. **Report a summary**: what got implemented, what tests were added, what
   was flagged as spec/code drift and needs a decision, and what's still
   blocked on open questions. Don't ask the user to re-read the whole diff —
   surface the decisions that actually need them.

## What this skill is not

It doesn't invent requirements. If the spec is silent on something, that's a
gap to flag or ask about, not a blank check to design freely — bias toward
asking when a choice would meaningfully shape behavior, and use ordinary
engineering judgment for the rest (naming, file layout, error message wording).
