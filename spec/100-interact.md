# AI Interaction Specification

> Status: draft | active | stable
> This document describes the *current intended behavior* of this area of the app.
> Edit it in place as your understanding changes — do not append dated entries or
> "v2 update" sections. Git history is the changelog; this file is always the
> present truth.

## Purpose

The AI interaction area of the application is the core part of the application where
the user will be spending most of their time and getting most of the value from the
application.  Users will have the option to leverage multiple vehicle of communications 
to interact with AI personna(s), who will then respond back appropriately.

## Behavior

The main view of the application is the listening view.  The listening view should have
a large microphone image in the towards the top of the screen.  When the application is 
not listening the background should be a light color or white.  When the application is listening
it should be darker and have "Listening..." presented somewhere on the screen.  Listening 
is controlled by clicking the microphone. The bottom of the screen is a transcription box
where text from the user as well as knowledge from AI is written.  The user's text must have
a different style than AI's response.

When the application is listening, it must transcribe English to text from the audio device
configured in the settings.


## Acceptance criteria

Testable statements. Each one should be checkable by a human or a test, phrased
as Given/When/Then or a plain assertion.

- [ ] Given the main listening view, when the page is first opened, then listening should be off by default.
- [ ] Given the main listening view, when listening is off, then a clickable microphone must be presented against a light background.
- [ ] Given the main listening view, when listening is on, then a clickable microphone must be presented against a darker background with the word "Listening..." somewhere on the screen.
- [ ] Given the main listening view, when the user accesses Settings, then the Settings management view must be opened.
- [ ] Given the main listening view, when the user speaks into the app while it is listening, then their words must be transcribed by AI and written to the transcription box.
- [ ] Given the main listening view, when the user speaks into the app while it is listening or the AI responds, then the messages written to the transcription box must be in order of newest first.
- [ ] Given the main listening view, when the transcription box is full, then the box must be scrollable.

## Non-goals

Things this area deliberately does *not* do. Prevents scope creep and stops
`/spec-sync` from "fixing" something you intentionally left out.

## Open questions

Things you haven't decided yet. `/spec-sync` will surface these rather than
guessing.
