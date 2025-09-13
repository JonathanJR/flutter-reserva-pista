# Reserva Pista - Flutter App

Una aplicación Flutter que sigue los principios de Clean Architecture y Domain-Driven Design para la gestión de reservas de pistas deportivas.

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

## 📁 Estructura de Carpetas

### 🎯 **Domain Layer** (`domain/`)
**Responsabilidad**: Contiene la lógica de negocio pura, independiente de frameworks externos.

```
domain/
├── entities/         # Entidades del dominio
├── enums/           # Enumeraciones del negocio
├── events/          # Eventos de dominio (auth, deeplink, lang, startup)
├── i_repositories/  # Interfaces de repositorios
├── models/          # Modelos de dominio
├── providers/       # Proveedores de dominio (Riverpod)
└── use_case/        # Casos de uso (lógica de negocio)
```

**Características**:
- ✅ Sin dependencias externas
- ✅ Interfaces puras
- ✅ Lógica de negocio encapsulada
- ✅ Eventos de dominio para comunicación

### 💾 **Data Layer** (`data/`)
**Responsabilidad**: Implementa las interfaces del dominio y maneja fuentes de datos externas.

```
data/
├── api/             # APIs REST (Retrofit + Dio)
├── data_source/     # Fuentes de datos (local/remoto)
├── models/          # DTOs y modelos de datos
├── repository/      # Implementaciones de repositorios
└── router_guard/    # Guards de navegación
```

**Características**:
- 🌐 Integración con APIs REST
- 💽 Manejo de datos locales y remotos
- 🔄 Mapeo entre DTOs y entidades de dominio
- 🛡️ Implementación del patrón Repository

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
**Responsabilidad**: Interfaz de usuario y manejo del estado de la UI.

```
presentation/
├── [feature]/
│   ├── notifier/    # Riverpod Notifiers (State Management)
│   ├── state/       # Estados de la UI
│   └── views/       # Widgets y páginas
├── common/          # Componentes compartidos
└── main_navigation/ # Navegación principal
```

**Características**:
- 🎨 Implementación MVVM con Riverpod
- 🧩 Componentes reutilizables
- 🧭 Navegación declarativa con Go Router
- 🔄 Manejo reactivo del estado

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

### State Management
- **Riverpod**: Gestión del estado reactivo y dependency injection
- **Freezed**: Inmutabilidad y generación de código

### Navegación
- **Go Router**: Navegación declarativa con rutas tipadas
- **Navegación por pestañas**: Bottom navigation con shell routes

### Networking
- **Dio**: Cliente HTTP con interceptores
- **Retrofit**: Generación automática de APIs REST
- **Cache**: Sistema de caché integrado

### Arquitectura de Eventos
- **Event Bus**: Comunicación asíncrona entre capas
- **Domain Events**: Eventos tipados del dominio
- **Event Handlers**: Manejadores especializados

### Configuración y Entornos
- **Multi-environment**: dev, stg, prd, mock
- **Remote Config**: Configuración remota dinámica
- **Feature Flags**: Control de características

### Analytics y Privacy
- **Adobe Analytics**: Seguimiento de eventos
- **OneTrust**: Gestión de privacidad y consentimientos

### Internacionalización
- **Easy Localization**: Soporte multi-idioma
- **Assets Generation**: Generación automática de assets

## 🔄 Flujo de Datos

1. **UI Event** → Presentation Layer (Notifier)
2. **Use Case Execution** → Application Layer  
3. **Repository Call** → Data Layer
4. **API/Local Data** → External Sources
5. **Data Mapping** → Domain Models
6. **State Update** → UI Reactivity

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
- Flutter SDK ^3.0.0
- Dart SDK ^3.0.0

### Configuración del Proyecto
1. Clonar el repositorio
2. Ejecutar `flutter pub get`
3. Configurar las claves de API en `core/keys/`
4. Ejecutar `flutter run --flavor dev`

### Entornos Disponibles
- `dev`: Desarrollo local
- `stg`: Staging/QA  
- `prd`: Producción
- `mock`: Testing con datos mockeados

---

Esta arquitectura asegura:
- ✅ **Mantenibilidad**: Código organizado y separación clara de responsabilidades
- ✅ **Escalabilidad**: Fácil agregar nuevas características
- ✅ **Testabilidad**: Cada capa puede probarse de forma aislada  
- ✅ **Flexibilidad**: Intercambio fácil de implementaciones
- ✅ **Reutilización**: Componentes y lógica reutilizable