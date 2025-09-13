package com.jonathandevapps.reservapistagilena.domain.core

sealed class DomainError(
    override val message: String,
    override val cause: Throwable? = null
) : Exception(message, cause) {
    
    class AuthenticationError(reason: String) : DomainError("Error de autenticación: $reason")
    class UnauthorizedError(action: String) : DomainError("No autorizado para: $action")
    
    class ReservationValidationError(reason: String) : DomainError("Error de validación: $reason")
    class SlotNotAvailableError(courtId: String, dateTime: String) : 
        DomainError("El slot no está disponible para la pista $courtId en $dateTime")
    class MaxReservationsExceededError(limit: Int) : 
        DomainError("Máximo de $limit reserva(s) por día excedido")
    class MaxActiveReservationsExceededError(limit: Int) : 
        DomainError("Máximo de $limit reserva(s) activas por usuario excedido")
    class WeekendReservationError : DomainError("No se permiten reservas los fines de semana")
    class AdvanceBookingLimitError(maxDays: Int) : 
        DomainError("Solo se puede reservar con máximo $maxDays días de antelación")
    class PastTimeReservationError : DomainError("No se pueden hacer reservas para horarios que ya han pasado")
    
    class DataError(operation: String, cause: Throwable?) :
        DomainError("Error en operación de datos: $operation", cause)
    class NotFoundError(resource: String, id: String) : 
        DomainError("$resource con ID $id no encontrado")
    
    class NetworkError(cause: Throwable?) :
        DomainError("Error de conexión", cause)
    class RemoteConfigError(configKey: String) : 
        DomainError("Error obteniendo configuración remota: $configKey")
    
    class UnknownError(cause: Throwable?) :
        DomainError("Error desconocido", cause)
} 