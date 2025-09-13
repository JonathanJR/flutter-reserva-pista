package com.jonathandevapps.reservapistagilena.data.repository

import android.annotation.SuppressLint
import com.jonathandevapps.reservapistagilena.data.entities.ReservationEntity
import com.jonathandevapps.reservapistagilena.data.entities.ReservationFirebase
import com.jonathandevapps.reservapistagilena.data.manager.dao.CourtDao
import com.jonathandevapps.reservapistagilena.data.manager.dao.ReservationDao
import com.jonathandevapps.reservapistagilena.domain.core.DomainError
import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.model.CourtUI
import com.jonathandevapps.reservapistagilena.domain.model.ReservationUI
import com.jonathandevapps.reservapistagilena.domain.model.ReservationStatus
import com.jonathandevapps.reservapistagilena.domain.repository.ReservationRepository
import com.jonathandevapps.reservapistagilena.domain.repository.TimeSlot
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.tasks.await
import kotlinx.datetime.*
import java.util.UUID
import javax.inject.Inject

class ReservationRepositoryImpl @Inject constructor(
    private val firebaseAuth: FirebaseAuth,
    private val firestore: FirebaseFirestore,
    private val reservationDao: ReservationDao,
    private val courtDao: CourtDao
) : ReservationRepository {
    
    private companion object {
        const val RESERVATIONS_COLLECTION = "reservations"
        
        const val OP_CREATE_RESERVATION = "create_reservation"
        const val OP_CANCEL_RESERVATION = "cancel_reservation"
        const val OP_GET_USER_RESERVATIONS = "get_user_reservations"
        const val OP_GET_USER_ACTIVE_RESERVATIONS = "get_user_active_reservations"
        const val OP_GET_USER_RESERVATION_HISTORY = "get_user_reservation_history"
        const val OP_GET_AVAILABLE_SLOTS = "get_available_slots"
        const val OP_CHECK_SLOT_AVAILABILITY = "check_slot_availability"
        const val OP_VALIDATE_RESERVATION = "validate_reservation"
        const val OP_GET_RESERVATION_BY_ID = "get_reservation_by_id"
        
        const val RESOURCE_RESERVATION = "Reserva"
        
        const val ERROR_USER_NOT_AUTHENTICATED = "Usuario no autenticado"
    }
    
    override suspend fun createReservation(
        courtId: String,
        date: LocalDate,
        startTime: LocalTime
    ): Result<ReservationUI> {
        return try {
            val currentUser = firebaseAuth.currentUser
                ?: return Result.error(DomainError.UnauthorizedError(ERROR_USER_NOT_AUTHENTICATED))
            
            val reservationId = UUID.randomUUID().toString()
            val reservationEntity = ReservationEntity(
                id = reservationId,
                userId = currentUser.uid,
                courtId = courtId,
                reservationDate = date,
                startTime = startTime,
                durationMinutes = 90,
                status = ReservationStatus.Active.id,
                createdAt = Clock.System.now()
            )
            
            val reservationFirebase = ReservationFirebase.fromReservationEntity(reservationEntity)
            firestore.collection(RESERVATIONS_COLLECTION)
                .document(reservationId)
                .set(reservationFirebase)
                .await()
            
            reservationDao.insertReservation(reservationEntity)
            
            val reservationUI = ReservationUI.fromReservationEntity(reservationEntity)
            val court = courtDao.getCourtById(courtId)
            val courtUI = court?.let { CourtUI.fromCourtEntity(it) }
            
            Result.success(if (courtUI != null) reservationUI.withCourtInfo(courtUI) else reservationUI)
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_CREATE_RESERVATION para pista $courtId en $date $startTime", e))
        }
    }
    
    override suspend fun cancelReservation(reservationId: String): Result<Unit> {
        return try {
            firestore.collection(RESERVATIONS_COLLECTION)
                .document(reservationId)
                .update("status", ReservationStatus.Cancelled.id)
                .await()
            
            reservationDao.updateReservationStatus(reservationId, ReservationStatus.Cancelled.id)
            
            Result.success(Unit)
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_CANCEL_RESERVATION: $reservationId", e))
        }
    }
    
    override suspend fun getUserReservations(userId: String): Result<List<ReservationUI>> {
        return try {
            val reservations = reservationDao.getReservationsByUser(userId)
            val reservationUIs = reservations.map { reservation ->
                val court = courtDao.getCourtById(reservation.courtId)
                val courtUI = court?.let { CourtUI.fromCourtEntity(it) }
                val reservationUI = ReservationUI.fromReservationEntity(reservation)
                if (courtUI != null) reservationUI.withCourtInfo(courtUI) else reservationUI
            }
            Result.success(reservationUIs)
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_GET_USER_RESERVATIONS: $userId", e))
        }
    }
    
    override suspend fun getUserActiveReservations(userId: String): Result<List<ReservationUI>> {
        return try {
            val activeReservations = reservationDao.getActiveReservationsByUser(userId)
            val reservationUIs = activeReservations.map { reservation ->
                val court = courtDao.getCourtById(reservation.courtId)
                val courtUI = court?.let { CourtUI.fromCourtEntity(it) }
                val reservationUI = ReservationUI.fromReservationEntity(reservation)
                if (courtUI != null) reservationUI.withCourtInfo(courtUI) else reservationUI
            }
            Result.success(reservationUIs)
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_GET_USER_ACTIVE_RESERVATIONS: $userId", e))
        }
    }
    
    override suspend fun getUserReservationHistory(userId: String): Result<List<ReservationUI>> {
        return try {
            val allReservations = reservationDao.getReservationsByUser(userId)
            val historyReservations = allReservations.filter { it.status != ReservationStatus.Active.id }
            
            val reservationUIs = historyReservations.map { reservation ->
                val court = courtDao.getCourtById(reservation.courtId)
                val courtUI = court?.let { CourtUI.fromCourtEntity(it) }
                val reservationUI = ReservationUI.fromReservationEntity(reservation)
                if (courtUI != null) reservationUI.withCourtInfo(courtUI) else reservationUI
            }
            Result.success(reservationUIs)
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_GET_USER_RESERVATION_HISTORY: $userId", e))
        }
    }
    
    override suspend fun getAvailableSlots(courtId: String, date: LocalDate): Result<List<TimeSlot>> {
        return try {
            val allSlots = getAllPossibleSlots()
            
            val dateString = date.toString()
            
            val querySnapshot = firestore.collection(RESERVATIONS_COLLECTION)
                .whereEqualTo("courtId", courtId)
                .whereEqualTo("reservationDate", dateString)
                .whereEqualTo("status", ReservationStatus.Active.id)
                .get()
                .await()
            
            val reservationFirebaseList = querySnapshot.documents.mapNotNull { doc ->
                doc.toObject(ReservationFirebase::class.java)
            }
            
            val reservedTimes = reservationFirebaseList.mapNotNull { reservation ->
                val timeParts = reservation.startTime.split(":")
                if (timeParts.size == 2) {
                    val hour = timeParts[0].toIntOrNull() ?: return@mapNotNull null
                    val minute = timeParts[1].toIntOrNull() ?: return@mapNotNull null
                    LocalTime(hour, minute)
                } else {
                    null
                }
            }.toSet()
            
            val availableSlots = allSlots.map { slot ->
                TimeSlot(
                    startTime = slot.startTime,
                    endTime = slot.endTime,
                    isAvailable = slot.startTime !in reservedTimes
                )
            }
            
            Result.success(availableSlots)
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_GET_AVAILABLE_SLOTS para pista $courtId en fecha $date", e))
        }
    }
    
    @SuppressLint("DefaultLocale")
    override suspend fun isSlotAvailable(
        courtId: String,
        date: LocalDate,
        startTime: LocalTime
    ): Result<Boolean> {
        return try {
            val dateString = date.toString()
            val timeString = String.format("%02d:%02d", startTime.hour, startTime.minute)
            
            val querySnapshot = firestore.collection(RESERVATIONS_COLLECTION)
                .whereEqualTo("courtId", courtId)
                .whereEqualTo("reservationDate", dateString)
                .whereEqualTo("startTime", timeString)
                .whereEqualTo("status", ReservationStatus.Active.id)
                .get()
                .await()
            
            val isAvailable = querySnapshot.documents.isEmpty()
            
            Result.success(isAvailable)
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_CHECK_SLOT_AVAILABILITY para pista $courtId en $date $startTime", e))
        }
    }
    
    override suspend fun validateReservation(
        userId: String,
        courtId: String,
        date: LocalDate,
        startTime: LocalTime
    ): Result<Unit> {
        return try {
            val slotAvailable = isSlotAvailable(courtId, date, startTime)
            if (slotAvailable.isError || slotAvailable.getOrNull() == false) {
                return Result.error(DomainError.SlotNotAvailableError(courtId, "$date $startTime"))
            }
            
            val dateString = date.toString()
            
            val userReservationsOnDateQuery = firestore.collection(RESERVATIONS_COLLECTION)
                .whereEqualTo("userId", userId)
                .whereEqualTo("reservationDate", dateString)
                .whereEqualTo("status", ReservationStatus.Active.id)
                .get()
                .await()
            
            val activeReservationsOnDate = userReservationsOnDateQuery.documents.size
            
            if (activeReservationsOnDate > 0) {
                return Result.error(DomainError.MaxReservationsExceededError(1))
            }
            
            val allUserActiveReservationsQuery = firestore.collection(RESERVATIONS_COLLECTION)
                .whereEqualTo("userId", userId)
                .whereEqualTo("status", ReservationStatus.Active.id)
                .get()
                .await()
                
            val totalActiveReservations = allUserActiveReservationsQuery.documents.size
            
            if (totalActiveReservations >= 2) {
                return Result.error(DomainError.MaxActiveReservationsExceededError(2))
            }
            
            Result.success(Unit)
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_VALIDATE_RESERVATION para usuario $userId, pista $courtId en $date $startTime", e))
        }
    }
    
    override fun getUserReservationsFlow(userId: String): Flow<List<ReservationUI>> {
        return reservationDao.getReservationsByUserFlow(userId).map { reservations ->
            reservations.map { reservation ->
                val court = courtDao.getCourtById(reservation.courtId)
                val courtUI = court?.let { CourtUI.fromCourtEntity(it) }
                val reservationUI = ReservationUI.fromReservationEntity(reservation)
                if (courtUI != null) reservationUI.withCourtInfo(courtUI) else reservationUI
            }
        }
    }
    
    override suspend fun refreshReservations(): Result<Unit> {
        return try {
            val currentUser = firebaseAuth.currentUser
                ?: return Result.success(Unit)
            
            val querySnapshot = firestore.collection(RESERVATIONS_COLLECTION)
                .whereEqualTo("userId", currentUser.uid)
                .get()
                .await()
            
            val reservationFirebaseList = querySnapshot.documents.mapNotNull { doc ->
                doc.toObject(ReservationFirebase::class.java)
            }
            
            val reservationEntities = reservationFirebaseList.map { it.toReservationEntity() }
            
            reservationDao.deleteReservationsByUser(currentUser.uid)
            reservationDao.insertReservations(reservationEntities)
            
            Result.success(Unit)
        } catch (e: Exception) {
            Result.error(DomainError.NetworkError(e))
        }
    }
    
    override suspend fun refreshAllReservations(): Result<Unit> {
        return try {
            val querySnapshot = firestore.collection(RESERVATIONS_COLLECTION)
                .get()
                .await()
            
            val reservationFirebaseList = querySnapshot.documents.mapNotNull { doc ->
                doc.toObject(ReservationFirebase::class.java)
            }
            
            val reservationEntities = reservationFirebaseList.map { it.toReservationEntity() }
            
            reservationDao.deleteAllReservations()
            
            reservationDao.insertReservations(reservationEntities)
            
            Result.success(Unit)
        } catch (e: Exception) {
            Result.error(DomainError.NetworkError(e))
        }
    }
    
    override suspend fun getReservationById(reservationId: String): Result<ReservationUI> {
        return try {
            val reservation = reservationDao.getReservationById(reservationId)
            if (reservation != null) {
                val court = courtDao.getCourtById(reservation.courtId)
                val courtUI = court?.let { CourtUI.fromCourtEntity(it) }
                val reservationUI = ReservationUI.fromReservationEntity(reservation)
                val finalReservationUI = if (courtUI != null) reservationUI.withCourtInfo(courtUI) else reservationUI
                Result.success(finalReservationUI)
            } else {
                Result.error(DomainError.NotFoundError(RESOURCE_RESERVATION, reservationId))
            }
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_GET_RESERVATION_BY_ID: $reservationId", e))
        }
    }
    
    private fun getAllPossibleSlots(): List<TimeSlot> {
        val morningSlots = listOf(
            TimeSlot(LocalTime(10, 0), LocalTime(11, 30), true),   // 10:00-11:30
            TimeSlot(LocalTime(11, 30), LocalTime(13, 0), true),   // 11:30-13:00
            TimeSlot(LocalTime(13, 0), LocalTime(14, 30), true)    // 13:00-14:30
        )
        
        val afternoonSlots = listOf(
            TimeSlot(LocalTime(16, 0), LocalTime(17, 30), true),   // 16:00-17:30
            TimeSlot(LocalTime(17, 30), LocalTime(19, 0), true),   // 17:30-19:00
            TimeSlot(LocalTime(19, 0), LocalTime(20, 30), true),   // 19:00-20:30
            TimeSlot(LocalTime(20, 30), LocalTime(22, 0), true)    // 20:30-22:00
        )
        
        return morningSlots + afternoonSlots
    }
} 