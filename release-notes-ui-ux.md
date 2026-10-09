# UI/UX overhaul

## What changed

- Reworked the home tab into a focused learning dashboard with a branded hero, search, content stats, featured courses, and fresh articles.
- Reworked the auth screen with consistent Material 3 components, inline validation, password visibility control, keyboard submission, and responsive content width.
- Reworked the profile tab into grouped account/preferences/session sections with clearer plan status and accessible list rows.
- Added a GitHub Actions workflow that runs `flutter analyze`, `flutter test`, then publishes release APK and web build artifacts.

## Verification

Run locally from the repository root:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build web --release
```

The workflow artifact is retained for 14 days per run. Production Android distribution still requires signing credentials and should be added through GitHub Actions secrets before publishing to a store.
