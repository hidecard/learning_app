# Admin Dashboard CRUD Guide

## Overview
The admin dashboard provides full CRUD (Create, Read, Update, Delete) functionality for managing blogs and courses through Google Sheets integration. Only the admin user `ak1500@gmail.com` has access to these features.

## Authentication
- **Admin Email**: `ak1500@gmail.com`
- **Access Control**: The dashboard automatically checks if the current user is the admin
- **Unauthorized Access**: Non-admin users will see an access denied message and be redirected

## Features

### 1. Blog Management
- **Create**: Add new blog posts with title, content, category, and optional image URL
- **Read**: View all existing blogs with preview images and metadata
- **Update**: Edit existing blog posts (title, content, category, image URL)
- **Delete**: Remove blog posts with confirmation dialog

### 2. Course Management  
- **Create**: Add new course videos with course name, video title, YouTube URL, and category
- **Read**: View all course videos with YouTube URL preview and copy functionality
- **Update**: Edit existing course video information
- **Delete**: Remove course videos with confirmation dialog

### 3. Activation Key Management
- **Create**: Generate new activation keys for premium access
- **Read**: View available and used activation keys
- **Manage**: Track key usage and status

## Google Sheets Integration

### Required Sheets Structure
Your Google Sheet should have these tabs:

#### Blogs Tab
Headers: `id`, `title`, `content`, `category`, `image_url`

#### Courses Tab  
Headers: `course_name`, `video_title`, `youtube_url`, `category`

### Apps Script Deployment
1. Copy the enhanced `app_script.js` to your Google Apps Script project
2. Deploy as Web App with permissions:
   - Execute as: Me
   - Who has access: Anyone
3. Update `SHEETS_API_BASE` in `lib/core/constants.dart` with your deployment URL

## API Endpoints

### Blog Operations
- **Read**: `GET {BASE_URL}?type=blogs`
- **Create**: `GET {BASE_URL}?operation=create&type=blogs&admin=ak1500@gmail.com&id={id}&title={title}&content={content}&category={category}&image_url={url}`
- **Update**: `GET {BASE_URL}?operation=update&type=blogs&admin=ak1500@gmail.com&id={id}&title={title}&content={content}&category={category}&image_url={url}`
- **Delete**: `GET {BASE_URL}?operation=delete&type=blogs&admin=ak1500@gmail.com&id={id}`

### Course Operations
- **Read**: `GET {BASE_URL}?type=courses` (for app display)
- **Read Raw**: `GET {BASE_URL}?type=courses_raw&admin=ak1500@gmail.com` (for admin)
- **Create**: `GET {BASE_URL}?operation=create&type=courses&admin=ak1500@gmail.com&course_name={name}&video_title={title}&youtube_url={url}&category={category}`
- **Update**: `GET {BASE_URL}?operation=update&type=courses&admin=ak1500@gmail.com&row={row}&course_name={name}&video_title={title}&youtube_url={url}&category={category}`
- **Delete**: `GET {BASE_URL}?operation=delete&type=courses&admin=ak1500@gmail.com&row={row}`

## Form Validation

### Blog Form
- **Title**: Required, any length
- **Content**: Required, any length  
- **Category**: Required, any length
- **Image URL**: Optional, must be valid URL if provided

### Course Form
- **Course Name**: Required, any length
- **Video Title**: Required, any length
- **YouTube URL**: Required, must be valid YouTube URL
  - Supported formats:
    - `youtube.com/watch?v=ID`
    - `youtu.be/ID`
    - `youtube.com/embed/ID`
    - `youtube.com/v/ID`
- **Category**: Required, any length

## Error Handling

### Network Errors
- No internet connection detection
- Timeout handling
- API response validation

### Validation Errors
- Real-time form validation
- User-friendly error messages
- Field-specific error indicators

### Permission Errors
- Admin access verification
- Unauthorized operation blocking
- Clear error messaging

## Testing Checklist

### Authentication Tests
- [ ] Admin user can access dashboard
- [ ] Non-admin user gets access denied
- [ ] User session refresh works correctly

### Blog CRUD Tests
- [ ] Create new blog successfully
- [ ] Edit existing blog successfully  
- [ ] Delete blog with confirmation
- [ ] Form validation works correctly
- [ ] Image URL validation works
- [ ] Empty state displays correctly

### Course CRUD Tests
- [ ] Create new course video successfully
- [ ] Edit existing course video successfully
- [ ] Delete course video with confirmation
- [ ] YouTube URL validation works
- [ ] Copy URL functionality works
- [ ] Empty state displays correctly

### Activation Key Tests
- [ ] Create new activation key
- [ ] View available keys list
- [ ] View used keys list
- [ ] Key format validation works

### Integration Tests
- [ ] Data syncs with Google Sheets
- [ ] Changes reflect in app immediately
- [ ] Network error handling works
- [ ] Loading states display correctly

## Troubleshooting

### Common Issues

#### "Access Denied" Error
- Verify user is logged in as `ak1500@gmail.com`
- Check Firebase Auth configuration
- Ensure admin email is correctly set in `AdminAuthService`

#### "Failed to connect to Google Sheets"
- Verify Apps Script deployment URL
- Check network connectivity
- Ensure sheet permissions are correct
- Verify sheet structure matches required headers

#### "Form validation errors"
- Check all required fields are filled
- Verify URL formats are correct
- Ensure YouTube URLs are valid

#### "Data not syncing"
- Refresh the page/app
- Check Apps Script logs for errors
- Verify sheet permissions
- Test API endpoints directly

### Debug Mode
Enable debug mode in Flutter to see detailed logs:
- API request/response logging
- Error stack traces
- Network request details

## Security Considerations

- Admin operations require `ak1500@gmail.com` authentication
- All write operations include admin parameter verification
- Input validation prevents injection attacks
- Error messages don't expose sensitive information

## Performance Notes

- Data is cached locally after initial load
- Refresh functionality updates cached data
- Lazy loading for large datasets
- Optimized image loading with error handling
