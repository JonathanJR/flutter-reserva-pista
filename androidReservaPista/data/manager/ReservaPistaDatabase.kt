package com.jonathandevapps.reservapistagilena.data.manager

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.jonathandevapps.reservapistagilena.data.entities.CourtEntity
import com.jonathandevapps.reservapistagilena.data.entities.ReservationEntity
import com.jonathandevapps.reservapistagilena.data.entities.UserEntity
import com.jonathandevapps.reservapistagilena.data.manager.converters.DateTimeConverters
import com.jonathandevapps.reservapistagilena.data.manager.dao.CourtDao
import com.jonathandevapps.reservapistagilena.data.manager.dao.ReservationDao
import com.jonathandevapps.reservapistagilena.data.manager.dao.UserDao

@Database(
    entities = [
        UserEntity::class,
        CourtEntity::class,
        ReservationEntity::class
    ],
    version = 2,
    exportSchema = false
)
@TypeConverters(DateTimeConverters::class)
abstract class ReservaPistaDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
    abstract fun courtDao(): CourtDao
    abstract fun reservationDao(): ReservationDao
} 