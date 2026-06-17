# BarberTurno - Guia de Configuracion del Entorno

## Stack Tecnologico Seleccionado

| Componente | Tecnologia | Justificacion |
|---|---|---|
| Framework | Flutter 3.x (Dart) | Multiplataforma, UI consistente, hot reload |
| Base de datos | Cloud Firestore (Firebase) | NoSQL en tiempo real, reglas de seguridad granulares, sin backend propio |
| Autenticacion | Firebase Authentication | Email/password, Google Sign-In, seguro por defecto |
| Notificaciones | Firebase Cloud Messaging | Push notifications nativas Android/iOS |
| State Management | flutter_bloc | Patron BLoC, testeable, escalable |
| Navegacion | go_router | Declarativo, deep linking, guards de autenticacion |
| Inyeccion de dependencias | get_it + injectable | Service locator, generacion de codigo |
| Arquitectura | Clean Architecture | Separacion de capas: data, domain, presentation |

## Por que Firebase y no otra base de datos

Firebase fue seleccionado considerando los requisitos del proyecto:

1. **Seguridad**: Firestore Security Rules permiten definir permisos a nivel de documento (ya configuradas en `firestore.rules`). Firebase Auth maneja tokens JWT automaticamente.

2. **Produccion real (Play Store)**: Firebase es usado por apps con millones de usuarios. El plan Spark (gratis) soporta hasta 50K lecturas/dia y 20K escrituras/dia, suficiente para iniciar.

3. **Equipo de 1-2 personas**: Elimina la necesidad de construir y mantener un backend. No hay servidores que administrar.

4. **Compatibilidad con IA**: Firebase tiene documentacion extensa y FlutterFire es el SDK oficial de Google, lo que facilita asistencia con herramientas de IA.

5. **Tiempo real**: Firestore sincroniza datos en tiempo real, ideal para que el barbero vea nuevas citas instantaneamente.

---

## PASO 1: Instalar Flutter SDK

### Windows
1. Descargar Flutter SDK desde https://docs.flutter.dev/get-started/install/windows/mobile
2. Extraer en `C:\flutter` (evitar rutas con espacios)
3. Agregar `C:\flutter\bin` al PATH del sistema
4. Ejecutar en terminal:
```bash
flutter doctor
```

### Verificar instalacion
```bash
flutter --version
dart --version
```
Se necesita Flutter 3.2+ y Dart 3.2+.

---

## PASO 2: Instalar Android Studio

1. Descargar desde https://developer.android.com/studio
2. Instalar con las opciones por defecto
3. Abrir Android Studio > Settings > Plugins > Instalar **Flutter** (incluye Dart)
4. Settings > Languages & Frameworks > Android SDK > SDK Tools:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools
5. Aceptar licencias:
```bash
flutter doctor --android-licenses
```

---

## PASO 3: Configurar Firebase

### 3.1 Crear proyecto en Firebase Console
1. Ir a https://console.firebase.google.com
2. "Agregar proyecto" > Nombre: **BarberTurno**
3. Habilitar Google Analytics (opcional pero recomendado)

### 3.2 Instalar Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### 3.3 Instalar FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 3.4 Conectar Flutter con Firebase
Desde la carpeta del proyecto:
```bash
cd barber_turno
flutterfire configure --project=TU_PROJECT_ID
```
Esto genera automaticamente `firebase_options.dart` con las credenciales.

### 3.5 Activar servicios en Firebase Console
1. **Authentication**: Ir a Authentication > Sign-in method > Habilitar "Email/Password"
2. **Firestore**: Ir a Firestore Database > Crear base de datos > Modo produccion
3. **Cloud Messaging**: Se activa automaticamente
4. **Subir reglas de seguridad**: Ir a Firestore > Rules > Pegar contenido de `firestore.rules`

---

## PASO 4: Ejecutar el proyecto

```bash
cd barber_turno
flutter pub get
flutter run
```

Si hay problemas, verificar con:
```bash
flutter doctor -v
```

---

## PASO 5: Configurar Git

```bash
cd barber_turno
git init
git add .
git commit -m "feat: proyecto inicial BarberTurno MVP v1"
```

Para trabajo en equipo, crear repositorio en GitHub y conectar:
```bash
git remote add origin https://github.com/TU_USUARIO/barber-turno.git
git push -u origin main
```

---

## Estructura del Proyecto

```
barber_turno/
  lib/
    main.dart                    # Punto de entrada
    config/
      app_router.dart            # Rutas de navegacion
      app_theme.dart             # Tema visual de la app
    core/
      constants/                 # Constantes globales
      errors/                    # Manejo de errores
      utils/                     # Utilidades comunes
      widgets/                   # Widgets reutilizables
    features/
      auth/                      # Modulo de autenticacion
        data/
          datasources/           # Conexion con Firebase Auth
          models/                # UserModel
          repositories/          # Implementacion de repositorios
        domain/
          entities/              # Entidades puras
          repositories/          # Interfaces de repositorios
          usecases/              # Casos de uso (Login, Register)
        presentation/
          bloc/                  # BLoC para auth
          pages/                 # LoginPage, RegisterPage
          widgets/               # Widgets especificos
      appointments/              # Modulo de citas (misma estructura)
      barber/                    # Modulo barbero
      admin/                     # Modulo administrador
      services/                  # Modulo servicios
      home/                      # Pantalla principal
    injection/
      injection.dart             # Configuracion de get_it
  assets/
    images/                      # Imagenes de la app
    icons/                       # Iconos personalizados
  firestore.rules                # Reglas de seguridad de Firestore
  pubspec.yaml                   # Dependencias del proyecto
```

---

## Modelo de Datos en Firestore

### Coleccion: users
```
users/{userId}
  - email: string
  - fullName: string
  - phone: string
  - role: "client" | "barber" | "admin"
  - photoUrl: string?
  - createdAt: timestamp
  - isActive: boolean
```

### Coleccion: services
```
services/{serviceId}
  - name: string
  - description: string
  - price: number
  - durationMinutes: number
  - imageUrl: string?
  - isActive: boolean
```

### Coleccion: appointments
```
appointments/{appointmentId}
  - clientId: string (ref a users)
  - clientName: string
  - barberId: string (ref a users)
  - barberName: string
  - serviceId: string (ref a services)
  - serviceName: string
  - servicePrice: number
  - dateTime: timestamp
  - durationMinutes: number
  - status: "pending" | "confirmed" | "rejected" | "completed" | "cancelled"
  - notes: string?
  - createdAt: timestamp
```

### Coleccion: schedules
```
schedules/{barberId}
  - barberId: string
  - dayOfWeek: number (1-7)
  - openTime: string ("09:00")
  - closeTime: string ("20:00")
  - blockedSlots: array<timestamp>
  - isAvailable: boolean
```

---

## Checklist antes de la revision

- [ ] Flutter SDK instalado y `flutter doctor` sin errores criticos
- [ ] Android Studio con plugin Flutter instalado
- [ ] Proyecto Firebase creado en la consola
- [ ] FlutterFire configurado (`flutterfire configure`)
- [ ] Authentication habilitado (Email/Password)
- [ ] Firestore creado en modo produccion
- [ ] Reglas de seguridad subidas
- [ ] `flutter pub get` ejecutado sin errores
- [ ] `flutter run` funciona en emulador o dispositivo fisico
- [ ] Repositorio Git inicializado
