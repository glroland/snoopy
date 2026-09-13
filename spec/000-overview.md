# Overview

> Status: draft
> This is the one spec file that isn't a single feature — it's the project-level
> context every other spec file assumes. Keep it short. Fill it in with `/spec-new`
> or by hand whenever you're ready.

## What this app is

Snoopy is a application that provides an audio interface to customizable AI intelligence.  The goal is to provide a human like way of interacting with one or more configurable AI personalities.  This application is for personal use by me and my family.  

I'm creating this application for these reasons:
 * I am tired of primarily using reading and writing as the vehicle for interacting with AI.  I am also on conference calls a lot and would like a way of interacting with AI outside of/in parallel to that context while my hands are already full.
 * My family has some ideas for passively using AI to listen to the sounds around then and getting feedback.  Their idea would be one of the personalities.

## Constraints

* Core application must be written in Swift.
* Must run natively on iOS and Mac OS under a single, unified code base using SwiftUI Multiplatform as the enabler.
* AI functions (voice to text, LLM invocations, etc) can be written in Swift if natively supported.  If non-Apple components are needed to perform these functions in Swift, then PythonKit should be used to embed a Python interpreter into the application and standard AI components from the Python ecosystem must be used instead.  In this case, Python 3.12 or above must be used.
* Voice-to-text and text-to-voice must run natively in the application with no cloud dependencies.  LLM inferencing must occur over an OpenAI compatible API.
* AI Personas must be completely configurable via a directory structure that is bundled or compiled into the application.
* Require a dedicated microphone for audio input.  Share audio output if the underlying system is able to mix multiple concurrent audiostreams at a time.

## Domains

- Application Look and Feel (010-look-and-feel.md)
- General Design of AI Personnas (020-ai-personna-design.md)
- Configurable Values (030-configurable-values.md)
- Settings Management (040-settings-management.md)
- End User Interaction with AI (100-interact.md)
