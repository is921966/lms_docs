# Changelog

All notable changes to the TDD Methodology will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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