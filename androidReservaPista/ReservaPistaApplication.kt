package com.jonathandevapps.reservapistagilena

import android.app.Application
import com.google.firebase.Firebase
import com.google.firebase.initialize
import com.google.firebase.remoteconfig.FirebaseRemoteConfig
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings.Builder
import com.jonathandevapps.reservapistagilena.domain.usecase.reservation.RefreshAllReservationsUseCase
import dagger.hilt.android.HiltAndroidApp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltAndroidApp
class ReservaPistaApplication : Application() {

    @Inject
    lateinit var refreshAllReservationsUseCase: RefreshAllReservationsUseCase

    override fun onCreate() {
        super.onCreate()
        Firebase.initialize(this)
        setupRemoteConfig()
        
        CoroutineScope(Dispatchers.IO).launch {
            refreshAllReservationsUseCase()
        }
    }

    private fun setupRemoteConfig() {
        val remoteConfig = FirebaseRemoteConfig.getInstance()
        val configSettings = Builder()
            .setMinimumFetchIntervalInSeconds(3600) // 1 hour
            .build()
        
        remoteConfig.setConfigSettingsAsync(configSettings)
        
        // Set default values
        val defaults = mapOf(
            "morning_start_hour" to 10,
            "morning_end_hour" to 14,
            "morning_end_minute" to 30,
            "afternoon_start_hour" to 16,
            "afternoon_end_hour" to 21,
            "afternoon_end_minute" to 0,
            "max_days_advance" to 7,
            "reservation_duration_minutes" to 90
        )
        
        remoteConfig.setDefaultsAsync(defaults)
        
        // Fetch and activate
        remoteConfig.fetchAndActivate()
    }
} 