# Chell UI Rationale

Chell is the visual transcript layer for LeoTerm command execution.

It does not introduce a custom terminal theme.
It does not try to imitate a modern chat application.
It does not define a separate TUI style guide.

Chell translates shell interaction into a native Cocoa-style command transcript.

## Core Idea

A classic terminal is a continuous text stream.

Chell turns command execution into readable transcript blocks:

- command block ID
- timestamp
- action title
- working directory
- command line
- output
- result
- duration
- line count
- collapsed state

The goal is not decoration.

The goal is readability, orientation, copying, searching, folding, and navigation.

## Cupertino 2009 Interpretation

LeoTerm should feel like something Apple could plausibly have shipped for Leopard developers in 2009.

For Chell this means:

- use native Cocoa controls and patterns
- use disclosure-style progressive detail instead of modern accordion widgets
- keep the normal app chrome in the system font
- keep command/output text in a fixed-width font
- respect the user's existing Terminal.app preferences
- avoid a separate LeoTerm theme system in V1

## Terminal.app Preferences

LeoTerm uses Terminal.app as the source of truth for console styling.

The console area should inherit:

- font
- text color
- background color

LeoTerm must only read Terminal.app preferences.
It must never write or modify them.

If Terminal.app preferences cannot be read, LeoTerm falls back to Leopard-appropriate defaults such as Monaco 11 or the system fixed-pitch font.

## Chell Visual Hierarchy

Chell metadata should be visually distinct but subtle.

The base style comes from Terminal.app.

Chell may derive visual hierarchy from that style:

- command output: normal Terminal.app text color
- block header: same color, stronger weight where possible
- metadata: same color, slightly muted
- separator: same color, strongly muted

Chell should not introduce arbitrary bright colors.

Color exists only to support structure.

## Folding Model

Long outputs must eventually be foldable.

The preferred Leopard-native direction is a disclosure-based transcript view.

A future implementation should prefer native Cocoa structures such as:

- NSOutlineView
- disclosure triangles
- block-based model objects

over custom modern accordion controls.

## Collapsed State

Collapsed state belongs to the transcript block model.

It is not merely a temporary drawing effect.

For the first implementation, collapsed state only needs to survive during the current LeoTerm session.

Persistence across application restarts is out of scope for V1.

## Current Implementation Status

The current V0 implementation uses a monospaced NSTextView with Chell-style transcript sections.

This is an intentional intermediate step.

It provides:

- block IDs
- timestamps
- command metadata
- output separation
- result summaries
- Terminal.app-derived styling

The later target is a real block model and foldable transcript view.

