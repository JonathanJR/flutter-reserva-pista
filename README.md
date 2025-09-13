# Reserva Pista - Flutter App

Una aplicación Flutter multiplataforma que sigue los principios de Clean Architecture y Domain-Driven Design para la gestión de reservas de pistas deportivas en polideportivos municipales. Permite a los usuarios consultar disponibilidad, realizar reservas y gestionar su perfil de manera intuitiva tanto en usuarios autenticados como no autenticados.

## 🏗️ Arquitectura del Proyecto

Este proyecto implementa una arquitectura limpia y escalable basada en los siguientes principios:

### Clean Architecture + Domain-Driven Design

La aplicación está estructurada en capas claramente separadas que siguen el patrón de Clean Architecture:

```
lib/
├── domain/           # 🎯 Capa de Dominio
├── data/             # 💾 Capa de Datos  
├── application/      # 🔄 Capa de Aplicación
├── presentation/     # 📱 Capa de Presentación
└── core/            # ⚙️ Núcleo del Sistema
```

## 🏟️ Dominio de Negocio: Reservas Deportivas

### Tipos de Pistas Deportivas

#### 🎾 **Tenis**
- **Pista Pasillo**: Situada junto al pasillo del polideportivo
- **Pista Piscina**: Situada junto a la piscina

#### 🏓 **Pádel**
- **Pista de Cemento**: Pista con suelo de cemento
- **Pista de Cristal**: Pista con paredes de cristal

#### ⚽ **Fútbol Sala**
- **Pista Interior**: Dentro del edificio
- **Pista Exterior**: Al aire libre

### ⏰ Sistema de Horarios

#### Configuración Dinámica (Firebase Remote Config)
- **Horario Matutino**: 10:00 - 14:30 (configurable)
- **Horario Vespertino**: 16:00 - 21:00 (configurable)

#### Slots de Tiempo (Duración: 90 minutos)
- **Mañana**: 10:00-11:30, 11:30-13:00, 13:00-14:30
- **Tarde**: 16:00-17:30, 17:30-19:00, 19:00-20:30, 20:30-22:00

### 📋 Reglas de Negocio

#### Restricciones de Reservas
- ✅ **Antelación Máxima**: 7 días hábiles
- ✅ **Límite por Usuario**: 1 reserva por día
- ✅ **Máximo de Reservas Activas**: 2 por usuario
- ❌ **Días Prohibidos**: No se permiten reservas los fines de semana
- ❌ **Horarios Pasados**: No se pueden reservar slots ya transcurridos
- ⏱️ **Cancelación**: Solo hasta 2 horas antes del slot reservado

#### Permisos de Usuario
##### Usuarios No Autenticados:
- 👀 Ver disponibilidad de todas las pistas
- 📅 Consultar horarios y calendarios
- 🧭 Navegar por la aplicación

##### Usuarios Autenticados:
- 📝 Realizar reservas siguiendo las reglas de negocio
- ❌ Cancelar sus propias reservas activas
- 👤 Gestionar perfil personal
- 📊 Ver historial de reservas

### 🔥 Backend: Firebase

#### Servicios Utilizados
- **Firebase Auth**: Autenticación con email/password
- **Firestore Database**: Base de datos NoSQL para persistencia
- **Remote Config**: Configuración dinámica de horarios
- **Cloud Functions**: Lógica de servidor (futuro)

## 📁 Estructura de Carpetas

### 🎯 **Domain Layer** (`domain/`)
**Responsabilidad**: Contiene la lógica de negocio pura del dominio de reservas deportivas.

```
domain/
├── entities/         # Entidades del dominio (User, Court, Reservation)
├── enums/           # Enums (CourtType, ReservationStatus, TimeSlot)
├── events/          # Eventos (AuthEvent, ReservationEvent, CourtEvent)
├── i_repositories/  # Interfaces (IUserRepository, ICourtRepository, IReservationRepository)
├── models/          # Modelos UI (UserUI, CourtUI, ReservationUI, SportInfo)
├── providers/       # Proveedores de dominio (auth, courts, reservations)
└── use_case/        # Casos de uso específicos del dominio
    ├── auth/        # Login, Register, Logout, GetCurrentUser
    ├── courts/      # GetCourts, GetCourtsByType, RefreshCourts
    └── reservations/# CreateReservation, CancelReservation, GetAvailableSlots
```

