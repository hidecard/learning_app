# Learning App

A comprehensive Flutter learning application with video courses, blogs, and premium features.

## Features

### Core Learning Features
- Video course library with YouTube integration
- Blog articles and tutorials
- Premium content with activation keys
- User authentication and profiles
- Course progress tracking
- Video player with custom controls

### User Experience
- Modern Material Design 3 UI
- Full accessibility support (screen readers, high contrast, large text)
- Smooth animations and transitions
- Responsive design for mobile, tablet, and desktop
- Dark/light theme support
- Offline connectivity handling

### Technical Features
- Cross-platform (iOS, Android, Web)
- Firebase backend integration
- Google Sheets API for content management
- Premium subscription system
- Admin panel for content management
- Real-time data synchronization

## Tech Stack

### Frontend Framework
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language

### State Management
- **GetX** - State management and navigation

### Backend & Database
- **Firebase Auth** - User authentication
- **Firebase Firestore** - Real-time database
- **Google Sheets API** - Content management system

### UI/UX Libraries
- **YouTube Player Flutter** - Video playback
- **Material 3** - Design system
- **Custom animations** - Fade, slide, scale transitions

### Deployment
- **Vercel** - Web hosting
- **Firebase Hosting** - Alternative web deployment
- **App Store/Play Store** - Mobile distribution

### Development Tools
- **Flutter SDK** - Development environment
- **VS Code/Android Studio** - IDE support
- **Git** - Version control

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
