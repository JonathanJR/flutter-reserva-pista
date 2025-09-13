package com.jonathandevapps.reservapistagilena.data.manager.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.jonathandevapps.reservapistagilena.data.entities.CourtEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface CourtDao {
    @Query("SELECT * FROM courts WHERE id = :id")
    suspend fun getCourtById(id: String): CourtEntity?

    @Query("SELECT * FROM courts")
    suspend fun getAllCourts(): List<CourtEntity>

    @Query("SELECT * FROM courts")
    fun getAllCourtsFlow(): Flow<List<CourtEntity>>

    @Query("SELECT * FROM courts WHERE courtType = :courtType")
    suspend fun getCourtsByType(courtType: String): List<CourtEntity>

    @Query("SELECT * FROM courts WHERE courtType = :courtType")
    fun getCourtsByTypeFlow(courtType: String): Flow<List<CourtEntity>>

    @Query("SELECT * FROM courts WHERE isAvailable = 1")
    suspend fun getAvailableCourts(): List<CourtEntity>

    @Query("SELECT * FROM courts WHERE isAvailable = 1")
    fun getAvailableCourtsFlow(): Flow<List<CourtEntity>>

    @Query("SELECT * FROM courts WHERE courtType = :courtType AND isAvailable = 1")
    suspend fun getAvailableCourtsByType(courtType: String): List<CourtEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertCourt(court: CourtEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertCourts(courts: List<CourtEntity>)

    @Update
    suspend fun updateCourt(court: CourtEntity)

    @Delete
    suspend fun deleteCourt(court: CourtEntity)

    @Query("DELETE FROM courts WHERE id = :id")
    suspend fun deleteCourtById(id: String)

    @Query("DELETE FROM courts")
    suspend fun deleteAllCourts()

    @Query("UPDATE courts SET isAvailable = :isAvailable WHERE id = :courtId")
    suspend fun updateCourtAvailability(courtId: String, isAvailable: Boolean)
} 