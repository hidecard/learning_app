function doGet(e) {
  const ss = SpreadsheetApp.openById('1JJCDMHWMKtToFl9cRoJ-OIgMop4tVdOB-l8jbkg1wbs');
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
