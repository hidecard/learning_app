# Google Sheets and Apps Script Setup

This directory contains the optional Google Sheets content backend for Nexus Tech Learning. The Flutter app reads public course and blog content from a deployed Apps Script web app, while administrative mutations are protected by the configured admin email gate. Firestore remains the source of truth for user profiles, blog engagement, and premium activation keys.

> **Important:** The sample Apps Script currently retains a fallback spreadsheet ID for backward compatibility. For a real deployment, set the `SHEET_ID` script property and remove or replace the fallback before sharing the script with anyone outside the project.

## Spreadsheet structure

Create a spreadsheet with the following tabs and headers. The Apps Script creates a missing tab on demand for public reads, but creating the headers manually is recommended so the data shape is predictable.

| Tab | Required columns | Purpose |
| --- | --- | --- |
| `blogs` | `id`, `title`, `content`, `category`, `image_url` | Public article content. `image_url` may be empty. |
| `courses` | `course_name`, `video_title`, `youtube_url`, `category` | One row per lesson. Rows are grouped by `course_name` for the app. |

The first ten lessons in each course are free. Lessons from index ten onward are presented as premium content by the Flutter client. Use complete YouTube URLs, for example `https://www.youtube.com/watch?v=VIDEO_ID` or `https://youtu.be/VIDEO_ID`.

## Apps Script deployment

Open [Google Apps Script](https://script.google.com), create a project, and replace the default source with [`app_script.js`](./app_script.js). In **Project Settings**, add Script Properties named `SHEET_ID` and `ADMIN_EMAIL`. Set `SHEET_ID` to the spreadsheet ID from the spreadsheet URL and `ADMIN_EMAIL` to the administrator account used by the Flutter client. The source file retains compatibility defaults, but project properties should be used for every real deployment. Deploy the project as a **Web app**, execute it as the owner, and restrict access according to the intended audience.
 The client’s public reads require the deployed URL to be reachable from the device or browser.

After deployment, update `lib/core/constants.dart`:

```dart
const String sheetsApiBase =
    'https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec';
const String blogsEndpoint = '$sheetsApiBase?type=blogs';
const String coursesEndpoint = '$sheetsApiBase?type=courses';
```

The Flutter client applies a two-minute in-memory cache, shares concurrent in-flight requests, times out requests after twelve seconds, and returns cached content during a temporary offline state. A pull-to-refresh action explicitly bypasses the content cache.

## API contract

| Operation | Method | Parameters | Access |
| --- | --- | --- | --- |
| Read blogs | `GET` | `type=blogs` | Public |
| Read grouped courses | `GET` | `type=courses` | Public |
| Read raw course rows | `GET` | `type=courses_raw&admin=...` | Admin |
| Create or update content | `GET` or `POST` | `operation`, `type`, content fields, `admin` | Admin |
| Delete content | `GET` or `POST` | `operation=delete`, `type`, row or ID, `admin` | Admin |

The Apps Script also exposes `doPost` for JSON requests. The current Flutter client uses query parameters for compatibility with the existing deployment. All mutation responses use a JSON object with `success` and, when relevant, `message`, `error`, or `id` fields. Invalid content types, missing required fields, malformed image URLs, and invalid YouTube URLs are rejected with a JSON error response.

## Firestore collections

Firebase Authentication manages sign-in accounts. Firestore stores application data using these collections:

| Collection | Important fields | Notes |
| --- | --- | --- |
| `profiles` | `id`, `email`, `name`, `is_premium`, `activation_key`, `activated_at` | Profile data is merged idempotently. |
| `blogs` | `view_count`, `like_count`, `last_updated` | Engagement counters are transactionally updated. |
| `blog_likes` | `blog_id`, `user_id`, `created_at` | The document ID is `{blogId}_{userId}` to make toggles deterministic. |
| `activation_keys` | `key_code`, `is_used`, `used_by`, `used_at`, `created_at` | Claims are transactionally paired with the user profile update. |

Configure Firestore security rules so clients can only perform the reads and writes intended by the product. The Apps Script admin email parameter is not a substitute for Firebase security rules or a signed server-side admin token; treat it as a compatibility gate and keep the deployment private to the project team. For a production deployment, configure `ADMIN_EMAIL` as a Script Property instead of relying on the compatibility default.

## Verification checklist

Run the following commands from the repository root after changing the endpoint or Apps Script code:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release
```

Verify both public URLs in a browser, confirm that `courses_raw` rejects requests without the admin parameter, create a blog and course row from the admin screen, and confirm that the updated content appears after a pull-to-refresh. Finally, test activation-key redemption with two simultaneous clients to confirm that only one user can claim a key.

## Troubleshooting

If public content is empty, confirm the deployment URL, spreadsheet tab names, and header rows. If admin reads return `Unauthorized`, verify the configured admin email and that the request contains the expected `admin` parameter. If mutations fail, inspect Apps Script execution logs and verify that the Apps Script owner can edit the spreadsheet. If the app shows cached data while online, use pull-to-refresh; the normal two-minute cache is intentional and avoids repeated network calls during navigation.
