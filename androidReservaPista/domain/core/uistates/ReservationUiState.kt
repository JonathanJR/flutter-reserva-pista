package com.jonathandevapps.reservapistagilena.domain.core.uistates

import com.jonathandevapps.reservapistagilena.domain.model.CourtUI
import com.jonathandevapps.reservapistagilena.domain.model.ReservationUI
import com.jonathandevapps.reservapistagilena.domain.repository.TimeSlot
import kotlinx.datetime.LocalDate

/**
 * Improved UI state for reservation operations
 * Uses the UiState pattern for better state management
 */
data class ReservationUiState(
    val reservationsState: UiState<List<ReservationUI>> = UiState.Idle,
    val availableSlotsState: UiState<List<TimeSlot>> = UiState.Idle,
    val createReservationState: UiState<ReservationUI> = UiState.Idle,
    val cancelReservationState: UiState<Unit> = UiState.Idle,
    val selectedCourt: CourtUI? = null,
    val selectedDate: LocalDate? = null,
    val selectedTimeSlot: TimeSlot? = null,
    val successMessage: String? = null
) {
    // Convenience properties for checking loading states
    val isLoadingReservations: Boolean get() = reservationsState.isLoading
    val isLoadingSlots: Boolean get() = availableSlotsState.isLoading
    val isCreatingReservation: Boolean get() = createReservationState.isLoading
    val isCancellingReservation: Boolean get() = cancelReservationState.isLoading
    
    // General loading state
    val isLoading: Boolean get() = isLoadingReservations || isLoadingSlots || 
                                   isCreatingReservation || isCancellingReservation
    
    // Data accessors
    val userReservations: List<ReservationUI> get() = 
        (reservationsState as? UiState.Success)?.data ?: emptyList()
    
    val availableSlots: List<TimeSlot> get() = 
        (availableSlotsState as? UiState.Success)?.data ?: emptyList()
    
    // Error message accessor
    val errorMessage: String? get() = listOfNotNull(
        (reservationsState as? UiState.Error)?.message,
        (availableSlotsState as? UiState.Error)?.message,
        (createReservationState as? UiState.Error)?.message,
        (cancelReservationState as? UiState.Error)?.message
    ).firstOrNull()
    
    companion object {
        fun idle() = ReservationUiState()
        
        fun loadingReservations() = ReservationUiState(
            reservationsState = UiState.Loading
        )
        
        fun loadingSlots() = ReservationUiState(
            availableSlotsState = UiState.Loading
        )
        
        fun creatingReservation() = ReservationUiState(
            createReservationState = UiState.Loading
        )
        
        fun cancellingReservation() = ReservationUiState(
            cancelReservationState = UiState.Loading
        )
    }
} 