package com.jonathandevapps.reservapistagilena.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "courts")
data class CourtEntity(
    @PrimaryKey
    val id: String,
    val courtType: String,
    val specificOption: String,
    val isAvailable: Boolean = true,
    val imageUrl: String? = null
) 