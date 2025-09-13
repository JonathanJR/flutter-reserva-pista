package com.jonathandevapps.reservapistagilena.domain.model

/**
 * Type-safe reservation filters
 * Replaces hardcoded strings like "all", "active", "completed", "cancelled"
 */
enum class ReservationFilter(val id: String) {
    ALL("all"),
    ACTIVE("active"),
    COMPLETED("completed"),
    CANCELLED("cancelled");

    companion object {
        /**
         * Convert from string to enum safely
         */
        fun fromString(value: String): ReservationFilter {
            return entries.find { it.id == value } ?: ALL
        }

        /**
         * Get default filter
         */
        fun default(): ReservationFilter = ALL
    }

    /**
     * Convert to string for navigation/serialization
     */
    override fun toString(): String = id
}