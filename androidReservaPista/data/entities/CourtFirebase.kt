package com.jonathandevapps.reservapistagilena.data.entities

import kotlinx.serialization.Serializable

@Serializable
data class CourtFirebase(
    val id: String = "",
    val courtType: String = "",
    val specificOption: String = "",
    val isAvailable: Boolean = true,
    val imageUrl: String? = null,
    val displayOrder: Int = 0
) {
    constructor() : this("", "", "", true, null, 0)

    fun toCourtEntity(): CourtEntity {
        return CourtEntity(
            id = id,
            courtType = courtType,
            specificOption = specificOption,
            isAvailable = isAvailable,
            imageUrl = imageUrl
        )
    }

    companion object {
        fun fromCourtEntity(court: CourtEntity, displayOrder: Int = 0): CourtFirebase {
            return CourtFirebase(
                id = court.id,
                courtType = court.courtType,
                specificOption = court.specificOption,
                isAvailable = court.isAvailable,
                imageUrl = court.imageUrl,
                displayOrder = displayOrder
            )
        }
    }
} 