# Nexus Tech Learning App v1.2.2

## Learning features

- Persist lesson completion and resume position locally with SharedPreferences.
- Show Continue Learning on the Home dashboard.
- Show lesson completion state and course progress percentage.
- Save courses and articles to a local library.
- Add saved course/article counts to Profile.
- Add estimated article reading time.
- Add previous/next lesson navigation in the video player.
- Mark a lesson complete when its YouTube playback ends.
- Keep offline-download behavior clearly labelled until device file storage is configured.

## Verification

- `flutter analyze` — passed with no issues.
- `flutter test` — all tests passed.
- Android, Windows, and Web release builds are produced by the tag-based GitHub Actions release workflow.
