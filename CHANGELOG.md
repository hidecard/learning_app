# Changelog

All notable changes to Nexus Tech Learning are documented here. Release-specific implementation details remain in the corresponding `release-notes-*.md` file.

## [1.2.0] — Second-pass quality release

The second quality pass closes remaining lifecycle and data-integrity issues. Authentication subscriptions now clean up correctly; premium key claims update the key and profile atomically; admin data is loaded only after authorization; and activation-key creation rejects empty and duplicate values. Blog like-state loading is batched, Sheets mutation responses are validated, and caches are invalidated only after confirmed success.

The release also removes fabricated profile-age information and aggressive scroll-triggered refreshes, adds functional in-app legal summaries and a discoverable dark-mode control, and aligns browser, PWA, Android, iOS, macOS, Linux, and Windows visible names with Nexus Tech Learning. Unused plugin dependencies were removed, and the root, Sheets setup, and admin guides were rewritten.

## [1.1.0] — Stability and UX overhaul

The first quality release added Material 3 theming, accessible navigation, offline recovery, content caching, in-flight request de-duplication, parallel content loading, resilient model parsing, safer video lifecycle handling, transactional engagement updates, and a validated test suite.

[1.2.0]: https://github.com/hidecard/learning_app/releases/tag/v1.2.0
[1.1.0]: https://github.com/hidecard/learning_app/releases/tag/v1.1.0
