function doGet(e) {
  const ss = SpreadsheetApp.openById('1JJCDMHWMKtToFl9cRoJ-OIgMop4tVdOB-l8jbkg1wbs');
  const operation = e?.parameter?.operation || 'read';
  const type = e?.parameter?.type || 'blogs';
  const adminEmail = e?.parameter?.admin || '';
  
  // Simple admin check
  if (operation !== 'read' && adminEmail !== 'ak1500@gmail.com') {
    return ContentService.createTextOutput(JSON.stringify({ error: 'Unauthorized' }))
      .setMimeType(ContentService.MimeType.JSON);
  }

  try {
    switch (operation) {
      case 'read':
        return readData(ss, type);
      case 'create':
        return createData(ss, type, e);
      case 'update':
        return updateData(ss, type, e);
      case 'delete':
        return deleteData(ss, type, e);
      default:
        return ContentService.createTextOutput(JSON.stringify({ error: 'Invalid operation' }))
          .setMimeType(ContentService.MimeType.JSON);
    }
  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({ error: error.message }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

function readData(ss, type) {
  let data = [];

  if (type === 'blogs') {
    const sheet = ss.getSheetByName('blogs') || ss.insertSheet('blogs');
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
    
    const coursesMap = new Map();
    
    rows.forEach(row => {
      const courseName = row[0];
      const videoTitle = row[1];
      const youtubeUrl = row[2];
      const category = row[3];
      
      if (!courseName) return;
      
      if (!coursesMap.has(courseName)) {
        coursesMap.set(courseName, {
          id: courseName.toLowerCase().replace(/\s+/g, '_'),
          title: courseName,
          videos: []
        });
      }
      
      if (youtubeUrl) {
        coursesMap.get(courseName).videos.push({
          video_title: videoTitle || '',
          youtube_url: youtubeUrl,
          category: category || ''
        });
      }
    });
    
    data = Array.from(coursesMap.values());
  } else if (type === 'courses_raw') {
    // Return raw data with row numbers for admin operations
    const sheet = ss.getSheetByName('courses') || ss.insertSheet('courses');
    const rows = sheet.getDataRange().getValues();
    
    data = rows.slice(1).map((row, index) => ({
      row: index + 2, // +2 because slice(1) removes header and index is 0-based
      course_name: row[0] || '',
      video_title: row[1] || '',
      youtube_url: row[2] || '',
      category: row[3] || ''
    }));
  }

  return ContentService.createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}

function createData(ss, type, e) {
  if (type === 'blogs') {
    const sheet = ss.getSheetByName('blogs') || ss.insertSheet('blogs');
    const id = e?.parameter?.id || Date.now().toString();
    const title = e?.parameter?.title || '';
    const content = e?.parameter?.content || '';
    const category = e?.parameter?.category || '';
    const imageUrl = e?.parameter?.image_url || '';
    
    sheet.appendRow([id, title, content, category, imageUrl]);
    
    return ContentService.createTextOutput(JSON.stringify({ 
      success: true, 
      message: 'Blog created successfully',
      id: id
    })).setMimeType(ContentService.MimeType.JSON);
  } else if (type === 'courses') {
    const sheet = ss.getSheetByName('courses') || ss.insertSheet('courses');
    const courseName = e?.parameter?.course_name || '';
    const videoTitle = e?.parameter?.video_title || '';
    const youtubeUrl = e?.parameter?.youtube_url || '';
    const category = e?.parameter?.category || '';
    
    sheet.appendRow([courseName, videoTitle, youtubeUrl, category]);
    
    return ContentService.createTextOutput(JSON.stringify({ 
      success: true, 
      message: 'Course video created successfully'
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

function updateData(ss, type, e) {
  if (type === 'blogs') {
    const sheet = ss.getSheetByName('blogs');
    if (!sheet) {
      return ContentService.createTextOutput(JSON.stringify({ error: 'Blogs sheet not found' }))
        .setMimeType(ContentService.MimeType.JSON);
    }
    
    const id = e?.parameter?.id;
    const title = e?.parameter?.title;
    const content = e?.parameter?.content;
    const category = e?.parameter?.category;
    const imageUrl = e?.parameter?.image_url;
    
    const data = sheet.getDataRange().getValues();
    let updated = false;
    
    for (let i = 1; i < data.length; i++) {
      if (data[i][0] == id) {
        if (title !== undefined) data[i][1] = title;
        if (content !== undefined) data[i][2] = content;
        if (category !== undefined) data[i][3] = category;
        if (imageUrl !== undefined) data[i][4] = imageUrl;
        updated = true;
        break;
      }
    }
    
    if (updated) {
      sheet.getRange(1, 1, data.length, data[0].length).setValues(data);
      return ContentService.createTextOutput(JSON.stringify({ 
        success: true, 
        message: 'Blog updated successfully'
      })).setMimeType(ContentService.MimeType.JSON);
    } else {
      return ContentService.createTextOutput(JSON.stringify({ error: 'Blog not found' }))
        .setMimeType(ContentService.MimeType.JSON);
    }
  } else if (type === 'courses') {
    const sheet = ss.getSheetByName('courses');
    if (!sheet) {
      return ContentService.createTextOutput(JSON.stringify({ error: 'Courses sheet not found' }))
        .setMimeType(ContentService.MimeType.JSON);
    }
    
    const row = parseInt(e?.parameter?.row);
    const courseName = e?.parameter?.course_name;
    const videoTitle = e?.parameter?.video_title;
    const youtubeUrl = e?.parameter?.youtube_url;
    const category = e?.parameter?.category;
    
    if (!row || row < 2) {
      return ContentService.createTextOutput(JSON.stringify({ error: 'Invalid row number' }))
        .setMimeType(ContentService.MimeType.JSON);
    }
    
    const data = sheet.getDataRange().getValues();
    
    if (row <= data.length) {
      if (courseName !== undefined) data[row - 1][0] = courseName;
      if (videoTitle !== undefined) data[row - 1][1] = videoTitle;
      if (youtubeUrl !== undefined) data[row - 1][2] = youtubeUrl;
      if (category !== undefined) data[row - 1][3] = category;
      
      sheet.getRange(1, 1, data.length, data[0].length).setValues(data);
      return ContentService.createTextOutput(JSON.stringify({ 
        success: true, 
        message: 'Course video updated successfully'
      })).setMimeType(ContentService.MimeType.JSON);
    } else {
      return ContentService.createTextOutput(JSON.stringify({ error: 'Row not found' }))
        .setMimeType(ContentService.MimeType.JSON);
    }
  }
}

function deleteData(ss, type, e) {
  if (type === 'blogs') {
    const sheet = ss.getSheetByName('blogs');
    if (!sheet) {
      return ContentService.createTextOutput(JSON.stringify({ error: 'Blogs sheet not found' }))
        .setMimeType(ContentService.MimeType.JSON);
    }
    
    const id = e?.parameter?.id;
    const data = sheet.getDataRange().getValues();
    let deleted = false;
    
    for (let i = 1; i < data.length; i++) {
      if (data[i][0] == id) {
        sheet.deleteRow(i + 1);
        deleted = true;
        break;
      }
    }
    
    if (deleted) {
      return ContentService.createTextOutput(JSON.stringify({ 
        success: true, 
        message: 'Blog deleted successfully'
      })).setMimeType(ContentService.MimeType.JSON);
    } else {
      return ContentService.createTextOutput(JSON.stringify({ error: 'Blog not found' }))
        .setMimeType(ContentService.MimeType.JSON);
    }
  } else if (type === 'courses') {
    const sheet = ss.getSheetByName('courses');
    if (!sheet) {
      return ContentService.createTextOutput(JSON.stringify({ error: 'Courses sheet not found' }))
        .setMimeType(ContentService.MimeType.JSON);
    }
    
    const row = parseInt(e?.parameter?.row);
    
    if (!row || row < 2) {
      return ContentService.createTextOutput(JSON.stringify({ error: 'Invalid row number' }))
        .setMimeType(ContentService.MimeType.JSON);
    }
    
    const data = sheet.getDataRange().getValues();
    
    if (row <= data.length) {
      sheet.deleteRow(row);
      return ContentService.createTextOutput(JSON.stringify({ 
        success: true, 
        message: 'Course video deleted successfully'
      })).setMimeType(ContentService.MimeType.JSON);
    } else {
      return ContentService.createTextOutput(JSON.stringify({ error: 'Row not found' }))
        .setMimeType(ContentService.MimeType.JSON);
    }
  }
}
