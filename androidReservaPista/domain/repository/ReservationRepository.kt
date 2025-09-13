package com.jonathandevapps.reservapistagilena.domain.repository

import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.model.ReservationUI
import kotlinx.coroutines.flow.Flow
import kotlinx.datetime.LocalDate
import kotlinx.datetime.LocalTime

data class TimeSlot(
    val startTime: LocalTime,
    val endTime: LocalTime,
    val isAvailable: Boolean
)

interface ReservationRepository {
    suspend fun createReservation(
        courtId: String,
        date: LocalDate,
        startTime: LocalTime
    ): Result<ReservationUI>

    suspend fun cancelReservation(reservationId: String): Result<Unit>

    suspend fun getUserReservations(userId: String): Result<List<ReservationUI>>

    suspend fun getUserActiveReservations(userId: String): Result<List<ReservationUI>>

    suspend fun getUserReservationHistory(userId: String): Result<List<ReservationUI>>

    suspend fun getAvailableSlots(courtId: String, date: LocalDate): Result<List<TimeSlot>>

    suspend fun isSlotAvailable(
        courtId: String,
        date: LocalDate,
        startTime: LocalTime
    ): Result<Boolean>

    suspend fun validateReservation(
        userId: String,
        courtId: String,
        date: LocalDate,
        startTime: LocalTime
    ): Result<Unit>

    fun getUserReservationsFlow(userId: String): Flow<List<ReservationUI>>

    suspend fun refreshReservations(): Result<Unit>

    suspend fun refreshAllReservations(): Result<Unit>

    suspend fun getReservationById(reservationId: String): Result<ReservationUI>
} 