**Modelos de Dominio**:
- 👤 **User**: Gestión de usuarios y perfiles
- 🏟️ **Court**: Pistas deportivas con tipos específicos
- 📅 **Reservation**: Reservas con validaciones de negocio
- ⏰ **TimeSlot**: Slots de tiempo disponibles/ocupados

**Casos de Uso Principales**:
- 🔐 **Autenticación**: Login, registro, gestión de sesión
- 🏟️ **Gestión de Pistas**: Consulta por tipo, disponibilidad
- 📝 **Reservas**: Crear, cancelar, validar reglas de negocio
- 📊 **Consultas**: Disponibilidad, historial, reservas activas

### 💾 **Data Layer** (`data/`)
**Responsabilidad**: Implementa las interfaces del dominio con Firebase como backend principal.

```
data/
├── api/             # APIs Firebase (Firestore, Auth, Remote Config)
├── data_source/     # Fuentes de datos
│   ├── local/       # Cache local (Hive/SQLite)
│   ├── remote/      # Firebase Firestore
│   └── config/      # Remote Config para configuración dinámica
├── models/          # DTOs Firebase y mappers
│   ├── user_dto.dart         # Modelo Firebase de usuarios
│   ├── court_dto.dart        # Modelo Firebase de pistas
│   ├── reservation_dto.dart  # Modelo Firebase de reservas
│   └── mappers/              # Mappers DTO ↔ Domain
├── repository/      # Implementaciones de repositorios
│   ├── user_repository_impl.dart
│   ├── court_repository_impl.dart
│   └── reservation_repository_impl.dart
└── router_guard/    # Guards de autenticación
```

**Fuentes de Datos**:
- 🔥 **Firebase Auth**: Autenticación de usuarios
- 📊 **Firestore**: Base de datos principal (users, courts, reservations)
- ⚙️ **Remote Config**: Configuración dinámica de horarios
- 💾 **Cache Local**: Optimización offline con Hive/SQLite
- 📡 **Real-time**: Escucha en tiempo real de cambios en Firestore

### 🔄 **Application Layer** (`application/`)
**Responsabilidad**: Orquesta casos de uso y maneja eventos del sistema.

```
application/
├── event_handlers/  # Manejadores de eventos (auth, lang, startup)
├── observers/       # Observadores del bus de eventos
├── providers/       # Proveedores de aplicación
└── remote_config/   # Configuración remota
```

**Características**:
- 🚌 Event Bus para comunicación asíncrona
- 🎭 Orquestación de casos de uso
- ⚙️ Configuración remota de la app
- 📡 Manejo de eventos del sistema

### 📱 **Presentation Layer** (`presentation/`)
**Responsabilidad**: Interfaz de usuario específica para reservas deportivas.

```
presentation/
├── auth/            # Autenticación
│   ├── notifier/    # AuthNotifier (login, register, logout)
│   ├── state/       # AuthState
│   └── views/       # LoginView, RegisterView
├── home/            # Pantalla principal
│   ├── notifier/    # HomeNotifier
│   ├── state/       # HomeState
│   └── views/       # HomeView (tarjetas de deportes)
├── courts/          # Pistas deportivas
│   ├── notifier/    # CourtNotifier
│   ├── state/       # CourtState
│   └── views/       # CourtListView, CourtOptionsView
├── calendar/        # Calendario de reservas
│   ├── notifier/    # CalendarNotifier
│   ├── state/       # CalendarState
│   └── views/       # CalendarView, TimeSlotView
├── reservations/    # Gestión de reservas
│   ├── notifier/    # ReservationNotifier
│   ├── state/       # ReservationState
│   └── views/       # MyReservationsView, ConfirmationView
├── profile/         # Perfil de usuario
│   ├── notifier/    # ProfileNotifier
│   ├── state/       # ProfileState
│   └── views/       # ProfileView, EditProfileView
├── common/          # Componentes compartidos
│   ├── widgets/     # CourtCard, ReservationCard, TimeSlotButton
│   ├── dialogs/     # ConfirmDialog, ErrorDialog
│   └── forms/       # LoginForm, ReservationForm
└── main_navigation/ # Navegación con Go Router
```

