package com.jonathandevapps.reservapistagilena.domain.usecase.reservation

import com.jonathandevapps.reservapistagilena.domain.core.DomainError
import com.jonathandevapps.reservapistagilena.domain.core.ErrorMessages
import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.core.UserInputValidator
import com.jonathandevapps.reservapistagilena.domain.core.isDateWithinBookingWindow
import com.jonathandevapps.reservapistagilena.domain.model.ReservationUI
import com.jonathandevapps.reservapistagilena.domain.repository.ReservationRepository
import com.jonathandevapps.reservapistagilena.domain.repository.UserRepository
import kotlinx.datetime.Clock
import kotlinx.datetime.DayOfWeek
import kotlinx.datetime.LocalDate
import kotlinx.datetime.LocalTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import javax.inject.Inject

/**
 * Use case for creating court reservations
 * Handles business rules validation and delegates to repository
 */
class CreateReservationUseCase @Inject constructor(
    private val reservationRepository: ReservationRepository,
    private val userRepository: UserRepository,
    private val validator: UserInputValidator
) {
    suspend operator fun invoke(
        courtId: String,
        date: LocalDate,
        startTime: LocalTime
    ): Result<ReservationUI> {
        if (!userRepository.isUserAuthenticated()) {
            return Result.error(DomainError.UnauthorizedError(ErrorMessages.MUST_BE_AUTHENTICATED_TO_RESERVE))
        }

        val currentUser = userRepository.getCurrentUser()
        if (currentUser.isError || currentUser.getOrNull() == null) {
            return Result.error(DomainError.AuthenticationError(ErrorMessages.USER_NOT_FOUND))
        }

        val userId = currentUser.getOrNull()!!.id

        // Validate court ID
        val courtValidation = validator.validateCourtId(courtId)
        if (!courtValidation.isValid) {
            return Result.error(DomainError.ReservationValidationError(courtValidation.errorMessage!!))
        }

        val validationResult = validateReservationRules(userId, date, startTime)
        if (validationResult.isError) {
            return Result.error((validationResult as Result.Error).error)
        }

        val repositoryValidation = reservationRepository.validateReservation(userId, courtId, date, startTime)
        if (repositoryValidation.isError) {
            return Result.error((repositoryValidation as Result.Error).error)
        }

        return reservationRepository.createReservation(courtId, date, startTime)
    }

    private suspend fun validateReservationRules(
        userId: String,
        date: LocalDate,
        startTime: LocalTime
    ): Result<Unit> {
        val now = Clock.System.now()
        val today = now.toLocalDateTime(TimeZone.currentSystemDefault()).date

        if (date.dayOfWeek == DayOfWeek.SATURDAY || date.dayOfWeek == DayOfWeek.SUNDAY) {
            return Result.error(DomainError.WeekendReservationError())
        }

        if (date < today) {
            return Result.error(DomainError.PastTimeReservationError())
        }

        if (date == today) {
            val currentTime = now.toLocalDateTime(TimeZone.currentSystemDefault()).time
            if (startTime <= currentTime) {
                return Result.error(DomainError.PastTimeReservationError())
            }
        }

        if (!isDateWithinBookingWindow(today, date)) {
            return Result.error(DomainError.AdvanceBookingLimitError(7))
        }

        if (!isValidTimeSlot(startTime)) {
            return Result.error(DomainError.ReservationValidationError(ErrorMessages.INVALID_TIME_SLOT))
        }

        val userReservationsResult = reservationRepository.getUserActiveReservations(userId)
        if (userReservationsResult.isSuccess) {
            val reservationsOnSameDay = userReservationsResult.getOrNull()!!
                .filter { it.reservationDate == date }

            if (reservationsOnSameDay.isNotEmpty()) {
                return Result.error(DomainError.MaxReservationsExceededError(1))
            }

            val totalActiveReservations = userReservationsResult.getOrNull()!!.size
            if (totalActiveReservations >= 2) {
                return Result.error(DomainError.MaxActiveReservationsExceededError(2))
            }
        }

        return Result.success(Unit)
    }

    private fun isValidTimeSlot(startTime: LocalTime): Boolean {
        val morningSlots = listOf(
            LocalTime(10, 0),  // 10:00-11:30
            LocalTime(11, 30), // 11:30-13:00
            LocalTime(13, 0)   // 13:00-14:30
        )

        val afternoonSlots = listOf(
            LocalTime(16, 0),  // 16:00-17:30
            LocalTime(17, 30), // 17:30-19:00
            LocalTime(19, 0),  // 19:00-20:30
            LocalTime(20, 30)  // 20:30-22:00
        )

        return startTime in morningSlots || startTime in afternoonSlots
    }
} 