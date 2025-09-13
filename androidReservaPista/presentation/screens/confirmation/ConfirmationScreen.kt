package com.jonathandevapps.reservapistagilena.presentation.screens.confirmation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

import com.jonathandevapps.reservapistagilena.R
import com.jonathandevapps.reservapistagilena.domain.model.CourtUI
import com.jonathandevapps.reservapistagilena.presentation.components.LoadingDialog
import com.jonathandevapps.reservapistagilena.presentation.components.ReservaPistaTopBar
import com.jonathandevapps.reservapistagilena.presentation.components.SuccessDialog
import com.jonathandevapps.reservapistagilena.presentation.components.ErrorDialog
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.ReservationViewModel
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.CourtViewModel
import androidx.hilt.navigation.compose.hiltViewModel
import kotlinx.coroutines.delay
import kotlinx.datetime.LocalDate
import kotlinx.datetime.LocalTime
import kotlinx.datetime.toJavaLocalDate
import kotlinx.datetime.Clock
import kotlinx.datetime.TimeZone.Companion.currentSystemDefault
import kotlinx.datetime.toLocalDateTime
import java.time.format.DateTimeFormatter
import java.util.*

data class ReservationData(
    val courtId: String,
    val courtName: String,
    val date: LocalDate,
    val startTime: String,
    val endTime: String,
    val duration: String = "1h 30min",
    val price: String = "Gratuito"
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ConfirmationScreen(
    reservationData: String,
    onNavigateToMyReservations: () -> Unit,
    onNavigateToHome: () -> Unit
) {
    val reservationViewModel: ReservationViewModel = hiltViewModel()
    val courtViewModel: CourtViewModel = hiltViewModel()
    
    val reservationState by reservationViewModel.uiState.collectAsState()
    val courtState by courtViewModel.uiState.collectAsState()

    val (courtId, date, startTime) = remember(reservationData) {
        parseReservationData(reservationData)
    }
    
    var court by remember { mutableStateOf<CourtUI?>(null) }
    
    LaunchedEffect(courtId, courtState.courts) {
        if (courtState.courts.isEmpty() || courtState.courts.none { it.id == courtId }) {
            courtViewModel.loadCourts()
        } else {
            court = courtState.courts.find { it.id == courtId }
        }
    }
    
    val courtDisplayName = court?.fullDisplayName ?: stringResource(R.string.calendar_default_court)
    
    val reservation = ReservationData(
        courtId = courtId,
        courtName = courtDisplayName,
        date = date,
        startTime = "${startTime.hour.toString().padStart(2, '0')}:${startTime.minute.toString().padStart(2, '0')}",
        endTime = "${(startTime.hour + 1).toString().padStart(2, '0')}:${(startTime.minute + 30).toString().padStart(2, '0')}"
    )
    
    Scaffold(
        topBar = {
            ReservaPistaTopBar(
                title = stringResource(R.string.confirmation_title),
                onBackClick = onNavigateToHome
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp)
        ) {
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
                        .padding(20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Icon(
                        imageVector = Icons.Default.CheckCircle,
                        contentDescription = null,
                        modifier = Modifier.size(48.dp),
                        tint = MaterialTheme.colorScheme.primary
                    )
                    
                    Spacer(modifier = Modifier.height(12.dp))
                    
                    Text(
                        text = stringResource(R.string.confirmation_ready),
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onPrimaryContainer,
                        textAlign = TextAlign.Center
                    )
                    
                    Text(
                        text = stringResource(R.string.confirmation_review),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f),
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
            }
            
            Text(
                text = stringResource(R.string.confirmation_details),
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 16.dp)
            )
            
            ReservationDetailCard(
                icon = Icons.Default.CheckCircle,
                title = stringResource(R.string.confirmation_court),
                content = reservation.courtName,
                subtitle = stringResource(R.string.confirmation_location)
            )
            
            Spacer(modifier = Modifier.height(12.dp))
            
            ReservationDetailCard(
                icon = Icons.Default.DateRange,
                title = stringResource(R.string.confirmation_date_time),
                content = "${formatDate(reservation.date)}\n${reservation.startTime} - ${reservation.endTime}",
                subtitle = stringResource(R.string.confirmation_duration, reservation.duration)
            )
            
            Spacer(modifier = Modifier.height(12.dp))
            
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.secondaryContainer
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = stringResource(R.string.confirmation_price_title),
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSecondaryContainer
                        )
                        Text(
                            text = stringResource(R.string.confirmation_price_subtitle),
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.7f)
                        )
                    }
                    
                    Text(
                        text = stringResource(R.string.confirmation_free),
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.primary
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Column(
                    modifier = Modifier.padding(16.dp)
                ) {
                    Text(
                        text = stringResource(R.string.confirmation_conditions_title),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(bottom = 12.dp)
                    )
                    
                    val conditions = listOf(
                        stringResource(R.string.confirmation_condition_1),
                        stringResource(R.string.confirmation_condition_2),
                        stringResource(R.string.confirmation_condition_3),
                        stringResource(R.string.confirmation_condition_4),
                        stringResource(R.string.confirmation_condition_5)
                    )
                    
                    conditions.forEach { rule ->
                        Row(
                            modifier = Modifier.padding(bottom = 6.dp)
                        ) {
                            Text(
                                text = stringResource(R.string.confirmation_bullet),
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.primary
                            )
                            Text(
                                text = rule,
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(32.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                OutlinedButton(
                    onClick = onNavigateToHome,
                    modifier = Modifier.weight(1f)
                ) {
                    Text(stringResource(R.string.confirmation_cancel))
                }
                
                Button(
                    onClick = {
                        reservationViewModel.createReservation(courtId, date, startTime)
                    },
                    modifier = Modifier.weight(1f),
                    enabled = !reservationState.isCreatingReservation
                ) {
                    Text(stringResource(R.string.confirmation_confirm))
                }
            }
            
            Spacer(modifier = Modifier.height(24.dp))
        }
    }
    
    LaunchedEffect(reservationState.successMessage) {
        reservationState.successMessage?.let {
            delay(2000)
            reservationViewModel.clearMessages()
            onNavigateToMyReservations()
        }
    }
    
    if (reservationState.isCreatingReservation) {
        LoadingDialog(message = stringResource(R.string.confirmation_loading))
    }
    
    reservationState.successMessage?.let { message ->
        SuccessDialog(
            title = stringResource(R.string.confirmation_success_title),
            message = message,
            onDismiss = {
                reservationViewModel.clearMessages()
                onNavigateToMyReservations()
            }
        )
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
fun ReservationDetailCard(
    icon: ImageVector,
    title: String,
    content: String,
    subtitle: String,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .background(
                        MaterialTheme.colorScheme.primary.copy(alpha = 0.1f),
                        RoundedCornerShape(12.dp)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(24.dp)
                )
            }
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface,
                    modifier = Modifier.padding(bottom = 4.dp)
                )
                
                Text(
                    text = content,
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurface,
                    modifier = Modifier.padding(bottom = 2.dp)
                )
                
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                )
            }
        }
    }
}

private fun parseReservationData(data: String): Triple<String, LocalDate, LocalTime> {
    val parts = data.split("|")
    val courtId = parts.getOrNull(0) ?: ""
    val dateStr = parts.getOrNull(1) ?: ""
    val timeStr = parts.getOrNull(2) ?: ""
    
    val date = try {
        LocalDate.parse(dateStr)
    } catch (_: Exception) {
        Clock.System.now().toLocalDateTime(currentSystemDefault()).date
    }
    
    val startTime = try {
        val timeParts = timeStr.split(":")
        val hour = timeParts[0].toInt()
        val minute = timeParts[1].toInt()
        LocalTime(hour, minute)
    } catch (_: Exception) {
        LocalTime(10, 0)
    }
    
    return Triple(courtId, date, startTime)
}

private fun formatDate(date: LocalDate): String {
    val javaDate = date.toJavaLocalDate()
    val formatter = DateTimeFormatter.ofPattern("EEEE, d 'de' MMMM 'de' yyyy", Locale("es", "ES"))
    return javaDate.format(formatter)
} 