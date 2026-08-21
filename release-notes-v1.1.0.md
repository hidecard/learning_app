## Nexus Tech Learning App v1.1.0

This release delivers a stability, performance, and user-experience overhaul for the Nexus Tech Learning App.

### Highlights

- Fixed the stale generated widget test and restored a meaningful automated test suite.
- Fixed startup authentication races, duplicate controller initialization, null assertions, and unsafe profile writes.
- Added a reliable light/dark Material 3 theme with accessible navigation components.
- Reworked offline handling with a single connectivity service, less aggressive polling, and a themed recovery screen.
- Added short-lived content caching and in-flight request de-duplication for Google Sheets content.
- Parallelized course/blog loading and reduced blog analytics hydration from two Firestore reads per blog to one stats read.
- Made activation-key claims atomic and refreshed premium state immediately after redemption.
- Hardened model parsing for spreadsheet numeric values, YouTube URLs, durations, and missing fields.
- Made video-player lifecycle cleanup safe for invalid links and removed high-frequency debug rebuilds.
- Improved search/filter state synchronization and replaced the custom gesture-only tab bar with Material NavigationBar.
- Removed stale hard-coded profile metrics, dead helpers, release print logging, and deprecated color APIs.
- Updated README documentation, package metadata, endpoint constant naming, and release version to `1.1.0+2`.

### Verification

- `dart analyze` — no issues found.
- `flutter test` — all tests passed.
- `flutter build web --release` — build completed successfully.
