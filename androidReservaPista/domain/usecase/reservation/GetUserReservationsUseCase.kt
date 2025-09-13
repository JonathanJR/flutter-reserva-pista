package com.jonathandevapps.reservapistagilena.domain.usecase.reservation

import com.jonathandevapps.reservapistagilena.domain.core.DomainError
import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.model.ReservationUI
import com.jonathandevapps.reservapistagilena.domain.repository.ReservationRepository
import com.jonathandevapps.reservapistagilena.domain.repository.UserRepository
import javax.inject.Inject

class GetUserReservationsUseCase @Inject constructor(
    private val reservationRepository: ReservationRepository,
    private val userRepository: UserRepository
) {
    suspend operator fun invoke(): Result<List<ReservationUI>> {
        if (!userRepository.isUserAuthenticated()) {
            return Result.error(DomainError.UnauthorizedError("Debe estar autenticado para ver reservas"))
        }

        val currentUser = userRepository.getCurrentUser()
        if (currentUser.isError || currentUser.getOrNull() == null) {
            return Result.error(DomainError.AuthenticationError("Usuario no encontrado"))
        }

        val userId = currentUser.getOrNull()!!.id

        return reservationRepository.getUserReservations(userId)
    }
} 