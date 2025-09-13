package com.jonathandevapps.reservapistagilena.presentation.screens.options

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

import com.jonathandevapps.reservapistagilena.R
import com.jonathandevapps.reservapistagilena.domain.model.SportType
import com.jonathandevapps.reservapistagilena.presentation.components.LoadingDialog
import com.jonathandevapps.reservapistagilena.presentation.components.ReservaPistaTopBar
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.AuthViewModel
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.CourtViewModel
import androidx.hilt.navigation.compose.hiltViewModel

data class CourtOption(
    val id: String,
    val title: String,
    val description: String,
    val icon: String,
    val isAvailable: Boolean = true
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OptionsScreen(
    sportType: String,
    onNavigateToCalendar: (String) -> Unit,
    onNavigateBack: () -> Unit,
    onNavigateToLogin: () -> Unit
) {
    val authViewModel: AuthViewModel = hiltViewModel()
    val courtViewModel: CourtViewModel = hiltViewModel()

    val authState by authViewModel.uiState.collectAsState()
    val courtState by courtViewModel.uiState.collectAsState()

    val courts = courtViewModel.getCourtsBySportType(sportType)
    val isRefreshing = courtState.refreshState.isLoading

    val options = courts.map { court ->
        CourtOption(
            id = court.id,
            title = court.displayName,
            description = court.description,
            icon = court.sportIcon,
            isAvailable = court.isAvailable
        )
    }

    val sportTitle = when (sportType) {
        SportType.TENNIS.id -> stringResource(R.string.sport_tennis)
        SportType.PADEL.id -> stringResource(R.string.sport_padel)
        SportType.FOOTBALL.id -> stringResource(R.string.sport_football)
        else -> stringResource(R.string.sport_generic)
    }

    Scaffold(
        topBar = {
            ReservaPistaTopBar(
                title = stringResource(R.string.screen_options, sportTitle),
                onBackClick = onNavigateBack
            )
        }
    ) { innerPadding ->
        PullToRefreshBox(
            isRefreshing = isRefreshing,
            onRefresh = { courtViewModel.refreshCourts() },
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp)
            ) {
                // Header section
                item {
                    Column(
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(
                            text = stringResource(R.string.options_select_court),
                            style = MaterialTheme.typography.headlineSmall,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(bottom = 8.dp)
                        )

                        Text(
                            text = stringResource(R.string.options_description),
                            style = MaterialTheme.typography.bodyLarge,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                            modifier = Modifier.padding(bottom = 8.dp)
                        )
                    }
                }

                // Login card (only if not authenticated)
                if (!authState.isAuthenticated) {
                    item {
                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            colors = CardDefaults.cardColors(
                                containerColor = MaterialTheme.colorScheme.secondaryContainer
                            )
                        ) {
                            Column(
                                modifier = Modifier.padding(16.dp)
                            ) {
                                Text(
                                    text = stringResource(R.string.options_login_card_title),
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onSecondaryContainer,
                                    modifier = Modifier.padding(bottom = 8.dp)
                                )

                                Text(
                                    text = stringResource(R.string.options_login_card_content),
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.8f),
                                    modifier = Modifier.padding(bottom = 12.dp)
                                )

                                Button(
                                    onClick = onNavigateToLogin,
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    Text(stringResource(R.string.options_login_button))
                                }
                            }
                        }
                    }
                }

                // Court option cards
                items(options) { option ->
                    CourtOptionCard(
                        option = option,
                        isAuthenticated = authState.isAuthenticated,
                        onViewAvailability = { onNavigateToCalendar(option.id) },
                        onReserve = {
                            if (authState.isAuthenticated) {
                                onNavigateToCalendar(option.id)
                            } else {
                                onNavigateToLogin()
                            }
                        }
                    )
                }
            }
        }

        if (courtState.isLoading) {
            LoadingDialog(message = stringResource(R.string.options_loading))
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CourtOptionCard(
    option: CourtOption,
    isAuthenticated: Boolean,
    onViewAvailability: () -> Unit,
    onReserve: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Text(
                    text = option.icon,
                    style = MaterialTheme.typography.headlineMedium
                )

                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = option.title,
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(bottom = 4.dp)
                    )

                    Text(
                        text = option.description,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            if (isAuthenticated) {
                Button(
                    onClick = onReserve,
                    modifier = Modifier.fillMaxWidth(),
                    enabled = option.isAvailable
                ) {
                    Text(stringResource(R.string.options_book))
                }
            } else {
                OutlinedButton(
                    modifier = Modifier.fillMaxWidth(),
                    onClick = onViewAvailability,
                ) {
                    Text(stringResource(R.string.options_view_availability))
                }
            }

            if (!option.isAvailable) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = stringResource(R.string.options_unavailable),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.error
                )
            }
        }
    }
}