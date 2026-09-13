# AI Personna Design Guide

> Status: draft | active | stable
> This document describes the *current intended behavior* of this area of the app.
> Edit it in place as your understanding changes — do not append dated entries or
> "v2 update" sections. Git history is the changelog; this file is always the
> present truth.

## Purpose

This application supports multiple AI personnas where their behaviors are defined
as configuration.  This specification defines the structure of an AI personna as
well as the Default, which is always provided with the application.

## Behavior

The most fundamental portion of an AI Personna is defined its system prompt.
That prompt defines the nature of the personna and how it should interpret
and respond to user inquiries.

## Acceptance criteria

Testable statements. Each one should be checkable by a human or a test, phrased
as Given/When/Then or a plain assertion.

- [ ] Given the main interaction page, when a user inquiry is received, then an LLM inference should be made.
- [ ] Given the main interaction page, when an LLM inference is made, then the system prompt must be included in the conversation.

## Non-goals

Things this area deliberately does *not* do. Prevents scope creep and stops
`/spec-sync` from "fixing" something you intentionally left out.

## Open questions

Things you haven't decided yet. `/spec-sync` will surface these rather than
guessing.
