package com.jonathandevapps.reservapistagilena.domain.model

/**
 * Enumeración para los tipos principales de pistas deportivas
 */
enum class SportType(val id: String, val displayName: String, val icon: String) {
    TENNIS("tennis", "Tenis", "🎾"),
    PADEL("padel", "Pádel", "🏓"),
    FOOTBALL("football", "Fútbol Sala", "⚽");

    companion object {
        fun fromString(value: String): SportType {
            return SportType.entries.find { it.id == value }
                ?: throw IllegalArgumentException("Tipo de deporte desconocido: $value")
        }
    }
}

/**
 * Enumeración para las opciones específicas de pistas de tenis
 */
enum class TennisCourtOption(val id: String, val displayName: String, val description: String) {
    PASILLO("pasillo", "Pista Pasillo", "Pista de tenis situada junto al pasillo del polideportivo"),
    PISCINA("piscina", "Pista Piscina", "Pista de tenis situada junto a la piscina");

    companion object {
        fun fromString(value: String): TennisCourtOption {
            return TennisCourtOption.entries.find { it.id == value }
                ?: throw IllegalArgumentException("Opción de pista de tenis desconocida: $value")
        }
    }
}

/**
 * Enumeración para las opciones específicas de pistas de pádel
 */
enum class PadelCourtOption(val id: String, val displayName: String, val description: String) {
    CEMENTO("cemento", "Pista de Cemento", "Pista de pádel con suelo de cemento"),
    CRISTAL("cristal", "Pista de Cristal", "Pista de pádel con paredes de cristal");

    companion object {
        fun fromString(value: String): PadelCourtOption {
            return PadelCourtOption.entries.find { it.id == value }
                ?: throw IllegalArgumentException("Opción de pista de pádel desconocida: $value")
        }
    }
}

/**
 * Enumeración para las opciones específicas de pistas de fútbol sala
 */
enum class FootballCourtOption(val id: String, val displayName: String, val description: String) {
    INTERIOR("interior", "Pista Interior", "Pista de fútbol sala dentro del edificio"),
    EXTERIOR("exterior", "Pista Exterior", "Pista de fútbol sala al aire libre");

    companion object {
        fun fromString(value: String): FootballCourtOption {
            return FootballCourtOption.entries.find { it.id == value }
                ?: throw IllegalArgumentException("Opción de pista de fútbol sala desconocida: $value")
        }
    }
}

/**
 * Clase sellada que representa las opciones específicas para cualquier tipo de pista
 */
sealed class CourtOption(
    open val id: String,
    open val displayName: String,
    open val description: String
) {
    data class Tennis(val option: TennisCourtOption) : CourtOption(
        option.id,
        option.displayName,
        option.description
    )
    
    data class Padel(val option: PadelCourtOption) : CourtOption(
        option.id,
        option.displayName,
        option.description
    )
    
    data class Football(val option: FootballCourtOption) : CourtOption(
        option.id,
        option.displayName,
        option.description
    )
    
    companion object {
        fun fromStrings(sportType: String, specificOption: String): CourtOption {
            return when (SportType.fromString(sportType)) {
                SportType.TENNIS -> Tennis(TennisCourtOption.fromString(specificOption))
                SportType.PADEL -> Padel(PadelCourtOption.fromString(specificOption))
                SportType.FOOTBALL -> Football(FootballCourtOption.fromString(specificOption))
            }
        }
    }
} 