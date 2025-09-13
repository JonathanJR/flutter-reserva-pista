package com.jonathandevapps.reservapistagilena.data.repository

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.jonathandevapps.reservapistagilena.data.entities.UserEntity
import com.jonathandevapps.reservapistagilena.data.entities.UserFirebase
import com.jonathandevapps.reservapistagilena.data.manager.dao.UserDao
import com.jonathandevapps.reservapistagilena.domain.core.DomainError
import com.jonathandevapps.reservapistagilena.domain.core.Result
import com.jonathandevapps.reservapistagilena.domain.model.UserUI
import com.jonathandevapps.reservapistagilena.domain.repository.UserRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.tasks.await
import kotlinx.datetime.Clock
import javax.inject.Inject

class UserRepositoryImpl @Inject constructor(
    private val firebaseAuth: FirebaseAuth,
    private val firestore: FirebaseFirestore,
    private val userDao: UserDao
) : UserRepository {

    private companion object {
        const val USERS_COLLECTION = "users"
        
        const val OP_REGISTER_USER = "register_user"
        const val OP_GET_CURRENT_USER = "get_current_user"
        const val OP_UPDATE_USER = "update_user"
        const val OP_DELETE_USER = "delete_user"
        
        const val RESOURCE_USER = "Usuario"
        
        const val ERROR_USER_CREATION = "Error creando usuario"
        const val ERROR_USER_NOT_FOUND = "Usuario no encontrado"
        const val ERROR_LOGIN = "Error iniciando sesión"
        const val ERROR_LOGOUT = "Error cerrando sesión"
    }

    override suspend fun registerUser(fullName: String, email: String, password: String): Result<UserUI> {
        return try {
            val authResult = firebaseAuth.createUserWithEmailAndPassword(email, password).await()
            val firebaseUser = authResult.user
                ?: return Result.error(DomainError.AuthenticationError(ERROR_USER_CREATION))

            val userEntity = UserEntity(
                id = firebaseUser.uid,
                fullName = fullName,
                email = email,
                registrationDate = Clock.System.now(),
                isActive = true
            )

            val userFirebase = UserFirebase.fromUserEntity(userEntity)
            firestore.collection(USERS_COLLECTION)
                .document(firebaseUser.uid)
                .set(userFirebase)
                .await()

            userDao.insertUser(userEntity)

            Result.success(UserUI.fromUserEntity(userEntity))
        } catch (e: Exception) {
            Result.error(DomainError.AuthenticationError("$OP_REGISTER_USER: ${e.message}"))
        }
    }

    override suspend fun loginUser(email: String, password: String): Result<UserUI> {
        return try {
            val authResult = firebaseAuth.signInWithEmailAndPassword(email, password).await()
            val firebaseUser = authResult.user
                ?: return Result.error(DomainError.AuthenticationError(ERROR_USER_NOT_FOUND))

            val userDoc = firestore.collection(USERS_COLLECTION)
                .document(firebaseUser.uid)
                .get()
                .await()

            val userFirebase = userDoc.toObject(UserFirebase::class.java)
                ?: return Result.error(DomainError.DataError("$OP_GET_CURRENT_USER: ID ${firebaseUser.uid}", null))

            val userEntity = userFirebase.toUserEntity()
            userDao.insertUser(userEntity)

            Result.success(UserUI.fromUserEntity(userEntity))
        } catch (e: Exception) {
            Result.error(DomainError.AuthenticationError("$ERROR_LOGIN: ${e.message}"))
        }
    }

    override suspend fun getCurrentUser(): Result<UserUI?> {
        return try {
            val firebaseUser = firebaseAuth.currentUser
            if (firebaseUser == null) {
                return Result.success(null)
            }

            val localUser = userDao.getUserById(firebaseUser.uid)
            if (localUser != null) {
                return Result.success(UserUI.fromUserEntity(localUser))
            }

            val userDoc = firestore.collection(USERS_COLLECTION)
                .document(firebaseUser.uid)
                .get()
                .await()

            val userFirebase = userDoc.toObject(UserFirebase::class.java)
            if (userFirebase != null) {
                val userEntity = userFirebase.toUserEntity()
                userDao.insertUser(userEntity)
                Result.success(UserUI.fromUserEntity(userEntity))
            } else {
                Result.success(null)
            }
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_GET_CURRENT_USER: ID ${firebaseAuth.currentUser?.uid}", e))
        }
    }

    override suspend fun updateUserProfile(userId: String, fullName: String): Result<UserUI> {
        return try {
            firestore.collection(USERS_COLLECTION)
                .document(userId)
                .update("fullName", fullName)
                .await()

            val localUser = userDao.getUserById(userId)
            if (localUser != null) {
                val updatedUser = localUser.copy(fullName = fullName)
                userDao.updateUser(updatedUser)
                Result.success(UserUI.fromUserEntity(updatedUser))
            } else {
                Result.error(DomainError.NotFoundError(RESOURCE_USER, userId))
            }
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_UPDATE_USER: ID $userId", e))
        }
    }

    override suspend fun logoutUser(): Result<Unit> {
        return try {
            firebaseAuth.signOut()
            userDao.deleteAllUsers()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.error(DomainError.AuthenticationError("$ERROR_LOGOUT: ${e.message}"))
        }
    }

    override suspend fun isUserAuthenticated(): Boolean {
        return firebaseAuth.currentUser != null
    }

    override fun getCurrentUserFlow(): Flow<UserUI?> {
        val currentUserId = firebaseAuth.currentUser?.uid
        return if (currentUserId != null) {
            userDao.getUserByIdFlow(currentUserId).map { userEntity ->
                userEntity?.let { UserUI.fromUserEntity(it) }
            }
        } else {
            kotlinx.coroutines.flow.flowOf(null)
        }
    }

    override suspend fun deleteUserAccount(userId: String): Result<Unit> {
        return try {
            firestore.collection(USERS_COLLECTION)
                .document(userId)
                .delete()
                .await()

            userDao.deleteUserById(userId)

            firebaseAuth.currentUser?.delete()?.await()

            Result.success(Unit)
        } catch (e: Exception) {
            Result.error(DomainError.DataError("$OP_DELETE_USER: ID $userId", e))
        }
    }
} 