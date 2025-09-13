package com.jonathandevapps.reservapistagilena.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.jonathandevapps.reservapistagilena.domain.core.uistates.AuthUiState
import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.core.UIMessages
import com.jonathandevapps.reservapistagilena.domain.core.uistates.UiState
import com.jonathandevapps.reservapistagilena.domain.repository.UserRepository
import com.jonathandevapps.reservapistagilena.domain.usecase.user.GetCurrentUserStateUseCase
import com.jonathandevapps.reservapistagilena.domain.usecase.user.LoginUserUseCase
import com.jonathandevapps.reservapistagilena.domain.usecase.user.RegisterUserUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * ViewModel for authentication operations
 * Follows MVVM pattern with clear separation of concerns
 */
@HiltViewModel
class AuthViewModel @Inject constructor(
    private val loginUserUseCase: LoginUserUseCase,
    private val registerUserUseCase: RegisterUserUseCase,
    private val getCurrentUserStateUseCase: GetCurrentUserStateUseCase,
    private val userRepository: UserRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    init {
        observeUserAuthenticationState()
    }

    /**
     * Attempts to log in user with provided credentials
     */
    fun login(email: String, password: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.loading()

            when (val result = loginUserUseCase(email, password)) {
                is Result.Success -> {
                    _uiState.value = AuthUiState.success(result.data).copy(
                        successMessage = UIMessages.LOGIN_SUCCESS
                    )
                }
                is Result.Error -> {
                    _uiState.value = AuthUiState.error(result.error.message)
                }
            }
        }
    }

    /**
     * Attempts to register a new user with provided information
     */
    fun register(name: String, email: String, password: String, confirmPassword: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.loading()

            when (val result = registerUserUseCase(name, email, password, confirmPassword)) {
                is Result.Success -> {
                    _uiState.value = AuthUiState.success(result.data).copy(
                        successMessage = UIMessages.REGISTRATION_SUCCESS
                    )
                }
                is Result.Error -> {
                    _uiState.value = AuthUiState.error(result.error.message)
                }
            }
        }
    }

    /**
     * Updates the current user's profile information
     */
    fun updateUserProfile(newName: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.loading()

            val currentUser = _uiState.value.currentUser
            if (currentUser != null) {
                when (val result = userRepository.updateUserProfile(currentUser.id, newName)) {
                    is Result.Success -> {
                        _uiState.value = AuthUiState.success(result.data).copy(
                            successMessage = UIMessages.PROFILE_UPDATE_SUCCESS
                        )
                    }
                    is Result.Error -> {
                        _uiState.value = AuthUiState.error(
                            result.error.message ?: UIMessages.PROFILE_UPDATE_FAILED
                        )
                    }
                }
            } else {
                _uiState.value = AuthUiState.error(UIMessages.NO_USER_LOGGED_IN)
            }
        }
    }

    /**
     * Logs out the current user
     */
    fun logout() {
        viewModelScope.launch {
            _uiState.value = AuthUiState.loading()
            
            when (val result = userRepository.logoutUser()) {
                is Result.Success -> {
                    _uiState.value = AuthUiState.idle()
                }
                is Result.Error -> {
                    _uiState.value = AuthUiState.error(
                        result.error.message ?: UIMessages.LOGOUT_FAILED
                    )
                }
            }
        }
    }

    /**
     * Clears any error messages from the UI state
     */
    fun clearError() {
        val currentState = _uiState.value
        _uiState.value = currentState.copy(
            authenticationState = UiState.Idle
        )
    }

    /**
     * Clears any success messages from the UI state
     */
    fun clearSuccess() {
        val currentState = _uiState.value
        _uiState.value = currentState.copy(successMessage = null)
    }

    /**
     * Observes user authentication state reactively using flows
     * This provides real-time updates when user auth status changes
     */
    private fun observeUserAuthenticationState() {
        // Observe authentication status and current user reactively
        combine(
            getCurrentUserStateUseCase.getAuthenticationStatusFlow(),
            getCurrentUserStateUseCase.getCurrentUserFlow()
        ) { isAuthenticated, currentUser ->
            when {
                isAuthenticated && currentUser != null -> AuthUiState.success(currentUser)
                else -> AuthUiState.idle()
            }
        }.onEach { newState ->
            // Only update if we're not in a loading state from an active operation
            if (_uiState.value.authenticationState !is UiState.Loading) {
                _uiState.value = newState
            }
        }.launchIn(viewModelScope)
    }

    /**
     * Manual check for current user state (fallback method)
     */
    private suspend fun checkCurrentUser() {
        if (getCurrentUserStateUseCase.isUserAuthenticated()) {
            when (val result = getCurrentUserStateUseCase.getCurrentUser()) {
                is Result.Success -> {
                    result.data?.let { user ->
                        _uiState.value = AuthUiState.success(user)
                    } ?: run {
                        _uiState.value = AuthUiState.idle()
                    }
                }
                is Result.Error -> {
                    _uiState.value = AuthUiState.idle()
                }
            }
        } else {
            _uiState.value = AuthUiState.idle()
        }
    }
} 