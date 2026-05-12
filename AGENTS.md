# Memoria Project Instructions

This repository is for Memoria, a private offline-first macOS app for file organization and semantic search.

## Standing Rules
- Always use the `macos-design-guidelines` skill when working on any macOS UI, windowing, navigation, toolbar, menu, or keyboard shortcut behavior.
- Keep the app feeling native to macOS: standard menu bar commands, proper window resizing, sidebar-first navigation, and contextual menus where appropriate.
- Treat the HP visual theme documented in `docs/design/hp-theme.md` as the product's visual reference when designing surfaces, typography, spacing, and emphasis.
- Prefer offline, local-only behavior for AI features and file processing unless the user explicitly asks otherwise.
- Do not duplicate imported files. Store references, metadata, tags, and embeddings only.
- Preserve the path toward future iPhone sync, but keep v1 single-machine and offline.

## Workflow Notes
- Follow brainstorming and planning first for new product or UX ideas before implementing.
- When making code changes, keep them small and focused.
- Avoid introducing unnecessary abstractions that obscure the local-first architecture.
