# Google Sheets & Apps Script Setup

## 1. Create Google Sheet
- New Sheet: tabs 'blogs', 'courses', 'keys' (optional, use Supabase for keys).

### blogs tab headers: id,title,content,category,image_url
```
id,title,content,category,image_url
1,"Intro to Flutter","Flutter basics...",flutter,https://example.com/img.jpg
2,"Dart Tips","Advanced Dart...",dart,
```

### courses tab headers: id,title,videos
```
id,title,videos
1,"Flutter Course","[" dQw4w9WgXcQ","eHzT1VsAidk","fJ9rUzIMcZQ"...]"  // JSON array YT IDs, up to 20
2,"Dart Course","["abc123","def456"]"
```
*Note: videos as JSON string array (Apps Script parses). Import CSV or manual.*

## 2. Apps Script (Code.gs)
Paste into https://script.google.com > New project > replace code:

```
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
    data = sheet.getDataRange().getValues().slice(1).map(row => ({
      id: row[0],
      title: row[1],
      videos: JSON.parse(row[2] || '[]')  // Safe parse
    }));
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

Test: https://script.../exec?type=blogs → JSON array.

Sheet ID from URL: docs.google.com/spreadsheets/d/**SHEET_ID**/edit