**Pantallas Principales**:
- 🏠 **Home**: Tarjetas por deporte (Tenis, Pádel, Fútbol Sala)
- 🏟️ **Court Options**: Opciones específicas por tipo de pista
- 📅 **Calendar**: Selección de fecha y visualización de disponibilidad
- ⏰ **Time Slots**: Selección de horario disponible
- ✅ **Confirmation**: Confirmación de reserva con resumen
- 📋 **My Reservations**: Reservas activas e historial
- 👤 **Profile**: Gestión de perfil y configuración
- 🔐 **Auth**: Login y registro de usuarios

### ⚙️ **Core Layer** (`core/`)
**Responsabilidad**: Funcionalidades transversales y configuración del sistema.

```
core/
├── constants/       # Constantes y configuración de entorno
├── interceptor/     # Interceptores HTTP
├── keys/            # Claves API por entorno (dev, stg, prd)
├── listener/        # Listeners del sistema
├── navigation/      # Configuración de rutas
├── providers/       # Proveedores del core
├── theme/           # Tema y assets generados
└── utils/           # Utilidades generales
```

**Características**:
- 🔐 Gestión de configuración por entornos
- 🌐 Configuración de clientes HTTP
- 🎨 Sistema de temas
- 🛠️ Utilidades transversales

## 🛠️ Stack Tecnológico

### 🔥 Backend as a Service (Firebase)
- **Firebase Auth**: Autenticación con email/password
- **Firestore Database**: Base de datos NoSQL en tiempo real
- **Firebase Remote Config**: Configuración dinámica de horarios
- **Firebase Storage**: Almacenamiento de archivos (futuro)
- **Firebase Functions**: Lógica de servidor (futuro)

### 📱 State Management
- **Riverpod**: Gestión del estado reactivo y dependency injection
- **Freezed**: Inmutabilidad y generación de código
- **Reactive State**: Estados tipados para UI (Loading, Success, Error)

### 🧭 Navegación
- **Go Router**: Navegación declarativa con rutas tipadas
- **Navegación Condicional**: Rutas protegidas por autenticación
- **Deep Linking**: Enlaces profundos a reservas específicas

### 🌐 Data & Cache
- **Hive**: Base de datos local para cache offline
- **Real-time Subscriptions**: Actualizaciones en tiempo real vía Firestore
- **Repository Pattern**: Abstracción de fuentes de datos

### 📅 Funcionalidades Específicas
- **DateTime Handling**: Manejo de fechas y horarios con timezone
- **Business Rules Validation**: Validación de reglas de reserva
- **Calendar Integration**: Sistema de calendario personalizado
- **Time Slot Management**: Gestión de slots de tiempo disponibles

### 🎨 UI/UX
- **Material Design 3**: Componentes modernos de Flutter
- **Custom Theme**: Tema personalizado para deportes
- **Responsive Design**: Adaptación a diferentes tamaños de pantalla
- **Loading States**: Estados de carga informativos

### 🔧 Configuración y Entornos
- **Multi-environment**: dev, stg, prd (Firebase projects)
- **Remote Config**: Configuración dinámica desde Firebase
- **Feature Flags**: Control de características remotas
- **Environment Variables**: Configuración segura por entorno

### 📊 Monitoreo y Analytics
- **Firebase Analytics**: Seguimiento de eventos de usuario
- **Firebase Crashlytics**: Reporte de errores en producción
- **Performance Monitoring**: Métricas de rendimiento

## 🔄 Flujo de Datos

### Flujo de Reserva Completo
1. **Selección de Deporte** → HomeView → CourtNotifier
2. **Selección de Pista** → OptionsView → CalendarNotifier
3. **Selección de Fecha** → CalendarView → TimeSlot Query
4. **Selección de Horario** → TimeSlotView → ReservationNotifier
5. **Validación de Reglas** → CreateReservationUseCase
6. **Persistencia** → Firebase Firestore
7. **Confirmación** → ConfirmationView → Estado Actualizado

### Flujo de Datos Reactivo
1. **UI Event** → Presentation Layer (Notifier)
2. **Use Case Execution** → Domain Layer  
3. **Repository Call** → Data Layer
4. **Firebase Query** → Firestore/Auth
5. **Real-time Updates** → Stream Subscription
6. **Data Mapping** → DTO → Domain Models
7. **State Update** → UI Reactivity → Widget Rebuild

## 📊 Modelos de Datos

### Esquemas de Firebase

