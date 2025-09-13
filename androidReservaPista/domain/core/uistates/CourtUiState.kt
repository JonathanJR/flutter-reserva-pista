package com.jonathandevapps.reservapistagilena.domain.core.uistates

import com.jonathandevapps.reservapistagilena.domain.model.CourtUI

/**
 * UI state for court operations using the UiState pattern
 */
data class CourtUiState(
    val courtsState: UiState<List<CourtUI>> = UiState.Idle,
    val refreshState: UiState<Unit> = UiState.Idle
) {
    // Convenience properties
    val isLoading: Boolean get() = courtsState.isLoading || refreshState.isLoading
    val courts: List<CourtUI> get() = (courtsState as? UiState.Success)?.data ?: emptyList()
    val errorMessage: String? get() = 
        (courtsState as? UiState.Error)?.message ?: (refreshState as? UiState.Error)?.message
    
    // Derived data
    val courtsBySport: Map<String, List<CourtUI>> get() = courts.groupBy { it.courtType }
    
    companion object {
        fun loading() = CourtUiState(courtsState = UiState.Loading)
        fun refreshing(courts: List<CourtUI>) = CourtUiState(
            courtsState = UiState.Success(courts),
            refreshState = UiState.Loading
        )
        fun success(courts: List<CourtUI>) = CourtUiState(
            courtsState = UiState.Success(courts),
            refreshState = UiState.Idle
        )
        fun error(message: String) = CourtUiState(
            courtsState = UiState.Error(message)
        )
    }
}

/**
 * Information about a sport type for display purposes
 */
data class SportTypeInfo(
    val type: String,
    val title: String,
    val isAvailable: Boolean = true
) 