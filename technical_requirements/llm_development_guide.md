## File Size Limits

### Optimal for LLM:
- **Best**: 50-150 lines per file
- **Good**: 150-300 lines per file  
- **Needs refactoring**: > 300 lines
- **Critical for LLM**: > 500 lines

### Current violations:
- User.php (677 lines) - needs splitting
- LdapService.php (654 lines) - needs splitting
- AuthService.php (584 lines) - needs splitting

### Refactoring strategies:
1. Extract traits for related behavior
2. Create specialized services (Single Responsibility)
3. Use composition over inheritance
4. Keep test files under 400 lines

## Modular Structure 