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

## MVP v1 (Version actual) - Especificacion completa
Objetivo: resolver la gestion informal de citas en barberias independientes. Cada modulo tiene exactamente 5 funciones.

### Modulo Cliente
1. Registro e inicio de sesion        [HECHO]
2. Visualizacion de servicios          [pendiente]
3. Seleccion de barbero                [pendiente]
4. Reserva de cita                     [pendiente]
5. Consulta y cancelacion de citas     [pendiente]

### Modulo Barbero
1. Visualizacion de agenda diaria      [pendiente]
2. Confirmacion de citas               [pendiente]
3. Rechazo de citas                    [pendiente]
4. Bloqueo de horarios no disponibles  [pendiente]
5. Marcado de clientes atendidos       [pendiente]

### Modulo Administrador
1. Gestion de servicios (CRUD)         [pendiente]
2. Gestion de barberos (CRUD)          [pendiente]
3. Visualizacion de citas programadas  [pendiente]
4. Configuracion de horarios generales [pendiente]
5. Consulta basica de ingresos diarios [pendiente]

### Funcionalidades del Sistema
1. Autenticacion de usuarios           [HECHO]
2. Gestion de reservas                 [HECHO]
3. Motor de disponibilidad de horarios [HECHO - availability_engine.dart]
4. Notificaciones de confirmacion      [HECHO - in-app en tiempo real]
5. Base de datos centralizada          [HECHO - Firestore]

### Decision tecnica: notificaciones (V1)
Las "notificaciones de confirmacion" de la V1 se resuelven con actualizacion
en tiempo real dentro de la app (Firestore streams): al reservar se muestra
aviso de exito y el estado de la cita cambia solo (Pendiente -> Confirmada)
en "Mis citas". No se usan notificaciones push porque:
- Push entre dispositivos (barbero -> cliente) requiere Firebase Cloud
  Messaging + Cloud Functions, que exigen el plan Blaze (de pago).
- Las notificaciones locales NO cruzan dispositivos, asi que no resuelven
  el caso de uso real (avisar al cliente cuando el barbero confirma).
El documento del MVP ubica los "recordatorios automaticos" en la V2; las
push reales se implementaran ahi (FCM + Cloud Function al cambiar estado).

### MVP v1: COMPLETO (20/20 funciones, notificaciones via in-app real-time)

### Fuera del MVP v1 (NO implementar todavia)
- V2: historial, reprogramacion, perfil avanzado, agenda semanal/mensual,
  estadisticas, reportes, recordatorios automaticos, notificaciones push (FCM)
- V3: sistema de puntos, recompensas, promociones, multiples sucursales, pagos digitales

## Notas
- El proyecto se desplegara en Google Play Store (produccion real, no solo academico)
- Equipo de 1-2 personas
- Priorizar seguridad y buenas practicas
- Usar Firestore Security Rules siempre
