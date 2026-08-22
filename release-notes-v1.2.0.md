# Nexus Tech Learning App v1.2.0

Version 1.2.0 is a second-pass quality release focused on closing remaining lifecycle, data-integrity, admin, platform-branding, and documentation gaps.

## Changes

| Area | Update |
| --- | --- |
| Authentication | Removed duplicate startup checks and cancel the Firebase auth subscription when the controller closes. |
| Premium activation | Activation now claims the Firestore key and updates the user profile inside one transaction, preventing a key from being consumed without granting premium access. |
| Admin dashboard | Admin authorization completes before admin data loads; keys, blogs, and courses load concurrently; failures are surfaced with safe messages. |
| Activation keys | Key creation normalizes values, rejects empty or duplicate keys, and uses deterministic documents to reduce duplicate-key races. |
| Engagement | Blog list like state loads with one user-scoped query; like toggles return explicit success; blog detail handles async disposal safely. |
| Content API | Sheets requests share timeouts, validate JSON responses, and invalidate caches only after explicit mutation success. |
| Legacy screens | Removed fabricated age information and scroll-triggered auto-refresh from the legacy home screen; retained manual loading behavior. |
| UX | Added functional in-app Privacy Policy, Terms of Service, and License Agreement summaries plus a discoverable dark-mode setting. |
| Platform branding | Updated browser, PWA, Android, iOS, macOS, Linux, and Windows visible product names to Nexus Tech Learning while preserving Firebase-coupled bundle identifiers. |
| Documentation | Updated the root README, Sheets setup README, admin dashboard guide, package metadata, and Apps Script API documentation. |
| Dependencies | Removed unused Firebase Storage and InAppWebView packages to reduce plugin and build surface. |

## Verification

| Check | Result |
| --- | --- |
| `flutter pub get` | Passed; lockfile refreshed after dependency cleanup. |
| `dart analyze` | No issues found. |
| `flutter test` | All tests passed, including profile parsing, activation-key clearing, content parsing, and validation tests. |
| `flutter build web --release` | Completed successfully. |
| Apps Script syntax check | Passed with Node syntax validation. |