#### Colección `users`
```dart
class UserDTO {
  final String id;                    // Firebase UID
  final String fullName;
  final String email;
  final DateTime registrationDate;
  final bool isActive;
  final int reservationCount;         // Contador de reservas históricas
}
```

#### Colección `courts`
```dart
class CourtDTO {
  final String id;                    // e.g., "tennis_pasillo"
  final String courtType;             // "tennis", "padel", "football"
  final String specificOption;       // "pasillo", "cemento", "interior"
  final bool isAvailable;
  final String? imageUrl;
  final int displayOrder;             // Orden de visualización
}
```

#### Colección `reservations`
```dart
class ReservationDTO {
  final String id;                    // UUID de la reserva
  final String userId;                // Firebase UID del usuario
  final String courtId;               // ID de la pista
  final String reservationDate;       // "2024-01-15" (ISO Date)
  final String startTime;             // "10:00" (HH:mm format)
  final int durationMinutes;          // Siempre 90 minutos
  final String status;                // "active", "cancelled", "completed"
  final int createdAt;                // Timestamp Unix
  final int year;                     // Para indexación
  final int month;                    // Para indexación
  final int dayOfWeek;                // 1=Lunes, 7=Domingo
}
```

### Modelos de Dominio

#### UserUI (Domain Model)
- Información de perfil con datos calculados
- Estados de autenticación
- Validación de permisos

#### CourtUI (Domain Model)
- Información enriquecida con nombres localizados
- Estado de disponibilidad
- Iconos y colores por tipo de deporte

#### ReservationUI (Domain Model)
- Información de reserva con formateo localizado
- Validación de reglas de cancelación
- Estado calculado (activa, pasada, cancelable)

#### TimeSlot (Value Object)
- Slots de tiempo con disponibilidad
- Validación de horarios permitidos
- Formateo para UI

## 🚀 Patrones Implementados

### 🏛️ **Arquitecturales**
- ✅ Clean Architecture
- ✅ Domain-Driven Design (DDD)
- ✅ Onion Architecture
- ✅ Event-Driven Architecture

### 🧩 **De Diseño**
- ✅ Repository Pattern
- ✅ Use Case Pattern  
- ✅ Factory Pattern
- ✅ Observer Pattern
- ✅ Provider Pattern
- ✅ MVVM Pattern

### 🔄 **De Estado**
- ✅ Unidirectional Data Flow
- ✅ Reactive Programming
- ✅ Dependency Injection
- ✅ State Management con Riverpod

## 🎯 Principios SOLID

- **S** - Single Responsibility: Cada clase tiene una única responsabilidad
- **O** - Open/Closed: Abierto para extensión, cerrado para modificación
- **L** - Liskov Substitution: Las implementaciones son intercambiables
- **I** - Interface Segregation: Interfaces específicas y cohesivas
- **D** - Dependency Inversion: Dependencia de abstracciones, no de concreciones

## 📋 Convenciones de Nomenclatura

### Archivos y Carpetas
- `snake_case` para archivos y carpetas
- `PascalCase` para clases
- `camelCase` para variables y funciones

### Organización por Características
```
presentation/
├── home/
│   ├── notifier/home_notifier.dart
│   ├── state/home_state.dart
│   └── views/home_view.dart
```

### Providers (Riverpod)
```dart
@riverpod
class HomeNotifier extends _$HomeNotifier {
  // Implementación
}

final repositoryProvider = Provider<Repository>((ref) => 
  RepositoryImpl(ref.read(dataSourceProvider))
);
```

## 🧪 Testing Strategy

- **Unit Tests**: Casos de uso y lógica de negocio
- **Widget Tests**: Componentes de UI
- **Integration Tests**: Flujos completos
- **Golden Tests**: Comparación visual

## 🚀 Getting Started

### Requisitos Previos
- **Flutter SDK**: ^3.19.0
- **Dart SDK**: ^3.3.0
- **Firebase CLI**: Para configurar proyectos Firebase
- **FlutterFire CLI**: Para configuración automática de Firebase

### Configuración del Proyecto

#### 1. Clonar y Configurar Dependencias
```bash
git clone <repository-url>
cd reserva-pista-flutter
flutter pub get
```

#### 2. Configuración de Firebase

##### 2.1 Crear Proyectos Firebase
- **Dev**: `reserva-pista-dev`
- **Staging**: `reserva-pista-stg`  
- **Production**: `reserva-pista-prod`

