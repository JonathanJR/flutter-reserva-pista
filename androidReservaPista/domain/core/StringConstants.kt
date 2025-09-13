package com.jonathandevapps.reservapistagilena.domain.core

/**
 * Constants for validation and UI messages
 * These should eventually be moved to string resources for i18n support
 */
object ValidationMessages {
    const val EMAIL_REQUIRED = "Email is required"
    const val EMAIL_INVALID = "Invalid email format"
    const val PASSWORD_REQUIRED = "Password is required"
    const val PASSWORD_TOO_SHORT = "Password must be at least %d characters"
    const val NAME_REQUIRED = "Name is required"
    const val NAME_TOO_SHORT = "Name must be at least %d characters"
    const val PASSWORDS_NOT_MATCH = "Passwords do not match"
    const val INVALID_COURT_ID = "Invalid court ID"
}

object UIMessages {
    const val LOGIN_SUCCESS = "Login successful"
    const val REGISTRATION_SUCCESS = "Registration successful"
    const val REGISTRATION_FAILED = "Registration failed"
    const val LOGOUT_FAILED = "Logout failed"
    const val PROFILE_UPDATE_SUCCESS = "Profile updated successfully"
    const val PROFILE_UPDATE_FAILED = "Failed to update profile"
    const val NO_USER_LOGGED_IN = "No user logged in"
    const val UNKNOWN_ERROR = "Unknown error occurred"
}

/**
 * Constants for error messages in use cases and business logic
 */
object ErrorMessages {
    // Authentication errors
    const val MUST_BE_AUTHENTICATED_TO_RESERVE = "You must be logged in to make reservations"
    const val MUST_BE_AUTHENTICATED_TO_CANCEL = "You must be logged in to cancel reservations"
    const val USER_NOT_FOUND = "User not found"
    
    // Reservation validation errors
    const val INVALID_RESERVATION_ID = "Invalid reservation ID"
    const val CANNOT_CANCEL_OTHER_USER_RESERVATION = "You cannot cancel other users' reservations"
    const val CAN_ONLY_CANCEL_ACTIVE_RESERVATIONS = "Only active reservations can be cancelled"
    const val CANNOT_CANCEL_PAST_RESERVATIONS = "Past reservations cannot be cancelled"
    const val MUST_CANCEL_2_HOURS_BEFORE = "Reservations can only be cancelled up to 2 hours before the scheduled time"
    const val INVALID_TIME_SLOT = "Invalid time slot"
} 