# Nexus Tech Learning App

A polished cross-platform Flutter learning application for video courses, technical articles, and premium learning content. The app combines a Material 3 interface with Firebase authentication and Firestore-backed user and engagement data, while Google Sheets provides a lightweight content-management workflow.

## Highlights

- Browse searchable video courses and learning articles.
- Watch YouTube lessons with responsive controls and premium content gating.
- Track blog views and likes with transactional Firestore updates.
- Sign up, sign in, edit a profile, and redeem premium activation keys.
- Use the app across Android, iOS, Web, macOS, Windows, and Linux.
- Switch between light and dark themes with an accessible Material 3 navigation experience.
- Continue seeing cached course and article data during short-lived network interruptions.
- Receive a clear offline recovery screen instead of a nested or broken application shell.
- Use the admin panel for course, blog, and activation-key management.

## Technology

| Area | Technology |
| --- | --- |
| UI | Flutter, Dart, Material 3 |
| State and navigation | GetX |
| Authentication | Firebase Auth |
| Database and engagement | Cloud Firestore |
| Content source | Google Apps Script / Google Sheets |
| Video playback | youtube_player_flutter |
| Deployment | Vercel or Firebase Hosting |

## Local development

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install), then run:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release
```

To run the application locally:

```bash
flutter run
# or for web
flutter run -d chrome
```

The web build output is generated in `build/web/`. The existing `package.json` keeps the Vercel workflow available through `npm run build` and `npm run deploy` when Flutter and Vercel CLI are installed in the environment.

## Configuration

Firebase platform options are stored in `lib/firebase_options.dart`. The content endpoints are defined in `lib/core/constants.dart`. Configure Firebase Authentication, Firestore security rules, and the Google Apps Script endpoint before using production data. Never commit private service-account credentials or administrative secrets.

## Architecture

Application entry and global theme configuration live in `lib/main.dart`. Authentication, premium, theme, and connectivity state are managed in `lib/logic/controllers/`. Firebase, content, and engagement integrations live in `lib/data/services/`, while reusable screens and widgets are organized under `lib/ui/`.

Content requests use a short-lived in-memory cache and shared in-flight requests to avoid duplicate HTTP calls. Blog analytics use one Firestore stats read per item during list hydration, and user activation-key claims are guarded by a Firestore transaction.

## License and project status

This repository is not published to pub.dev. Review the project owner’s intended license and deployment configuration before distributing the application publicly.
