package com.jonathandevapps.reservapistagilena.domain.core

import kotlinx.datetime.DayOfWeek
import kotlinx.datetime.LocalDate

fun isDateWithinBookingWindow(today: LocalDate, targetDate: LocalDate): Boolean {
    if (targetDate <= today) return true

    var currentDate = today
    var businessDaysCount = 0
    val MAX_BOOKING_DAYS = 7

    while (businessDaysCount < MAX_BOOKING_DAYS) {
        currentDate = LocalDate.fromEpochDays(currentDate.toEpochDays() + 1)

        if (currentDate.dayOfWeek != DayOfWeek.SATURDAY && currentDate.dayOfWeek != DayOfWeek.SUNDAY) {
            businessDaysCount++

            if (currentDate >= targetDate) {
                return true
            }
        }
    }

    return false
}