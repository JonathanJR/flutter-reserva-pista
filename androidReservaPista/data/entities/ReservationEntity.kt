package com.jonathandevapps.reservapistagilena.data.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDate
import kotlinx.datetime.LocalTime

@Entity(
    tableName = "reservations",
    foreignKeys = [
        ForeignKey(
            entity = UserEntity::class,
            parentColumns = ["id"],
            childColumns = ["userId"],
            onDelete = ForeignKey.CASCADE
        ),
        ForeignKey(
            entity = CourtEntity::class,
            parentColumns = ["id"],
            childColumns = ["courtId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [
        Index("userId"),
        Index("courtId")
    ]
)
data class ReservationEntity(
    @PrimaryKey
    val id: String,
    val userId: String,
    val courtId: String,
    val reservationDate: LocalDate,
    val startTime: LocalTime,
    val durationMinutes: Int = 90,
    val status: String,
    val createdAt: Instant
) 