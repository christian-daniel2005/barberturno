# BarberTurno - Contexto del Proyecto

## Descripcion
App movil de gestion de citas para barberias independientes. Permite a clientes reservar citas, a barberos administrar su agenda y a administradores gestionar el negocio.

## Stack Tecnologico
- **Framework**: Flutter 3.x (Dart)
- **Base de datos**: Cloud Firestore (Firebase)
- **Autenticacion**: Firebase Authentication (email/password)
- **Notificaciones**: Firebase Cloud Messaging
- **State Management**: flutter_bloc (patron BLoC)
- **Navegacion**: go_router
- **Inyeccion de dependencias**: get_it
- **Arquitectura**: Clean Architecture (data/domain/presentation por feature)

## Estructura del Proyecto
```
lib/
  main.dart
  config/          → app_router.dart, app_theme.dart
  core/
    constants/     → app_constants.dart (colecciones, roles, estados)
    errors/        → manejo de errores
    utils/         → utilidades comunes
    widgets/       → widgets reutilizables
  features/
    auth/          → registro, login (Firebase Auth)
    appointments/  → reservas, cancelaciones, lista de citas
    barber/        → agenda del barbero, confirmar/rechazar citas
    admin/         → CRUD servicios/barberos, dashboard, ingresos
    services/      → catalogo de servicios
    home/          → pantalla principal segun rol
  injection/       → configuracion de get_it
```

## Convenciones de Codigo
- Nombrar archivos en snake_case: `user_model.dart`, `login_page.dart`
- Clases en PascalCase: `UserModel`, `LoginPage`
- Cada feature sigue Clean Architecture:
  - `data/datasources/` → conexion con Firebase
  - `data/models/` → modelos con serialization Firestore
  - `data/repositories/` → implementacion de repositorios
  - `domain/entities/` → entidades puras (sin dependencias)
  - `domain/repositories/` → interfaces abstractas
  - `domain/usecases/` → logica de negocio
  - `presentation/bloc/` → BLoC con estados y eventos
  - `presentation/pages/` → pantallas
  - `presentation/widgets/` → widgets especificos del feature

## Modelos de Datos (Firestore)
- **users**: uid, email, fullName, phone, role (client|barber|admin), photoUrl, createdAt, isActive
- **services**: name, description, price, durationMinutes, imageUrl, isActive
- **appointments**: clientId, clientName, barberId, barberName, serviceId, serviceName, servicePrice, dateTime, durationMinutes, status (pending|confirmed|rejected|completed|cancelled), notes, createdAt
- **schedules**: barberId, dayOfWeek, openTime, closeTime, blockedSlots, isAvailable

## Reglas de Seguridad
Las reglas estan en `firestore.rules`. Resumen:
- Usuarios autenticados leen perfiles y servicios
- Solo el propio usuario edita su perfil
- Clientes crean citas, barberos confirman/rechazan, admins ven todo
- Solo admins gestionan servicios y barberos

## MVP v1 (Version actual)
Modulos: auth, cliente (reservar/cancelar citas), barbero (agenda, confirmar/rechazar), admin (CRUD servicios/barberos, horarios, ingresos basicos), sistema (motor de disponibilidad, notificaciones).

## Notas
- El proyecto se desplegara en Google Play Store (produccion real, no solo academico)
- Equipo de 1-2 personas
- Priorizar seguridad y buenas practicas
- Usar Firestore Security Rules siempre
