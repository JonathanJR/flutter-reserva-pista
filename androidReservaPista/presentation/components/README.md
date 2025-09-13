# Presentation Components - Form Validation & Pull-to-Refresh

## Form Validation Components

### Overview
This directory contains streamlined form validation components that provide automatic, debounced validation with excellent UX.

### Available Hooks

#### `rememberFormFieldState()`
**The main validation hook** - Handles all standard validation types.
```kotlin
val emailState = rememberFormFieldState(validationType = ValidationType.EMAIL)
val passwordState = rememberFormFieldState(validationType = ValidationType.PASSWORD)
val nameState = rememberFormFieldState(validationType = ValidationType.NAME)
```

#### `rememberPasswordConfirmationState()`
**Special hook for password confirmation** - Compares against another password field.
```kotlin
val confirmPasswordState = rememberPasswordConfirmationState(passwordState.value)
```

### Usage Examples

#### Login Form
```kotlin
@Composable
fun LoginForm() {
    val emailState = rememberFormFieldState(validationType = ValidationType.EMAIL)
    val passwordState = rememberFormFieldState(validationType = ValidationType.PASSWORD)
    
    EmailTextField(
        value = emailState.value,
        onValueChange = emailState.onValueChange,
        isError = !emailState.isValid && emailState.value.isNotBlank(),
        errorMessage = emailState.errorMessage
    )
    
    PasswordTextField(
        value = passwordState.value,
        onValueChange = passwordState.onValueChange,
        isError = !passwordState.isValid && passwordState.value.isNotBlank(),
        errorMessage = passwordState.errorMessage,
        // ... other props
    )
}
```

#### Registration Form with Password Confirmation
```kotlin
@Composable
fun RegistrationForm() {
    val nameState = rememberFormFieldState(validationType = ValidationType.NAME)
    val emailState = rememberFormFieldState(validationType = ValidationType.EMAIL)
    val passwordState = rememberFormFieldState(validationType = ValidationType.PASSWORD)
    val confirmPasswordState = rememberPasswordConfirmationState(passwordState.value)
    
    // Use in UI components...
}
```

### Features

- **Debounced Validation**: 300ms delay prevents excessive validation calls
- **Type Safety**: ValidationResult sealed class ensures safe error handling
- **Automatic State Management**: No manual state tracking needed
- **Reusable**: Works with any TextField component
- **Extensible**: Easy to add new validation types

## Pull-to-Refresh Integration

### CourtViewModel.refreshCourts()
The `refreshCourts()` method in CourtViewModel was previously unused. It's now integrated into:

- **HomeScreen**: Pull down to refresh sport types and court availability
- **OptionsScreen**: Pull down to refresh court list for specific sport

### Implementation Details

#### Material3 Pull-to-Refresh
Uses the latest Material3 `PullToRefreshContainer` and `rememberPullToRefreshState()`:

```kotlin
val pullToRefreshState = rememberPullToRefreshState()
val isRefreshing = courtState.refreshState.isLoading

LaunchedEffect(pullToRefreshState.isRefreshing) {
    if (pullToRefreshState.isRefreshing) {
        courtViewModel.refreshCourts()
    }
}
```

#### Benefits
- **Better UX**: Users can manually refresh court data
- **Real-time Updates**: Fresh data on user action
- **Visual Feedback**: Loading indicator during refresh
- **Seamless Integration**: Works with existing court loading

### Files Modified

1. **FormValidationComponents.kt**
   - Simplified to use only `rememberFormFieldState()` and `rememberPasswordConfirmationState()`
   - Removed redundant specialized hooks
   - Fixed ValidationResult usage and improved error handling

2. **LoginScreen.kt** & **RegisterScreen.kt**
   - Migrated to unified validation hook with ValidationType parameters
   - Cleaner, more consistent validation approach

3. **HomeScreen.kt** & **OptionsScreen.kt**
   - Updated to use correct `PullToRefreshBox` component
   - Simplified pull-to-refresh implementation
   - Integrated with CourtViewModel.refreshCourts()

### Migration Guide

#### From Manual Validation
```kotlin
// Before ❌
var email by remember { mutableStateOf("") }
val emailError = viewModel.validateEmail(email) // Method doesn't exist!

// After ✅  
val emailState = rememberFormFieldState(validationType = ValidationType.EMAIL)
// Automatic validation with debouncing
```

#### From Basic TextField to Form Components
```kotlin
// Before ❌
OutlinedTextField(
    value = email,
    onValueChange = { email = it },
    isError = emailError != null,
    // Manual error handling...
)

// After ✅
EmailTextField(
    value = emailState.value,
    onValueChange = emailState.onValueChange,
    isError = !emailState.isValid && emailState.value.isNotBlank(),
    errorMessage = emailState.errorMessage
)
```

### Best Practices

1. **Validation Types**
   - Use `ValidationType.EMAIL` for email fields
   - Use `ValidationType.PASSWORD` for password fields
   - Use `ValidationType.NAME` for name/text fields
   - Use `rememberPasswordConfirmationState()` for password confirmation

2. **Error Display**
   - Only show errors when field has content: `!state.isValid && state.value.isNotBlank()`
   - This prevents showing errors on empty fields

3. **Form Validation**
   - Combine all field states for overall form validity
   - Check both `isValid` and `isNotBlank()` for required fields
   ```kotlin
   val isFormValid = emailState.isValid && passwordState.isValid &&
                    emailState.value.isNotBlank() && passwordState.value.isNotBlank()
   ```

4. **Pull-to-Refresh**
   - Use in screens where users expect fresh data
   - Integrate with existing loading states
   - Provide visual feedback during refresh 