# Reserva Pista Gilena

Aplicación Android nativa para la gestión de reservas de pistas en un polideportivo municipal. Permite a los usuarios ver disponibilidad, realizar reservas y gestionar su perfil de manera intuitiva.

## 🏗️ Arquitectura Técnica

### Stack Tecnológico
- **Plataforma**: Android nativo (Kotlin)
- **Framework de UI**: Jetpack Compose
- **Arquitectura**: Clean Architecture con diseño por capas
- **Inyección de Dependencias**: Dagger Hilt
- **Base de Datos Local**: Room
- **Backend**: Firebase (Firestore Database)
- **Autenticación**: Firebase Auth
- **Configuración**: Firebase Remote Config

### Estructura de Capas

La aplicación sigue una estructura de carpetas específica con 6 capas principales:

#### 1. **Capa Data** (`data/`)
- **Core**: Utilidades comunes como mapeos genéricos y manejo de excepciones
- **Entities**: Modelos de datos, DTOs y entidades de base de datos
- **Manager**: Lógica de acceso a datos, gestores de base de datos y configuración de servicios
- **Repository**: Clases que implementan los repositorios usando fuentes locales y remotas

#### 2. **Capa DI** (`di/`)
- Módulos de inyección de dependencias para Dagger Hilt

#### 3. **Capa Domain** (`domain/`)
- **Core**: Clases y tipos compartidos, manejo de errores de dominio
- **Model**: Modelos de negocio independientes de la capa de datos
- **Repository**: Interfaces de repositorios que definen operaciones de negocio
- **UseCases**: Casos de uso que representan acciones de negocio

#### 4. **Capa Presentation** (`presentation/`)
- **Screens**: Pantallas principales con sus Composables y ViewModels

#### 5. **Capa UI** (`ui/`)
- **Theme**: Definición de temas globales, colores, tipografías y formas

## 🎯 Modelos de Datos

### Modelos de Base de Datos Local (Room)

#### UserEntity
```kotlin
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey val id: String,
    val fullName: String,
    val email: String,
    val registrationDate: Instant,
    val isActive: Boolean = true
)
```

#### CourtEntity
```kotlin
@Entity(tableName = "courts")
data class CourtEntity(
    @PrimaryKey val id: String,
    val courtType: String, // "tennis", "padel", "football"
    val specificOption: String,
    val isAvailable: Boolean = true,
    val imageUrl: String? = null
)
```

#### ReservationEntity
```kotlin
@Entity(tableName = "reservations")
data class ReservationEntity(
    @PrimaryKey val id: String,
    val userId: String,
    val courtId: String,
    val reservationDate: LocalDate,
    val startTime: LocalTime,
    val durationMinutes: Int = 90,
    val status: String, // "active", "cancelled", "completed"
    val createdAt: Instant
)
```

## 🏟️ Tipos de Pistas y Opciones

### Tenis
- **Pista Pasillo**: Situada junto al pasillo del polideportivo
- **Pista Piscina**: Situada junto a la piscina

### Pádel
- **Pista de Cemento**: Pista con suelo de cemento
- **Pista de Cristal**: Pista con paredes de cristal

### Fútbol Sala
- **Pista Interior**: Dentro del edificio
- **Pista Exterior**: Al aire libre

## ⏰ Sistema de Horarios

### Horarios Configurables (Firebase Remote Config)
- **Mañana**: 10:00 - 14:30 (por defecto)
- **Tarde**: 16:00 - 21:00 (por defecto)

### Slots de Tiempo
- **Duración**: Todas las reservas duran exactamente 1 hora y 30 minutos
- **Mañana**: 10:00-11:30, 11:30-13:00, 13:00-14:30
- **Tarde**: 16:00-17:30, 17:30-19:00, 19:00-20:30, 20:30-22:00

## 📋 Reglas de Negocio

### Restricciones de Reservas
- ✅ Máximo 7 días de antelación
- ✅ Máximo 1 reserva por día por usuario
- ❌ No se permiten reservas los sábados y domingos
- ❌ No se pueden hacer reservas para horarios que ya han pasado

### Permisos de Usuario
#### Usuarios no autenticados:
- Ver disponibilidad de todas las pistas
- Navegar por la app y ver horarios

#### Usuarios autenticados:
- Realizar reservas siguiendo las reglas de negocio
- Cancelar sus propias reservas
- Gestionar su perfil y ver su historial

## 🔧 Configuración del Proyecto

### 1. Clonar el repositorio
```bash
git clone <url-del-repositorio>
cd ReservaPistaGilena
```

### 2. Configurar Firebase

#### 2.1 Crear proyecto en Firebase Console
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto llamado "reserva-pista-gilena"
3. Habilita los siguientes servicios:
   - **Authentication** (Email/Password)
   - **Firestore Database**
   - **Remote Config**

#### 2.2 Configurar Authentication
1. En Firebase Console → Authentication → Sign-in method
2. Habilitar "Email/Password"

#### 2.3 Configurar Firestore Database
1. Crear la base de datos en modo "test" inicialmente
2. Configurar las siguientes colecciones:

##### Colección `users`
```javascript
// Documento de ejemplo
{
  id: "user123",
  fullName: "Juan Pérez",
  email: "juan@email.com",
  registrationDate: 1640995200000,
  isActive: true,
  reservationCount: 5
}
```

