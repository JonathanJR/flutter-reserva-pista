package com.jonathandevapps.reservapistagilena.presentation.screens.home

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.List
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
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
import com.jonathandevapps.reservapistagilena.presentation.components.LoadingDialog
import com.jonathandevapps.reservapistagilena.presentation.components.ReservaPistaTopBar
import com.jonathandevapps.reservapistagilena.presentation.components.SportCard
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.AuthViewModel
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.CourtViewModel
import androidx.hilt.navigation.compose.hiltViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    onNavigateToOptions: (String) -> Unit,
    onNavigateToProfile: () -> Unit,
    onNavigateToMyReservations: () -> Unit
) {
    val courtViewModel: CourtViewModel = hiltViewModel()
    val authViewModel: AuthViewModel = hiltViewModel()

    val courtState by courtViewModel.uiState.collectAsState()
    val authState by authViewModel.uiState.collectAsState()
    
    val sports = courtViewModel.getSportTypes()
    val isRefreshing = courtState.refreshState.isLoading

    Scaffold(
        topBar = {
            ReservaPistaTopBar(
                title = stringResource(R.string.home_title),
                showProfile = true,
                onProfileClick = onNavigateToProfile
            )
        },
        floatingActionButton = {
            if (authState.isAuthenticated) {
                ExtendedFloatingActionButton(
                    onClick = onNavigateToMyReservations,
                    icon = {
                        Icon(
                            imageVector = Icons.Default.List,
                            contentDescription = stringResource(R.string.home_my_reservations)
                        )
                    },
                    text = { Text(stringResource(R.string.home_my_reservations)) },
                    containerColor = MaterialTheme.colorScheme.secondary
                )
            }
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
                verticalArrangement = Arrangement.spacedBy(24.dp),
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
                            text = stringResource(R.string.home_welcome),
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(bottom = 8.dp)
                        )

                        Text(
                            text = stringResource(R.string.home_select_court_type),
                            style = MaterialTheme.typography.bodyLarge,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                        )
                    }
                }

                // Sport cards
                items(sports) { sport ->
                    SportCard(
                        sportTypeInfo = sport,
                        onClick = { onNavigateToOptions(sport.type) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(180.dp)
                    )
                }

                // Bottom spacer for FAB
                item {
                    Spacer(modifier = Modifier.height(80.dp))
                }
            }
        }

        if (courtState.isLoading) {
            LoadingDialog(message = stringResource(R.string.home_loading))
        }
    }
} 