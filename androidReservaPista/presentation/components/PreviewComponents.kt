package com.jonathandevapps.reservapistagilena.presentation.components

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.jonathandevapps.reservapistagilena.ui.theme.ReservaPistaGilenaTheme

@Preview(name = "Email Field - Normal")
@Composable
private fun EmailTextFieldPreview() {
    ReservaPistaGilenaTheme {
        Surface {
            var email by remember { mutableStateOf("") }
            EmailTextField(
                value = email,
                onValueChange = { email = it },
                modifier = Modifier.padding(16.dp)
            )
        }
    }
}

@Preview(name = "Email Field - Error")
@Composable
private fun EmailTextFieldErrorPreview() {
    ReservaPistaGilenaTheme {
        Surface {
            var email by remember { mutableStateOf("invalid-email") }
            EmailTextField(
                value = email,
                onValueChange = { email = it },
                isError = true,
                errorMessage = "Invalid email format",
                modifier = Modifier.padding(16.dp)
            )
        }
    }
}

@Preview(name = "Password Field - Hidden")
@Composable
private fun PasswordTextFieldHiddenPreview() {
    ReservaPistaGilenaTheme {
        Surface {
            var password by remember { mutableStateOf("secretpassword") }
            var isVisible by remember { mutableStateOf(false) }
            
            PasswordTextField(
                value = password,
                onValueChange = { password = it },
                isVisible = isVisible,
                onVisibilityToggle = { isVisible = !isVisible },
                modifier = Modifier.padding(16.dp)
            )
        }
    }
}

@Preview(name = "Password Field - Visible")
@Composable
private fun PasswordTextFieldVisiblePreview() {
    ReservaPistaGilenaTheme {
        Surface {
            var password by remember { mutableStateOf("secretpassword") }
            var isVisible by remember { mutableStateOf(true) }
            
            PasswordTextField(
                value = password,
                onValueChange = { password = it },
                isVisible = isVisible,
                onVisibilityToggle = { isVisible = !isVisible },
                modifier = Modifier.padding(16.dp)
            )
        }
    }
}

@Preview(name = "Password Field - Error")
@Composable
private fun PasswordTextFieldErrorPreview() {
    ReservaPistaGilenaTheme {
        Surface {
            var password by remember { mutableStateOf("123") }
            var isVisible by remember { mutableStateOf(false) }
            
            PasswordTextField(
                value = password,
                onValueChange = { password = it },
                isVisible = isVisible,
                onVisibilityToggle = { isVisible = !isVisible },
                isError = true,
                errorMessage = "Password must be at least 6 characters",
                modifier = Modifier.padding(16.dp)
            )
        }
    }
}

@Preview(name = "Name Field - Normal")
@Composable
private fun NameTextFieldPreview() {
    ReservaPistaGilenaTheme {
        Surface {
            var name by remember { mutableStateOf("") }
            NameTextField(
                value = name,
                onValueChange = { name = it },
                modifier = Modifier.padding(16.dp)
            )
        }
    }
}

@Preview(name = "Name Field - Error")
@Composable
private fun NameTextFieldErrorPreview() {
    ReservaPistaGilenaTheme {
        Surface {
            var name by remember { mutableStateOf("J") }
            NameTextField(
                value = name,
                onValueChange = { name = it },
                isError = true,
                errorMessage = "Name must be at least 2 characters",
                modifier = Modifier.padding(16.dp)
            )
        }
    }
} 