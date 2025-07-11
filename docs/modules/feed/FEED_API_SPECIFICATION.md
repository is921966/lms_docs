# Feed Module API Specification

## OpenAPI 3.0 Specification

```yaml
openapi: 3.0.0
info:
  title: LMS Feed API
  version: 1.0.0
  description: Social feed functionality for LMS application

servers:
  - url: https://api.lms.example.com/v1
    description: Production server
  - url: http://localhost:8000/v1
    description: Development server

security:
  - bearerAuth: []

paths:
  /feed/posts:
    get:
      summary: Get feed posts
      tags:
        - Posts
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
        - name: visibility
          in: query
          schema:
            type: string
            enum: [everyone, department, instructorsOnly]
        - name: search
          in: query
          schema:
            type: string
        - name: tags
          in: query
          schema:
            type: array
            items:
              type: string
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PostListResponse'
        '401':
          $ref: '#/components/responses/Unauthorized'
    
    post:
      summary: Create new post
      tags:
        - Posts
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreatePostRequest'
      responses:
        '201':
          description: Post created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Post'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '403':
          $ref: '#/components/responses/Forbidden'

  /feed/posts/{postId}:
    get:
      summary: Get post by ID
      tags:
        - Posts
      parameters:
        - name: postId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Post'
        '404':
          $ref: '#/components/responses/NotFound'
    
    put:
      summary: Update post
      tags:
        - Posts
      parameters:
        - name: postId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdatePostRequest'
      responses:
        '200':
          description: Post updated
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Post'
        '403':
          $ref: '#/components/responses/Forbidden'
        '404':
          $ref: '#/components/responses/NotFound'
    
    delete:
      summary: Delete post
      tags:
        - Posts
      parameters:
        - name: postId
          in: path
          required: true
          schema:
            type: string
      responses:
        '204':
          description: Post deleted
        '403':
          $ref: '#/components/responses/Forbidden'
        '404':
          $ref: '#/components/responses/NotFound'

  /feed/posts/{postId}/like:
    post:
      summary: Toggle like on post
      tags:
        - Posts
      parameters:
        - name: postId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Like toggled
          content:
            application/json:
              schema:
                type: object
                properties:
                  liked:
                    type: boolean
                  likesCount:
                    type: integer

  /feed/posts/{postId}/comments:
    get:
      summary: Get post comments
      tags:
        - Comments
      parameters:
        - name: postId
          in: path
          required: true
          schema:
            type: string
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CommentListResponse'
    
    post:
      summary: Add comment to post
      tags:
        - Comments
      parameters:
        - name: postId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateCommentRequest'
      responses:
        '201':
          description: Comment created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Comment'

  /feed/comments/{commentId}:
    delete:
      summary: Delete comment
      tags:
        - Comments
      parameters:
        - name: commentId
          in: path
          required: true
          schema:
            type: string
      responses:
        '204':
          description: Comment deleted
        '403':
          $ref: '#/components/responses/Forbidden'
        '404':
          $ref: '#/components/responses/NotFound'

  /feed/comments/{commentId}/like:
    post:
      summary: Toggle like on comment
      tags:
        - Comments
      parameters:
        - name: commentId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Like toggled
          content:
            application/json:
              schema:
                type: object
                properties:
                  liked:
                    type: boolean
                  likesCount:
                    type: integer

  /feed/attachments:
    post:
      summary: Upload attachment
      tags:
        - Attachments
      requestBody:
        required: true
        content:
          multipart/form-data:
            schema:
              type: object
              properties:
                file:
                  type: string
                  format: binary
                type:
                  type: string
                  enum: [document, image, video, audio, other]
      responses:
        '201':
          description: Attachment uploaded
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Attachment'
        '400':
          $ref: '#/components/responses/BadRequest'
        '413':
          description: File too large

  /feed/attachments/{attachmentId}:
    get:
      summary: Download attachment
      tags:
        - Attachments
      parameters:
        - name: attachmentId
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: File content
          content:
            application/octet-stream:
              schema:
                type: string
                format: binary
        '404':
          $ref: '#/components/responses/NotFound'
    
    delete:
      summary: Delete attachment
      tags:
        - Attachments
      parameters:
        - name: attachmentId
          in: path
          required: true
          schema:
            type: string
      responses:
        '204':
          description: Attachment deleted
        '403':
          $ref: '#/components/responses/Forbidden'
        '404':
          $ref: '#/components/responses/NotFound'

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    Post:
      type: object
      properties:
        id:
          type: string
        author:
          $ref: '#/components/schemas/Author'
        content:
          type: string
        images:
          type: array
          items:
            type: string
        attachments:
          type: array
          items:
            $ref: '#/components/schemas/Attachment'
        createdAt:
          type: string
          format: date-time
        visibility:
          type: string
          enum: [everyone, department, instructorsOnly]
        likes:
          type: array
          items:
            type: string
        likesCount:
          type: integer
        commentsCount:
          type: integer
        tags:
          type: array
          items:
            type: string
        isLiked:
          type: boolean
        canEdit:
          type: boolean
        canDelete:
          type: boolean

    Author:
      type: object
      properties:
        id:
          type: string
        name:
          type: string
        email:
          type: string
        role:
          type: string
          enum: [student, instructor, admin]
        avatarUrl:
          type: string

    Comment:
      type: object
      properties:
        id:
          type: string
        postId:
          type: string
        author:
          $ref: '#/components/schemas/Author'
        content:
          type: string
        createdAt:
          type: string
          format: date-time
        likes:
          type: array
          items:
            type: string
        likesCount:
          type: integer
        isLiked:
          type: boolean
        canDelete:
          type: boolean

    Attachment:
      type: object
      properties:
        id:
          type: string
        type:
          type: string
          enum: [document, image, video, audio, other]
        url:
          type: string
        name:
          type: string
        size:
          type: integer
          format: int64
        thumbnailUrl:
          type: string
        mimeType:
          type: string

    CreatePostRequest:
      type: object
      required:
        - content
        - visibility
      properties:
        content:
          type: string
          minLength: 1
          maxLength: 1000
        images:
          type: array
          items:
            type: string
          maxItems: 10
        attachmentIds:
          type: array
          items:
            type: string
          maxItems: 5
        visibility:
          type: string
          enum: [everyone, department, instructorsOnly]
        tags:
          type: array
          items:
            type: string
          maxItems: 10

    UpdatePostRequest:
      type: object
      properties:
        content:
          type: string
          minLength: 1
          maxLength: 1000
        visibility:
          type: string
          enum: [everyone, department, instructorsOnly]
        tags:
          type: array
          items:
            type: string
          maxItems: 10

    CreateCommentRequest:
      type: object
      required:
        - content
      properties:
        content:
          type: string
          minLength: 1
          maxLength: 500

    PostListResponse:
      type: object
      properties:
        posts:
          type: array
          items:
            $ref: '#/components/schemas/Post'
        pagination:
          $ref: '#/components/schemas/Pagination'
        permissions:
          $ref: '#/components/schemas/FeedPermissions'

    CommentListResponse:
      type: object
      properties:
        comments:
          type: array
          items:
            $ref: '#/components/schemas/Comment'
        pagination:
          $ref: '#/components/schemas/Pagination'

    Pagination:
      type: object
      properties:
        page:
          type: integer
        limit:
          type: integer
        totalPages:
          type: integer
        totalItems:
          type: integer
        hasNext:
          type: boolean
        hasPrevious:
          type: boolean

    FeedPermissions:
      type: object
      properties:
        canPost:
          type: boolean
        canComment:
          type: boolean
        canLike:
          type: boolean
        canShare:
          type: boolean
        canDelete:
          type: boolean
        canEdit:
          type: boolean
        canModerate:
          type: boolean
        visibilityOptions:
          type: array
          items:
            type: string

    Error:
      type: object
      properties:
        error:
          type: string
        message:
          type: string
        details:
          type: object

  responses:
    BadRequest:
      description: Bad request
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
    
    Unauthorized:
      description: Unauthorized
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
    
    Forbidden:
      description: Forbidden
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
    
    NotFound:
      description: Not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
```

