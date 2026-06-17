# Arquitectura del Proyecto — BarberTurno MVP v1

Documento de referencia para la explicación técnica. Describe **dónde está el
frontend**, **dónde está el backend**, **dónde está cada módulo** y **cómo
fluyen los datos**.

---

## 1. Visión general

BarberTurno es una aplicación **cliente-servidor**:

```
┌──────────────────────────────┐         ┌──────────────────────────────┐
│         FRONTEND             │         │           BACKEND            │
│   (App Flutter en el móvil)  │ ◄─────► │      (Firebase en la nube)   │
│                              │         │                              │
│  - Pantallas (UI)            │         │  - Authentication (login)    │
│  - Lógica de estado (BLoC)   │         │  - Cloud Firestore (datos)   │
│  - Navegación por rol        │         │  - Security Rules (permisos) │
└──────────────────────────────┘         └──────────────────────────────┘
```

- El **frontend** es todo el código Dart/Flutter dentro de la carpeta `lib/`.
- El **backend** NO es código propio: es **Firebase** (servicios gestionados de
  Google). No hay servidor que mantener; Firebase provee base de datos,
  autenticación y reglas de seguridad.

---

## 2. ¿Dónde está el FRONTEND?

Todo en la carpeta **`lib/`**. Es una app Flutter que compila a Android, iOS y Web.

```
lib/
├── main.dart                 → Punto de entrada; inicializa Firebase y la app
├── firebase_options.dart     → Configuración de conexión a Firebase (autogenerado)
│
├── config/                   → Configuración transversal
│   ├── app_router.dart       → Rutas y control de acceso por ROL (go_router)
│   └── app_theme.dart        → Tema visual (paleta Cobre/Bronce, tipografía)
│
├── core/                     → Código compartido por toda la app
│   ├── constants/            → Nombres de colecciones, roles, estados de cita
│   └── utils/                → Utilidades (badges de estado, refresh del router)
│
├── injection/                → Inyección de dependencias (get_it)
│   └── injection.dart        → Registra repositorios y BLoCs
│
└── features/                 → UN FOLDER POR MÓDULO (ver sección 4)
```

La capa de **presentación** (lo que el usuario ve y toca) vive en
`features/<módulo>/presentation/` (páginas + BLoC).

---

## 3. ¿Dónde está el BACKEND?

El backend es **Firebase**, configurado en la consola web. El proyecto se llama
`barberturno-d3ec6`. Tiene tres piezas:

| Servicio Firebase | Función | Dónde se ve en el código |
|---|---|---|
| **Authentication** | Registro/login con email y contraseña | `features/auth/data/datasources/` |
| **Cloud Firestore** | Base de datos NoSQL en tiempo real | repositorios `data/repositories/` |
| **Security Rules** | Permisos de lectura/escritura por rol | `firestore.rules` (raíz del proyecto) |

La app **no habla con un servidor propio**: cada repositorio del frontend se
conecta directamente a Firestore mediante el SDK oficial de Firebase.

### Modelo de datos en Firestore (colecciones)

| Colección | Qué guarda |
|---|---|
| `users` | uid, email, fullName, phone, **role** (client/barber/admin), isActive |
| `services` | nombre, descripción, precio, duración, isActive |
| `barbers` | perfil del barbero (id = uid del usuario), especialidad, isActive |
| `appointments` | cliente, barbero, servicio, fecha/hora, **estado**, precio |
| `schedules` | `config` = horario general + documentos de bloqueos por barbero |

### Reglas de seguridad (`firestore.rules`)
- Solo usuarios autenticados leen datos.
- Solo el **admin** gestiona servicios y barberos.
- Los **clientes** crean citas; **barberos** las confirman/rechazan.
- Cada quien solo edita lo que le corresponde.

---

## 4. ¿Dónde está cada MÓDULO?

Cada módulo es una carpeta dentro de `lib/features/`. El MVP tiene 6:

| Módulo | Carpeta | Responsabilidad |
|---|---|---|
| **Autenticación** | `features/auth/` | Registro, login, detección de rol |
| **Servicios** | `features/services/` | Catálogo de cortes (admin CRUD, cliente ve) |
| **Barberos** | `features/barber/` | Perfiles, promoción, agenda del barbero |
| **Reservas/Citas** | `features/appointments/` | Reserva, cancelación, agenda, estados |
| **Horarios** | `features/schedule/` | Horario general + motor de disponibilidad |
| **Administración** | `features/admin/` | Dashboard, gestión, ingresos |
| **Inicio** | `features/home/` | Pantalla principal del cliente |

