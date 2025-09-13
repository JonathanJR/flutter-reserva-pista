package com.jonathandevapps.reservapistagilena.di

import com.jonathandevapps.reservapistagilena.data.repository.CourtRepositoryImpl
import com.jonathandevapps.reservapistagilena.data.repository.ReservationRepositoryImpl
import com.jonathandevapps.reservapistagilena.data.repository.UserRepositoryImpl
import com.jonathandevapps.reservapistagilena.domain.repository.CourtRepository
import com.jonathandevapps.reservapistagilena.domain.repository.ReservationRepository
import com.jonathandevapps.reservapistagilena.domain.repository.UserRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindUserRepository(
        userRepositoryImpl: UserRepositoryImpl
    ): UserRepository

    @Binds
    @Singleton
    abstract fun bindCourtRepository(
        courtRepositoryImpl: CourtRepositoryImpl
    ): CourtRepository

    @Binds
    @Singleton
    abstract fun bindReservationRepository(
        reservationRepositoryImpl: ReservationRepositoryImpl
    ): ReservationRepository
} 