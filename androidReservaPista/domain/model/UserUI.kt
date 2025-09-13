package com.jonathandevapps.reservapistagilena.domain.model

import com.jonathandevapps.reservapistagilena.data.entities.UserEntity
import kotlinx.datetime.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime

data class UserUI(
    val id: String,
    val fullName: String,
    val email: String,
    val registrationDate: Instant,
    val isActive: Boolean,
    val initials: String,
    val formattedRegistrationDate: String,
    val displayName: String
) {
    companion object {
        fun fromUserEntity(user: UserEntity): UserUI {
            val initials = user.fullName
                .split(" ")
                .take(2)
                .joinToString("")
                { it.firstOrNull()?.uppercase() ?: "" }

            val displayName = if (user.fullName.isBlank()) {
                user.email.substringBefore("@")
            } else {
                user.fullName
            }

            return UserUI(
                id = user.id,
                fullName = user.fullName,
                email = user.email,
                registrationDate = user.registrationDate,
                isActive = user.isActive,
                initials = initials,
                formattedRegistrationDate = formatDate(user.registrationDate),
                displayName = displayName
            )
        }

        private fun formatDate(instant: Instant): String {
            val localDateTime = instant.toLocalDateTime(TimeZone.currentSystemDefault())
            val day = localDateTime.dayOfMonth
            val month = getMonthName(localDateTime.monthNumber)
            val year = localDateTime.year

            return "$day de $month del $year"
        }

        private fun getMonthName(monthNumber: Int): String {
            return when (monthNumber) {
                1 -> "Enero"
                2 -> "Febrero"
                3 -> "Marzo"
                4 -> "Abril"
                5 -> "Mayo"
                6 -> "Junio"
                7 -> "Julio"
                8 -> "Agosto"
                9 -> "Septiembre"
                10 -> "Octubre"
                11 -> "Noviembre"
                12 -> "Diciembre"
                else -> ""
            }
        }
    }
} 