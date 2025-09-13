package com.jonathandevapps.reservapistagilena.domain.model

import android.annotation.SuppressLint
import com.jonathandevapps.reservapistagilena.data.entities.ReservationEntity
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDate
import kotlinx.datetime.LocalTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime

data class ReservationUI(
    val id: String,
    val userId: String,
    val courtId: String,
    val reservationDate: LocalDate,
    val startTime: LocalTime,
    val durationMinutes: Int,
    val status: String,
    val createdAt: Instant,
    val formattedDate: String,
    val formattedTime: String,
    val endTime: LocalTime,
    val formattedTimeRange: String,
    val canBeCancelled: Boolean,
    val courtInfo: CourtUI? = null,
    val courtName: String? = null,
    val courtType: String? = null
) {
    companion object {
        fun fromReservationEntity(reservation: ReservationEntity): ReservationUI {
            val endTime = LocalTime(
                hour = (reservation.startTime.hour * 60 + reservation.startTime.minute + reservation.durationMinutes) / 60,
                minute = (reservation.startTime.hour * 60 + reservation.startTime.minute + reservation.durationMinutes) % 60
            )

            return ReservationUI(
                id = reservation.id,
                userId = reservation.userId,
                courtId = reservation.courtId,
                reservationDate = reservation.reservationDate,
                startTime = reservation.startTime,
                durationMinutes = reservation.durationMinutes,
                status = reservation.status,
                createdAt = reservation.createdAt,
                formattedDate = formatDate(reservation.reservationDate),
                formattedTime = formatTime(reservation.startTime),
                endTime = endTime,
                formattedTimeRange = "${formatTime(reservation.startTime)} - ${formatTime(endTime)}",
                canBeCancelled = reservation.status == ReservationStatus.Active.id && 
                    isAtLeastTwoHoursBeforeReservation(reservation.reservationDate, reservation.startTime),
            )
        }

        private fun formatDate(date: LocalDate): String {
            val dayNames = listOf("", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo")
            val monthNames = listOf(
                "", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
            )

            return "${dayNames[date.dayOfWeek.value]}, ${date.dayOfMonth} de ${monthNames[date.monthNumber]} de ${date.year}"
        }

        @SuppressLint("DefaultLocale")
        private fun formatTime(time: LocalTime): String {
            return String.format("%02d:%02d", time.hour, time.minute)
        }

        private fun isAtLeastTwoHoursBeforeReservation(date: LocalDate, time: LocalTime): Boolean {
            val currentMoment = Clock.System.now()
            val localZone = TimeZone.currentSystemDefault()
            val currentDateTime = currentMoment.toLocalDateTime(localZone)
            val currentDate = currentDateTime.date
            val currentTime = currentDateTime.time
            
            if (date > currentDate) {
                if (date.dayOfYear - currentDate.dayOfYear == 1) {
                    val minutesToMidnight = 24 * 60 - (currentTime.hour * 60 + currentTime.minute)
                    val minutesFromMidnight = time.hour * 60 + time.minute
                    return (minutesToMidnight + minutesFromMidnight) >= 120
                }
                return true
            } 
            else if (date == currentDate) {
                val currentMinutes = currentTime.hour * 60 + currentTime.minute
                val reservationMinutes = time.hour * 60 + time.minute
                return (reservationMinutes - currentMinutes) >= 120
            }
            
            return false
        }
    }

    fun withCourtInfo(court: CourtUI): ReservationUI {
        return copy(
            courtInfo = court,
            courtName = court.fullDisplayName,
            courtType = court.courtType
        )
    }
} 