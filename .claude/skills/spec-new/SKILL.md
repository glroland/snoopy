---
name: spec-new
description: Create or revise a living spec document for one feature/domain area of this app, through an interview with the user. Planning only — never writes application code.
---

# spec-new

Use this when the user wants to define, flesh out, or revise a feature/domain
area of the app before any code gets written or updated. This is a **planning
skill**: it produces or edits a file under `spec/`, and does not touch
application code or tests. Code changes happen later, via `/spec-sync`.

## Arguments

`args` may name a domain (e.g. `/spec-new auth` or `/spec-new "recipe import"`).
If no domain is given, ask the user which area they want to work on.

## Steps

1. **Resolve the target file.** Slugify the domain name to `spec/<slug>.md`
   (lowercase, hyphens). If it already exists, you're revising it — read it
   first and treat the interview as an update to specific sections, not a
   rewrite from scratch. If it's new, read `spec/_template.md` for the shape
   to fill in and `spec/000-overview.md` for project-level context/constraints
   this feature should stay consistent with.

2. **Interview the user.** Don't just ask "what should this do?" and transcribe
   the answer. Work section by section (Purpose, Behavior, Acceptance criteria,
   Non-goals, Open questions):
   - Ask about the normal path first, then edge cases — but only chase edge
     cases the user actually cares about. Don't pad the doc with hypotheticals.
   - Push for specifics that make Acceptance criteria testable. "Handle errors
     gracefully" is not acceptable; "if the import file is malformed, show an
     error and leave existing data untouched" is.
   - When the user is genuinely undecided, write it into **Open questions**
     rather than inventing an answer. Don't let undecided points block writing
     the rest of the doc.
   - Use AskUserQuestion for concrete either/or decisions; use plain
     conversation for open-ended description.

3. **Write the file** following `spec/_template.md`'s structure. Keep it
   describing *current intended behavior*, not a request or a diff. If this is
   a revision, edit the relevant sections in place — don't append a dated
   "update" block; git history is what preserves the old version.

4. **Update the domain list** in `spec/000-overview.md` if this is a new
   domain that isn't listed there yet.

5. **Stop there.** Tell the user the spec is ready and that `/spec-sync` (all,
   or scoped to this domain) is the next step whenever they want code to catch
   up to it. Do not start implementing.
