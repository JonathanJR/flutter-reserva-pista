package com.jonathandevapps.reservapistagilena.domain.core

import android.util.Patterns
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Centralized validator for user input following Domain-Driven Design principles
 */
@Singleton
class UserInputValidator @Inject constructor() {
    
    companion object {
        private const val MIN_NAME_LENGTH = 2
        private const val MIN_PASSWORD_LENGTH = 6
    }
    
    /**
     * Validates email format and requirements
     */
    fun validateEmail(email: String): ValidationResult {
        return when {
            email.isBlank() -> ValidationResult.Invalid(ValidationMessages.EMAIL_REQUIRED)
            !Patterns.EMAIL_ADDRESS.matcher(email).matches() -> 
                ValidationResult.Invalid(ValidationMessages.EMAIL_INVALID)
            else -> ValidationResult.Valid
        }
    }
    
    /**
     * Validates password strength and requirements
     */
    fun validatePassword(password: String): ValidationResult {
        return when {
            password.isBlank() -> ValidationResult.Invalid(ValidationMessages.PASSWORD_REQUIRED)
            password.length < MIN_PASSWORD_LENGTH -> 
                ValidationResult.Invalid(ValidationMessages.PASSWORD_TOO_SHORT.format(MIN_PASSWORD_LENGTH))
            else -> ValidationResult.Valid
        }
    }
    
    /**
     * Validates full name requirements
     */
    fun validateName(name: String): ValidationResult {
        return when {
            name.isBlank() -> ValidationResult.Invalid(ValidationMessages.NAME_REQUIRED)
            name.length < MIN_NAME_LENGTH -> 
                ValidationResult.Invalid(ValidationMessages.NAME_TOO_SHORT.format(MIN_NAME_LENGTH))
            else -> ValidationResult.Valid
        }
    }
    
    /**
     * Validates password confirmation match
     */
    fun validatePasswordMatch(password: String, confirmPassword: String): ValidationResult {
        return if (password != confirmPassword) {
            ValidationResult.Invalid(ValidationMessages.PASSWORDS_NOT_MATCH)
        } else {
            ValidationResult.Valid
        }
    }
    
    /**
     * Validates court ID format
     */
    fun validateCourtId(courtId: String): ValidationResult {
        return if (courtId.isBlank()) {
            ValidationResult.Invalid(ValidationMessages.INVALID_COURT_ID)
        } else {
            ValidationResult.Valid
        }
    }
} 