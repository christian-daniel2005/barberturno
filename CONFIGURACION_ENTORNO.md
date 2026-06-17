# Documentación: Configuración del Entorno de Desarrollo
## BarberTurno MVP v1

**Fecha de configuración**: 17 de junio de 2026  
**Estado**: ✅ Completado  
**Plataforma**: Windows 11

---

## 📋 Tabla de Contenidos

1. [Herramientas Instaladas](#herramientas-instaladas)
2. [Instalación de Flutter](#instalación-de-flutter)
3. [Instalación de Node.js](#instalación-de-nodejs)
4. [Instalación de Firebase CLI](#instalación-de-firebase-cli)
5. [Instalación de FlutterFire CLI](#instalación-de-flutterfire-cli)
6. [Configuración de Firebase Console](#configuración-de-firebase-console)
7. [Configuración del Proyecto Flutter](#configuración-del-proyecto-flutter)
8. [Verificación Final](#verificación-final)

---

## 🛠️ Herramientas Instaladas

| Herramienta | Versión | Método | Ubicación |
|---|---|---|---|
| Flutter SDK | 3.44.2 | Descarga automática | `C:\flutter` |
| Dart SDK | 3.12.2 | Incluido con Flutter | `C:\flutter\bin\dart.bat` |
| Node.js | 24.12.0 | Pre-instalado | Sistema |
| npm | 11.6.2 | Incluido con Node.js | Sistema |
| Git | 2.52.0 | Pre-instalado | Sistema |
| Firebase CLI | 15.20.0 | npm | Sistema |
| FlutterFire CLI | 1.4.0 | dart pub global | `C:\Users\CRISTIAN\AppData\Local\Pub\Cache\bin` |
| Android SDK | 37.0.0 | Pre-instalado | `C:\Users\CRISTIAN\AppData\Local\Android\sdk` |

---

## 📥 Instalación de Flutter

### Estado Inicial
Flutter ya estaba instalado en el sistema en `C:\flutter` desde instalaciones previas.

### Verificación Realizada
```bash
flutter --version
# Resultado: Flutter 3.44.2 • channel stable
```

### Configuración PATH
Flutter ya estaba agregado al PATH del usuario:
- Variable: `Path` (User environment variables)
- Valor: `C:\flutter\bin`

### Verificación de Dart
```bash
dart --version
# Resultado: Dart SDK version: 3.12.2 (stable)
```

---

## 📥 Instalación de Node.js

### Estado Inicial
Node.js v24.12.0 y npm 11.6.2 ya estaban pre-instalados en el sistema.

### Verificación Realizada
```bash
node --version      # v24.12.0
npm --version       # 11.6.2
```

**Función**: Requerido para Firebase CLI y Claude Code CLI.

---

## 📥 Instalación de Firebase CLI

### Método: npm (Gestor de paquetes Node.js)

**Comando ejecutado:**
```bash
npm install -g firebase-tools
```

### Proceso
1. Descargó 677 paquetes desde npm registry
2. Instaló globalmente en el sistema
3. Tiempo de instalación: ~24 segundos

### Verificación
```bash
firebase --version
# Resultado: 15.20.0
```

### Configuración PATH
- Automáticamente agregado al PATH por npm
- Ubicación: `C:\Users\CRISTIAN\AppData\Local\Programs\npm`

### Autenticación Firebase
**Comando ejecutado en cmd.exe:**
```cmd
firebase login
```

**Proceso:**
1. Abrió navegador para autenticación
2. Inició sesión con cuenta Google de Firebase
3. Autorizó acceso a Firebase CLI
4. Sesión guardada para comandos posteriores

**Nota**: Necesario ejecutar en `cmd.exe` en lugar de PowerShell debido a limitaciones de ejecución de scripts.

---

## 📥 Instalación de FlutterFire CLI

### Método: Dart pub (Gestor de paquetes Dart)

**Comando ejecutado:**
```bash
C:\flutter\bin\dart.bat pub global activate flutterfire_cli
```

### Proceso
1. Descargó 34 paquetes de pub.dev
2. Compiló ejecutable `flutterfire.bat`
3. Ubicación: `C:\Users\CRISTIAN\AppData\Local\Pub\Cache\bin`

### Verificación
```bash
flutterfire --version
# Resultado: 1.4.0
```

### Configuración PATH
- FlutterFire se agregó al PATH pero no siempre reconocido en PowerShell
- **Solución utilizada**: Usar ruta completa en cmd.exe o agregar manualmente al PATH

---

## 🌐 Configuración de Firebase Console

### Paso 1: Crear Proyecto Firebase

**Ubicación**: https://console.firebase.google.com

**Acciones realizadas:**
1. Hizo clic en "Agregar proyecto"
2. Nombre del proyecto: **BarberTurno**
3. Completó el asistente de creación
4. Proyecto creado exitosamente

**ID del Proyecto**: `barberturno-d3ec6`

### Paso 2: Registrar Aplicaciones

**Método**: FlutterFire CLI (automático)

**Comando ejecutado en cmd.exe:**
```cmd
C:\flutter\bin\dart.bat pub global run flutterfire_cli:flutterfire configure --project=barberturno-d3ec6
```

**Proceso interactivo:**
1. **Seleccionar plataformas**: Android, iOS, Web
2. **Android Package Name**: `com.barberturno.app`
3. **iOS Bundle ID**: `com.barberturno.app`
4. **Web App Name**: `barber_turno` (automático)

**Aplicaciones registradas automáticamente:**
- 🤖 Android: `1:419300768456:android:b6e4441f072853ba7d43fd`
- 🍎 iOS: `1:419300768456:ios:325e3da5b19545ff7d43fd`
- 🌐 Web: `1:419300768456:web:2a81ac37e3764bbc7d43fd`

**Archivo generado:**
- `lib/firebase_options.dart` (configuración automática de Firebase)

### Paso 3: Habilitar Authentication

**Ubicación**: Firebase Console > Authentication > Sign-in method

**Acciones realizadas:**
1. Navegó a sección "Seguridad" > "Authentication"
2. Seleccionó pestaña "Método de acceso"
3. Habilitó "Email/Password"
4. Habilitó "Google" (ya estaba activo)
5. Guardó cambios

**Métodos de autenticación habilitados:**
- ✅ Email/Password
- ✅ Google Sign-In

### Paso 4: Crear Firestore Database

**Ubicación**: Firebase Console > Cloud Firestore

**Acciones realizadas:**
1. Hizo clic en "Crear base de datos"
2. Seleccionó "Edición Standard" (motor de consultas simple)
3. ID de base de datos: `(default)`
4. Ubicación: `southamerica-east1 (Santiago)` - más cercana a Perú
5. Modo: Producción (requiere reglas de seguridad)
6. Completó creación

**Estado final:**
- ✅ Base de datos creada vacía
- ✅ Lista para agregar colecciones

### Paso 5: Publicar Reglas de Seguridad

**Ubicación**: Firebase Console > Firestore > Rules

**Proceso:**
1. Navegó a pestaña "Reglas"
2. Limpió contenido existente
3. Copió contenido de `firestore.rules` del proyecto
4. Pegó en el editor de reglas Firebase
5. Hizo clic en "Publicar"

**Reglas implementadas:**
- Usuarios: autenticación requerida, solo propietario puede editar perfil
- Servicios: solo admins pueden crear/editar/eliminar
- Citas: clientes crean, barberos confirman, admins ven todo
- Horarios: solo admins y barberos pueden escribir
- Control granular de permisos por rol (client, barber, admin)

**Archivo de reglas:**
```
firestore.rules (81 líneas)
- Funciones auxiliares: isAuthenticated, isOwner, getUserRole, isAdmin, isBarber
- 5 colecciones configuradas: users, services, appointments, schedules, barbers
```

---

## 🔧 Configuración del Proyecto Flutter

### Paso 1: Instalación de Dependencias

**Ubicación del proyecto:**
```
C:\Users\CRISTIAN\OneDrive\Documentos\VII CICLO\villazana\new. ing\team dev\Desarrollo Movil\barber_turno
```

**Comando ejecutado:**
```bash
flutter pub get
```

**Resultado:**
- ✅ 167 dependencias descargadas e instaladas
- ✅ Todos los paquetes compilados exitosamente
- ✅ pubspec.lock actualizado

**Dependencias principales instaladas:**
- firebase_core 3.15.2
- firebase_auth 5.7.0
- cloud_firestore 5.6.12
- flutter_bloc 9.1.1
- go_router 14.8.1
- get_it 8.3.0
- injectable 2.7.1

### Paso 2: Actualizar main.dart

**Archivo modificado:** `lib/main.dart`

**Cambios realizados:**
```dart
// Agregado import
import 'firebase_options.dart';

// Modificado función main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // ← Agregado
  );
  configureDependencies();
  runApp(const BarberTurnoApp());
}
```

**Propósito:**
- Inicializa Firebase con configuración automática según plataforma
- Ejecuta antes de lanzar la app
- Asegura conexión a Firestore y Authentication

### Paso 3: Generar Archivos de Plataforma

**Comando ejecutado:**
```bash
flutter create .
```

**Archivos generados:**
- Android: carpeta `android/` con proyecto Gradle (128 archivos)
- iOS: carpeta `ios/` con proyecto Xcode
- Web: carpeta `web/` con assets y configuración
- Windows: carpeta `windows/` con proyecto CMake
- macOS: carpeta `macos/` con proyecto Xcode
- Linux: carpeta `linux/` con proyecto CMake

**Propósito:**
- Crear estructura nativa para cada plataforma
- Permitir compilación a Android, iOS, Web, Windows, macOS, Linux
- Agregar assets y configuraciones específicas de cada plataforma

### Paso 4: Inicializar Repositorio Git

**Comando ejecutado:**
```bash
cd barber_turno
git init
git add .
git commit -m "feat: proyecto inicial BarberTurno MVP v1 - Flutter + Firebase"
```

**Resultado:**
- ✅ Repositorio Git inicializado
- ✅ Primer commit con todos los archivos
- ✅ Historia de cambios disponible

---

## ✅ Verificación Final

### Flutter Doctor
```bash
flutter doctor -v
```

**Estado de componentes:**
| Componente | Estado | Nota |
|---|---|---|
| Flutter | ✅ OK | 3.44.2 stable |
| Dart | ✅ OK | 3.12.2 |
| Android Toolchain | ⚠️ Advertencia | cmdline-tools missing (no crítico) |
| Chrome | ✅ OK | Para pruebas web |
| Visual Studio | ❌ No instalado | No requerido para Android |
| Dispositivos | ✅ OK | Windows, Chrome, Edge disponibles |

### Ejecución de Aplicación

**Comando para ejecutar:**
```bash
# Agregar Flutter al PATH
set PATH=%PATH%;C:\flutter\bin

# Ejecutar en Chrome
flutter run -d chrome

# Ejecutar en Windows Desktop
flutter run -d windows

# Ejecutar en Edge
flutter run -d edge
```

**Resultado de ejecución:**
- ✅ App compilada sin errores
- ✅ Servidor de desarrollo iniciado en `localhost:29645`
- ✅ LoginPage se muestra correctamente
- ✅ Hot reload habilitado para desarrollo rápido
- ✅ Conexión a Firebase establecida

**Pantalla inicial:**
- Título: "LoginPage"
- Subtítulo: "LoginPage - En desarrollo"
- Estado: Ready para desarrollo

---

## 🔐 Variables de Entorno y PATH

### PATH actualizado
```
C:\flutter\bin
C:\Users\CRISTIAN\AppData\Local\Pub\Cache\bin
C:\Users\CRISTIAN\AppData\Local\Programs\npm
```

### ANDROID_HOME
```
Configurado: C:\Users\CRISTIAN\AppData\Local\Android\sdk
```

---

## 📁 Estructura de Directorios Finales

```
barber_turno/
├── lib/
│   ├── main.dart ...................... Punto de entrada (MODIFICADO)
│   ├── firebase_options.dart .......... Configuración Firebase (GENERADO)
│   ├── config/
│   ├── core/
│   ├── features/
│   │   ├── auth/
│   │   ├── appointments/
│   │   ├── barber/
│   │   ├── admin/
│   │   ├── services/
│   │   └── home/
│   └── injection/
├── android/ ........................... Proyecto Android (GENERADO)
├── ios/ .............................. Proyecto iOS (GENERADO)
├── web/ .............................. Configuración Web (GENERADO)
├── windows/ .......................... Configuración Windows (GENERADO)
├── pubspec.yaml ...................... Dependencias (ORIGINAL)
├── pubspec.lock ...................... Lock file (GENERADO)
├── firestore.rules ................... Reglas de seguridad (ORIGINAL)
├── firebase_options.dart ............. Config Firebase (GENERADO)
├── analysis_options.yaml ............. Linting (GENERADO)
├── .git/ ............................ Repositorio Git (GENERADO)
└── README.md ........................ Documentación Flutter (GENERADO)
```

---

## 🚀 Resumen de Cambios

### Archivos Agregados
1. `lib/firebase_options.dart` - Configuración automática de Firebase
2. Carpetas de plataforma: `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`
3. Archivos de configuración: `analysis_options.yaml`, `test/widget_test.dart`
4. `.git/` - Repositorio de control de versiones

### Archivos Modificados
1. `lib/main.dart` - Agregado inicialización de Firebase

### Configuraciones Externas
1. Firebase Console - 3 apps registradas, Authentication habilitado, Firestore creado
2. Reglas de Firestore - Publicadas en Firebase Console
3. PATH del sistema - FlutterFire CLI agregado

---

## ✨ Estado Final

**Ambiente listo para desarrollo**: ✅ SÍ

**Componentes verificados:**
- ✅ Flutter SDK instalado y funcionando
- ✅ Firebase conectado y configurado
- ✅ Firestore database creado
- ✅ Autenticación habilitada
- ✅ Reglas de seguridad publicadas
- ✅ Aplicación ejecutándose sin errores
- ✅ Hot reload disponible
- ✅ Git inicializado

**Próximo paso:** Comenzar desarrollo de MVP v1

---

## 📞 Solución de Problemas Durante Configuración

### Problema 1: PowerShell no reconoce comandos
**Causa:** Política de ejecución de scripts deshabilitada  
**Solución:** Usar `cmd.exe` en lugar de PowerShell  
**Ejemplo:**
```cmd
firebase login
flutterfire configure --project=barberturno-d3ec6
```

### Problema 2: Firebase CLI no autenticado
**Causa:** Firebase login no ejecutado  
**Solución:** Ejecutar `firebase login` en cmd.exe de forma interactiva  
**Nota:** No funciona en terminal no-interactiva

### Problema 3: FlutterFire no reconocido
**Causa:** PATH no actualizado o FlutterFire no instalado globalmente  
**Solución:** Usar ruta completa de dart:
```bash
C:\flutter\bin\dart.bat pub global run flutterfire_cli:flutterfire configure --project=...
```

### Problema 4: Flutter no soporta Windows/Web
**Causa:** Archivos de plataforma no generados  
**Solución:** Ejecutar `flutter create .` en el directorio del proyecto

---

**Documento completado**: 17 de junio de 2026  
**Responsable**: Configuración automática + Manual del usuario  
**Validación**: App ejecutándose correctamente en Chrome
