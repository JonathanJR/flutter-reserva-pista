package com.jonathandevapps.reservapistagilena.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.datetime.Instant

@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey
    val id: String,
    val fullName: String,
    val email: String,
    val registrationDate: Instant,
    val isActive: Boolean = true
) 