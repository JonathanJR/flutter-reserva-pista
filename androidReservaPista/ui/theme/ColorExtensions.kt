package com.jonathandevapps.reservapistagilena.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

/**
 * Common alpha values used throughout the app
 */
object AppAlpha {
    const val DISABLED = 0.6f
    const val SECONDARY = 0.7f
    const val MEDIUM = 0.8f
    const val HIGH = 0.9f
}

/**
 * Extension properties for commonly used color variants
 */
val MaterialTheme.extendedColors: ExtendedColors
    @Composable get() = ExtendedColors(this)

@JvmInline
value class ExtendedColors(private val materialTheme: MaterialTheme) {
    
    // Primary colors with alpha
    val onPrimaryMedium: Color 
        @Composable get() = materialTheme.colorScheme.onPrimary.copy(alpha = AppAlpha.MEDIUM)
    
    val onPrimarySecondary: Color 
        @Composable get() = materialTheme.colorScheme.onPrimary.copy(alpha = AppAlpha.SECONDARY)
    
    val primaryDisabled: Color 
        @Composable get() = materialTheme.colorScheme.primary.copy(alpha = AppAlpha.DISABLED)
    
    val primarySecondary: Color 
        @Composable get() = materialTheme.colorScheme.primary.copy(alpha = AppAlpha.SECONDARY)
    
    val primaryMedium: Color 
        @Composable get() = materialTheme.colorScheme.primary.copy(alpha = AppAlpha.MEDIUM)
    
    // Surface colors with alpha
    val onSurfaceDisabled: Color 
        @Composable get() = materialTheme.colorScheme.onSurface.copy(alpha = AppAlpha.DISABLED)
    
    val onSurfaceSecondary: Color 
        @Composable get() = materialTheme.colorScheme.onSurface.copy(alpha = AppAlpha.SECONDARY)
    
    val onSurfaceMedium: Color 
        @Composable get() = materialTheme.colorScheme.onSurface.copy(alpha = AppAlpha.MEDIUM)
    
    // Container colors with alpha
    val onPrimaryContainerMedium: Color 
        @Composable get() = materialTheme.colorScheme.onPrimaryContainer.copy(alpha = AppAlpha.MEDIUM)
    
    val onSecondaryContainerMedium: Color 
        @Composable get() = materialTheme.colorScheme.onSecondaryContainer.copy(alpha = AppAlpha.MEDIUM)
    
    val onSecondaryContainerSecondary: Color 
        @Composable get() = materialTheme.colorScheme.onSecondaryContainer.copy(alpha = AppAlpha.SECONDARY)
    
    // Outline with alpha
    val outlineLight: Color 
        @Composable get() = materialTheme.colorScheme.outline.copy(alpha = 0.3f)
    
    // Primary with light alpha for backgrounds
    val primaryLight: Color 
        @Composable get() = materialTheme.colorScheme.primary.copy(alpha = 0.1f)
}

/**
 * Status colors with predefined alpha values
 */
object StatusColors {
    val errorMedium: Color 
        @Composable get() = ErrorRed.copy(alpha = AppAlpha.MEDIUM)
    
    val errorHigh: Color 
        @Composable get() = ErrorRed.copy(alpha = AppAlpha.HIGH)
    
    val infoMedium: Color 
        @Composable get() = InfoBlue.copy(alpha = AppAlpha.MEDIUM)
    
    val infoDisabled: Color 
        @Composable get() = InfoBlue.copy(alpha = AppAlpha.DISABLED)
} 