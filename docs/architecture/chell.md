# Chell Transcript Concept

Chell means Chat + Shell.

For LeoTerm this does not mean artificial intelligence.

Chell is a visual and structural transcript model for shell interaction.
Its purpose is to make command execution readable as a dialogue between the user and the computer.

## Problem

Classic terminal output becomes an undifferentiated stream:

- user input
- command output
- errors
- warnings
- prompts
- previous commands
- new commands

After long builds this becomes difficult to read, search, copy, and understand.

## Goal

Chell turns command execution into identifiable transcript blocks.

Each command action creates one block.

A block contains:

- stable block ID for the current session
- timestamp
- action title
- working directory
- command line
- output
- exit code
- duration
- line count
- collapsed state

## Example Expanded Block

    ▾ #0007  2026-05-05 22:41:13  Build

    cwd:
    /Users/admin/Desktop/Projekte/LeooRexx

    command:
    /usr/bin/xcodebuild -project LeooRexx.xcodeproj

    output:
    ...

    result:
    Exit code: 0
    Duration: 08:14
    Lines: 2319

## Example Collapsed Block

    ▸ #0007  2026-05-05 22:41:13  Build  Exit 0 · 08:14 · 2319 lines

## Collapsed State

Collapsed state is part of the transcript block model, not just a temporary view effect.

If a user collapses a block, that block must remain collapsed during the current LeoTerm session.

This means:

- new output must not automatically expand older collapsed blocks
- search or scrolling must not destroy collapsed state
- later commands must not reset collapsed state
- rebuilding the transcript view must preserve collapsed state from the block model

V1 only needs to remember collapsed state during the current application session.

Persistence across application restarts is explicitly out of scope for the first implementation.

## Leopard UI Translation

The preferred Leopard-native visual model is not modern chat bubbles.

The preferred model is:

- transcript blocks
- disclosure triangles
- calm Cocoa layout
- monospaced command/output text
- system font for block headers and UI chrome

A future implementation should prefer a native Cocoa structure such as NSOutlineView or a block-based NSScrollView over a custom modern accordion widget.

## Design Boundary

Chell is not:

- a chatbot
- an AI shell
- a PowerShell clone
- a terminal emulator feature for its own sake

Chell is:

- readable command history
- structured build/output transcript
- visual separation of input, output, and result
- a foundation for folding, copying, searching, and navigating command blocks

