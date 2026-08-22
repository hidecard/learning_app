# Admin Dashboard Guide

The admin dashboard manages blog articles, course lessons, and premium activation keys. It is available from the authenticated Flutter app only when the current Firebase account matches the configured admin email. The dashboard now checks authorization before loading any admin data, loads independent sections in parallel, and reports failed reads or writes instead of silently showing empty results.

## Access and security

The current compatibility configuration uses `ak1500@gmail.com` as the admin email in the Flutter client, Apps Script, and `AdminAuthService`. Configure the Apps Script `ADMIN_EMAIL` Script Property for each deployment and change the Flutter-side value consistently before deploying to another owner.
 Email matching is an application-level gate only; it is not a replacement for Firestore security rules, Apps Script deployment permissions, or a signed server-side token.

The `courses_raw` endpoint is admin-protected. Public users can read only grouped course data and public blog data. Administrative writes include the admin parameter and are validated by the Apps Script request handler. Keep the Apps Script deployment and spreadsheet permissions limited to the project team.

## Dashboard capabilities

| Section | Supported actions | Data source |
| --- | --- | --- |
| Blogs | Create, list, edit, delete, preview image, validate image URL | Google Sheets `blogs` tab |
| Courses | Create, list raw rows, edit, delete, validate YouTube URL | Google Sheets `courses` tab |
| Activation keys | Create, list available/used keys, delete unused records | Firestore `activation_keys` |

The Flutter client refreshes the affected content cache after a successful mutation. This prevents a recently created or edited item from remaining hidden behind the normal two-minute content cache.

## Required Google Sheets structure

| Tab | Headers in row 1 |
| --- | --- |
| `blogs` | `id`, `title`, `content`, `category`, `image_url` |
| `courses` | `course_name`, `video_title`, `youtube_url`, `category` |

Course rows are grouped by `course_name` for learners. The first ten videos in a course are free; videos from index ten onward require the user’s premium status. Use a full YouTube URL in the course form.

## API operations

The shared Apps Script base URL is configured in `lib/core/constants.dart` as `sheetsApiBase`. Public reads use `blogsEndpoint` and `coursesEndpoint`. Admin operations are sent with query parameters for compatibility with the current deployment, although the script also supports JSON `POST` requests.

| Action | Request shape |
| --- | --- |
| Read blogs | `GET BASE_URL?type=blogs` |
| Read grouped courses | `GET BASE_URL?type=courses` |
| Read raw courses | `GET BASE_URL?type=courses_raw&admin=ADMIN_EMAIL` |
| Create blog | `operation=create&type=blogs&admin=...&title=...&content=...&category=...` |
| Update blog | `operation=update&type=blogs&admin=...&id=...` plus changed fields |
| Delete blog | `operation=delete&type=blogs&admin=...&id=...` |
| Create lesson | `operation=create&type=courses&admin=...&course_name=...&video_title=...&youtube_url=...&category=...` |
| Update lesson | `operation=update&type=courses&admin=...&row=...` plus changed fields |
| Delete lesson | `operation=delete&type=courses&admin=...&row=...` |

Mutation responses are JSON objects. A successful response includes `success: true`; failed responses include `success: false` and a safe error message. The Apps Script rejects missing required values, invalid HTTP image URLs, malformed YouTube URLs, invalid row numbers, unknown content types, and unauthorized admin requests.

## Premium activation behavior

Activation keys are claimed through a Firestore transaction that reads the key and profile, marks the key as used, and stores the premium profile fields as one atomic operation. If a second user attempts to claim the same key, the transaction returns a failure and the key remains associated with the first successful claim. The UI refreshes the complete profile after redemption so the premium badge and activation-key state update immediately.

Removing a key clears both `is_premium` and `activation_key` in the profile. The operation is confirmed in the UI and the current reactive profile is updated only after Firestore succeeds.

## Validation and QA

Use the following checklist before releasing an admin change:

| Test | Expected result |
| --- | --- |
| Non-admin opens `/admin` | Access denied and no admin data requests are started. |
| Admin loads the dashboard | Keys, blogs, and courses load concurrently with independent loading states. |
| Blog form has an empty required field | The field shows a specific validation message. |
| Blog form has an invalid image URL | The request is rejected before the write. |
| Course form has an invalid YouTube URL | The request is rejected before the write. |
| Two clients claim one activation key | Exactly one claim succeeds. |
| Network is unavailable | The app shows the offline recovery screen and retry action. |
| Content is mutated successfully | A pull-to-refresh shows the new data immediately. |

Run the repository checks from the project root:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release
```

## Troubleshooting

For `Unauthorized`, verify that the signed-in account and configured admin email match and that the Apps Script request includes the admin parameter. For empty public content, verify the deployment URL, spreadsheet tabs, headers, and Apps Script execution logs. For Firestore permission failures, review Firebase security rules and the authenticated user’s access. For stale content, use pull-to-refresh; the short cache is intentional and can be invalidated after successful admin mutations.
