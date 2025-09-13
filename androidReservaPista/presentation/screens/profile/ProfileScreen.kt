package com.jonathandevapps.reservapistagilena.presentation.screens.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ExitToApp
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.ExitToApp
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

import com.jonathandevapps.reservapistagilena.R
import com.jonathandevapps.reservapistagilena.domain.model.ReservationStatus
import com.jonathandevapps.reservapistagilena.presentation.components.ErrorDialog
import com.jonathandevapps.reservapistagilena.presentation.components.LoadingDialog
import com.jonathandevapps.reservapistagilena.presentation.components.ReservaPistaTopBar
import com.jonathandevapps.reservapistagilena.presentation.components.SuccessDialog
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.AuthViewModel
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.ReservationViewModel
import androidx.hilt.navigation.compose.hiltViewModel

data class UserStats(
    val totalReservations: Int,
    val activeReservations: Int,
    val memberSince: String
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    onNavigateToLogin: () -> Unit,
    onNavigateBack: () -> Unit,
    onNavigateToHome: () -> Unit = onNavigateBack,
    onNavigateToAllReservations: () -> Unit = {},
    onNavigateToActiveReservations: () -> Unit = {}
) {
    val authViewModel: AuthViewModel = hiltViewModel()
    val reservationViewModel: ReservationViewModel = hiltViewModel()

    val authState by authViewModel.uiState.collectAsState()
    val reservationState by reservationViewModel.uiState.collectAsState()

    var showLogoutDialog by remember { mutableStateOf(false) }
    var showEditDialog by remember { mutableStateOf(false) }
    var logoutRequested by remember { mutableStateOf(false) }

    val context = LocalContext.current

    LaunchedEffect(Unit, authState.isAuthenticated) {
        if (authState.isAuthenticated && authState.currentUser != null) {
            reservationViewModel.loadUserReservations()
        }
    }

    LaunchedEffect(authState.isAuthenticated, authState.isLoading) {
        if (logoutRequested && !authState.isAuthenticated && !authState.isLoading) {
            logoutRequested = false
            onNavigateToHome()
        }
    }

    val totalReservations = reservationState.userReservations.size
    val activeReservations = reservationState.userReservations.count { it.status == ReservationStatus.Active.id }

    val userData = authState.currentUser?.let { user ->
        UserProfile(
            name = user.fullName,
            email = user.email,
            stats = UserStats(
                totalReservations = totalReservations,
                activeReservations = activeReservations,
                memberSince = user.formattedRegistrationDate
            )
        )
    }

    Scaffold(
        topBar = {
            ReservaPistaTopBar(
                title = stringResource(R.string.screen_profile),
                onBackClick = onNavigateBack
            )
        }
    ) { innerPadding ->
        when {
            authState.isInitializing || reservationState.isLoading -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(innerPadding),
                    contentAlignment = Alignment.Center
                ) {
                    LoadingDialog(message = stringResource(R.string.profile_loading))
                }
            }

            !authState.isAuthenticated || userData == null -> {
                GuestProfileContent(
                    onNavigateToLogin = onNavigateToLogin,
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(innerPadding)
                        .padding(16.dp)
                )
            }

            else -> {
                AuthenticatedProfileContent(
                    user = userData,
                    onEditProfile = { showEditDialog = true },
                    onLogout = { showLogoutDialog = true },
                    onNavigateToAllReservations = onNavigateToAllReservations,
                    onNavigateToActiveReservations = onNavigateToActiveReservations,
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(innerPadding)
                        .verticalScroll(rememberScrollState())
                        .padding(16.dp)
                )
            }
        }
    }

    if (showLogoutDialog) {
        AlertDialog(
            onDismissRequest = { showLogoutDialog = false },
            title = {
                Text(
                    text = stringResource(R.string.profile_logout_title),
                    fontWeight = FontWeight.Bold
                )
            },
            text = {
                Text(stringResource(R.string.profile_logout_message))
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        showLogoutDialog = false
                        logoutRequested = true
                        authViewModel.logout()
                    }
                ) {
                    Text(stringResource(R.string.profile_logout_confirm))
                }
            },
            dismissButton = {
                TextButton(
                    onClick = { showLogoutDialog = false }
                ) {
                    Text(stringResource(R.string.profile_logout_cancel))
                }
            }
        )
    }

    if (showEditDialog) {
        var editName by remember { mutableStateOf(userData?.name ?: "") }
        var nameError by remember { mutableStateOf<String?>(null) }

        AlertDialog(
            onDismissRequest = { showEditDialog = false },
            title = {
                Text(
                    text = stringResource(R.string.profile_edit_title),
                    fontWeight = FontWeight.Bold
                )
            },
            text = {
                Column {
                    OutlinedTextField(
                        value = editName,
                        onValueChange = { 
                            editName = it
                            nameError = null
                        },
                        label = { Text(stringResource(R.string.profile_edit_name)) },
                        singleLine = true,
                        isError = nameError != null,
                        modifier = Modifier.fillMaxWidth()
                    )
                    
                    nameError?.let {
                        Text(
                            text = it,
                            color = MaterialTheme.colorScheme.error,
                            style = MaterialTheme.typography.bodySmall,
                            modifier = Modifier.padding(start = 16.dp, top = 4.dp)
                        )
                    }
                }
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        when {
                            editName.isBlank() -> {
                                nameError = context.getString(R.string.profile_edit_name_required)
                            }
                            editName.length < 2 -> {
                                nameError = context.getString(R.string.profile_edit_name_short)
                            }
                            else -> {
                                showEditDialog = false
                                authViewModel.updateUserProfile(editName)
                            }
                        }
                    }
                ) {
                    Text(stringResource(R.string.profile_edit_save))
                }
            },
            dismissButton = {
                TextButton(
                    onClick = { showEditDialog = false }
                ) {
                    Text(stringResource(R.string.profile_edit_cancel))
                }
            }
        )
    }

    if (authState.isLoading) {
        val loadingMessage = if (logoutRequested) 
            stringResource(R.string.profile_logout_loading) 
        else 
            stringResource(R.string.profile_edit_loading)
        LoadingDialog(message = loadingMessage)
    }

    authState.errorMessage?.let { errorMessage ->
        val translatedError = when (errorMessage) {
            "profile_edit_no_user" -> stringResource(R.string.profile_edit_no_user)
            "profile_edit_error" -> stringResource(R.string.profile_edit_error)
            else -> errorMessage
        }
        
        ErrorDialog(
            message = translatedError,
            onDismiss = { authViewModel.clearError() }
        )
    }

    authState.successMessage?.let { successMessage ->
        val translatedSuccess = when (successMessage) {
            "profile_edit_success" -> stringResource(R.string.profile_edit_success)
            else -> successMessage
        }
        
        SuccessDialog(
            title = stringResource(R.string.profile_edit_title),
            message = translatedSuccess
        ) {
            authViewModel.clearSuccess()
        }
    }
}

