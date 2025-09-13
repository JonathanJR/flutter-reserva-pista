package com.jonathandevapps.reservapistagilena.domain.model

import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import com.jonathandevapps.reservapistagilena.R
import com.jonathandevapps.reservapistagilena.ui.theme.ErrorRed
import com.jonathandevapps.reservapistagilena.ui.theme.InfoBlue
import com.jonathandevapps.reservapistagilena.ui.theme.SuccessGreen

/**
 * Type-safe reservation status using sealed classes
 * This provides both the enum-like UI behavior AND the constants for data storage
 */
sealed class ReservationStatus(
    val id: String
) {
    /**
     * Active (current/upcoming) reservation
     */
    object Active : ReservationStatus(STATUS_ACTIVE)

    /**
     * Completed (past) reservation
     */
    object Completed : ReservationStatus(STATUS_COMPLETED)

    /**
     * Cancelled reservation
     */
    object Cancelled : ReservationStatus(STATUS_CANCELLED)

    companion object {
        const val STATUS_ACTIVE = "active"
        const val STATUS_COMPLETED = "completed"
        const val STATUS_CANCELLED = "cancelled"

        /**
         * Convert from string safely
         */
        fun fromString(value: String): ReservationStatus = when (value.lowercase()) {
            STATUS_ACTIVE -> Active
            STATUS_COMPLETED -> Completed
            STATUS_CANCELLED -> Cancelled
            else -> Active // Default to active for unknown values
        }
    }
    
    /**
     * Get localized display name from resources
     */
    @Composable
    fun getLocalizedName(): String = when (this) {
        Active -> stringResource(R.string.my_reservations_status_active)
        Completed -> stringResource(R.string.my_reservations_status_completed)
        Cancelled -> stringResource(R.string.my_reservations_status_cancelled)
    }
    
    /**
     * Get color for status display
     */
    fun getColor() = when (this) {
        Active -> SuccessGreen
        Completed -> InfoBlue
        Cancelled -> ErrorRed
    }
} 