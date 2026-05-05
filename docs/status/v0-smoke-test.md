# LeoTerm V0 Smoke Test

This document captures the first functional LeoTerm Developer Console milestone.

## Verified State

LeoTerm currently:

- starts as a native Cocoa application on Mac OS X 10.5.8 Leopard / PowerPC
- creates its main Developer Console window programmatically
- detects its own project root during development
- displays the default LeoTerm project path in the project pane
- runs project actions through `NSTask`
- sets a deterministic command execution `PATH` for GUI-launched sessions
- supports the following initial actions:
  - Build
  - Clean
  - Smoke Test
  - Reveal

## Smoke Test Result

The Smoke Test action verifies that LeoTerm can execute commands inside its own project directory.

Expected output includes:

- the LeoTerm project path
- `git status --short`
- the last few Git commits

## Finder Integration

The Reveal action opens the LeoTerm project folder in Finder.

## Build Integration

The Build action runs:

```sh
/usr/bin/xcodebuild -project LeoTerm.xcodeproj -configuration Debug
````

The Clean action runs:

```sh
/usr/bin/xcodebuild -project LeoTerm.xcodeproj clean
```

## Important V0 Limitation

Command execution is currently synchronous.

This is acceptable for the first V0 smoke test, but it will block the user interface while a command is running.

The next architectural step is to make command execution asynchronous and stream output into the console view.

## Design Boundary

LeoTerm V0 is still a Developer Console skeleton.

It is intentionally not:

- a full terminal emulator
    
- a PTY host
    
- a ncurses-compatible terminal
    
- a PowerShell clone
    
- a Windows Terminal port  
    