package com.jonathandevapps.reservapistagilena.domain.repository

import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.model.CourtUI
import kotlinx.coroutines.flow.Flow

interface CourtRepository {
    suspend fun getAllCourts(): Result<List<CourtUI>>
    suspend fun getCourtsByType(courtType: String): Result<List<CourtUI>>
    suspend fun getCourtById(courtId: String): Result<CourtUI>
    fun getCourtsFlow(): Flow<List<CourtUI>>
    suspend fun refreshCourts(): Result<Unit>
    suspend fun getAvailableCourts(): Result<List<CourtUI>>
} 