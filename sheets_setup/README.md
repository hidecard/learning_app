# Google Sheets & Apps Script Setup

## 1. Create Google Sheet
- New Sheet: tabs 'blogs', 'courses', 'keys' (optional, use Firestore for keys).

### blogs tab headers: id,title,content,category,image_url
```
id,title,content,category,image_url
1,"Intro to Flutter","Flutter basics...",flutter,https://example.com/img.jpg
2,"Dart Tips","Advanced Dart...",dart,
```

### courses tab headers: course_name,video_title,youtube_url,category
```
course_name,video_title,youtube_url,category
Flutter Basic,Lesson 1,https://youtube.com/watch?v=dQw4w9WgXcQ,Programming
Flutter Basic,Lesson 2,https://youtube.com/watch?v=eHzT1VsAidk,Programming
Flutter Basic,Lesson 3,https://youtube.com/watch?v=fJ9rUzIMcZQ,Programming
Flutter Advanced,Lesson 1,https://youtube.com/watch?v=abc123,Programming
Dart Basics,Lesson 1,https://youtube.com/watch?v=def456,Dart
```

**Important:**
- First 10 videos per course are FREE
- Videos 11+ require premium subscription
- Use full YouTube URLs (not just IDs)
- Videos are automatically grouped by course_name

## 2. Apps Script (Code.gs)
Paste into https://script.google.com > New project > replace code:

```javascript
function doGet(e) {
  const ss = SpreadsheetApp.openById('YOUR_SHEET_ID');
  const type = e?.parameter?.type || 'blogs';  // Fix: null-safe
  let data = [];

  if (type === 'blogs') {
    const sheet = ss.getSheetByName('blogs') || ss.insertSheet('blogs');  // Auto-create if missing
    data = sheet.getDataRange().getValues().slice(1).map(row => ({
      id: row[0],
      title: row[1],
      content: row[2],
      category: row[3],
      image_url: row[4] || ''
    }));
  } else if (type === 'courses') {
    const sheet = ss.getSheetByName('courses') || ss.insertSheet('courses');
    const rows = sheet.getDataRange().getValues().slice(1);
    
    // Group videos by course name
    const coursesMap = new Map();
    
    rows.forEach(row => {
      const courseName = row[0];  // course_name column
      const videoTitle = row[1];  // video_title column
      const youtubeUrl = row[2]; // youtube_url column
      const category = row[3];   // category column
      
      if (!courseName) return; // Skip empty rows
      
      if (!coursesMap.has(courseName)) {
        coursesMap.set(courseName, {
          id: courseName.toLowerCase().replace(/\s+/g, '_'),
          title: courseName,
          videos: []
        });
      }
      
      // Add video info if YouTube URL exists
      if (youtubeUrl) {
        coursesMap.get(courseName).videos.push({
          video_title: videoTitle || '',
          youtube_url: youtubeUrl,
          category: category || ''
        });
      }
    });
    
    // Convert Map to Array
    data = Array.from(coursesMap.values());
  }

  return ContentService.createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}
```

## 3. Deploy
- Deploy > New deployment > Web app > Execute as Me > Anyone.
- Copy web app URL to constants.dart SHEETS_API_BASE.

## 4. Update constants.dart
```
const String SHEETS_API_BASE = 'https://script.google.com/macros/s/YOUR_DEPLOY_ID/exec';
```

## 5. Firebase Firestore Setup
Create these collections:

### users collection
```
{
  uid: "user_uid",
  email: "user@example.com",
  isPremium: false,
  created_at: timestamp,
  activated_at: null,
  activated_key: null
}
```

### activation_keys collection
```
{
  key_code: "ABC-123",
  is_used: false,
  used_by: null,
  used_at: null,
  created_at: timestamp
}
```

## 6. Test URLs
- Blogs: https://script.../exec?type=blogs
- Courses: https://script.../exec?type=courses
- Admin Panel: /admin route in app

## 7. Premium Logic
- Videos 0-9: Free for all users
- Videos 10+: Premium only (shows lock icon)
- Users can activate premium with activation key
- Admin can create/manage keys at /admin

Sheet ID from URL: docs.google.com/spreadsheets/d/**SHEET_ID**/edit
