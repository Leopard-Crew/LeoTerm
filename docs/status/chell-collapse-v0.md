
# Chell Collapse V0

This document captures the first working Chell transcript collapse milestone.

## Verified State

LeoTerm now supports a first functional transcript block model.

Each command action creates an `LTTranscriptBlock` containing:

- block identifier
- title
- command
- working directory
- start time
- output text
- exit status
- duration
- line count
- collapsed state

## Visible Behavior

LeoTerm currently renders command actions as Chell-style transcript blocks.

Expanded blocks show:

- block ID
- timestamp
- action title
- working directory
- command line
- output
- result summary

Collapsed blocks show:

- block ID
- timestamp
- action title
- exit status
- duration
- line count

## Current Controls

The current V0 implementation provides two temporary controls:

- Collapse Last
- Expand All

These controls are intentionally simple.

They prove that collapsed state belongs to the transcript block model and survives during the current LeoTerm session.

## Important Result

Collapsed state is no longer a temporary drawing effect.

It is stored in the `LTTranscriptBlock` model.

This means later UI implementations can rebuild the transcript view without losing which blocks are collapsed.

## Current Limitation

Collapse is not yet available per individual block.

The current implementation can only:

- collapse the most recent block
- expand all blocks

## Future Direction

The next UI direction is a Leopard-native disclosure-based transcript view.

Preferred future implementation:

- block-oriented transcript view
- per-block collapse and expand
- native Cocoa disclosure behavior
- likely `NSOutlineView` or a block-based `NSScrollView`
- no custom modern accordion widget

## Design Boundary

Chell collapse is not meant to imitate modern chat UIs.

It exists to make long command output manageable, especially long builds such as LeooRexx builds.

The goal is readability, navigation, and control.

