package com.jonathandevapps.reservapistagilena.presentation.components

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import com.jonathandevapps.reservapistagilena.domain.core.UserInputValidator
import com.jonathandevapps.reservapistagilena.domain.core.ValidationResult
import kotlinx.coroutines.delay

/**
 * Data class to hold form validation state
 */
data class FormFieldState(
    val value: String = "",
    val errorMessage: String? = null,
    val isValid: Boolean = true,
    val onValueChange: (String) -> Unit = {}
) {
    val hasError: Boolean get() = errorMessage != null
}

/**
 * Hook for managing form field state with debounced validation
 * Generalized version that can be used for any validation type
 */
@Composable
fun rememberFormFieldState(
    initialValue: String = "",
    validator: UserInputValidator = UserInputValidator(),
    validationType: ValidationType,
    debounceMs: Long = 300L
): FormFieldState {
    var value by remember { mutableStateOf(initialValue) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var isValid by remember { mutableStateOf(true) }
    
    val onValueChange: (String) -> Unit = { newValue ->
        value = newValue
    }
    
    // Debounced validation
    LaunchedEffect(value) {
        if (value.isNotBlank()) {
            delay(debounceMs)
            val validation = when (validationType) {
                ValidationType.EMAIL -> validator.validateEmail(value)
                ValidationType.PASSWORD -> validator.validatePassword(value)
                ValidationType.NAME -> validator.validateName(value)
            }
            
            errorMessage = when (validation) {
                is ValidationResult.Valid -> null
                is ValidationResult.Invalid -> validation.message
            }
            isValid = validation is ValidationResult.Valid
        } else {
            errorMessage = null
            isValid = true
        }
    }
    
    return FormFieldState(
        value = value,
        errorMessage = errorMessage,
        isValid = isValid,
        onValueChange = onValueChange
    )
}



/**
 * Validation types for form fields
 */
enum class ValidationType {
    EMAIL, PASSWORD, NAME
}

/**
 * Hook for password confirmation validation
 */
@Composable
fun rememberPasswordConfirmationState(
    password: String,
    initialValue: String = "",
    debounceMs: Long = 300L
): FormFieldState {
    val validator = UserInputValidator()
    var value by remember { mutableStateOf(initialValue) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var isValid by remember { mutableStateOf(true) }
    
    val onValueChange: (String) -> Unit = { newValue ->
        value = newValue
    }
    
    // Debounced validation
    LaunchedEffect(password, value) {
        if (value.isNotBlank()) {
            delay(debounceMs)
            val validation = validator.validatePasswordMatch(password, value)
            errorMessage = when (validation) {
                is ValidationResult.Valid -> null
                is ValidationResult.Invalid -> validation.message
            }
            isValid = validation is ValidationResult.Valid
        } else {
            errorMessage = null
            isValid = true
        }
    }
    
    return FormFieldState(
        value = value,
        errorMessage = errorMessage,
        isValid = isValid,
        onValueChange = onValueChange
    )
} 