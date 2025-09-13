package com.jonathandevapps.reservapistagilena.domain.usecase.reservation

import com.jonathandevapps.reservapistagilena.domain.core.DomainError
import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.core.isDateWithinBookingWindow
import com.jonathandevapps.reservapistagilena.domain.repository.ReservationRepository
import com.jonathandevapps.reservapistagilena.domain.repository.TimeSlot
import kotlinx.datetime.Clock
import kotlinx.datetime.DayOfWeek
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import javax.inject.Inject

class GetAvailableSlotsUseCase @Inject constructor(
    private val reservationRepository: ReservationRepository
) {
    suspend operator fun invoke(courtId: String, date: LocalDate): Result<List<TimeSlot>> {
        if (courtId.isBlank()) {
            return Result.error(DomainError.ReservationValidationError("ID de pista inválido"))
        }

        if (date.dayOfWeek == DayOfWeek.SATURDAY || date.dayOfWeek == DayOfWeek.SUNDAY) {
            return Result.success(emptyList())
        }

        val today = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()).date
        if (date < today) {
            return Result.success(emptyList())
        }

        if (!isDateWithinBookingWindow(today, date)) {
            return Result.success(emptyList())
        }

        return reservationRepository.getAvailableSlots(courtId, date)
            .map { slots ->
                if (date == today) {
                    val currentTime = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()).time
                    slots.filter { it.startTime > currentTime }
                } else {
                    slots
                }
            }
    }
}