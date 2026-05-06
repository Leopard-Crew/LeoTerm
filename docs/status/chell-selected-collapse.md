# Chell Selected Collapse

This document captures the first working targeted Chell block collapse milestone.

## Verified State

LeoTerm can now collapse transcript blocks by block identifier.

The current temporary UI provides:

- Block ID field
- Collapse Selected
- Collapse Last
- Expand All

## Behavior

A user can run multiple command actions, such as:

- Smoke Test
- Build
- Clean

Each command creates a numbered Chell transcript block.

The user can then enter a block number and collapse that specific block.

Example:

- enter `1`
- click `Collapse Selected`
- block `#0001` collapses
- other blocks remain unchanged

## Session State

Collapsed state is stored in the `LTTranscriptBlock` model.

This proves that collapsed state survives transcript view rebuilding during the current LeoTerm session.

## Temporary Nature

The Block ID field is not the intended final user interface.

It is a deterministic development control used to prove the underlying model behavior.

The future UI direction remains:

- native Cocoa disclosure behavior
- per-block collapse and expand
- likely `NSOutlineView` or a block-based transcript view
- no custom modern accordion widget

## Design Meaning

This milestone moves Chell from simple text formatting toward a real structured transcript system.

LeoTerm now understands command output as identifiable blocks, not merely appended text.