##### 2.2 Habilitar Servicios Firebase
```bash
# Habilitar Authentication (Email/Password)
# Habilitar Firestore Database
# Habilitar Remote Config
# Habilitar Analytics & Crashlytics
```

##### 2.3 Configurar FlutterFire
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar para cada entorno
flutterfire configure --project=reserva-pista-dev
flutterfire configure --project=reserva-pista-stg  
flutterfire configure --project=reserva-pista-prod
```

#### 3. Configurar Datos Base en Firestore

##### Colección `courts` (Datos iniciales)
```javascript
// Documento: tennis_pasillo
{
  "id": "tennis_pasillo",
  "courtType": "tennis",
  "specificOption": "pasillo", 
  "isAvailable": true,
  "displayOrder": 1
}

// Documento: tennis_piscina
{
  "id": "tennis_piscina",
  "courtType": "tennis",
  "specificOption": "piscina",
  "isAvailable": true, 
  "displayOrder": 2
}

// Documento: padel_cemento
{
  "id": "padel_cemento",
  "courtType": "padel",
  "specificOption": "cemento",
  "isAvailable": true,
  "displayOrder": 3
}

// Documento: padel_cristal
{
  "id": "padel_cristal", 
  "courtType": "padel",
  "specificOption": "cristal",
  "isAvailable": true,
  "displayOrder": 4
}

// Documento: football_interior
{
  "id": "football_interior",
  "courtType": "football", 
  "specificOption": "interior",
  "isAvailable": true,
  "displayOrder": 5
}

// Documento: football_exterior  
{
  "id": "football_exterior",
  "courtType": "football",
  "specificOption": "exterior", 
  "isAvailable": true,
  "displayOrder": 6
}
```

##### Remote Config (Configuración de Horarios)
```javascript
{
  "morning_start_hour": 10,
  "morning_end_hour": 14, 
  "morning_end_minute": 30,
  "afternoon_start_hour": 16,
  "afternoon_end_hour": 21,
  "afternoon_end_minute": 0,
  "max_days_advance": 7,
  "reservation_duration_minutes": 90,
  "min_cancellation_hours": 2
}
```

#### 4. Ejecutar la Aplicación
```bash
# Desarrollo
flutter run --flavor dev --target lib/main_dev.dart

# Staging  
flutter run --flavor stg --target lib/main_stg.dart

