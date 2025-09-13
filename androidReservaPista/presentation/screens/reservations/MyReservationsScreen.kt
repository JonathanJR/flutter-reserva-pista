package com.jonathandevapps.reservapistagilena.presentation.screens.reservations

import androidx.compose.foundation.BorderStroke
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.jonathandevapps.reservapistagilena.R
import com.jonathandevapps.reservapistagilena.domain.model.ReservationFilter
import com.jonathandevapps.reservapistagilena.domain.model.ReservationStatus
import com.jonathandevapps.reservapistagilena.domain.model.ReservationUI
import com.jonathandevapps.reservapistagilena.presentation.components.ErrorDialog
import com.jonathandevapps.reservapistagilena.presentation.components.LoadingDialog
import com.jonathandevapps.reservapistagilena.presentation.components.ReservaPistaTopBar
import com.jonathandevapps.reservapistagilena.presentation.components.StatusChip
import com.jonathandevapps.reservapistagilena.presentation.components.SuccessDialog
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.AuthViewModel
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.ReservationViewModel
import com.jonathandevapps.reservapistagilena.ui.theme.ErrorRed
import com.jonathandevapps.reservapistagilena.ui.theme.InfoBlue
import com.jonathandevapps.reservapistagilena.ui.theme.StatusColors.errorHigh
import com.jonathandevapps.reservapistagilena.ui.theme.StatusColors.infoDisabled
import com.jonathandevapps.reservapistagilena.ui.theme.SuccessGreen
import com.jonathandevapps.reservapistagilena.ui.theme.extendedColors
import kotlinx.coroutines.delay
import kotlinx.datetime.LocalDate
import kotlinx.datetime.LocalTime
import kotlinx.datetime.toJavaLocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

private fun ReservationUI.toDisplayFormat(): MyReservation {
    val status = ReservationStatus.fromString(this.status)

    val startTotalMinutes = this.startTime.hour * 60 + this.startTime.minute
    val endTotalMinutes = startTotalMinutes + 90
    val endHour = endTotalMinutes / 60
    val endMinute = endTotalMinutes % 60

    return MyReservation(
        id = this.id,
        courtName = this.courtName ?: "Pista Deportiva",
        courtType = this.courtType ?: "",
        date = this.reservationDate,
        startTime = this.startTime,
        endTime = LocalTime(endHour, endMinute),
        status = status,
        canCancel = status == ReservationStatus.Active
    )
}

data class MyReservation(
    val id: String,
    val courtName: String,
    val courtType: String,
    val date: LocalDate,
    val startTime: LocalTime,
    val endTime: LocalTime,
    val status: ReservationStatus,
    val canCancel: Boolean = true
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MyReservationsScreen(
    onNavigateBack: () -> Unit,
    initialFilter: ReservationFilter = ReservationFilter.ALL
) {
    val authViewModel: AuthViewModel = hiltViewModel()
    val reservationViewModel: ReservationViewModel = hiltViewModel()

    val authState by authViewModel.uiState.collectAsState()
    val reservationState by reservationViewModel.uiState.collectAsState()

    var selectedFilter by remember { mutableStateOf(initialFilter) }
    var showCancelDialog by remember { mutableStateOf(false) }
    var reservationToCancel by remember { mutableStateOf<MyReservation?>(null) }

    val allReservations = reservationState.userReservations.map { it.toDisplayFormat() }

    LaunchedEffect(Unit, authState.isAuthenticated) {
        if (authState.isAuthenticated && authState.currentUser != null) {
            reservationViewModel.loadUserReservations()
        }
    }

    val filteredReservations = remember(selectedFilter, allReservations) {
        when (selectedFilter) {
            ReservationFilter.ACTIVE -> allReservations.filter { it.status == ReservationStatus.Active }
            ReservationFilter.COMPLETED -> allReservations.filter { it.status == ReservationStatus.Completed }
            ReservationFilter.CANCELLED -> allReservations.filter { it.status == ReservationStatus.Cancelled }
            ReservationFilter.ALL -> allReservations
        }.sortedByDescending { it.date }
    }

    Scaffold(
        topBar = { ReservaPistaTopBar(title = stringResource(R.string.screen_my_reservations), onBackClick = onNavigateBack) }
    ) { innerPadding ->
        if (allReservations.isEmpty()) {
            EmptyState(
                Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
                    .padding(16.dp)
            )
        } else {
            Column(
                Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
                    .padding(16.dp)
            ) {
                FilterSection(selectedFilter, { selectedFilter = it }, getReservationCounts(allReservations))

                Spacer(modifier = Modifier.height(16.dp))

                if (filteredReservations.isEmpty()) {
                    EmptyFilterState(selectedFilter)
                } else {
                    LazyColumn(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        items(filteredReservations) { reservation ->
                            ReservationCard(reservation) {
                                reservationToCancel = reservation
                                showCancelDialog = true
                            }
                        }
                    }
                }
            }
        }
    }

    if (showCancelDialog && reservationToCancel != null) {
        AlertDialog(
            onDismissRequest = { showCancelDialog = false },
            title = { Text(stringResource(R.string.my_reservations_cancel_title), fontWeight = FontWeight.Bold) },
            text = {
                Column {
                    Text(stringResource(R.string.my_reservations_cancel_message))
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = stringResource(R.string.my_reservations_cancel_note),
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                    )
                }
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        showCancelDialog = false
                        reservationViewModel.cancelReservation(reservationToCancel!!.id)
                    }
                ) {
                    Text(stringResource(R.string.my_reservations_cancel_button), color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showCancelDialog = false; reservationToCancel = null }) {
                    Text(stringResource(R.string.my_reservations_keep_button))
                }
            }
        )
    }

    LaunchedEffect(reservationState.successMessage) {
        reservationState.successMessage?.let {
            delay(2000)
            reservationViewModel.clearMessages()
            reservationToCancel = null
        }
    }

    if (reservationState.isLoading || reservationState.isCancellingReservation) {
        LoadingDialog(message = stringResource(R.string.my_reservations_loading))
    }

    reservationState.successMessage?.let { message ->
        SuccessDialog(
            title = stringResource(R.string.my_reservations_success_title),
            message = message
        ) {
            reservationViewModel.clearMessages()
            reservationToCancel = null
        }
    }

    reservationState.errorMessage?.let { error ->
        ErrorDialog(
            message = error,
            onDismiss = {
                reservationViewModel.clearMessages()
            }
        )
    }
}

