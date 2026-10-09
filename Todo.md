# Nexus Tech Learning — UI/UX & Release Todo

## Completed in this update

- [x] Refresh course browsing screen with responsive cards, search, category filters, loading and empty states
- [x] Refresh blog browsing screen with reading-first cards, category filters and like actions
- [x] Refresh course detail with clear course summary, lesson states, free/premium access and CTA
- [x] Refresh blog detail with reading layout, metadata, like action and share affordance
- [x] Refresh premium activation screen with benefit comparison and active status
- [x] Refresh edit profile, activation key and about pages for light/dark surfaces
- [x] Improve global Material 3 light/dark theme tokens and component consistency
- [x] Audit Blog detail and Activation key pages for dark-mode text visibility
- [x] Replace hardcoded light surfaces in refreshed secondary pages with ColorScheme surfaces
- [x] Add separate Android APK workflow
- [x] Add separate Flutter Web workflow
- [x] Add separate Windows EXE workflow

## Next product improvements

- [ ] Persist lesson watch progress and show Continue Learning on Home
- [ ] Add completed lesson state and course progress percentage
- [ ] Add saved/bookmarked courses and articles
- [ ] Add global search results for courses, lessons and articles
- [ ] Add reading progress and estimated reading time to articles
- [ ] Add next/previous lesson navigation in the video player
- [ ] Add offline lesson download state and offline library
- [ ] Add streaks, daily learning goals and achievement badges
- [ ] Add responsive tablet/desktop two-column course detail layout
- [ ] Add accessibility audit for text contrast, semantics and text scaling

## Release checklist

- [ ] Add Android signing secrets before store distribution
- [ ] Add Windows code-signing certificate before public EXE distribution
- [ ] Configure Firebase production rules and release configuration
- [ ] Verify web hosting environment variables and Firebase authorized domains
- [ ] Run `flutter analyze`, `flutter test`, `flutter build web --release`
- [ ] Validate APK on a physical Android device
- [ ] Validate Windows EXE on a clean Windows machine