# Producción
flutter run --flavor prd --target lib/main_prd.dart
```

### 📱 Pantallas de la Aplicación

#### Flujo de Usuario No Autenticado
1. **🏠 Home Screen**: Tarjetas de deportes (Tenis, Pádel, Fútbol Sala)
2. **🏟️ Court Options**: Selección de tipo específico de pista
3. **📅 Calendar View**: Calendario de próximos 7 días laborables
4. **⏰ Time Slots**: Horarios disponibles (solo visualización)
5. **🔐 Auth Prompt**: Solicitud de login para continuar

#### Flujo de Usuario Autenticado
1. **🏠 Home Screen**: Tarjetas + botón perfil + indicador de sesión
2. **🏟️ Court Options**: Selección con botón "Reservar"
3. **📅 Calendar View**: Calendario interactivo con selección
4. **⏰ Time Slots**: Horarios disponibles con botones de reserva
5. **✅ Confirmation**: Resumen completo antes de confirmar
6. **🎉 Success**: Confirmación de reserva exitosa
7. **📋 My Reservations**: Gestión de reservas activas
8. **👤 Profile**: Perfil, historial y configuración

### Entornos Disponibles
- **🧪 Dev**: Desarrollo local con Firebase dev
- **🔧 Stg**: Staging/QA con Firebase stg  
- **🚀 Prd**: Producción con Firebase prod
- **🎭 Mock**: Testing con datos simulados (sin Firebase)

## 🎯 Funcionalidades Específicas

### 🏟️ **Gestión de Pistas Deportivas**
- **Catálogo Dinámico**: Tipos de pista configurables desde Firebase
- **Estado en Tiempo Real**: Disponibilidad actualizada automáticamente
- **Filtros Inteligentes**: Búsqueda por deporte, disponibilidad, horario

### 📅 **Sistema de Reservas Inteligente**
- **Validación de Reglas**: Aplicación automática de restricciones de negocio
- **Calendario Dinámico**: Solo días laborables, máximo 7 días antelación
- **Slots Optimizados**: Horarios de 90 minutos con configuración remota
- **Cancelación Inteligente**: Validación de tiempo mínimo (2 horas)

### 👤 **Gestión de Usuario Avanzada**
- **Perfil Completo**: Información personal y estadísticas
- **Historial Detallado**: Reservas pasadas con filtros y búsqueda
- **Estados de Reserva**: Activas, completadas, canceladas
- **Límites Inteligentes**: Máximo 1 por día, 2 activas por usuario

### 🔔 **Notificaciones y Recordatorios**
- **Push Notifications**: Recordatorios de reservas próximas
- **Email Confirmations**: Confirmación de reserva y cancelación
- **Alertas de Disponibilidad**: Notificación cuando se libere un slot

## 🚀 Roadmap de Funcionalidades

### 🎯 **V1.0 - MVP (Funcionalidad Básica)**
- [x] Autenticación con Firebase Auth
- [x] Visualización de pistas por deporte
- [x] Sistema de reservas con validaciones
- [x] Gestión de perfil de usuario
- [x] Historial de reservas

### 📅 **V1.1 - Mejoras de UX**
- [ ] **Modo Offline**: Cache local con sincronización
- [ ] **Filtros Avanzados**: Por fecha, deporte, disponibilidad
- [ ] **Búsqueda Inteligente**: Búsqueda de slots por criterios
- [ ] **Favoritos**: Pistas y horarios preferidos

### 🔔 **V1.2 - Notificaciones**
- [ ] **Push Notifications**: FCM integrado
- [ ] **Email Templates**: Confirmaciones automáticas
- [ ] **Recordatorios**: 24h y 2h antes de la reserva
- [ ] **Alertas**: Cambios en disponibilidad

### 👥 **V1.3 - Social Features**
- [ ] **Reservas Grupales**: Invitar amigos a reservas
- [ ] **Chat Interno**: Comunicación entre usuarios de la misma reserva
- [ ] **Ratings**: Valoración de pistas
- [ ] **Comentarios**: Feedback sobre instalaciones

### 🏆 **V2.0 - Gamificación**
- [ ] **Sistema de Puntos**: Recompensas por uso frecuente
- [ ] **Logros**: Badges por objetivos cumplidos
- [ ] **Estadísticas**: Tiempo jugado, deportes favoritos
- [ ] **Ranking**: Leaderboard de usuarios más activos

### 📊 **V2.1 - Analytics Avanzado**
- [ ] **Dashboard Admin**: Panel de administración web
- [ ] **Reportes**: Ocupación, deportes populares, estadísticas
- [ ] **Predicciones**: ML para sugerir horarios óptimos
- [ ] **Optimización**: Recomendaciones de disponibilidad

### 💰 **V3.0 - Monetización**
- [ ] **Sistema de Pagos**: Stripe/PayPal integration
- [ ] **Tarifas Dinámicas**: Precios por horario/deporte
- [ ] **Suscripciones**: Planes premium con beneficios
- [ ] **Descuentos**: Códigos promocionales y ofertas

## 🛡️ Seguridad y Reglas Firestore

### Reglas de Seguridad Implementadas
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios solo pueden acceder a sus propios datos
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Pistas son de solo lectura para usuarios autenticados
    match /courts/{courtId} {
      allow read: if request.auth != null;
    }
    
    // Reservas - usuarios solo pueden gestionar las suyas
    match /reservations/{reservationId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

---

## 📋 Beneficios de la Arquitectura

Esta arquitectura específica para reservas deportivas asegura:

- ✅ **Mantenibilidad**: Código organizado por dominio de negocio
- ✅ **Escalabilidad**: Fácil agregar nuevos deportes y funcionalidades
- ✅ **Testabilidad**: Cada caso de uso y regla de negocio es testeable
- ✅ **Flexibilidad**: Intercambio fácil de backends (Firebase → REST API)
- ✅ **Reutilización**: Componentes UI y lógica reutilizable entre deportes
- ✅ **Performance**: Cache inteligente y sincronización optimizada
- ✅ **UX Óptima**: Estados de carga, errores informativos, flujo intuitivo
- ✅ **Offline-First**: Funcionalidad básica sin conexión a internet