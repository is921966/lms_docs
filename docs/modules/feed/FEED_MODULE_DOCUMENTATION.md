# Feed Module Documentation

## Overview

The Feed module is a comprehensive social interaction system within the LMS application that allows users to create posts, share content, comment, and interact with each other. It provides a Twitter-like experience tailored for educational environments.

## Features

### 1. Posts
- Create text posts with rich content
- Attach images and documents
- Set visibility levels (everyone, department, instructors only)
- Tag posts for better organization
- Edit and delete own posts (with appropriate permissions)

### 2. Comments
- Comment on posts
- Nested comment threads
- Like/unlike comments
- Delete own comments

### 3. Attachments
- Support for multiple file types (documents, images, videos)
- Thumbnail generation for visual content
- File size limits and validation
- Secure file storage and retrieval

### 4. Permissions System
- Role-based access control
- Visibility settings per post
- Moderation capabilities for administrators
- Department-specific content restrictions

### 5. Real-time Updates
- Live feed updates
- Instant comment notifications
- Like/unlike animations
- Optimistic UI updates

## Architecture

### Models

#### FeedPost
```swift
struct FeedPost: Identifiable, Codable {
    let id: String
    let author: UserResponse
    var content: String
    var images: [String]
    var attachments: [FeedAttachment]
    let createdAt: Date
    var visibility: FeedVisibility
    var likes: [String]
    var comments: [FeedComment]
    var tags: [String]?
}
```

#### FeedComment
```swift
struct FeedComment: Identifiable, Codable {
    let id: String
    let postId: String
    let author: UserResponse
    var content: String
    let createdAt: Date
    var likes: [String]
}
```

#### FeedAttachment
```swift
struct FeedAttachment: Identifiable, Codable {
    let id: String
    let type: AttachmentType
    let url: String
    let name: String
    let size: Int64
    let thumbnailUrl: String?
}
```

#### FeedPermissions
```swift
struct FeedPermissions: Codable {
    let canPost: Bool
    let canComment: Bool
    let canLike: Bool
    let canShare: Bool
    let canDelete: Bool
    let canEdit: Bool
    let canModerate: Bool
    let visibilityOptions: [FeedVisibility]
}
```

### Services

#### FeedService
The main service managing all feed operations:
- Post CRUD operations
- Comment management
- Like/unlike functionality
- Permission checking
- Real-time updates via Combine

#### MockFeedService
Test implementation for development and testing:
- Simulates network delays
- Provides sample data
- Supports all FeedService operations

### Views

#### FeedView
Main feed display with:
- Infinite scrolling
- Pull-to-refresh
- Search functionality
- Visibility filters
- Create post button (permission-based)

#### FeedPostCard
Individual post display component:
- Author information
- Post content with expandable text
- Image carousel
- Attachment list
- Like/comment/share actions
- Context menu for edit/delete

#### CreatePostView
Post creation interface:
- Rich text editor
- Image picker
- Document attachment
- Visibility selector
- Tag input
- Character counter

#### CommentsView
Comment thread display:
- Nested comment structure
- Load more functionality
- Comment input field
- Like actions on comments

### ViewModels

#### FeedViewModel
Manages feed state and business logic:
- Post filtering and search
- Pagination
- Permission management
- Error handling
- Loading states

## API Endpoints

### Posts
- `GET /api/feed/posts` - Get paginated posts
- `POST /api/feed/posts` - Create new post
- `PUT /api/feed/posts/{id}` - Update post
- `DELETE /api/feed/posts/{id}` - Delete post
- `POST /api/feed/posts/{id}/like` - Toggle like

### Comments
- `GET /api/feed/posts/{postId}/comments` - Get comments
- `POST /api/feed/posts/{postId}/comments` - Add comment
- `DELETE /api/feed/comments/{id}` - Delete comment
- `POST /api/feed/comments/{id}/like` - Toggle comment like

### Attachments
- `POST /api/feed/attachments` - Upload attachment
- `GET /api/feed/attachments/{id}` - Download attachment
- `DELETE /api/feed/attachments/{id}` - Delete attachment

## Security Considerations

### Authentication
- All endpoints require authentication
- JWT tokens for API access
- Session management

### Authorization
- Role-based permissions
- Department-level restrictions
- Content moderation for admins

### Data Protection
- Input sanitization for XSS prevention
- SQL injection protection
- Rate limiting on post creation
- File upload validation

### Privacy
- Visibility controls respected at all levels
- User blocking functionality
- Deleted content permanently removed
- Audit logging for sensitive actions

## Testing

### Unit Tests (70+ tests)
- Model validation and serialization
- Service logic and error handling
- Permission calculations
- Data transformation

### UI Tests (80+ tests)
- View rendering and interactions
- User flow testing
- Accessibility compliance
- Performance under load

### Integration Tests (15+ tests)
- End-to-end workflows
- API integration
- Real-time updates
- Error recovery

### Security Tests (20+ tests)
- Authentication flows
- Authorization checks
- Input validation
- XSS/injection prevention

### Performance Tests (12+ tests)
- Large dataset handling
- Scroll performance
- Image loading optimization
- Search efficiency

## Performance Optimizations

### Lazy Loading
- Images loaded on demand
- Comments paginated
- Virtualized scrolling for large feeds

### Caching
- Post content cached locally
- Images cached with expiration
- User data cached for quick display

### Optimistic Updates
- Immediate UI feedback
- Background synchronization
- Conflict resolution

## Accessibility

### VoiceOver Support
- All interactive elements labeled
- Semantic grouping of content
- Navigation announcements

### Dynamic Type
- Text scales appropriately
- Layout adjusts to text size
- Minimum touch targets maintained

### Color and Contrast
- WCAG AA compliance
- High contrast mode support
- Color-blind friendly design

## Configuration

### Feature Flags
```swift
FeedConfiguration.shared.maxPostLength = 1000
FeedConfiguration.shared.maxImagesPerPost = 10
FeedConfiguration.shared.maxFileSize = 10 * 1024 * 1024 // 10MB
FeedConfiguration.shared.enableRealTimeUpdates = true
```

### Customization
- Theming support
- Localization ready
- Configurable permissions
- Extensible attachment types

## Migration Guide

### From v1.0 to v2.0
1. Update data models for new fields
2. Migrate visibility settings
3. Update API endpoints
4. Test permission changes

## Troubleshooting

### Common Issues

#### Posts not loading
- Check network connectivity
- Verify authentication token
- Check server logs for errors

#### Images not displaying
- Verify image URLs are accessible
- Check cache settings
- Ensure proper permissions

#### Cannot create posts
- Verify user has posting permissions
- Check post length limits
- Validate attachment sizes

## Future Enhancements

### Planned Features
- Rich text formatting
- Polls and surveys
- Scheduled posts
- Analytics dashboard
- AI-powered content moderation

### Technical Improvements
- WebSocket for real-time updates
- GraphQL API migration
- Offline mode with sync
- Enhanced search with filters

## Contributing

### Code Style
- Follow Swift style guide
- Write comprehensive tests
- Document public APIs
- Use meaningful commit messages

### Testing Requirements
- Unit test coverage > 90%
- UI tests for critical paths
- Performance benchmarks
- Security review for changes

### Review Process
1. Create feature branch
2. Implement with tests
3. Update documentation
4. Submit pull request
5. Address review feedback

## Support

For questions or issues:
- Check documentation first
- Search existing issues
- Create detailed bug reports
- Include reproduction steps

## License

This module is part of the LMS application and follows the same licensing terms. 