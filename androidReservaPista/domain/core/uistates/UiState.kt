package com.jonathandevapps.reservapistagilena.domain.core.uistates

import com.jonathandevapps.reservapistagilena.domain.model.UserUI

/**
 * Generic UI state wrapper that provides consistent state management across the app
 */
sealed class UiState<out T> {
    object Loading : UiState<Nothing>()
    object Idle : UiState<Nothing>()
    data class Success<T>(val data: T) : UiState<T>()
    data class Error(val message: String) : UiState<Nothing>()
    
    val isLoading: Boolean get() = this is Loading
    val isSuccess: Boolean get() = this is Success
    val isError: Boolean get() = this is Error
    val isIdle: Boolean get() = this is Idle
}

/**
 * Enhanced AuthUiState using the improved state management pattern
 */
data class AuthUiState(
    val authenticationState: UiState<UserUI> = UiState.Idle,
    val currentUser: UserUI? = null,
    val isAuthenticated: Boolean = false,
    val isInitializing: Boolean = true,
    val successMessage: String? = null
) {
    val isLoading: Boolean get() = authenticationState.isLoading
    val errorMessage: String? get() = (authenticationState as? UiState.Error)?.message
    
    companion object {
        fun loading() = AuthUiState(authenticationState = UiState.Loading)
        fun success(user: UserUI) = AuthUiState(
            authenticationState = UiState.Success(user),
            currentUser = user,
            isAuthenticated = true,
            isInitializing = false
        )
        fun error(message: String) = AuthUiState(
            authenticationState = UiState.Error(message),
            isInitializing = false
        )
        fun idle() = AuthUiState(authenticationState = UiState.Idle, isInitializing = false)
    }
}

/**
 * Extension function to handle common UI state patterns
 */
fun <T> UiState<T>.onLoading(action: () -> Unit): UiState<T> {
    if (this is UiState.Loading) action()
    return this
}

fun <T> UiState<T>.onSuccess(action: (T) -> Unit): UiState<T> {
    if (this is UiState.Success) action(data)
    return this
}

fun <T> UiState<T>.onError(action: (String) -> Unit): UiState<T> {
    if (this is UiState.Error) action(message)
    return this
} 