package com.jonathandevapps.reservapistagilena.domain.repository

import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.model.UserUI
import kotlinx.coroutines.flow.Flow

interface UserRepository {
    suspend fun registerUser(fullName: String, email: String, password: String): Result<UserUI>
    suspend fun loginUser(email: String, password: String): Result<UserUI>
    suspend fun getCurrentUser(): Result<UserUI?>
    suspend fun updateUserProfile(userId: String, fullName: String): Result<UserUI>
    suspend fun logoutUser(): Result<Unit>
    suspend fun isUserAuthenticated(): Boolean
    fun getCurrentUserFlow(): Flow<UserUI?>
    suspend fun deleteUserAccount(userId: String): Result<Unit>
} 