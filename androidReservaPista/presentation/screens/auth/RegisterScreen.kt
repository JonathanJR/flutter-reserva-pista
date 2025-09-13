package com.jonathandevapps.reservapistagilena.presentation.screens.auth

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
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
import androidx.compose.ui.focus.FocusDirection
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

import com.jonathandevapps.reservapistagilena.R
import com.jonathandevapps.reservapistagilena.presentation.components.EmailTextField
import com.jonathandevapps.reservapistagilena.presentation.components.ErrorDialog
import com.jonathandevapps.reservapistagilena.presentation.components.LoadingDialog
import com.jonathandevapps.reservapistagilena.presentation.components.NameTextField
import com.jonathandevapps.reservapistagilena.presentation.components.PasswordTextField
import com.jonathandevapps.reservapistagilena.presentation.components.ReservaPistaTopBar
import com.jonathandevapps.reservapistagilena.presentation.components.SuccessDialog
import com.jonathandevapps.reservapistagilena.presentation.components.rememberFormFieldState
import com.jonathandevapps.reservapistagilena.presentation.components.rememberPasswordConfirmationState
import com.jonathandevapps.reservapistagilena.presentation.components.ValidationType
import com.jonathandevapps.reservapistagilena.presentation.viewmodel.AuthViewModel
import androidx.hilt.navigation.compose.hiltViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegisterScreen(
    onNavigateToLogin: () -> Unit,
    onNavigateToHome: () -> Unit,
    onNavigateBack: () -> Unit
) {
    val viewModel: AuthViewModel = hiltViewModel()
    val uiState by viewModel.uiState.collectAsState()

    // Using form field states with automatic validation
    val nameState = rememberFormFieldState(validationType = ValidationType.NAME)
    val emailState = rememberFormFieldState(validationType = ValidationType.EMAIL)
    val passwordState = rememberFormFieldState(validationType = ValidationType.PASSWORD)
    val confirmPasswordState = rememberPasswordConfirmationState(passwordState.value)
    
    var passwordVisible by remember { mutableStateOf(false) }
    var confirmPasswordVisible by remember { mutableStateOf(false) }
    var acceptTerms by remember { mutableStateOf(false) }

    val focusManager = LocalFocusManager.current

    val isFormValid = nameState.isValid && emailState.isValid && passwordState.isValid &&
            confirmPasswordState.isValid && acceptTerms && nameState.value.isNotBlank() &&
            emailState.value.isNotBlank() && passwordState.value.isNotBlank() && 
            confirmPasswordState.value.isNotBlank()

    Scaffold(
        topBar = {
            ReservaPistaTopBar(
                title = stringResource(R.string.register_title),
                onBackClick = onNavigateBack
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 32.dp),
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
                    Text(
                        text = stringResource(R.string.register_welcome_emoji),
                        style = MaterialTheme.typography.headlineLarge
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    Text(
                        text = stringResource(R.string.register_welcome_title),
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onPrimaryContainer,
                        textAlign = TextAlign.Center
                    )

                    Text(
                        text = stringResource(R.string.register_welcome_subtitle),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f),
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(top = 8.dp)
                    )
                }
            }

            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                NameTextField(
                    value = nameState.value,
                    onValueChange = nameState.onValueChange,
                    isError = !nameState.isValid && nameState.value.isNotBlank(),
                    errorMessage = nameState.errorMessage,
                    keyboardActions = KeyboardActions(
                        onNext = { focusManager.moveFocus(FocusDirection.Down) }
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                EmailTextField(
                    value = emailState.value,
                    onValueChange = emailState.onValueChange,
                    isError = !emailState.isValid && emailState.value.isNotBlank(),
                    errorMessage = emailState.errorMessage,
                    keyboardActions = KeyboardActions(
                        onNext = { focusManager.moveFocus(FocusDirection.Down) }
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                PasswordTextField(
                    value = passwordState.value,
                    onValueChange = passwordState.onValueChange,
                    isVisible = passwordVisible,
                    onVisibilityToggle = { passwordVisible = !passwordVisible },
                    isError = !passwordState.isValid && passwordState.value.isNotBlank(),
                    errorMessage = passwordState.errorMessage,
                    keyboardActions = KeyboardActions(
                        onNext = { focusManager.moveFocus(FocusDirection.Down) }
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                PasswordTextField(
                    value = confirmPasswordState.value,
                    onValueChange = confirmPasswordState.onValueChange,
                    isVisible = confirmPasswordVisible,
                    onVisibilityToggle = { confirmPasswordVisible = !confirmPasswordVisible },
                    isError = !confirmPasswordState.isValid && confirmPasswordState.value.isNotBlank(),
                    errorMessage = confirmPasswordState.errorMessage,
                    label = stringResource(R.string.register_confirm_password),
                    keyboardActions = KeyboardActions(
                        onDone = { focusManager.clearFocus() }
                    ),
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(8.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = acceptTerms,
                        onCheckedChange = { acceptTerms = it }
                    )

                    Spacer(modifier = Modifier.width(8.dp))

                    Column {
                        Text(
                            text = stringResource(R.string.register_accept_terms),
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            text = stringResource(R.string.register_accept_privacy),
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                Button(
                    onClick = { 
                        viewModel.register(
                            nameState.value, 
                            emailState.value, 
                            passwordState.value, 
                            confirmPasswordState.value
                        ) 
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(50.dp),
                    enabled = isFormValid && !uiState.isLoading
                ) {
                    Text(
                        text = stringResource(R.string.register_button),
                        style = MaterialTheme.typography.titleMedium
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = stringResource(R.string.register_already_account),
                        style = MaterialTheme.typography.bodyMedium
                    )

                    TextButton(
                        onClick = onNavigateToLogin
                    ) {
                        Text(
                            text = stringResource(R.string.register_login),
                            fontWeight = FontWeight.Bold
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))
            }
        }
    }

    LaunchedEffect(uiState.isAuthenticated) {
        if (uiState.isAuthenticated) {
            onNavigateToHome()
        }
    }

    if (uiState.isLoading) {
        LoadingDialog(message = stringResource(R.string.register_loading))
    }

    uiState.successMessage?.let { message ->
        SuccessDialog(
            title = stringResource(R.string.register_success_title),
            message = message,
            onDismiss = {
                viewModel.clearSuccess()
                onNavigateToHome()
            }
        )
    }

    uiState.errorMessage?.let { error ->
        ErrorDialog(
            title = stringResource(R.string.register_error_title),
            message = error,
            onDismiss = { viewModel.clearError() }
        )
    }
} 