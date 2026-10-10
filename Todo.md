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
- [x] Persist last lesson and completed lesson state locally
- [x] Add Continue Learning card to the Home dashboard
- [x] Add playlist-aware previous/next lesson navigation in the video player
- [x] Add saved article bookmarks from the Articles tab and Blog detail
- [x] Add saved course bookmarks from the Courses tab
- [x] Add article reading progress indicator with local persistence
- [x] Add estimated reading time to articles
- [x] Add course completion percentage to Course detail
- [x] Add daily learning streak tracking and Home streak banner
- [x] Add separate Android APK workflow
- [x] Add separate Flutter Web workflow
- [x] Add separate Windows EXE workflow

## Next product improvements

- [ ] Add percentage-based lesson watch progress to course cards and detail
- [ ] Add global search results for courses, lessons and articles
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
