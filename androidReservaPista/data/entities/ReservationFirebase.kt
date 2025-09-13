package com.jonathandevapps.reservapistagilena.data.entities

import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDate
import kotlinx.datetime.LocalTime
import kotlinx.serialization.Serializable

@Serializable
data class ReservationFirebase(
    val id: String = "",
    val userId: String = "",
    val courtId: String = "",
    val reservationDate: String = "",
    val startTime: String = "",
    val durationMinutes: Int = 90,
    val status: String = "",
    val createdAt: Long = 0,
    val year: Int = 0,
    val month: Int = 0,
    val dayOfWeek: Int = 0
) {
    constructor() : this("", "", "", "", "", 90, "", 0, 0, 0, 0)

    fun toReservationEntity(): ReservationEntity {
        return ReservationEntity(
            id = id,
            userId = userId,
            courtId = courtId,
            reservationDate = LocalDate.parse(reservationDate),
            startTime = LocalTime.parse(startTime),
            durationMinutes = durationMinutes,
            status = status,
            createdAt = Instant.fromEpochMilliseconds(createdAt)
        )
    }

    companion object {
        fun fromReservationEntity(reservation: ReservationEntity): ReservationFirebase {
            val date = reservation.reservationDate
            return ReservationFirebase(
                id = reservation.id,
                userId = reservation.userId,
                courtId = reservation.courtId,
                reservationDate = date.toString(),
                startTime = reservation.startTime.toString(),
                durationMinutes = reservation.durationMinutes,
                status = reservation.status,
                createdAt = reservation.createdAt.toEpochMilliseconds(),
                year = date.year,
                month = date.monthNumber,
                dayOfWeek = date.dayOfWeek.value
            )
        }
    }
} 