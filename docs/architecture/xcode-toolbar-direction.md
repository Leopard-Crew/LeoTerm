# Xcode-style Toolbar Direction

LeoTerm should visually move closer to Xcode's calm Developer Console layout.

The first functional prototype placed action buttons directly inside the window content area.

This was acceptable for early development, but it should not remain the long-term UI direction.

## Direction

LeoTerm should use a real top-level toolbar for primary developer actions.

The main window should be organized as:

- top toolbar
- project / transcript split view
- window-wide bottom status bar

## Toolbar Layout Concept

The toolbar should roughly follow this structure:

    [ Project ▼ ] [ Actions ▼ ]        [ Build & Go ] [ Tasks ] [ Info ]        [ Search ]

## Toolbar Roles

### Project Popup

Selects the current project or default profile.

For the current V0 implementation this only contains:

- LeoTerm

### Actions Popup

Contains secondary project actions.

Initial actions:

- Smoke Test
- Clean
- Reveal
- Collapse Last
- Expand All

### Build & Go

Primary action.

For the current V0 implementation this runs the existing Build action.

### Tasks

Temporary action placeholder.

For the current V0 implementation this may run Smoke Test until a real task model exists.

### Info

Shows basic project or application status.

### Search

The search field belongs visually in the toolbar.

Search does not need to be functional in the first toolbar implementation.

## Content Area

The content area should become calmer.

It should focus on:

- project list
- Chell transcript stream
- temporary Chell development controls only where still needed

Primary global actions should not remain as content buttons.

## Cupertino 2009 Interpretation

This direction follows the Xcode-like model:

- primary actions in the toolbar
- output in the transcript/log area
- result/status in the window-wide bottom bar
- no overloaded dashboard
- no modern command-center visual noise


