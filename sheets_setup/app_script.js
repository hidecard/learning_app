const DEFAULT_SHEET_ID = '1JJCDMHWMKtToFl9cRoJ-OIgMop4tVdOB-l8jbkg1wbs';
const DEFAULT_ADMIN_EMAIL = 'ak1500@gmail.com';

function doGet(e) {
  return handleRequest_(e && e.parameter ? e.parameter : {});
}

function doPost(e) {
  let params = {};
  try {
    params = JSON.parse((e && e.postData && e.postData.contents) || '{}');
  } catch (error) {
    return jsonResponse_({ success: false, error: 'Invalid JSON request body.' });
  }
  return handleRequest_(params);
}

function handleRequest_(params) {
  const sheetId = PropertiesService.getScriptProperties().getProperty('SHEET_ID') || DEFAULT_SHEET_ID;
  const ss = SpreadsheetApp.openById(sheetId);
  const operation = String(params.operation || 'read').toLowerCase();
  const type = String(params.type || 'blogs').toLowerCase();
  const adminEmail = String(params.admin || '').trim().toLowerCase();
  const configuredAdminEmail = (PropertiesService.getScriptProperties()
    .getProperty('ADMIN_EMAIL') || DEFAULT_ADMIN_EMAIL).trim().toLowerCase();
  const isAdminRead = type === 'courses_raw';

  if (operation !== 'read' || isAdminRead) {
    if (adminEmail !== configuredAdminEmail) {
      return jsonResponse_({ success: false, error: 'Unauthorized.' });
    }
  }

  try {
    switch (operation) {
      case 'read':
        return readData_(ss, type);
      case 'create':
        return createData_(ss, type, params);
      case 'update':
        return updateData_(ss, type, params);
      case 'delete':
        return deleteData_(ss, type, params);
      default:
        return jsonResponse_({ success: false, error: 'Invalid operation.' });
    }
  } catch (error) {
    return jsonResponse_({
      success: false,
      error: error && error.message ? error.message : 'Unexpected server error.',
    });
  }
}

function jsonResponse_(payload) {
  return ContentService.createTextOutput(JSON.stringify(payload))
    .setMimeType(ContentService.MimeType.JSON);
}

function required_(params, fields) {
  for (let i = 0; i < fields.length; i += 1) {
    const value = String(params[fields[i]] || '').trim();
    if (!value) throw new Error(fields[i] + ' is required.');
  }
}

function validImageUrl_(value) {
  if (!value) return true;
  return /^https?:\/\/\S+$/i.test(value);
}

