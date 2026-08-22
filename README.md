# Nexus Tech Learning App

Nexus Tech Learning is a cross-platform Flutter application for video courses, technical articles, and premium learning content. The product combines a Material 3 interface with Firebase authentication, Firestore-backed user and engagement data, and an optional Google Sheets content-management workflow.

## Product capabilities

| Capability | Current behavior |
| --- | --- |
| Learning content | Searchable course and article lists with responsive YouTube playback. |
| Premium access | The first ten lessons in each course are free; later lessons require an activation key. Key claims atomically update both the key and the user profile. |
| Engagement | Blog view and like counters use Firestore transactions. Like state is loaded in one user-scoped query for the article list. |
| Account | Firebase sign-in, registration, profile editing, reactive premium status, and activation-key removal. |
| Offline UX | A single connectivity gate, debounced status checks, cached content, and a themed retry screen. |
| Appearance | Light and dark Material 3 themes, with a discoverable dark-mode setting in the profile menu. |
| Administration | Blog and course CRUD through Apps Script plus Firestore activation-key management, with authorization checked before admin data loads. |
| Platforms | Android, iOS, Web, macOS, Windows, and Linux. Platform-visible names use Nexus Tech Learning branding. |

## Technology

| Area | Technology |
| --- | --- |
| UI | Flutter, Dart, Material 3 |
| State and navigation | GetX |
| Authentication | Firebase Auth |
| Database and engagement | Cloud Firestore |
| Content source | Google Apps Script / Google Sheets |
| Video playback | `youtube_player_flutter` |
| Web deployment | Vercel or Firebase Hosting |

## Local development

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install), then run the project checks from the repository root:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release
```

For local development, use `flutter run` for a connected device or `flutter run -d chrome` for the web target. The web output is generated in `build/web/`. The optional `package.json` helper exposes `npm run build` and `npm run deploy` for environments that also have the Vercel CLI installed.

## Configuration and security

Firebase platform options are stored in `lib/firebase_options.dart`. Public content endpoints are configured in `lib/core/constants.dart`. Set up Firebase Authentication and Firestore security rules before using production data. Do not commit service-account credentials, private signing keys, or other administrative secrets.

The optional Apps Script backend supports public grouped content reads and admin-protected raw-course and mutation operations. Configure the `SHEET_ID` Script Property in Apps Script before deployment. The compatibility admin-email parameter is an application-level gate and must be backed by restrictive Apps Script deployment permissions and Firestore rules; it is not a replacement for server-side authorization.

## Architecture and performance

Application entry, theming, and route configuration live in `lib/main.dart`. Authentication, premium, theme, and connectivity state live in `lib/logic/controllers/`. Firebase, Sheets, and engagement integrations live in `lib/data/services/`, while screens and reusable widgets live under `lib/ui/`.

Content requests use a two-minute in-memory cache, shared in-flight futures, twelve-second request timeouts, and explicit invalidation after successful admin mutations. Course and blog content load concurrently. Blog stats use a single document read per item during hydration, and the article list loads a signed-in user’s liked IDs with one Firestore query. Invalid YouTube links and failed images receive user-facing fallback states instead of crashing the screen.

## Documentation

| Guide | Purpose |
| --- | --- |
| [`sheets_setup/README.md`](sheets_setup/README.md) | Spreadsheet structure, Apps Script deployment, Firestore collections, API contract, and verification. |
| [`sheets_setup/ADMIN_DASHBOARD_GUIDE.md`](sheets_setup/ADMIN_DASHBOARD_GUIDE.md) | Admin access, CRUD operations, premium-key behavior, troubleshooting, and QA checklist. |
| [`CHANGELOG.md`](CHANGELOG.md) | Consolidated release history. |
| [`release-notes-v1.2.0.md`](release-notes-v1.2.0.md) | Detailed notes for the current quality release. |
| [`release-notes-v1.1.0.md`](release-notes-v1.1.0.md) | Previous stability and UX overhaul. |

The About screen now includes readable in-app Privacy Policy, Terms of Service, and License Agreement summaries. These summaries are product notices, not a substitute for legal review.

## Project status

This repository is private and is not published to pub.dev. Review the intended license, Firebase rules, Apps Script deployment permissions, and platform signing configuration before distributing the application publicly.
