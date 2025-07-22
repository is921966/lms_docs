# Changelog

All notable changes to the TDD Methodology will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2025-01-17

### Changed
- **Major Update**: Project Time DB Control Rule upgraded to v2.0
- Mandatory workflow sequence: start → control → end
- Enhanced command documentation with examples
- Added sprint number error correction procedures

### Added
- Detailed command reference for project_time_db.py
- show_last_10_days.py script documentation
- fix_sprint_numbers.py usage guidelines
- Complete workflow examples for daily operations

### Improved
- Consistency of project data tracking
- Automatic file naming generation
- Real-time work tracking accuracy
- Sprint/day numbering problem detection

## [1.8.10] - 2025-07-05

### Added
- **CRITICAL**: Mandatory rule to create project_time_registry record as first step of each day
- New section "🚨 ПЕРВЫЙ ШАГ КАЖДОГО ДНЯ - СОЗДАНИЕ ЗАПИСИ В БД" in documentation
- Warning: БЕЗ ЗАПИСИ В БД = ДЕНЬ НЕ СУЩЕСТВУЕТ!

### Changed
- Updated `.cursorrules` to version 1.8.10
- Updated `productmanager.mdc` to version 1.4.2
- Enhanced day start procedures

### Fixed
- Calendar date drift issue when DB record is not created at day start
- Day 146 record corrected with proper date (2025-07-05) and sprint info

## [1.8.4] - 2025-07-01

### Fixed
- **Critical**: Clarified time tracking terminology
  - Условные дни (conditional days) - internal project numbering (Day 1, 2, 3, ..., 101, 102...)
  - Календарные дни (calendar days) - actual days from project start June 21, 2025
  - Clarified that there is NO mathematical relationship between these two systems
  - Calendar days must be calculated programmatically

### Changed
- Updated `.cursorrules` with correct time calculation system
- Updated `productmanager.mdc` with time tracking terminology section
- Fixed all references to use proper terminology

### Added
- Examples of correct time tracking usage in reports
- Python code example for calendar day calculation

## [1.8.3] - 2025-06-30

### Added
- LLM agent automation for standard actions
- Automatic execution without user confirmation for routine tasks
- User approval required only for critical changes

## [1.8.2] - 2025-06-30

### Added
- Complete time tracking system integration
- Automatic report creation with time metrics
- JSON storage for project time history
- Project statistics and analytics support

## [1.8.0] - 2025-06-30

### Added
- **Comprehensive Cursor Rules System** - 7 specialized `.mdc` files for different development aspects
  - `architecture.mdc` - Clean Architecture, SOLID, DDD principles
  - `ui-guidelines.mdc` - SwiftUI, Apple HIG, Accessibility, Design Tokens
  - `testing.mdc` - TDD/BDD with Gherkin scenarios
  - `naming-and-structure.mdc` - Swift conventions and project organization
  - `client-server-integration.mdc` - API contracts, DTOs, network layer
  - `ci-cd-review.mdc` - CI/CD pipeline, code review, Conventional Commits
  - `ai-interaction.mdc` - AI security, responsible usage, best practices
- **BDD/ATDD Framework** integration with Gherkin scenarios
- **AI Security Guidelines** for data protection and code validation
- **Design System** with centralized tokens and theming
- **Enhanced CI/CD** with SwiftLint, SonarCloud, security scanning
- **Network Layer Standards** including offline support and interceptors

### Changed
- Significantly expanded `ai-interaction.mdc` with security focus
- Updated architecture guidelines with DTOs and Mappers
- Enhanced testing approach with BDD scenarios
- Improved CI/CD pipeline with quality gates

### Security
- Added data anonymization requirements for AI interactions
- Implemented AI code validation process
- Added emergency procedures for security incidents
- Mandated security scanning in CI/CD

## [1.7.1] - 2025-06-29

### Added
- Feedback System best practices
- Sprint 12 completion documentation

## [1.7.0] - 2025-06-28

### Added
- Feature Registry Framework for module management
- Automatic navigation registration
- Integration testing requirements

## [1.6.0] - 2025-06-27

### Added
- Central methodology repository synchronization
- Enhanced "обнови методологию" command

## [1.5.0] - 2025-06-26

### Added
- Feedback System design and implementation

## [1.4.0] - 2025-06-25

### Fixed
- Report locations standardization
- Folder structure improvements

## [1.3.0] - 2025-01-19

### Added
- Automatic methodology synchronization between projects
- `sync-methodology.sh` script for bi-directional sync
- Central repository setup at `/Users/ishirokov/lms_docs/cursor_tdd_methodology`
- AI command "обнови методологию" for automatic updates
- Makefile commands: `sync-methodology-push`, `sync-methodology-pull`, `update-methodology`
- `METHODOLOGY_SYNC.md` documentation
- `METHODOLOGY_UPDATE_v1.3.0.md` with detailed changes

### Changed
- Updated `.cursorrules` with synchronization instructions
- Enhanced AI behavior for methodology updates
- Improved version management across projects

### Benefits
- Unified methodology across all projects
- Easy propagation of improvements
- Version history and tracking
- Automated synchronization workflow

## [1.2.0] - 2025-06-22

### Added
- ⚡ **Quick Test Execution** - New `test-quick.sh` script for ultra-fast test runs (5-10 seconds)
- 📝 Enhanced documentation with quick test sections in all major files
- 🚀 Universal test runner supporting PHP, JavaScript, and Python projects
- 📊 Performance metrics showing 95% time reduction

### Changed
- Updated `.cursorrules` with mandatory quick test section
- Enhanced `TDD_GUIDE.md` with quick test workflow
- Modified `productmanager.md` to require test-quick.sh in DoD
- Improved all code examples to use quick test execution

### Fixed
- Slow feedback loop in TDD cycle (was 2-3 minutes, now 5-10 seconds)
- Docker build overhead for simple test runs
- Platform-specific test setup complexities

## [1.1.0] - 2025-01-19

### Added
- Product Manager methodology (`productmanager.md`)
- Mandatory methodology update rules
- LLM-specific development requirements
- Enhanced `.cursorrules` with AI assistant guidelines

### Changed
- Improved documentation structure
- Added version tracking requirements
- Enhanced antipatterns documentation

## [1.0.0] - 2025-01-19

### Added
- Initial TDD methodology release
- Universal Makefile for multi-language support
- Test templates for PHP, JavaScript, Python
- Git hooks for pre-commit testing
- CI/CD examples
- Comprehensive antipatterns guide
- Quick start documentation 