package com.jonathandevapps.reservapistagilena.di

import android.content.Context
import androidx.room.Room
import com.jonathandevapps.reservapistagilena.data.manager.ReservaPistaDatabase
import com.jonathandevapps.reservapistagilena.data.manager.dao.CourtDao
import com.jonathandevapps.reservapistagilena.data.manager.dao.ReservationDao
import com.jonathandevapps.reservapistagilena.data.manager.dao.UserDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideReservaPistaDatabase(
        @ApplicationContext context: Context
    ): ReservaPistaDatabase {
        return Room.databaseBuilder(
            context.applicationContext,
            ReservaPistaDatabase::class.java,
            "reserva_pista_database"
        ).fallbackToDestructiveMigration(true).build()
    }

    @Provides
    fun provideUserDao(database: ReservaPistaDatabase): UserDao = database.userDao()

    @Provides
    fun provideCourtDao(database: ReservaPistaDatabase): CourtDao = database.courtDao()

    @Provides
    fun provideReservationDao(database: ReservaPistaDatabase): ReservationDao = database.reservationDao()
} 