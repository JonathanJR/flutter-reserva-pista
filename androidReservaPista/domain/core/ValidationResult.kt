package com.jonathandevapps.reservapistagilena.domain.core

/**
 * Represents the result of a validation operation
 */
sealed class ValidationResult {
    object Valid : ValidationResult()
    data class Invalid(val message: String) : ValidationResult()
    
    val isValid: Boolean
        get() = this is Valid
        
    val errorMessage: String?
        get() = (this as? Invalid)?.message
} 