# Application Look and Feel Guidelines

> Status: draft | active | stable
> This document describes the *current intended behavior* of this area of the app.
> Edit it in place as your understanding changes — do not append dated entries or
> "v2 update" sections. Git history is the changelog; this file is always the
> present truth.

## Purpose

The purpose of these look and feel requirements is to define how general look and 
feel must be handled across iPhone, iPad and Mac OS.

## Behavior

Look and feel, as well as usability, must be generally consistent across all supported
devices (iPhone, iPad and Mac OS).  While minor differences are unavoidable simply due
to screen sizes and input tools, they should be minimal and how to handle they are 
handled documented here.

When the user launches the application, a brief tranition view for the application title
should be presented as a quick fade in and fade out.  The application title view should
have a title towards the top, a logo for the Snoopy AI application in the middle, and at
the bottom - "Copyright 2026 Lee Roland.  All rights reserved.".

## Acceptance criteria

Testable statements. Each one should be checkable by a human or a test, phrased
as Given/When/Then or a plain assertion.

The look and feel should generally be similar between Mac, iPhone and iPad.

- [ ] Given the application running, when on iPad, then full real estate of the screen must be used in a way that has a native look and feel.
- [ ] Given the application running, when on iPhone, then the layout should be efficient in how the real estate is used with smaller fonts.
- [ ] Given the application running, when on iPhone or iPad, then both landscape and portrait modes must be supported.

## Non-goals

- This application is not compatible with non-Apple devices or operating systems, such as Windows, Android or Linux.

Things this area deliberately does *not* do. Prevents scope creep and stops
`/spec-sync` from "fixing" something you intentionally left out.

## Open questions

Things you haven't decided yet. `/spec-sync` will surface these rather than
guessing.
