# Competency Management Module

## Overview

The Competency Management module provides functionality for managing employee competencies, skill levels, and assessments within the LMS system.

## Architecture

The module follows Domain-Driven Design (DDD) principles with clear separation of concerns:

```
Competency/
├── Domain/                 # Core business logic
│   ├── Competency.php     # Main aggregate root
│   ├── CompetencyAssessment.php
│   ├── UserCompetency.php
│   ├── ValueObjects/      # Immutable value objects
│   ├── Events/           # Domain events
│   ├── Repository/       # Repository interfaces
│   └── Service/          # Domain services
├── Application/          # Application layer (CQRS)
│   ├── Commands/         # Command objects
│   ├── Handlers/         # Command handlers
│   ├── Queries/          # Query objects
│   └── DTO/              # Data transfer objects
├── Infrastructure/       # Infrastructure implementations
│   ├── Repository/       # Concrete repositories
│   └── Persistence/      # Database mappings
└── Http/                 # HTTP layer
    ├── Controllers/      # REST controllers
    ├── Requests/         # Request validation
    ├── Resources/        # API resources
    └── Middleware/       # HTTP middleware
```

## API Endpoints

### Competencies

- `GET /api/v1/competencies` - List all competencies
- `GET /api/v1/competencies/{id}` - Get competency details
- `POST /api/v1/competencies` - Create new competency
- `PUT /api/v1/competencies/{id}` - Update competency
- `DELETE /api/v1/competencies/{id}` - Delete competency
- `POST /api/v1/competencies/{id}/assess` - Assess user competency

### Categories

- `GET /api/v1/competency-categories` - List categories
- `GET /api/v1/competency-categories/{id}` - Get category
- `POST /api/v1/competency-categories` - Create category
- `PUT /api/v1/competency-categories/{id}` - Update category

## Domain Model

### Competency
The main aggregate root representing a skill or knowledge area:
- Has unique ID and code
- Belongs to a category (technical, soft skills, etc.)
- Has multiple skill levels (1-5)
- Can be active/inactive
- Supports hierarchical structure (parent/child)

### CompetencyAssessment
Records an assessment of a user's competency level:
- Links user, competency, and assessor
- Records level and score
- Includes optional comments
- Immutable once confirmed

### UserCompetency
Tracks a user's current and target levels:
- Current assessed level
- Target level for development
- Progress percentage
- Last assessment date

## Value Objects

- **CompetencyId**: UUID-based identifier
- **CompetencyCode**: Unique business code (e.g., "TECH-PHP-001")
- **CompetencyLevel**: Skill level (1-5: Beginner to Expert)
- **CompetencyCategory**: Category type (technical, soft, leadership, business)
- **AssessmentScore**: Normalized score (0-100)

## Testing

The module includes comprehensive test coverage:

- **Unit Tests**: 236 tests covering all layers
- **Integration Tests**: Repository and service integration
- **Feature Tests**: HTTP endpoint testing

Run tests:
```bash
# All module tests
./test-quick.sh tests/Unit/Competency/

# Specific layer
./test-quick.sh tests/Unit/Competency/Domain/
./test-quick.sh tests/Unit/Competency/Application/
```

## Usage Examples

### Creating a Competency
```php
$competency = Competency::create(
    CompetencyId::generate(),
    CompetencyCode::fromString('PHP-001'),
    'PHP Development',
    'Proficiency in PHP programming',
    CompetencyCategory::technical()
);
```

### Assessing a Competency
```php
$command = new AssessCompetencyCommand(
    competencyId: $competencyId,
    userId: $userId,
    assessorId: $assessorId,
    level: 4,
    comment: 'Excellent PHP skills demonstrated'
);

$handler->handle($command);
```

## Configuration

### Middleware
The module includes authorization middleware that protects:
- Create/Update/Delete operations (admin, hr_manager)
- Assessment operations (admin, hr_manager, manager)

### Routes
Routes are configured in `config/routes/competency.yaml`

## Future Enhancements

1. **Competency Matrix**: Visual representation of team competencies
2. **Gap Analysis**: Identify skill gaps for positions
3. **Development Plans**: Auto-generate based on gaps
4. **Certification Integration**: Link to certifications
5. **360° Assessments**: Multi-source feedback

## Dependencies

- PHP 8.1+
- Symfony/Laravel framework components
- UUID library for identifiers
- Domain event system

---

Last updated: July 1, 2025 