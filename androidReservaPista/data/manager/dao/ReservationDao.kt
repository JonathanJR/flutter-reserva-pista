package com.jonathandevapps.reservapistagilena.data.manager.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.jonathandevapps.reservapistagilena.data.entities.ReservationEntity
import kotlinx.coroutines.flow.Flow
import kotlinx.datetime.LocalDate

@Dao
interface ReservationDao {
    @Query("SELECT * FROM reservations WHERE id = :id")
    suspend fun getReservationById(id: String): ReservationEntity?

    @Query("SELECT * FROM reservations WHERE userId = :userId")
    suspend fun getReservationsByUser(userId: String): List<ReservationEntity>

    @Query("SELECT * FROM reservations WHERE userId = :userId")
    fun getReservationsByUserFlow(userId: String): Flow<List<ReservationEntity>>

    @Query("SELECT * FROM reservations WHERE userId = :userId AND status = :status")
    suspend fun getReservationsByUserAndStatus(userId: String, status: String): List<ReservationEntity>

    @Query("SELECT * FROM reservations WHERE userId = :userId AND status = 'active'")
    suspend fun getActiveReservationsByUser(userId: String): List<ReservationEntity>

    @Query("SELECT * FROM reservations WHERE userId = :userId AND status = 'active'")
    fun getActiveReservationsByUserFlow(userId: String): Flow<List<ReservationEntity>>

    @Query("SELECT * FROM reservations WHERE courtId = :courtId AND reservationDate = :date")
    suspend fun getReservationsByCourtAndDate(courtId: String, date: LocalDate): List<ReservationEntity>

    @Query("SELECT * FROM reservations WHERE courtId = :courtId AND reservationDate = :date AND status = 'active'")
    suspend fun getActiveReservationsByCourtAndDate(courtId: String, date: LocalDate): List<ReservationEntity>

    @Query("SELECT * FROM reservations WHERE reservationDate = :date AND userId = :userId")
    suspend fun getReservationsByUserAndDate(userId: String, date: LocalDate): List<ReservationEntity>

    @Query("SELECT * FROM reservations WHERE reservationDate >= :startDate AND reservationDate <= :endDate")
    suspend fun getReservationsByDateRange(startDate: LocalDate, endDate: LocalDate): List<ReservationEntity>

    @Query("SELECT * FROM reservations WHERE status = :status")
    suspend fun getReservationsByStatus(status: String): List<ReservationEntity>

    @Query("SELECT COUNT(*) FROM reservations WHERE userId = :userId AND reservationDate = :date AND status = 'active'")
    suspend fun countActiveReservationsByUserAndDate(userId: String, date: LocalDate): Int

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertReservation(reservation: ReservationEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertReservations(reservations: List<ReservationEntity>)

    @Update
    suspend fun updateReservation(reservation: ReservationEntity)

    @Delete
    suspend fun deleteReservation(reservation: ReservationEntity)

    @Delete
    suspend fun deleteReservations(reservations: List<ReservationEntity>)

    @Query("DELETE FROM reservations WHERE id = :id")
    suspend fun deleteReservationById(id: String)

    @Query("UPDATE reservations SET status = :status WHERE id = :reservationId")
    suspend fun updateReservationStatus(reservationId: String, status: String)

    @Query("DELETE FROM reservations")
    suspend fun deleteAllReservations()

    @Query("DELETE FROM reservations WHERE userId = :userId")
    suspend fun deleteReservationsByUser(userId: String)
} 