## Rate Limiting

All endpoints are subject to rate limiting:

| Endpoint | Rate Limit |
|----------|------------|
| GET endpoints | 100 requests/minute |
| POST /feed/posts | 10 posts/hour |
| POST comments | 30 comments/hour |
| POST likes | 100 likes/minute |
| POST attachments | 20 uploads/hour |

## Webhooks

The Feed API supports webhooks for real-time notifications:

### Events
- `post.created`
- `post.updated`
- `post.deleted`
- `comment.created`
- `comment.deleted`
- `like.added`
- `like.removed`

### Webhook Payload
```json
{
  "event": "post.created",
  "timestamp": "2025-01-13T10:00:00Z",
  "data": {
    "post": { /* Post object */ },
    "user": { /* User who created */ }
  }
}
```

## Error Codes

| Code | Description |
|------|-------------|
| 400 | Invalid request parameters |
| 401 | Authentication required |
| 403 | Insufficient permissions |
| 404 | Resource not found |
| 413 | File too large |
| 429 | Rate limit exceeded |
| 500 | Internal server error |

## SDK Examples

### JavaScript/TypeScript
```typescript
import { FeedAPI } from '@lms/feed-sdk';

const api = new FeedAPI({
  baseURL: 'https://api.lms.example.com/v1',
  token: 'your-jwt-token'
});

// Get posts
const posts = await api.posts.list({ page: 1, limit: 20 });

// Create post
const newPost = await api.posts.create({
  content: 'Hello, LMS!',
  visibility: 'everyone'
});

// Like post
await api.posts.like(newPost.id);

// Add comment
await api.comments.create(newPost.id, {
  content: 'Great post!'
});
```

### Swift
```swift
import LMSAPI

let api = FeedAPI(baseURL: "https://api.lms.example.com/v1")
api.setAuthToken("your-jwt-token")

// Get posts
let posts = try await api.getPosts(page: 1, limit: 20)

// Create post
let newPost = try await api.createPost(
    content: "Hello, LMS!",
    visibility: .everyone
)

// Like post
try await api.likePost(postId: newPost.id)

// Add comment
try await api.addComment(
    postId: newPost.id,
    content: "Great post!"
)
``` 