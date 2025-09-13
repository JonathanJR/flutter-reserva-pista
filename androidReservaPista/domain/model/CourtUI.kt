package com.jonathandevapps.reservapistagilena.domain.model

import com.jonathandevapps.reservapistagilena.data.entities.CourtEntity

data class CourtUI(
    val id: String,
    val courtType: String,
    val specificOption: String,
    val isAvailable: Boolean,
    val imageUrl: String?,
    val displayName: String,
    val fullDisplayName: String,
    val description: String,
    val sportIcon: String,
    val availabilityText: String
) {
    companion object {
        fun fromCourtEntity(court: CourtEntity): CourtUI {
            val sportType = SportType.fromString(court.courtType)
            val courtOption = CourtOption.fromStrings(court.courtType, court.specificOption)
            
            val displayName = courtOption.displayName
            val description = courtOption.description
            val sportIcon = sportType.icon
            
            return CourtUI(
                id = court.id,
                courtType = court.courtType,
                specificOption = court.specificOption,
                isAvailable = court.isAvailable,
                imageUrl = court.imageUrl,
                displayName = displayName,
                fullDisplayName = "${sportType.displayName} - $displayName",
                description = description,
                sportIcon = sportIcon,
                availabilityText = if (court.isAvailable) "Disponible" else "No disponible"
            )
        }
    }
} 