@Composable
fun GuestProfileContent(
    onNavigateToLogin: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.primaryContainer
            )
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(32.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Icon(
                    imageVector = Icons.Default.Person,
                    contentDescription = null,
                    modifier = Modifier.size(64.dp),
                    tint = MaterialTheme.colorScheme.primary
                )

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = stringResource(R.string.profile_guest_title),
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )

                Text(
                    text = stringResource(R.string.profile_guest_subtitle),
                    style = MaterialTheme.typography.bodyMedium,
                    textAlign = TextAlign.Center,
                    color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f),
                    modifier = Modifier.padding(top = 8.dp, bottom = 24.dp)
                )

                Button(
                    onClick = onNavigateToLogin,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(stringResource(R.string.profile_guest_button))
                }
            }
        }
    }
}

@Composable
fun AuthenticatedProfileContent(
    user: UserProfile,
    onEditProfile: () -> Unit,
    onLogout: () -> Unit,
    onNavigateToAllReservations: () -> Unit,
    onNavigateToActiveReservations: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier) {
        // User info header
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 24.dp),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.primaryContainer
            )
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Avatar
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.primary),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = getInitials(user.name),
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onPrimary
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = user.name,
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )

                Text(
                    text = user.email,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f)
                )

                Spacer(modifier = Modifier.height(16.dp))

                OutlinedButton(
                    onClick = onEditProfile,
                    colors = ButtonDefaults.outlinedButtonColors(
                        contentColor = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                ) {
                    Icon(
                        imageVector = Icons.Default.Edit,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(stringResource(R.string.profile_edit_title))
                }
            }
        }

        // Statistics
        Text(
            text = stringResource(R.string.profile_stats_title),
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(bottom = 16.dp)
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 24.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            StatCard(
                icon = Icons.Default.Star,
                title = stringResource(R.string.profile_stats_total),
                value = user.stats.totalReservations.toString(),
                onClick = onNavigateToAllReservations,
                modifier = Modifier.weight(1f)
            )

            StatCard(
                icon = Icons.Default.Check,
                title = stringResource(R.string.profile_stats_active),
                value = user.stats.activeReservations.toString(),
                onClick = onNavigateToActiveReservations,
                modifier = Modifier.weight(1f)
            )
        }

        // Member since card
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 24.dp)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Person,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary
                )

                Spacer(modifier = Modifier.width(16.dp))

                Column {
                    Text(
                        text = stringResource(R.string.profile_member_since),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                    )
                    Text(
                        text = user.stats.memberSince,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        // Logout button
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.errorContainer
            ),
            onClick = onLogout
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ExitToApp,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onErrorContainer
                )

                Spacer(modifier = Modifier.width(8.dp))

                Text(
                    text = stringResource(R.string.profile_logout_title),
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onErrorContainer
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StatCard(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    title: String,
    value: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        onClick = onClick,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface,
            contentColor = MaterialTheme.colorScheme.onSurface
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(24.dp)
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = value,
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary
            )

            Text(
                text = title,
                style = MaterialTheme.typography.bodySmall,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
            )
        }
    }
}

data class UserProfile(
    val name: String,
    val email: String,
    val stats: UserStats
)

private fun getInitials(name: String): String {
    return name.split(" ")
        .take(2)
        .map { it.firstOrNull()?.uppercase() ?: "" }
        .joinToString("")
} 