@Composable
fun EmptyState(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("📅", style = MaterialTheme.typography.headlineLarge)
        Spacer(Modifier.height(16.dp))
        Text(
            stringResource(R.string.my_reservations_empty_title),
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold
        )
        Text(
            stringResource(R.string.my_reservations_empty_subtitle),
            style = MaterialTheme.typography.bodyMedium,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
fun EmptyFilterState(filter: ReservationFilter) {
    val messageRes = when (filter) {
        ReservationFilter.ACTIVE -> R.string.my_reservations_empty_active
        ReservationFilter.COMPLETED -> R.string.my_reservations_empty_completed
        ReservationFilter.CANCELLED -> R.string.my_reservations_empty_cancelled
        ReservationFilter.ALL -> R.string.my_reservations_empty_all
    }
    Box(
        Modifier
            .fillMaxWidth()
            .height(200.dp),
        Alignment.Center
    ) {
        Text(
            stringResource(messageRes),
            style = MaterialTheme.typography.bodyLarge,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
fun FilterSection(selectedFilter: ReservationFilter, onFilterChange: (ReservationFilter) -> Unit, counts: Map<ReservationFilter, Int>) {
    Column {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Default.Edit, null, tint = MaterialTheme.colorScheme.primary)
            Spacer(Modifier.width(8.dp))
            Text(
                stringResource(R.string.my_reservations_filter_title),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
        }
        Spacer(Modifier.height(12.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            FilterChipCustom(
                stringResource(R.string.my_reservations_filter_all, counts[ReservationFilter.ALL] ?: 0),
                selectedFilter == ReservationFilter.ALL
            ) { onFilterChange(ReservationFilter.ALL) }
            FilterChipCustom(
                stringResource(R.string.my_reservations_filter_active, counts[ReservationFilter.ACTIVE] ?: 0),
                selectedFilter == ReservationFilter.ACTIVE
            ) { onFilterChange(ReservationFilter.ACTIVE) }
        }
        Spacer(Modifier.height(8.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            FilterChipCustom(
                stringResource(R.string.my_reservations_filter_completed, counts[ReservationFilter.COMPLETED] ?: 0),
                selectedFilter == ReservationFilter.COMPLETED
            ) { onFilterChange(ReservationFilter.COMPLETED) }
            FilterChipCustom(
                stringResource(R.string.my_reservations_filter_cancelled, counts[ReservationFilter.CANCELLED] ?: 0),
                selectedFilter == ReservationFilter.CANCELLED
            ) { onFilterChange(ReservationFilter.CANCELLED) }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilterChipCustom(text: String, isSelected: Boolean, onClick: () -> Unit) {
    FilterChip(
        onClick = onClick,
        label = { Text(text) },
        selected = isSelected
    )
}

@Composable
fun ReservationCard(reservation: MyReservation, onCancel: () -> Unit) {
    Card(
        Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(2.dp),
        border = when (reservation.status) {
            ReservationStatus.Cancelled -> BorderStroke(1.dp, errorHigh)
            ReservationStatus.Completed -> BorderStroke(1.dp, infoDisabled)
            else -> null
        }
    ) {
        Column(Modifier.padding(16.dp)) {
            Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween, Alignment.Top) {
                Column(Modifier.weight(1f)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = reservation.courtName,
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            color = when (reservation.status) {
                                ReservationStatus.Cancelled -> MaterialTheme.extendedColors.onSurfaceSecondary
                                ReservationStatus.Completed -> MaterialTheme.extendedColors.onSurfaceMedium
                                else -> MaterialTheme.colorScheme.onSurface
                            }
                        )
                    }
                    Text(
                        text = formatDate(reservation.date),
                        style = MaterialTheme.typography.bodyMedium,
                        color = when (reservation.status) {
                            ReservationStatus.Cancelled -> MaterialTheme.extendedColors.onSurfaceDisabled
                            ReservationStatus.Completed -> MaterialTheme.extendedColors.onSurfaceSecondary
                            else -> MaterialTheme.colorScheme.onSurface
                        }
                    )
                }
                StatusChip(
                    text = statusTextFromRes(reservation.status),
                    backgroundColor = getStatusColor(reservation.status),
                    textColor = Color.White
                )
            }

            Spacer(Modifier.height(12.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.DateRange,
                    contentDescription = null,
                    tint = when (reservation.status) {
                        ReservationStatus.Cancelled -> MaterialTheme.extendedColors.primaryDisabled
                        ReservationStatus.Completed -> MaterialTheme.extendedColors.primarySecondary
                        else -> MaterialTheme.colorScheme.primary
                    },
                    modifier = Modifier.size(20.dp)
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    "${reservation.startTime} - ${reservation.endTime}",
                    style = MaterialTheme.typography.bodyLarge,
                    color = when (reservation.status) {
                        ReservationStatus.Cancelled -> MaterialTheme.extendedColors.onSurfaceDisabled
                        ReservationStatus.Completed -> MaterialTheme.extendedColors.onSurfaceSecondary
                        else -> MaterialTheme.colorScheme.onSurface
                    }
                )
                Spacer(Modifier.weight(1f))
                if (reservation.status == ReservationStatus.Active && reservation.canCancel) {
                    OutlinedButton(onCancel, colors = ButtonDefaults.outlinedButtonColors(contentColor = MaterialTheme.colorScheme.error)) {
                        Icon(Icons.Default.Close, null, Modifier.size(16.dp))
                        Spacer(Modifier.width(4.dp))
                        Text(stringResource(R.string.my_reservations_cancel_button_small))
                    }
                }
            }

            when (reservation.status) {
                ReservationStatus.Cancelled -> {
                    Spacer(Modifier.height(8.dp))
                    Text(
                        stringResource(R.string.my_reservations_cancelled_message),
                        style = MaterialTheme.typography.bodySmall,
                        color = ErrorRed.copy(alpha = 0.8f),
                        fontStyle = androidx.compose.ui.text.font.FontStyle.Italic
                    )
                }

                ReservationStatus.Completed -> {
                    Spacer(Modifier.height(8.dp))
                    Text(
                        stringResource(R.string.my_reservations_completed_message),
                        style = MaterialTheme.typography.bodySmall,
                        color = InfoBlue.copy(alpha = 0.8f),
                        fontStyle = androidx.compose.ui.text.font.FontStyle.Italic
                    )
                }

                else -> { /* No additional text for active */
                }
            }
        }
    }
}

private fun getReservationCounts(reservations: List<MyReservation>): Map<ReservationFilter, Int> = mapOf(
    ReservationFilter.ALL to reservations.size,
    ReservationFilter.ACTIVE to reservations.count { it.status == ReservationStatus.Active },
    ReservationFilter.COMPLETED to reservations.count { it.status == ReservationStatus.Completed },
    ReservationFilter.CANCELLED to reservations.count { it.status == ReservationStatus.Cancelled }
)

@Composable
private fun statusTextFromRes(status: ReservationStatus): String = status.getLocalizedName()

private fun getStatusColor(status: ReservationStatus): Color = status.getColor()

private fun formatDate(date: LocalDate): String {
    val javaDate = date.toJavaLocalDate()
    val formatter = DateTimeFormatter.ofPattern("EEEE, d 'de' MMMM", Locale("es", "ES"))
    return javaDate.format(formatter)
} 