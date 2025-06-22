# TDD Methodology Version

## Current Version: 1.3.0
**Release Date:** 2025-01-19

## What's New in 1.3.0
- Added automatic methodology synchronization between projects
- New command "обнови методологию" for AI-driven updates
- Central repository for methodology at `/Users/ishirokov/lms_docs/cursor_tdd_methodology`
- sync-methodology.sh script for manual synchronization
- Makefile commands for easy sync operations

## Version History

### 1.3.0 (2025-01-19)
- Automatic methodology synchronization
- Central repository setup
- AI command integration

### 1.2.0 (2025-06-22)
- Added test-quick.sh for rapid test execution
- Enhanced TDD workflow with 5-10 second feedback loop
- Updated examples for immediate test running

### 1.1.0 (2025-01-19)
- Added mandatory product manager methodology
- Implemented methodology update rules
- Strengthened test execution requirements
- Optimized for LLM development

### 1.0.0 (2025-01-18)
- Initial release
- Core TDD principles
- Antipatterns documentation
- Quick test execution guide

---

## Upgrade Instructions

### From 1.1.0 to 1.2.0:
1. Create `test-quick.sh` in your project root:
   ```bash
   cp test-quick.sh /your/project/
   chmod +x /your/project/test-quick.sh
   ```

2. Update your workflow to use quick tests:
   ```bash
   # Instead of: make test-run-specific TEST=...
   # Use: ./test-quick.sh path/to/test.php
   ```

3. Update documentation with new testing approach

### From 1.0.0 to 1.1.0:
1. Copy new files:
   ```bash
   cp productmanager.md /your/project/
   cp PRODUCT_MANAGER_GUIDE.md /your/project/
   ```

2. Update `.cursorrules` with new version

3. Review new methodology requirements

---

## Planned for Next Version (1.3.0)

- [ ] Watch mode for automatic test execution
- [ ] Coverage reports in test-quick.sh
- [ ] IDE integration guides
- [ ] Performance benchmarking tools
- [ ] Multi-language test-quick scripts

---

## Versioning Policy

We follow Semantic Versioning:
- **MAJOR**: Breaking changes in methodology
- **MINOR**: New features, backwards compatible
- **PATCH**: Bug fixes and clarifications

## How to Contribute

Found a new pattern or antipattern? 
1. Update relevant files
2. Add entry to this VERSION.md
3. Update version numbers
4. Document the change

Remember: **Continuous improvement is key!** 