### Mapa rápido: función del MVP → archivo

| Función | Archivo principal |
|---|---|
| Login / Registro | `auth/presentation/pages/login_page.dart`, `register_page.dart` |
| Catálogo de servicios (cliente) | `services/presentation/pages/services_page.dart` |
| Reservar cita | `appointments/presentation/pages/booking_page.dart` |
| Mis citas / cancelar | `appointments/presentation/pages/my_appointments_page.dart` |
| Agenda del barbero | `barber/presentation/pages/barber_agenda_page.dart` |
| Motor de disponibilidad | `schedule/domain/availability_engine.dart` |
| Panel admin | `admin/presentation/pages/admin_dashboard_page.dart` |
| Gestión de servicios (admin) | `admin/presentation/pages/manage_services_page.dart` |
| Gestión de barberos (admin) | `admin/presentation/pages/manage_barbers_page.dart` |
| Configurar horarios (admin) | `admin/presentation/pages/manage_schedule_page.dart` |

---

## 5. Clean Architecture (cómo se organiza cada módulo)

Cada módulo separa responsabilidades en 3 capas. Ejemplo con `auth`:

```
features/auth/
├── domain/          → REGLAS DE NEGOCIO (Dart puro, sin Firebase)
│   ├── entities/        → UserEntity (objeto de negocio)
│   ├── repositories/    → AuthRepository (interfaz/contrato)
│   └── usecases/        → LoginUseCase, RegisterUseCase, LogoutUseCase
│
├── data/            → CONEXIÓN CON FIREBASE (implementación)
│   ├── models/          → UserModel (serialización desde/hacia Firestore)
│   ├── datasources/     → AuthRemoteDatasource (llama a Firebase)
│   └── repositories/    → AuthRepositoryImpl (implementa el contrato)
│
└── presentation/    → INTERFAZ DE USUARIO
    ├── bloc/            → AuthBloc + eventos + estados
    └── pages/           → LoginPage, RegisterPage
```

**¿Por qué así?** La capa `domain` no depende de Firebase. Si mañana se cambia
Firebase por otra base de datos, solo se reescribe `data/`, sin tocar la lógica
de negocio ni la interfaz. Es mantenible y testeable.

> Nota: los módulos de CRUD simple (servicios, barberos, horarios) usan una
> versión pragmática (repositorio + BLoC + páginas) sin la capa `domain`
> completa, para no sobre-complicar funciones sencillas. `auth` muestra el
> patrón completo de referencia.

---

## 6. Flujo de datos (ejemplo: reservar una cita)

```
1. Cliente toca "Confirmar reserva"   (booking_page.dart  → PRESENTACIÓN)
2. Se crea un AppointmentModel        (appointment_model.dart → DATA)
3. AppointmentRepository.createAppointment()  → escribe en Firestore (BACKEND)
4. Firestore valida con firestore.rules       → ¿el clienteId == usuario? Sí
5. La cita queda guardada con estado "pending"
6. El barbero, en su agenda, recibe la cita EN TIEMPO REAL (stream de Firestore)
7. El barbero confirma → updateStatus("confirmed")
8. El cliente ve el cambio EN TIEMPO REAL en "Mis citas"
```

El **tiempo real** lo da Firestore mediante *streams*: cuando un documento
cambia en la nube, la UI suscrita se actualiza sola, sin recargar.

---

## 7. Control de acceso por rol

`config/app_router.dart` decide a qué pantalla entra cada usuario:

```
admin   → /admin            (Panel de administración)
barber  → /barber/agenda    (Mi agenda)
client  → /home             (Inicio del cliente)
```

El router lee el rol desde el `AuthBloc` (que a su vez lo obtuvo de Firestore al
iniciar sesión) y redirige automáticamente. Un usuario no puede acceder a
pantallas que no le corresponden.

---

## 8. Resumen para la exposición

- **Frontend:** Flutter (`lib/`), organizado por módulos con Clean Architecture.
- **Backend:** Firebase (Authentication + Firestore + Security Rules). Sin servidor propio.
- **Comunicación:** los repositorios del frontend hablan directo con Firestore vía SDK.
- **Tiempo real:** los datos se sincronizan solos mediante *streams*.
- **Seguridad:** reglas declarativas en `firestore.rules` controlan permisos por rol.
