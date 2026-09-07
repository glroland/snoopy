# Application Settings Management

> Status: draft | active | stable
> This document describes the *current intended behavior* of this area of the app.
> Edit it in place as your understanding changes — do not append dated entries or
> "v2 update" sections. Git history is the changelog; this file is always the
> present truth.

## Purpose

Configurable values that are User Managable must be surfaced via a dedicated user
experience.  The user must be able to see, change, and save the values in order to 
customize how the application functions for them.

## Behavior

Surfaced as either a dialog, dedicated screen, or similar, configurable values must
have the ability to be viewed, changed, and saved by the end user.  All values must
have suitable defaults.  Users can scroll to see the the configuration groups and 
values available and change as needed.  A "Reset to Defaults" option deletes
all value overrides and resets the values back to their original values.  Changes
to settings are automatically saved.

## Acceptance criteria

Testable statements. Each one should be checkable by a human or a test, phrased
as Given/When/Then or a plain assertion.

- [ ] Given view settings, when in-memory configuration exists, then the configuration key must be shown only if "User Managed" is yes (defined in specifications).
- [ ] Given view settings, when a configuration key is shown, then the current value must be presented in the UI.
- [ ] Given view settings, when in-memory configuration does not exist, then a fatal error should be shown to the user.
- [ ] Given view settings, when the local configuration database exists but a value is corrupted or not compatible with expected parameters, then the default value for that configuration key must be used and warning message in red displayed next to the configuration element.
- [ ] Given view settings, when the user selects "Reset to Defaults", then the local configuration database is deleted and the settings view reloaded with default values.
- [ ] Given view settings, when allowing change of a key of type Device ID String, then the system must list the applicable devices that the user can choose from that are available on the local system.  
- [ ] Given view settings, when the configuration key is Microphone, then the system must show only audio input devices.
- [ ] Given view settings, when the configuration key is Speaker, then the system must show only audio output devices.
- [ ] Given view settings, when the configuration key of type Device ID String, then the system should show a test bar that indicates if audio is actively playing or being heard through the device.
- [ ] Given view settings, when the configuration key of type URL String, then the system should have a test button next to the input text area that will test the URL to ensure it can be successfully connected to via a standard http GET.  If there is a corresponding Key value in the configurable settings, then it should be placed in the "Authorization: Bearear $OPENAI_API_KEY" header string.  The results of the connection should be shown as a dialog.

## Non-goals

Things this area deliberately does *not* do. Prevents scope creep and stops
`/spec-sync` from "fixing" something you intentionally left out.

## Open questions

None
