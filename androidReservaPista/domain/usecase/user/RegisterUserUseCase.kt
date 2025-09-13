package com.jonathandevapps.reservapistagilena.domain.usecase.user

import com.jonathandevapps.reservapistagilena.domain.core.DomainError
import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.core.UserInputValidator
import com.jonathandevapps.reservapistagilena.domain.model.UserUI
import com.jonathandevapps.reservapistagilena.domain.repository.UserRepository
import javax.inject.Inject

/**
 * Use case for user registration
 * Handles comprehensive validation and delegates user creation to repository
 */
class RegisterUserUseCase @Inject constructor(
    private val userRepository: UserRepository,
    private val validator: UserInputValidator
) {
    suspend operator fun invoke(
        fullName: String,
        email: String,
        password: String,
        confirmPassword: String
    ): Result<UserUI> {
        // Validate full name
        val nameValidation = validator.validateName(fullName)
        if (!nameValidation.isValid) {
            return Result.error(DomainError.AuthenticationError(nameValidation.errorMessage!!))
        }

        // Validate email
        val emailValidation = validator.validateEmail(email)
        if (!emailValidation.isValid) {
            return Result.error(DomainError.AuthenticationError(emailValidation.errorMessage!!))
        }

        // Validate password
        val passwordValidation = validator.validatePassword(password)
        if (!passwordValidation.isValid) {
            return Result.error(DomainError.AuthenticationError(passwordValidation.errorMessage!!))
        }

        // Validate password confirmation
        val passwordMatchValidation = validator.validatePasswordMatch(password, confirmPassword)
        if (!passwordMatchValidation.isValid) {
            return Result.error(DomainError.AuthenticationError(passwordMatchValidation.errorMessage!!))
        }

        return userRepository.registerUser(fullName.trim(), email.trim(), password)
    }
} 