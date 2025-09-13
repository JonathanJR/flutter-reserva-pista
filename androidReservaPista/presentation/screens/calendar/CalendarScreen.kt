package com.jonathandevapps.reservapistagilena.presentation.screens.calendar

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

import com.jonathandevapps.reservapistagilena.R
import com.jonathandevapps.reservapistagilena.domain.model.CourtUI
import com.jonathandevapps.reservapistagilena.presentation.components.LoadingDialog
import com.jonathandevapps.reservapistagilena.presentation.components.ReservaPistaTopBar
import com.jonathandevapps.reservapistagilena.presentation.components.TimeSlotCard
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.CourtViewModel
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.ReservationViewModel
import androidx.hilt.navigation.compose.hiltViewModel
import kotlinx.datetime.DayOfWeek
import kotlinx.datetime.LocalDate
import kotlinx.datetime.toJavaLocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

data class DateInfo(
    val date: LocalDate,
    val dayName: String,
    val dayNumber: String,
    val monthName: String,
    val isSelected: Boolean = false
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CalendarScreen(
    courtId: String,
    onNavigateToConfirmation: (String) -> Unit,
    onNavigateBack: () -> Unit
) {
    val reservationViewModel: ReservationViewModel = hiltViewModel()
    val courtViewModel: CourtViewModel = hiltViewModel()

    val reservationState by reservationViewModel.uiState.collectAsState()
    val courtState by courtViewModel.uiState.collectAsState()

    var selectedDate by remember { mutableStateOf<LocalDate?>(null) }
    var court by remember { mutableStateOf<CourtUI?>(null) }

    val context = LocalContext.current

    LaunchedEffect(courtId, courtState.courts) {
        if (courtState.courts.isEmpty() || courtState.courts.none { it.id == courtId }) {
            courtViewModel.loadCourts()
        } else {
            court = courtState.courts.find { it.id == courtId }
        }
    }

    val courtDisplayName = court?.displayName ?: stringResource(R.string.calendar_default_court)

    val availableDates = remember {
        reservationViewModel.getAvailableDates().map { date ->
            DateInfo(
                date = date,
                dayName = when (date.dayOfWeek) {
                    DayOfWeek.MONDAY -> context.getString(R.string.day_monday)
                    DayOfWeek.TUESDAY -> context.getString(R.string.day_tuesday)
                    DayOfWeek.WEDNESDAY -> context.getString(R.string.day_wednesday)
                    DayOfWeek.THURSDAY -> context.getString(R.string.day_thursday)
                    DayOfWeek.FRIDAY -> context.getString(R.string.day_friday)
                    else -> ""
                },
                dayNumber = date.dayOfMonth.toString(),
                monthName = when (date.monthNumber) {
                    1 -> context.getString(R.string.month_jan)
                    2 -> context.getString(R.string.month_feb)
                    3 -> context.getString(R.string.month_mar)
                    4 -> context.getString(R.string.month_apr)
                    5 -> context.getString(R.string.month_may)
                    6 -> context.getString(R.string.month_jun)
                    7 -> context.getString(R.string.month_jul)
                    8 -> context.getString(R.string.month_aug)
                    9 -> context.getString(R.string.month_sep)
                    10 -> context.getString(R.string.month_oct)
                    11 -> context.getString(R.string.month_nov)
                    12 -> context.getString(R.string.month_dec)
                    else -> ""
                }
            )
        }
    }

    LaunchedEffect(selectedDate) {
        selectedDate?.let { date ->
            reservationViewModel.loadAvailableSlots(courtId, date)
        }
    }

    Scaffold(
        topBar = {
            ReservaPistaTopBar(
                title = stringResource(R.string.screen_calendar, courtDisplayName),
                onBackClick = onNavigateBack
            )
        },
        bottomBar = {
            if (selectedDate != null && reservationState.selectedTimeSlot != null) {
                Column(
                    modifier = Modifier
                        .background(MaterialTheme.colorScheme.primaryContainer)
                        .fillMaxWidth()
                        .padding(16.dp)
                ) {
                    Text(
                        text = stringResource(R.string.calendar_selected_reservation),
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.Medium,
                        color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f)
                    )

                    Text(
                        text = "${formatDateForDisplay(selectedDate!!)} • ${reservationState.selectedTimeSlot!!.startTime}-${reservationState.selectedTimeSlot!!.endTime}",
                        style = MaterialTheme.typography.bodyLarge,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onPrimaryContainer,
                        modifier = Modifier.padding(vertical = 4.dp)
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    Button(
                        onClick = {
                            val reservationData = "${courtId}|${selectedDate}|${reservationState.selectedTimeSlot!!.startTime}"
                            onNavigateToConfirmation(reservationData)
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(40.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = MaterialTheme.colorScheme.primary,
                            contentColor = MaterialTheme.colorScheme.onPrimary
                        )
                    ) {
                        Text(
                            text = stringResource(R.string.calendar_button_continue),
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                }
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp)
        ) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) {
                Column {
                    Text(
                        text = stringResource(R.string.calendar_select_date_time),
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(bottom = 8.dp)
                    )

                    Text(
                        text = stringResource(R.string.calendar_select_date_time_subtitle),
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                        modifier = Modifier.padding(bottom = 16.dp)
                    )

                    Text(
                        text = stringResource(R.string.calendar_available_dates),
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(bottom = 12.dp)
                    )

                    LazyRow(
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        modifier = Modifier.padding(bottom = 24.dp)
                    ) {
                        items(availableDates) { dateInfo ->
                            DateCard(
                                dateInfo = dateInfo.copy(isSelected = dateInfo.date == selectedDate),
                                onClick = {
                                    selectedDate = dateInfo.date
                                    reservationViewModel.clearSelection()
                                }
                            )
                        }
                    }

                    if (selectedDate != null) {
                        Text(
                            text = stringResource(R.string.calendar_available_times),
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(bottom = 12.dp)
                        )

                        Text(
                            text = stringResource(R.string.calendar_selected_date, formatDateForDisplay(selectedDate!!)),
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.primary,
                            fontWeight = FontWeight.Medium,
                            modifier = Modifier.padding(bottom = 16.dp)
                        )

                        if (reservationState.availableSlots.isEmpty()) {
                            Card(
                                modifier = Modifier.fillMaxWidth(),
                                colors = CardDefaults.cardColors(
                                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                                )
                            ) {
                                Column(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(24.dp),
                                    horizontalAlignment = Alignment.CenterHorizontally
                                ) {
                                    Text(
                                        text = "⏰",
                                        style = MaterialTheme.typography.headlineLarge
                                    )
                                    Text(
                                        text = stringResource(R.string.calendar_no_slots_available),
                                        style = MaterialTheme.typography.titleMedium,
                                        fontWeight = FontWeight.Bold,
                                        textAlign = TextAlign.Center,
                                        modifier = Modifier.padding(top = 8.dp)
                                    )
                                    Text(
                                        text = stringResource(R.string.calendar_no_slots_message),
                                        style = MaterialTheme.typography.bodyMedium,
                                        textAlign = TextAlign.Center,
                                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                                    )
                                }
                            }
                        } else {
                            LazyColumn(
                                verticalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                item {
                                    Text(
                                        text = stringResource(R.string.calendar_morning),
                                        style = MaterialTheme.typography.titleSmall,
                                        fontWeight = FontWeight.Bold,
                                        color = MaterialTheme.colorScheme.primary,
                                        modifier = Modifier.padding(vertical = 8.dp)
                                    )
                                }

                                val morningSlots = reservationState.availableSlots.filter {
                                    it.startTime.hour < 15
                                }

                                if (morningSlots.isEmpty()) {
                                    item {
                                        Text(
                                            text = stringResource(R.string.calendar_no_morning_slots),
                                            style = MaterialTheme.typography.bodyMedium,
                                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                                            modifier = Modifier.padding(vertical = 8.dp)
                                        )
                                    }
                                } else {
                                    items(morningSlots) { slot ->
                                        TimeSlotCard(
                                            startTime = "${slot.startTime.hour.toString().padStart(2, '0')}:${slot.startTime.minute.toString().padStart(2, '0')}",
                                            endTime = "${slot.endTime.hour.toString().padStart(2, '0')}:${slot.endTime.minute.toString().padStart(2, '0')}",
                                            isAvailable = slot.isAvailable,
                                            isSelected = slot == reservationState.selectedTimeSlot,
                                            onClick = {
                                                reservationViewModel.selectTimeSlot(slot)
                                            }
                                        )
                                    }
                                }

                                item {
                                    Text(
                                        text = stringResource(R.string.calendar_afternoon),
                                        style = MaterialTheme.typography.titleSmall,
                                        fontWeight = FontWeight.Bold,
                                        color = MaterialTheme.colorScheme.primary,
                                        modifier = Modifier.padding(top = 16.dp, bottom = 8.dp)
                                    )
                                }

                                val afternoonSlots = reservationState.availableSlots.filter {
                                    it.startTime.hour >= 15
                                }

                                if (afternoonSlots.isEmpty()) {
                                    item {
                                        Text(
                                            text = stringResource(R.string.calendar_no_afternoon_slots),
                                            style = MaterialTheme.typography.bodyMedium,
                                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                                            modifier = Modifier.padding(vertical = 8.dp)
                                        )
                                    }
                                } else {
                                    items(afternoonSlots) { slot ->
                                        TimeSlotCard(
                                            startTime = "${slot.startTime.hour.toString().padStart(2, '0')}:${slot.startTime.minute.toString().padStart(2, '0')}",
                                            endTime = "${slot.endTime.hour.toString().padStart(2, '0')}:${slot.endTime.minute.toString().padStart(2, '0')}",
                                            isAvailable = slot.isAvailable,
                                            isSelected = slot == reservationState.selectedTimeSlot,
                                            onClick = {
                                                reservationViewModel.selectTimeSlot(slot)
                                            }
                                        )
                                    }
                                }

                                item {
                                    Spacer(modifier = Modifier.height(0.dp))
                                }
                            }
                        }
                    } else {
                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            colors = CardDefaults.cardColors(
                                containerColor = MaterialTheme.colorScheme.surfaceVariant
                            )
                        ) {
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(24.dp),
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Text(
                                    text = "📅",
                                    style = MaterialTheme.typography.headlineLarge
                                )
                                Text(
                                    text = stringResource(R.string.calendar_select_date_message),
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Bold,
                                    textAlign = TextAlign.Center,
                                    modifier = Modifier.padding(top = 8.dp)
                                )
                                Text(
                                    text = stringResource(R.string.calendar_select_date_subtitle),
                                    style = MaterialTheme.typography.bodyMedium,
                                    textAlign = TextAlign.Center,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    if (reservationState.isLoading) {
        LoadingDialog(message = stringResource(R.string.calendar_loading))
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DateCard(
    dateInfo: DateInfo,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        onClick = onClick,
        modifier = modifier.width(80.dp),
        elevation = CardDefaults.cardElevation(
            defaultElevation = if (dateInfo.isSelected) 8.dp else 2.dp
        ),
        colors = CardDefaults.cardColors(
            containerColor = if (dateInfo.isSelected)
                MaterialTheme.colorScheme.primary
            else
                MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = dateInfo.dayName,
                style = MaterialTheme.typography.bodySmall,
                color = if (dateInfo.isSelected)
                    MaterialTheme.colorScheme.onPrimary
                else
                    MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
            )

            Text(
                text = dateInfo.dayNumber,
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                color = if (dateInfo.isSelected)
                    MaterialTheme.colorScheme.onPrimary
                else
                    MaterialTheme.colorScheme.onSurface
            )

            Text(
                text = dateInfo.monthName,
                style = MaterialTheme.typography.bodySmall,
                color = if (dateInfo.isSelected)
                    MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.8f)
                else
                    MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
            )
        }
    }
}

private fun formatDateForDisplay(date: LocalDate): String {
    val javaDate = date.toJavaLocalDate()
    val formatter = DateTimeFormatter.ofPattern("EEEE, d 'de' MMMM", Locale("es", "ES"))
    return javaDate.format(formatter)
} 