function validYouTubeUrl_(value) {
  return /^(https?:\/\/)?(www\.)?(youtube\.com\/(watch\?v=|embed\/|v\/)|youtu\.be\/)[^\s&?#]+/i.test(value);
}

function readData_(ss, type) {
  if (type === 'blogs') {
    const sheet = ss.getSheetByName('blogs');
    if (!sheet) return jsonResponse_([]);
    return jsonResponse_(sheet.getDataRange().getValues().slice(1).map(function(row) {
      return {
        id: row[0],
        title: row[1] || '',
        content: row[2] || '',
        category: row[3] || 'General',
        image_url: row[4] || '',
      };
    }));
  }

  if (type === 'courses' || type === 'courses_raw') {
    const sheet = ss.getSheetByName('courses');
    if (!sheet) return jsonResponse_([]);
    const rows = sheet.getDataRange().getValues();

    if (type === 'courses_raw') {
      return jsonResponse_(rows.slice(1).map(function(row, index) {
        return {
          row: index + 2,
          course_name: row[0] || '',
          video_title: row[1] || '',
          youtube_url: row[2] || '',
          category: row[3] || '',
        };
      }));
    }

    const coursesMap = new Map();
    rows.slice(1).forEach(function(row) {
      const courseName = String(row[0] || '').trim();
      const videoTitle = String(row[1] || '').trim();
      const youtubeUrl = String(row[2] || '').trim();
      const category = String(row[3] || '').trim();
      if (!courseName) return;

      if (!coursesMap.has(courseName)) {
        coursesMap.set(courseName, {
          id: courseName.toLowerCase().replace(/\s+/g, '_'),
          title: courseName,
          videos: [],
        });
      }
      if (youtubeUrl) {
        coursesMap.get(courseName).videos.push({
          video_title: videoTitle,
          youtube_url: youtubeUrl,
          category: category,
        });
      }
    });
    return jsonResponse_(Array.from(coursesMap.values()));
  }

  return jsonResponse_({ success: false, error: 'Unknown content type.' });
}

function createData_(ss, type, params) {
  if (type === 'blogs') {
    required_(params, ['title', 'content', 'category']);
    const imageUrl = String(params.image_url || '').trim();
    if (!validImageUrl_(imageUrl)) throw new Error('image_url must be a valid HTTP(S) URL.');
    const sheet = ss.getSheetByName('blogs') || ss.insertSheet('blogs');
    const id = String(params.id || Date.now());
    sheet.appendRow([
      id,
      String(params.title).trim(),
      String(params.content).trim(),
      String(params.category).trim(),
      imageUrl,
    ]);
    return jsonResponse_({ success: true, message: 'Blog created successfully.', id: id });
  }

  if (type === 'courses') {
    required_(params, ['course_name', 'video_title', 'youtube_url', 'category']);
    const youtubeUrl = String(params.youtube_url).trim();
    if (!validYouTubeUrl_(youtubeUrl)) throw new Error('youtube_url must be a valid YouTube URL.');
    const sheet = ss.getSheetByName('courses') || ss.insertSheet('courses');
    sheet.appendRow([
      String(params.course_name).trim(),
      String(params.video_title).trim(),
      youtubeUrl,
      String(params.category).trim(),
    ]);
    return jsonResponse_({ success: true, message: 'Course video created successfully.' });
  }

  return jsonResponse_({ success: false, error: 'Unknown content type.' });
}

function updateData_(ss, type, params) {
  if (type === 'blogs') {
    required_(params, ['id']);
    const sheet = ss.getSheetByName('blogs');
    if (!sheet) return jsonResponse_({ success: false, error: 'Blogs sheet not found.' });
    const data = sheet.getDataRange().getValues();
    const id = String(params.id);
    for (let i = 1; i < data.length; i += 1) {
      if (String(data[i][0]) === id) {
        if (params.title !== undefined) data[i][1] = String(params.title).trim();
        if (params.content !== undefined) data[i][2] = String(params.content).trim();
        if (params.category !== undefined) data[i][3] = String(params.category).trim();
        if (params.image_url !== undefined) {
          const imageUrl = String(params.image_url).trim();
          if (!validImageUrl_(imageUrl)) throw new Error('image_url must be a valid HTTP(S) URL.');
          data[i][4] = imageUrl;
        }
        sheet.getRange(1, 1, data.length, data[0].length).setValues(data);
        return jsonResponse_({ success: true, message: 'Blog updated successfully.' });
      }
    }
    return jsonResponse_({ success: false, error: 'Blog not found.' });
  }

  if (type === 'courses') {
    const row = Number.parseInt(params.row, 10);
    if (!Number.isInteger(row) || row < 2) return jsonResponse_({ success: false, error: 'Invalid row number.' });
    const sheet = ss.getSheetByName('courses');
    if (!sheet) return jsonResponse_({ success: false, error: 'Courses sheet not found.' });
    if (row > sheet.getLastRow()) return jsonResponse_({ success: false, error: 'Row not found.' });
    if (params.youtube_url !== undefined && !validYouTubeUrl_(String(params.youtube_url).trim())) {
      throw new Error('youtube_url must be a valid YouTube URL.');
    }
    const values = [[
      params.course_name === undefined ? sheet.getRange(row, 1).getValue() : String(params.course_name).trim(),
      params.video_title === undefined ? sheet.getRange(row, 2).getValue() : String(params.video_title).trim(),
      params.youtube_url === undefined ? sheet.getRange(row, 3).getValue() : String(params.youtube_url).trim(),
      params.category === undefined ? sheet.getRange(row, 4).getValue() : String(params.category).trim(),
    ]];
    sheet.getRange(row, 1, 1, 4).setValues(values);
    return jsonResponse_({ success: true, message: 'Course video updated successfully.' });
  }

  return jsonResponse_({ success: false, error: 'Unknown content type.' });
}

function deleteData_(ss, type, params) {
  if (type === 'blogs') {
    required_(params, ['id']);
    const sheet = ss.getSheetByName('blogs');
    if (!sheet) return jsonResponse_({ success: false, error: 'Blogs sheet not found.' });
    const data = sheet.getDataRange().getValues();
    const id = String(params.id);
    for (let i = 1; i < data.length; i += 1) {
      if (String(data[i][0]) === id) {
        sheet.deleteRow(i + 1);
        return jsonResponse_({ success: true, message: 'Blog deleted successfully.' });
      }
    }
    return jsonResponse_({ success: false, error: 'Blog not found.' });
  }

  if (type === 'courses') {
    const row = Number.parseInt(params.row, 10);
    const sheet = ss.getSheetByName('courses');
    if (!sheet) return jsonResponse_({ success: false, error: 'Courses sheet not found.' });
    if (!Number.isInteger(row) || row < 2 || row > sheet.getLastRow()) {
      return jsonResponse_({ success: false, error: 'Row not found.' });
    }
    sheet.deleteRow(row);
    return jsonResponse_({ success: true, message: 'Course video deleted successfully.' });
  }

  return jsonResponse_({ success: false, error: 'Unknown content type.' });
}
