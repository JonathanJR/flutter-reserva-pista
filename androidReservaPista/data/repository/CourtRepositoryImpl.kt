package com.jonathandevapps.reservapistagilena.data.repository

import com.google.firebase.firestore.FirebaseFirestore
import com.jonathandevapps.reservapistagilena.data.entities.CourtFirebase
import com.jonathandevapps.reservapistagilena.data.manager.dao.CourtDao
import com.jonathandevapps.reservapistagilena.domain.core.DomainError
import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.model.CourtUI
import com.jonathandevapps.reservapistagilena.domain.repository.CourtRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.tasks.await
import javax.inject.Inject

class CourtRepositoryImpl @Inject constructor(
    private val firestore: FirebaseFirestore,
    private val courtDao: CourtDao
) : CourtRepository {

    private companion object {
        const val COURTS_COLLECTION = "courts"
        
        const val OP_GET_ALL_COURTS = "get_all_courts"
        const val OP_GET_COURTS_BY_TYPE = "get_courts_by_type"
        const val OP_GET_COURT_BY_ID = "get_court_by_id"
        const val OP_GET_AVAILABLE_COURTS = "get_available_courts"
        
        const val RESOURCE_COURT = "Pista"
    }

    override suspend fun getAllCourts(): Result<List<CourtUI>> {
        return try {
            val localCourts = courtDao.getAllCourts()
            if (localCourts.isNotEmpty()) {
                val courtUIs = localCourts.map { CourtUI.fromCourtEntity(it) }
                return Result.success(courtUIs)
            }

            refreshCourts()

            val updatedLocalCourts = courtDao.getAllCourts()
            val courtUIs = updatedLocalCourts.map { CourtUI.fromCourtEntity(it) }
            Result.success(courtUIs)
        } catch (e: Exception) {
            Result.error(DomainError.DataError(OP_GET_ALL_COURTS, e))
        }
    }

    override suspend fun getCourtsByType(courtType: String): Result<List<CourtUI>> {
        return try {
            val courts = courtDao.getCourtsByType(courtType)
            val courtUIs = courts.map { CourtUI.fromCourtEntity(it) }
            Result.success(courtUIs)
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_GET_COURTS_BY_TYPE: $courtType", e))
        }
    }

    override suspend fun getCourtById(courtId: String): Result<CourtUI> {
        return try {
            val court = courtDao.getCourtById(courtId)
            if (court != null) {
                Result.success(CourtUI.fromCourtEntity(court))
            } else {
                Result.error(DomainError.NotFoundError(RESOURCE_COURT, courtId))
            }
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_GET_COURT_BY_ID: $courtId", e))
        }
    }

    override fun getCourtsFlow(): Flow<List<CourtUI>> {
        return courtDao.getAllCourtsFlow().map { courts ->
            courts.map { CourtUI.fromCourtEntity(it) }
        }
    }

    override suspend fun refreshCourts(): Result<Unit> {
        return try {
            val querySnapshot = firestore.collection(COURTS_COLLECTION)
                .orderBy("displayOrder")
                .get()
                .await()

            val courtFirebaseList = querySnapshot.documents.mapNotNull { doc ->
                doc.toObject(CourtFirebase::class.java)
            }

            val courtEntities = courtFirebaseList.map { it.toCourtEntity() }

            courtDao.deleteAllCourts()
            courtDao.insertCourts(courtEntities)

            Result.success(Unit)
        } catch (e: Exception) {
            Result.error(DomainError.NetworkError(e))
        }
    }

    override suspend fun getAvailableCourts(): Result<List<CourtUI>> {
        return try {
            val availableCourts = courtDao.getAvailableCourts()
            val courtUIs = availableCourts.map { CourtUI.fromCourtEntity(it) }
            Result.success(courtUIs)
        } catch (e: Exception) {
            Result.error(DomainError.DataError(OP_GET_AVAILABLE_COURTS, e))
        }
    }
} 