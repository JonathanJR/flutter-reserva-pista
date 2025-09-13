package com.jonathandevapps.reservapistagilena.data.entities

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class UserFirebase(
    val id: String = "",
    val fullName: String = "",
    val email: String = "",
    val registrationDate: Long = 0,
    val isActive: Boolean = true,
    val reservationCount: Int = 0
) {
    constructor() : this("", "", "", 0, true, 0)

    fun toUserEntity(): UserEntity {
        return UserEntity(
            id = id,
            fullName = fullName,
            email = email,
            registrationDate = Instant.fromEpochMilliseconds(registrationDate),
            isActive = isActive
        )
    }

    companion object {
        fun fromUserEntity(user: UserEntity): UserFirebase {
            return UserFirebase(
                id = user.id,
                fullName = user.fullName,
                email = user.email,
                registrationDate = user.registrationDate.toEpochMilliseconds(),
                isActive = user.isActive,
                reservationCount = 0
            )
        }
    }
} 