---
name: code-maintenance-refactor
description: >-
  Maintain codebase health, modularize oversized Flutter/Dart files, and
  enforce clean component boundaries without changing behavior. Use when a
  file grows beyond ~300-400 lines, mixes multiple UI sections or business
  concerns, contains duplicated widgets/helpers, or when asked to refactor,
  split, clean up, or maintain files in the project.
---

# Code Maintenance & Refactoring (Flutter / Dart)

Keep the codebase modular, readable, and easy to evolve without breaking
existing public APIs or runtime behavior.

## Size & Complexity Thresholds

| File Type | Soft Target | Refactor Trigger |
|---|---|---|
| View / Screen (`*_view.dart`) | ≤ 250 lines | > 350 lines |
| Feature Card / Section Widget | ≤ 200 lines | > 300 lines |
| Provider / Service | ≤ 250 lines | > 400 lines |
| Model | ≤ 150 lines | > 250 lines |

When editing a file that already exceeds the trigger threshold, evaluate
whether extracting a cohesive sub-widget or helper module makes the change
cleaner and safer.

## Decomposition Strategy

1. **Preserve the Public Entrypoint:** Keep the existing class name, file
   path, and constructor signature of the parent widget (e.g.
   `profile_theme_card.dart`) so callers do not need invasive import updates.
2. **Co-locate Submodules in a Feature Subfolder:**
   - Example: `lib/views/student/profile/profile_theme_card.dart` delegates to
     focused section widgets in `lib/views/student/profile/theme/`:
     - `visual_style_section.dart`
     - `color_palette_section.dart`
     - `glass_effects_section.dart`
     - `theme_mode_section.dart`
     - `progress_bar_style_section.dart`
3. **One Responsibility per File:**
   - Each extracted widget should own one logical UI section or cohesive
     behavior.
   - Keep private helper widgets (`_Chip`, `_Tile`) in the same file as the
     section that uses them unless reused across multiple files (in which case
     promote to `lib/core/widgets/`).
4. **Minimize Rebuild Scope:**
   - Prefer `ref.watch(provider.select(...))` or narrow `ConsumerWidget`
     boundaries when splitting sections so changing one setting does not
     rebuild unrelated subtrees.
5. **Avoid Premature Over-Fragmentation:**
   - Do not split tiny (< 40 line) trivial widgets into separate files unless
     they are shared across features.
   - Avoid barrel files unless a folder has many external consumers.

## Safe Refactoring Checklist

1. Read the full target file before splitting so no state, listener,
   callback, or edge case is lost.
2. Create the new focused files with clear `snake_case` names matching the
   project's existing conventions.
3. Update the orchestrator file to compose the extracted components and remove
   unused imports or dead code.
4. Run `analyze_files` (Dart analyzer) across every created and modified file
   and verify **0 errors and 0 warnings**.
5. Run relevant tests (`flutter test`) when refactoring logic, providers, or
   services.
