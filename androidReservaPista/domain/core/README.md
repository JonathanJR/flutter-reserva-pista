# Domain Core Layer

This directory contains the core business logic utilities and patterns used throughout the application.

## Architecture Components

### State Management

#### `UiState<T>`
A sealed class that provides a consistent way to handle UI states across all ViewModels:
- `Idle`: Initial state
- `Loading`: Operation in progress  
- `Success<T>`: Operation completed successfully with data
- `Error`: Operation failed with error message

**Usage:**
```kotlin
val loadingState: UiState<List<User>> = UiState.Loading
val successState = UiState.Success(userList)
val errorState = UiState.Error("Failed to load users")
```

#### UI State Classes
- `AuthUiState`: Authentication-specific state management
- `ReservationUiState`: Reservation operations state management  
- `CourtUiState`: Court data state management

### Validation

#### `ValidationResult`
Sealed class for type-safe validation results:
- `Valid`: Input passes validation
- `Invalid`: Input fails with specific error message

#### `UserInputValidator`
Centralized validation logic for all user inputs:
- Email validation (format and domain)
- Password validation (length, complexity)
- Name validation (length, characters)
- Password confirmation matching
- Court ID validation

**Benefits:**
- Single source of truth for validation rules
- Consistent validation across screens
- Easy to test and maintain
- Reusable validation logic

### Constants

#### `StringConstants`
Centralized string constants to avoid hardcoding:
- `ValidationMessages`: All validation error messages
- `UIMessages`: General UI text constants

**Benefits:**
- Prevents string duplication
- Easier internationalization preparation
- Consistent messaging across app

## Design Patterns Used

1. **Sealed Classes**: For type-safe state representation
2. **Single Responsibility**: Each class has one clear purpose
3. **Dependency Injection**: All components use constructor injection
4. **Clean Architecture**: Clear separation between domain, data, and presentation

## Testing Considerations

All classes in this layer are designed to be easily testable:
- Pure functions with no side effects
- Clear input/output contracts
- No Android framework dependencies
- Mockable interfaces and dependencies 