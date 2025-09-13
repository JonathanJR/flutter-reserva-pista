package com.jonathandevapps.reservapistagilena.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.jonathandevapps.reservapistagilena.domain.core.uistates.CourtUiState
import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.core.uistates.SportTypeInfo
import com.jonathandevapps.reservapistagilena.domain.model.CourtUI
import com.jonathandevapps.reservapistagilena.domain.model.SportType
import com.jonathandevapps.reservapistagilena.domain.repository.CourtRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * ViewModel for managing court data and sport type information
 * Handles court loading, refresh operations, and sport type categorization
 */
@HiltViewModel
class CourtViewModel @Inject constructor(
    private val courtRepository: CourtRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(CourtUiState.loading())
    val uiState: StateFlow<CourtUiState> = _uiState.asStateFlow()

    init {
        loadCourts()
    }

    /**
     * Loads all courts from repository with refresh
     */
    fun loadCourts() {
        viewModelScope.launch {
            _uiState.value = CourtUiState.loading()

            try {
                // First try to refresh from remote source
                when (val refreshResult = courtRepository.refreshCourts()) {
                    is Result.Success -> {
                        // Refresh successful, now get local data
                        loadCourtsFromLocal()
                    }
                    is Result.Error -> {
                        // Refresh failed, still try to load local data
                        loadCourtsFromLocal()
                    }
                }
            } catch (e: Exception) {
                // Network error, try to load local data
                loadCourtsFromLocal()
            }
        }
    }

    /**
     * Refreshes courts data from remote source
     */
    fun refreshCourts() {
        viewModelScope.launch {
            val currentCourts = _uiState.value.courts
            _uiState.value = CourtUiState.refreshing(currentCourts)
            
            when (val result = courtRepository.refreshCourts()) {
                is Result.Success -> {
                    loadCourtsFromLocal()
                }
                is Result.Error -> {
                    _uiState.value = CourtUiState.error(result.error.message)
                }
            }
        }
    }

    /**
     * Gets courts filtered by sport type
     */
    fun getCourtsBySportType(sportType: String): List<CourtUI> {
        return _uiState.value.courtsBySport[sportType] ?: emptyList()
    }

    /**
     * Gets available sport types with availability information
     */
    fun getSportTypes(): List<SportTypeInfo> {
        return SportType.entries
            .map { sportType ->
                SportTypeInfo(
                    type = sportType.id,
                    title = sportType.displayName,
                    isAvailable = getCourtsBySportType(sportType.id).isNotEmpty()
                )
            }
    }

    /**
     * Loads courts from local database
     */
    private suspend fun loadCourtsFromLocal() {
        when (val result = courtRepository.getAllCourts()) {
            is Result.Success -> {
                _uiState.value = CourtUiState.success(result.data)
            }
            is Result.Error -> {
                _uiState.value = CourtUiState.error(result.error.message)
            }
        }
    }
} 