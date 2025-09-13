package com.jonathandevapps.reservapistagilena.domain.usecase.user

import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.model.UserUI
import com.jonathandevapps.reservapistagilena.domain.repository.UserRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

/**
 * Use case for managing current user authentication state
 * Provides reactive user state management
 */
class GetCurrentUserStateUseCase @Inject constructor(
    private val userRepository: UserRepository
) {
    
    /**
     * Gets the current user as a Flow for reactive updates
     */
    fun getCurrentUserFlow(): Flow<UserUI?> = userRepository.getCurrentUserFlow()
    
    /**
     * Checks if user is currently authenticated
     */
    suspend fun isUserAuthenticated(): Boolean = userRepository.isUserAuthenticated()
    
    /**
     * Gets current user with proper error handling
     */
    suspend fun getCurrentUser(): Result<UserUI?> = userRepository.getCurrentUser()
    
    /**
     * Creates a flow that indicates authentication status
     */
    fun getAuthenticationStatusFlow(): Flow<Boolean> = 
        userRepository.getCurrentUserFlow().map { it != null }
} 