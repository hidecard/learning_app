# Learning App

A comprehensive Flutter learning application with web deployment support.

## Features

- 📱 Cross-platform mobile app
- 🌐 Web version with Vercel deployment
- 🔥 Firebase integration
- 🎨 Modern UI with Material Design
- ♿ Accessibility features
- 🎭 Rich animations

## Web Deployment

This app is deployed on Vercel. The web version is automatically built and deployed when changes are pushed to the main branch.

### Build & Deploy Locally

1. Install dependencies:
   ```bash
   flutter pub get
   npm install
   ```

2. Build for web:
   ```bash
   npm run build
   ```

3. Deploy to Vercel:
   ```bash
   npm run deploy
   ```

### Vercel Configuration

- `vercel.json`: Deployment configuration
- `package.json`: Build scripts
- Build output: `build/web/`

## Getting Started

For Flutter development:

1. Install Flutter SDK
2. Run `flutter pub get`
3. Run on device/emulator: `flutter run`
4. Run on web: `flutter run -d chrome`

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
