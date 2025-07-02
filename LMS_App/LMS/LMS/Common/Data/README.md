# Data Layer Architecture

## Overview

The Data layer implements the DTO (Data Transfer Object) pattern for clean separation between Domain and API/Database layers.

## Structure

```
Common/Data/
├── DTOs/
│   ├── DataTransferObject.swift    # Base protocols and utilities
│   ├── UserDTO.swift              # User-related DTOs
│   └── CourseDTO.swift            # Course-related DTOs
└── Mappers/
    └── UserMapper.swift           # Domain ↔ DTO mapping
```

## Key Components

### 1. Base Protocols

- **`DataTransferObject`**: Base protocol with validation
- **`Mappable`**: Protocol for Domain ↔ DTO mapping
- **`APIResponse<T>`**: Generic wrapper for API responses
- **`CollectionResponse<T>`**: Paginated collection wrapper

### 2. DTOs

- **UserDTO**: Complete user model for API
- **UserProfileDTO**: Simplified user profile
- **CreateUserDTO**: User creation payload
- **UpdateUserDTO**: User update payload

### 3. Mappers

- **UserMapper**: Bidirectional User ↔ UserDTO mapping
- **Safe mapping**: Error collection and handling
- **Collection utilities**: Batch operations

## Usage Examples

### Creating DTOs

```swift
let userDTO = UserDTO(
    id: "USER_123",
    email: "user@example.com",
    firstName: "John",
    lastName: "Doe",
    role: "student",
    createdAt: ISO8601DateFormatter().string(from: Date()),
    updatedAt: ISO8601DateFormatter().string(from: Date())
)

// Validation
if userDTO.isValid() {
    // Use DTO
} else {
    print("Validation errors: \(userDTO.validationErrors())")
}
```

### Mapping

```swift
// Domain to DTO
let dto = UserMapper.toDTO(from: domainUser)

// DTO to Domain
let domain = UserMapper.toDomain(from: dto)

// Safe collection mapping
let (users, errors) = UserMapper.safeToDomains(from: dtos)
```

### API Responses

```swift
// Success response
let response = APIResponse(
    data: userDTO,
    success: true,
    message: "User retrieved successfully"
)

// Collection response
let collection = CollectionResponse(
    items: userDTOs,
    totalCount: 100,
    page: 1,
    pageSize: 20
)
```

## Validation

All DTOs implement comprehensive validation:

- **Required fields**: Empty string checks
- **Format validation**: Email, phone, URL formats
- **Business rules**: Role validation, date formats
- **Constraints**: String lengths, numeric ranges

## Error Handling

- **`MappingError`**: Typed errors for mapping failures
- **Validation errors**: Detailed error messages
- **Safe operations**: No exceptions, return optionals

## Testing

Comprehensive test coverage includes:

- DTO validation scenarios
- Mapping round-trip tests
- Collection operations
- Error handling
- Edge cases

## Integration

DTOs integrate with:

- **Repository pattern**: Data persistence layer
- **Network layer**: API communication
- **Domain models**: Business logic layer
- **UI layer**: View model population

## Best Practices

1. **Always validate** DTOs before use
2. **Use safe mapping** for collections
3. **Handle mapping errors** gracefully
4. **Test validation rules** thoroughly
5. **Keep DTOs immutable** (struct with let)
6. **Separate concerns** (different DTOs for different operations) 