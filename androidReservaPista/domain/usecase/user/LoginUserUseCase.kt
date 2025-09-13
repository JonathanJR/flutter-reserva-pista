package com.jonathandevapps.reservapistagilena.domain.usecase.user

import com.jonathandevapps.reservapistagilena.domain.core.DomainError
import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.core.UserInputValidator
import com.jonathandevapps.reservapistagilena.domain.model.UserUI
import com.jonathandevapps.reservapistagilena.domain.repository.UserRepository
import javax.inject.Inject

/**
 * Use case for user authentication
 * Handles validation and delegates authentication to repository
 */
class LoginUserUseCase @Inject constructor(
    private val userRepository: UserRepository,
    private val validator: UserInputValidator
) {
    suspend operator fun invoke(email: String, password: String): Result<UserUI> {
        // Validate email format
        val emailValidation = validator.validateEmail(email)
        if (!emailValidation.isValid) {
            return Result.error(DomainError.AuthenticationError(emailValidation.errorMessage!!))
        }

        // Validate password
        val passwordValidation = validator.validatePassword(password)
        if (!passwordValidation.isValid) {
            return Result.error(DomainError.AuthenticationError(passwordValidation.errorMessage!!))
        }

        return userRepository.loginUser(email.trim(), password)
    }
} 