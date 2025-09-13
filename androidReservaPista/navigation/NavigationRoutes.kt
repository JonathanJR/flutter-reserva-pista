package com.jonathandevapps.reservapistagilena.navigation

import androidx.navigation.NavController
import androidx.navigation.NavOptions
import com.jonathandevapps.reservapistagilena.domain.model.ReservationFilter

/**
 * Type-safe navigation routes using sealed classes
 * This ensures compile-time safety for navigation parameters
 */
sealed class NavigationRoute(val route: String) {

    object Splash : NavigationRoute("splash")
    object Home : NavigationRoute("home")
    object Login : NavigationRoute("login")
    object Register : NavigationRoute("register")
    object Profile : NavigationRoute("profile")
    object MyReservations : NavigationRoute("my_reservations")

    /**
     * Parameterized routes with argument definitions
     */
    sealed class WithParams(route: String) : NavigationRoute(route) {

        data class Options(val sportType: String) : WithParams("options/$sportType") {
            companion object {
                const val ROUTE = "options/{sportType}"
            }
        }

        data class Calendar(val courtId: String) : WithParams("calendar/$courtId") {
            companion object {
                const val ROUTE = "calendar/{courtId}"
            }
        }

        data class Confirmation(val reservationData: String) : WithParams("confirmation/$reservationData") {
            companion object {
                const val ROUTE = "confirmation/{reservationData}"
            }
        }

        data class MyReservationsFiltered(val filter: ReservationFilter) : WithParams("my_reservations/${filter.id}") {
            companion object {
                const val ROUTE = "my_reservations/{filter}"
            }
        }
    }
}

/**
 * Navigation arguments keys
 */
object NavigationArgs {
    const val SPORT_TYPE = "sportType"
    const val COURT_ID = "courtId"
    const val RESERVATION_DATA = "reservationData"
    const val FILTER = "filter"
}

/**
 * Navigation utilities for common navigation patterns
 */
object NavigationUtils {

    /**
     * Creates navigation options for single top launch
     */
    fun singleTop() = NavOptions.Builder()
        .setLaunchSingleTop(true)
        .build()

    /**
     * Creates navigation options for clearing back stack to home
     */
    fun toHomeAndClearStack() = NavOptions.Builder()
        .setPopUpTo(NavigationRoute.Home.route, true)
        .build()

    /**
     * Creates navigation options for authentication flow
     */
    fun authFlow() = NavOptions.Builder()
        .setLaunchSingleTop(true)
        .build()

    /**
     * Creates navigation options for confirmation flow (clear to home)
     */
    fun confirmationFlow() = NavOptions.Builder()
        .setPopUpTo(NavigationRoute.Home.route, false)
        .build()
}

/**
 * Type-safe navigation extensions for NavController
 */

/**
 * Navigate to simple routes (no parameters)
 */
fun NavController.navigateTo(route: NavigationRoute) {
    navigate(route.route)
}

/**
 * Navigate to routes with parameters
 */
fun NavController.navigateTo(route: NavigationRoute.WithParams) {
    navigate(route.route)
}

/**
 * Convenience methods for common navigation patterns
 */
fun NavController.navigateToHomeAndClearStack() {
    navigate(NavigationRoute.Home.route, NavigationUtils.toHomeAndClearStack())
}

fun NavController.navigateToLogin() {
    navigate(NavigationRoute.Login.route, NavigationUtils.authFlow())
}

fun NavController.navigateToMyReservations(filter: ReservationFilter = ReservationFilter.ALL) {
    navigate(NavigationRoute.WithParams.MyReservationsFiltered(filter).route, NavigationUtils.singleTop())
}

/**
 * Convenience methods for specific reservation filters
 */
fun NavController.navigateToAllReservations() {
    navigateToMyReservations(ReservationFilter.ALL)
}

fun NavController.navigateToActiveReservations() {
    navigateToMyReservations(ReservationFilter.ACTIVE)
}

fun NavController.navigateToCompletedReservations() {
    navigateToMyReservations(ReservationFilter.COMPLETED)
}

fun NavController.navigateToCancelledReservations() {
    navigateToMyReservations(ReservationFilter.CANCELLED)
}

/**
 * Navigate with confirmation flow pattern (used after completing reservations)
 */
fun NavController.navigateWithConfirmationFlow(route: NavigationRoute.WithParams) {
    navigate(route.route, NavigationUtils.confirmationFlow())
}

/**
 * Navigate to profile with proper back stack management
 */
fun NavController.navigateToProfile() {
    navigate(NavigationRoute.Profile.route, NavigationUtils.singleTop())
} 