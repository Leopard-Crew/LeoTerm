# Microsoft Terminal Cartography

Microsoft Terminal is used as reference material only.

Adopt as principles:
- Actions with stable identifiers
- Profiles
- Command/search palette concepts
- Tabs and panes as organizational tools
- Marked output regions
- Sensible scroll behavior during active output
- Context-aware drag and drop

Reject as implementation:
- Windows console architecture
- ConPTY dependency
- XAML / WinUI
- JSON-first configuration where Leopard property lists fit better
- Store/AppX/MSIX assumptions
- Windows-specific shell integration
- Cross-platform design as primary goal

LeoTerm translates useful ideas into native Leopard mechanisms.