##### Colección `courts`
```javascript
// Documentos de ejemplo para cada pista
{
  id: "tennis_pasillo",
  courtType: "tennis",
  specificOption: "pasillo",
  isAvailable: true,
  imageUrl: null,
  displayOrder: 1
},
{
  id: "tennis_piscina",
  courtType: "tennis",
  specificOption: "piscina",
  isAvailable: true,
  imageUrl: null,
  displayOrder: 2
},
{
  id: "padel_cemento",
  courtType: "padel",
  specificOption: "cemento",
  isAvailable: true,
  imageUrl: null,
  displayOrder: 3
},
{
  id: "padel_cristal",
  courtType: "padel",
  specificOption: "cristal",
  isAvailable: true,
  imageUrl: null,
  displayOrder: 4
},
{
  id: "football_interior",
  courtType: "football",
  specificOption: "interior",
  isAvailable: true,
  imageUrl: null,
  displayOrder: 5
},
{
  id: "football_exterior",
  courtType: "football",
  specificOption: "exterior",
  isAvailable: true,
  imageUrl: null,
  displayOrder: 6
}
```

##### Colección `reservations`
```javascript
// Documento de ejemplo
{
  id: "reservation123",
  userId: "user123",
  courtId: "tennis_pasillo",
  reservationDate: "2024-01-15",
  startTime: "10:00",
  durationMinutes: 90,
  status: "active",
  createdAt: 1640995200000,
  year: 2024,
  month: 1,
  dayOfWeek: 1
}
```

#### 2.4 Configurar Remote Config
Añadir las siguientes claves con sus valores por defecto:
- `morning_start_time`: "10:00"
- `morning_end_time`: "14:30"
- `afternoon_start_time`: "16:00"
- `afternoon_end_time`: "21:00"

#### 2.5 Configurar reglas de seguridad de Firestore
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios pueden leer y escribir solo sus propios datos
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Pistas son de solo lectura para usuarios autenticados
    match /courts/{courtId} {
      allow read: if request.auth != null;
    }
    
    // Reservas - usuarios pueden leer/escribir solo las suyas
    match /reservations/{reservationId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

#### 2.6 Descargar google-services.json
1. En Firebase Console → Project Settings → General
2. En la sección "Your apps", selecciona la app Android
3. Descarga el archivo `google-services.json`
4. **IMPORTANTE**: Reemplaza el archivo `app/google-services.json` actual con el tuyo

### 3. Compilar y ejecutar
```bash
./gradlew assembleDebug
# o desde Android Studio: Build → Make Project
```

## 📱 Pantallas de la Aplicación

### 1. Pantalla Principal (Home)
- Muestra tres tarjetas para cada tipo de pista
- Indicador visual de disponibilidad general
- Botón para login/perfil en la barra superior

### 2. Pantalla de Selección de Opciones
- Opciones específicas de cada tipo de pista
- Botón "Ver Disponibilidad" o "Reservar" según autenticación

### 3. Pantalla de Calendario
- Próximos 7 días (excluyendo fines de semana)
- Slots de tiempo disponibles/ocupados
- Selección de slot disponible

### 4. Pantalla de Confirmación
- Resumen completo de la reserva
- Información de pista, fecha, hora y duración
- Botón "Confirmar Reserva"

### 5. Pantalla de Perfil
- Información personal editable
- "Mis Reservas Activas"
- Historial de reservas
- Opción para cerrar sesión

## 🔧 Casos de Uso Principales

### Gestión de Usuarios
- `LoginUserUseCase`: Autenticación de usuarios
- `RegisterUserUseCase`: Registro de nuevos usuarios

### Gestión de Reservas
- `CreateReservationUseCase`: Crear nuevas reservas con validaciones
- `CancelReservationUseCase`: Cancelar reservas existentes
- `GetAvailableSlotsUseCase`: Obtener slots disponibles

### Validaciones Implementadas
- Verificación de autenticación
- Validación de reglas de tiempo (no fines de semana, no horarios pasados)
- Límite de antelación (7 días)
- Límite de reservas por día (1 por usuario)
- Verificación de disponibilidad en tiempo real

## 🎨 Sistema de Diseño

- **Base**: Material Design 3
- **Tema personalizado**: Colores representativos del polideportivo
- **Componentes consistentes**: Tarjetas, botones, campos de texto
- **Animaciones suaves** entre pantallas
- **Estados claros**: Cargando, error, éxito

## 🚀 Próximos Pasos

### Funcionalidades Pendientes
1. **Navegación completa** entre pantallas
2. **Pantallas de Login/Registro**
3. **Calendario de reservas** interactivo
4. **Notificaciones push** para recordatorios
5. **Modo offline** con sincronización
6. **Sistema de administración** para gestionar pistas

### Mejoras Técnicas
1. **Testing unitario** y de integración
2. **CI/CD pipeline**
3. **Monitoreo y analytics**
4. **Optimización de rendimiento**

## 📝 Contribución

1. Fork del proyecto
2. Crear rama para nueva funcionalidad (`git checkout -b feature/AmazingFeature`)
3. Commit de cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para detalles.

## ⚠️ Importante

- **Asegúrate de reemplazar el archivo `google-services.json` con el de tu proyecto Firebase**
- **Configura las reglas de seguridad de Firestore antes del despliegue en producción**
- **Los datos de ejemplo en este README son solo para desarrollo** 