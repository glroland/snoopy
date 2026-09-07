# Configurable Values

> Status: draft | active | stable
> This document describes the *current intended behavior* of this area of the app.
> Edit it in place as your understanding changes — do not append dated entries or
> "v2 update" sections. Git history is the changelog; this file is always the
> present truth.

## Purpose

Any property that influences application functionality must be made to be configurable.
This specification defines those configurable settings - their keys, default value,
type, and whether it should be user maintained.

## Behavior

Configurable settings must have hard coded defaults that can be overridden after
installation / deployment.  Once overridden, the new values (whether all possible
values or a subset of configuration keys) must be persisted to storage.  When the
application starts, it must check for the existance of these settings and automatically
load them.

## Configurable Values

| Configuration Key | Type | Default Value | User Managable |
| :--- | :--- | :--- | :--- |
| Microphone | Device ID String | "" | Yes |
| Speaker | Device ID String | "" | Yes |
| OpenAI Base URL | URL String | https://evolvewired.home.glroland.com/v1 | Yes |
| OpenAI API Key | Password String | no_key_needed | Yes |
| OpenAI Timeout (Seconds) | Number | 30 | Yes |

## Acceptance criteria

Testable statements. Each one should be checkable by a human or a test, phrased
as Given/When/Then or a plain assertion.

- [ ] Given the application loading, when no local configuration database exists, then default values must be used.
- [ ] Given the application loading, when local configuration database does exist, then the overriddened values must be loadeed and applied to the in memory values.
- [ ] Given the application loading, when the local configuration database exists but a value is corrupted or not compatible with expected parameters, then the default value for that configuration key must be used and a warning dialog shown that the user must acknowledge as a warning.  The warning message must indicate what value could not be loaded.
- [ ] Given a configuration key, when the key's value is being loading or being updated, then the new value must be validated before modifying the old value.  Illegal values must be surfaced to the user as a warning of some type - i.e. if during load, as a dialog.
- [ ] Given a configuration key of type URL String, when the key's value is being loading or being updated, then the new value must be a valid URI where the prefix is http or https.
- [ ] Given a configuration key of type Password String, when the key's value is being loading or being updated, then the new value must be numbers, letters, and symbols with a maximum length of 5000 characters.
- [ ] Given a configuration key of type Number, when the key's value is being loading or being updated, then the new value must be a positive integer less than 1000.
- [ ] Given a configuration key of type Device ID String, when the key's value is being loading or being updated, then the new value must align with how device IDs are uniquely identified in the underlying operating system.

## Non-goals

Things this area deliberately does *not* do. Prevents scope creep and stops
`/spec-sync` from "fixing" something you intentionally left out.

## Open questions

None
