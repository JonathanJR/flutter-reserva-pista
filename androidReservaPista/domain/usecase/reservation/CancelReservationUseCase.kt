package com.jonathandevapps.reservapistagilena.domain.usecase.reservation

import com.jonathandevapps.reservapistagilena.domain.core.DomainError
import com.jonathandevapps.reservapistagilena.domain.core.ErrorMessages
import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.model.ReservationStatus
import com.jonathandevapps.reservapistagilena.domain.repository.ReservationRepository
import com.jonathandevapps.reservapistagilena.domain.repository.UserRepository
import kotlinx.datetime.Clock
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import javax.inject.Inject

class CancelReservationUseCase @Inject constructor(
    private val reservationRepository: ReservationRepository,
    private val userRepository: UserRepository
) {
    suspend operator fun invoke(reservationId: String): Result<Unit> {
        if (!userRepository.isUserAuthenticated()) {
            return Result.error(DomainError.UnauthorizedError(ErrorMessages.MUST_BE_AUTHENTICATED_TO_CANCEL))
        }

        val currentUser = userRepository.getCurrentUser()
        if (currentUser.isError || currentUser.getOrNull() == null) {
            return Result.error(DomainError.AuthenticationError(ErrorMessages.USER_NOT_FOUND))
        }

        val userId = currentUser.getOrNull()!!.id

        if (reservationId.isBlank()) {
            return Result.error(DomainError.ReservationValidationError(ErrorMessages.INVALID_RESERVATION_ID))
        }

        val reservationResult = reservationRepository.getReservationById(reservationId)
        if (reservationResult.isError) {
            return Result.error((reservationResult as Result.Error).error)
        }

        val reservation = reservationResult.getOrNull()!!

        if (reservation.userId != userId) {
            return Result.error(DomainError.UnauthorizedError(ErrorMessages.CANNOT_CANCEL_OTHER_USER_RESERVATION))
        }

        if (reservation.status != ReservationStatus.Active.id) {
            return Result.error(DomainError.ReservationValidationError(ErrorMessages.CAN_ONLY_CANCEL_ACTIVE_RESERVATIONS))
        }

        val currentDateTime = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault())
        val today = currentDateTime.date
        val currentTime = currentDateTime.time

        if (reservation.reservationDate < today) {
            return Result.error(DomainError.ReservationValidationError(ErrorMessages.CANNOT_CANCEL_PAST_RESERVATIONS))
        }

        val minutesUntilReservation = if (reservation.reservationDate == today) {
            val currentMinutes = currentTime.hour * 60 + currentTime.minute
            val reservationMinutes = reservation.startTime.hour * 60 + reservation.startTime.minute
            reservationMinutes - currentMinutes
        } else {
            Int.MAX_VALUE
        }

        if (minutesUntilReservation < 120) {
            return Result.error(
                DomainError.ReservationValidationError(ErrorMessages.MUST_CANCEL_2_HOURS_BEFORE)
            )
        }

        return reservationRepository.cancelReservation(reservationId)
    }
} 