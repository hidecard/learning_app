# CodeNest Learning v1.2.4

This release merges the latest `main` UI/UX work and removes gradient-based visual treatment from the active Flutter UI. Home, course detail, video player and course cards now use solid Material surfaces, clear color blocks, outlined boundaries and stronger text hierarchy. The app shell no longer wraps screens in a translucent backdrop.

The learning dashboard now includes a daily one-lesson goal indicator and a first-lesson/ten-lessons achievement badge. Global search and Continue Learning remain available from the merged main branch, while Premium download remains gated and persisted as an offline-library state. Actual video-file caching is intentionally left for a future first-party media endpoint; YouTube URLs are not ripped or copied.

## Verification

- `flutter analyze` — passed with no issues.
- `flutter test` — all 4 tests passed.
- `flutter build web --release` — passed.
- Source scan — no `LinearGradient`, `RadialGradient`, `BackdropFilter`, or `ImageFilter` APIs remain under `lib/`.
