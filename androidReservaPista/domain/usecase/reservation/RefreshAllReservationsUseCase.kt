package com.jonathandevapps.reservapistagilena.domain.usecase.reservation

import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.repository.ReservationRepository
import javax.inject.Inject

class RefreshAllReservationsUseCase @Inject constructor(
    private val reservationRepository: ReservationRepository
) {
    suspend operator fun invoke(): Result<Unit> {
        return reservationRepository.refreshAllReservations()
    }
} 