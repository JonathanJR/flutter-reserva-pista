package com.jonathandevapps.reservapistagilena.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.jonathandevapps.reservapistagilena.domain.model.ReservationFilter
import com.jonathandevapps.reservapistagilena.presentation.screens.auth.LoginScreen
import com.jonathandevapps.reservapistagilena.presentation.screens.auth.RegisterScreen
import com.jonathandevapps.reservapistagilena.presentation.screens.calendar.CalendarScreen
import com.jonathandevapps.reservapistagilena.presentation.screens.confirmation.ConfirmationScreen
import com.jonathandevapps.reservapistagilena.presentation.screens.home.HomeScreen
import com.jonathandevapps.reservapistagilena.presentation.screens.options.OptionsScreen
import com.jonathandevapps.reservapistagilena.presentation.screens.profile.ProfileScreen
import com.jonathandevapps.reservapistagilena.presentation.screens.reservations.MyReservationsScreen
import com.jonathandevapps.reservapistagilena.presentation.screens.splash.SplashScreen

@Composable
fun ReservaPistaNavigation(
    modifier: Modifier = Modifier,
    navController: NavHostController = rememberNavController(),
    startDestination: String = NavigationRoute.Splash.route
) {
    NavHost(
        navController = navController,
        startDestination = startDestination,
        modifier = modifier
    ) {
        // Splash Screen
        composable(NavigationRoute.Splash.route) {
            SplashScreen(
                onNavigateToHome = {
                    navController.navigateToHomeAndClearStack()
                }
            )
        }
        
        // Home Screen
        composable(NavigationRoute.Home.route) {
            HomeScreen(
                onNavigateToOptions = { sportType ->
                    navController.navigateTo(NavigationRoute.WithParams.Options(sportType))
                },
                onNavigateToProfile = {
                    navController.navigateToProfile()
                },
                onNavigateToMyReservations = {
                    navController.navigateToAllReservations()
                }
            )
        }
        
        // Options Screen
        composable(NavigationRoute.WithParams.Options.ROUTE) { backStackEntry ->
            val sportType = backStackEntry.arguments?.getString(NavigationArgs.SPORT_TYPE) ?: ""
            OptionsScreen(
                sportType = sportType,
                onNavigateToCalendar = { courtId ->
                    navController.navigateTo(NavigationRoute.WithParams.Calendar(courtId))
                },
                onNavigateBack = {
                    navController.popBackStack()
                },
                onNavigateToLogin = {
                    navController.navigateToLogin()
                }
            )
        }
        
        // Calendar Screen
        composable(NavigationRoute.WithParams.Calendar.ROUTE) { backStackEntry ->
            val courtId = backStackEntry.arguments?.getString(NavigationArgs.COURT_ID) ?: ""
            CalendarScreen(
                courtId = courtId,
                onNavigateToConfirmation = { reservationData ->
                    navController.navigateTo(NavigationRoute.WithParams.Confirmation(reservationData))
                },
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
        
        // Confirmation Screen
        composable(NavigationRoute.WithParams.Confirmation.ROUTE) { backStackEntry ->
            val reservationData = backStackEntry.arguments?.getString(NavigationArgs.RESERVATION_DATA) ?: ""
            ConfirmationScreen(
                reservationData = reservationData,
                onNavigateToMyReservations = {
                    navController.navigateWithConfirmationFlow(NavigationRoute.WithParams.MyReservationsFiltered(ReservationFilter.ACTIVE))
                },
                onNavigateToHome = {
                    navController.navigateToHomeAndClearStack()
                }
            )
        }
        
        // Authentication Screens
        composable(NavigationRoute.Login.route) {
            LoginScreen(
                onNavigateToRegister = {
                    navController.navigateTo(NavigationRoute.Register)
                },
                onNavigateToHome = {
                    navController.navigateToHomeAndClearStack()
                },
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
        
        composable(NavigationRoute.Register.route) {
            RegisterScreen(
                onNavigateToLogin = {
                    navController.popBackStack()
                },
                onNavigateToHome = {
                    navController.navigateToHomeAndClearStack()
                },
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
        
        // Profile Screen
        composable(NavigationRoute.Profile.route) {
            ProfileScreen(
                onNavigateToLogin = {
                    navController.navigateToLogin()
                },
                onNavigateBack = {
                    navController.popBackStack()
                },
                onNavigateToHome = {
                    navController.navigateToHomeAndClearStack()
                },
                onNavigateToAllReservations = {
                    navController.navigateToAllReservations()
                },
                onNavigateToActiveReservations = {
                    navController.navigateToActiveReservations()
                }
            )
        }
        
        // My Reservations Screen
        composable(NavigationRoute.MyReservations.route) {
            MyReservationsScreen(
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
        
        // My Reservations Screen with Filter
        composable(
            route = NavigationRoute.WithParams.MyReservationsFiltered.ROUTE,
            arguments = listOf(
                navArgument(NavigationArgs.FILTER) { type = NavType.StringType }
            )
        ) { backStackEntry ->
            val filterString = backStackEntry.arguments?.getString(NavigationArgs.FILTER) ?: ReservationFilter.ALL.id
            val filter = ReservationFilter.fromString(filterString)
            MyReservationsScreen(
                initialFilter = filter,
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
    }
} 