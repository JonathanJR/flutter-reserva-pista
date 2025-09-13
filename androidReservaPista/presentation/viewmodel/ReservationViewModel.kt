package com.jonathandevapps.reservapistagilena.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.jonathandevapps.reservapistagilena.domain.core.uistates.ReservationUiState
import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.core.uistates.UiState
import com.jonathandevapps.reservapistagilena.domain.repository.TimeSlot
import com.jonathandevapps.reservapistagilena.domain.usecase.reservation.CancelReservationUseCase
import com.jonathandevapps.reservapistagilena.domain.usecase.reservation.CreateReservationUseCase
import com.jonathandevapps.reservapistagilena.domain.usecase.reservation.GetAvailableSlotsUseCase
import com.jonathandevapps.reservapistagilena.domain.usecase.reservation.GetUserReservationsUseCase
import com.jonathandevapps.reservapistagilena.domain.usecase.reservation.RefreshAllReservationsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock
import kotlinx.datetime.LocalDate
import kotlinx.datetime.LocalTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import javax.inject.Inject

/**
 * ViewModel for reservation management
 * Handles court reservations, slot availability, and user reservations
 */
@HiltViewModel
class ReservationViewModel @Inject constructor(
    private val createReservationUseCase: CreateReservationUseCase,
    private val cancelReservationUseCase: CancelReservationUseCase,
    private val getAvailableSlotsUseCase: GetAvailableSlotsUseCase,
    private val getUserReservationsUseCase: GetUserReservationsUseCase,
    private val refreshAllReservationsUseCase: RefreshAllReservationsUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(ReservationUiState.idle())
    val uiState: StateFlow<ReservationUiState> = _uiState.asStateFlow()
    
    init {
        initializeReservations()
    }

    /**
     * Loads available slots for a specific court and date
     * Filters out past time slots for current date
     */
    fun loadAvailableSlots(courtId: String, date: LocalDate) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(
                availableSlotsState = UiState.Loading,
                selectedDate = date
            )

            // Refresh reservations to get latest data
            refreshAllReservationsUseCase()

            when (val result = getAvailableSlotsUseCase(courtId, date)) {
                is Result.Success -> {
                    val filteredSlots = filterAvailableSlots(result.data, date)
                    _uiState.value = _uiState.value.copy(
                        availableSlotsState = UiState.Success(filteredSlots)
                    )
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        availableSlotsState = UiState.Error(result.error.message)
                    )
                }
            }
        }
    }

    /**
     * Selects a time slot for reservation
     */
    fun selectTimeSlot(timeSlot: TimeSlot) {
        _uiState.value = _uiState.value.copy(selectedTimeSlot = timeSlot)
    }

    /**
     * Creates a new reservation for the specified court, date and time
     */
    fun createReservation(courtId: String, date: LocalDate, startTime: LocalTime) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(
                createReservationState = UiState.Loading
            )

            when (val result = createReservationUseCase(courtId, date, startTime)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        createReservationState = UiState.Success(result.data),
                        successMessage = "Reservation created successfully",
                        selectedTimeSlot = null
                    )
                    // Refresh available slots after successful creation
                    loadAvailableSlots(courtId, date)
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        createReservationState = UiState.Error(result.error.message)
                    )
                }
            }
        }
    }

    /**
     * Cancels an existing reservation
     */
    fun cancelReservation(reservationId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(
                cancelReservationState = UiState.Loading
            )

            when (val result = cancelReservationUseCase(reservationId)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        cancelReservationState = UiState.Success(Unit),
                        successMessage = "Reservation cancelled successfully"
                    )
                    // Refresh user reservations after successful cancellation
                    loadUserReservations()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        cancelReservationState = UiState.Error(result.error.message)
                    )
                }
            }
        }
    }

    /**
     * Loads current user's reservations
     */
    fun loadUserReservations() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(
                reservationsState = UiState.Loading
            )

            // Refresh data from remote source
            try {
                refreshAllReservationsUseCase()
            } catch (_: Exception) { 
                // Continue with local data if refresh fails
            }

            when (val result = getUserReservationsUseCase()) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        reservationsState = UiState.Success(result.data)
                    )
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        reservationsState = UiState.Error(result.error.message)
                    )
                }
            }
        }
    }

    /**
     * Clears all UI messages (success and error)
     */
    fun clearMessages() {
        _uiState.value = _uiState.value.copy(
            reservationsState = if (_uiState.value.reservationsState is UiState.Error) UiState.Idle else _uiState.value.reservationsState,
            availableSlotsState = if (_uiState.value.availableSlotsState is UiState.Error) UiState.Idle else _uiState.value.availableSlotsState,
            createReservationState = if (_uiState.value.createReservationState is UiState.Error) UiState.Idle else _uiState.value.createReservationState,
            cancelReservationState = if (_uiState.value.cancelReservationState is UiState.Error) UiState.Idle else _uiState.value.cancelReservationState,
            successMessage = null
        )
    }

    /**
     * Clears all selection state
     */
    fun clearSelection() {
        _uiState.value = _uiState.value.copy(
            selectedTimeSlot = null,
            selectedDate = null,
            selectedCourt = null
        )
    }

    /**
     * Gets available dates for booking (excludes weekends and past dates)
     */
    fun getAvailableDates(): List<LocalDate> {
        val dates = mutableListOf<LocalDate>()
        val currentDateTime = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault())
        var currentDate = currentDateTime.date
        var daysAdded = 0
        
        // Skip today if no slots are available due to time constraints
        if (!hasAvailableSlotsForToday(currentDateTime)) {
            currentDate = LocalDate.fromEpochDays(currentDate.toEpochDays() + 1)
        }

        // Generate next 7 business days
        while (daysAdded < MAX_BOOKING_DAYS) {
            if (isBusinessDay(currentDate)) {
                dates.add(currentDate)
                daysAdded++
            }
            currentDate = LocalDate.fromEpochDays(currentDate.toEpochDays() + 1)
        }

        return dates
    }

    /**
     * Generates all possible time slots for a day
     */
    fun generateTimeSlots(): List<TimeSlot> {
        val slots = mutableListOf<TimeSlot>()
        
        // Morning slots
        slots.addAll(generateSlotsForPeriod(MORNING_START, MORNING_END))
        
        // Afternoon slots
        slots.addAll(generateSlotsForPeriod(AFTERNOON_START, AFTERNOON_END))
        
        return slots
    }

    // Private helper methods

    /**
     * Initializes reservations on ViewModel creation
     */
    private fun initializeReservations() {
        viewModelScope.launch {
            try {
                refreshAllReservationsUseCase()
            } catch (_: Exception) {
                // Silently handle initialization errors
            }
        }
    }

    /**
     * Filters available slots based on current time for today's date
     */
    private fun filterAvailableSlots(slots: List<TimeSlot>, date: LocalDate): List<TimeSlot> {
        val currentDateTime = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault())
        val currentDate = currentDateTime.date
        
        return if (date == currentDate) {
            val currentTimeMinutes = currentDateTime.time.hour * 60 + currentDateTime.time.minute
            val withMarginMinutes = currentTimeMinutes + TIME_MARGIN_MINUTES
            
            if (withMarginMinutes >= 24 * 60) {
                emptyList()
            } else {
                val currentTimeWithMargin = LocalTime(
                    hour = withMarginMinutes / 60,
                    minute = withMarginMinutes % 60
                )
                
                slots.filter { slot ->
                    slot.startTime > currentTimeWithMargin
                }
            }
        } else {
            slots
        }
    }

    /**
     * Checks if there are available slots for today considering time constraints
     */
    private fun hasAvailableSlotsForToday(currentDateTime: kotlinx.datetime.LocalDateTime): Boolean {
        val currentTimeMinutes = currentDateTime.time.hour * 60 + currentDateTime.time.minute
        val withMarginMinutes = currentTimeMinutes + TIME_MARGIN_MINUTES
        
        if (withMarginMinutes >= 24 * 60) return false
        
        val currentTimeWithMargin = LocalTime(
            hour = withMarginMinutes / 60,
            minute = withMarginMinutes % 60
        )
        
        val allSlots = generateTimeSlots()
        return allSlots.any { slot -> slot.startTime > currentTimeWithMargin }
    }

    /**
     * Checks if a given date is a business day (not weekend)
     */
    private fun isBusinessDay(date: LocalDate): Boolean {
        return date.dayOfWeek.value !in 6..7
    }

    /**
     * Generates time slots for a given period
     */
    private fun generateSlotsForPeriod(startTime: LocalTime, endTime: LocalTime): List<TimeSlot> {
        val slots = mutableListOf<TimeSlot>()
        var currentTime = startTime
        
        while (currentTime < endTime) {
            val totalMinutes = currentTime.hour * 60 + currentTime.minute + SLOT_DURATION_MINUTES
            val slotEndTime = LocalTime(
                hour = totalMinutes / 60,
                minute = totalMinutes % 60
            )
            
            slots.add(TimeSlot(currentTime, slotEndTime, true))
            
            currentTime = slotEndTime
        }
        
        return slots
    }

    companion object {
        private const val SLOT_DURATION_MINUTES = 90
        private const val TIME_MARGIN_MINUTES = 30
        private const val MAX_BOOKING_DAYS = 7
        
        // Business hours
        private val MORNING_START = LocalTime(10, 0)
        private val MORNING_END = LocalTime(14, 30)
        private val AFTERNOON_START = LocalTime(16, 0)
        private val AFTERNOON_END = LocalTime(21, 0)
    }
} 