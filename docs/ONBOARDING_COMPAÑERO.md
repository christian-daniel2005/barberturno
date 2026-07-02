# 🚀 Guía de Onboarding — BarberTurno
### Para el compañero de equipo: cómo levantar el proyecto desde cero

---

## ✅ PASO 0 — Verifica si ya tienes las herramientas instaladas

Abre una terminal (CMD o PowerShell) y ejecuta estos comandos uno por uno.
Si un comando dice "no se reconoce" o falla, ve directamente a la sección de instalación correspondiente.

```bash
flutter --version
dart --version
git --version
java -version
```

### ¿Qué versiones necesitas?

| Herramienta | Versión mínima requerida | Comando para verificar |
|---|---|---|
| Flutter SDK | **3.x o superior** | `flutter --version` |
| Dart SDK | **3.2 o superior** (viene con Flutter) | `dart --version` |
| Git | **2.x** | `git --version` |
| Java (JDK) | **17 o superior** (para Gradle/Android) | `java -version` |
| Android Studio | **Hedgehog 2023.1+** | Abrirlo manualmente |

> Dart NO se instala por separado. Viene incluido dentro del Flutter SDK.
> Si tienes Flutter, ya tienes Dart.

---

## 🛠️ PASO 1 — Instalar herramientas faltantes

### 1.1 Instalar Flutter SDK (si no lo tienes)

1. Ve a: https://docs.flutter.dev/get-started/install/windows
2. Descarga el `.zip` y descomprímelo en `C:\flutter` (sin espacios en la ruta)
3. Agrega `C:\flutter\bin` al **PATH del sistema**:
   - Busca "Variables de entorno" en el menú inicio
   - En "Variables del usuario" → selecciona `Path` → clic en **Editar**
   - Clic en **Nuevo** → escribe `C:\flutter\bin`
   - Aceptar todo y **abrir una terminal NUEVA**
4. Verifica:
   ```bash
   flutter --version
   ```

---

### 1.2 Instalar Android Studio (si no lo tienes)

1. Descarga desde: https://developer.android.com/studio
2. Instálalo con la configuración por defecto (incluye el Android SDK)
3. Al abrirlo por primera vez, completa el "Setup Wizard" (descarga el SDK)
4. **Instala los plugins de Flutter y Dart:**
   - `File → Settings → Plugins → Marketplace`
   - Busca **Flutter** → Install (automáticamente instala Dart también)
   - Reinicia Android Studio

5. **Acepta las licencias del SDK** (obligatorio para compilar):
   ```bash
   flutter doctor --android-licenses
   ```
   Escribe `y` y presiona Enter en cada pregunta.

6. **Crea un emulador Android:**
   - En Android Studio: `Device Manager` (panel derecho) → `Create Device`
   - Elige un dispositivo: **Pixel 6** o similar
   - Selecciona una imagen del sistema: **API 34 (Android 14)** → Descárgala si no la tienes
   - Finish → ya tienes tu emulador listo

---

### 1.3 Instalar Git (si no lo tienes)

1. Descarga desde: https://git-scm.com/download/win
2. Instala con la configuración por defecto
3. Verifica: `git --version`

---

## 🩺 PASO 2 — Diagnóstico completo del entorno

Ejecuta este comando que revisa TODO de una sola vez:

```bash
flutter doctor -v
```

### Resultado esperado (todo en verde):

```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Windows Version
[✓] Android toolchain - develop for Android devices
[✓] Android Studio
[✓] Connected device (emulador o celular)
```

### Qué hacer si algo aparece en rojo:

| Problema | Solución |
|---|---|
| `flutter` no reconocido | Agrega `C:\flutter\bin` al PATH y abre terminal nueva |
| Android toolchain: licencias | Ejecuta `flutter doctor --android-licenses` |
| Android Studio no detectado | Reinstala el plugin de Flutter en Android Studio |
| No hay dispositivo | Enciende el emulador desde Android Studio → Device Manager |
| cmdline-tools missing | Android Studio → SDK Manager → SDK Tools → instala "Android SDK Command-line Tools" |

> No es necesario que "Visual Studio" aparezca en verde. Ese check
> es solo para apps de escritorio Windows, no aplica a este proyecto.

---

## 📥 PASO 3 — Clonar el repositorio

```bash
git clone https://github.com/christian-daniel2005/barberturno.git
cd barberturno
```

> Si el repositorio es privado, pídele a tu compañero que te agregue
> como colaborador en GitHub antes de clonar.

---

## 📦 PASO 4 — Instalar dependencias del proyecto

Dentro de la carpeta del proyecto, ejecuta:

```bash
flutter pub get
```

Esto descarga todos los paquetes listados en `pubspec.yaml`
(Firebase, BLoC, go_router, etc.).
Debe terminar con el mensaje: `Got dependencies!`

---

## 🔥 PASO 5 — Conexión a Firebase

**NO necesitas hacer nada con Firebase.**

El proyecto ya viene conectado al Firebase del equipo mediante el archivo
`lib/firebase_options.dart` que está incluido en el repositorio.
Al clonar y ejecutar, la app se conecta automáticamente a la base de datos
compartida (Firestore + Firebase Auth).

NO necesitas:
- Crear un proyecto de Firebase nuevo
- Instalar Firebase CLI
- Ejecutar `flutterfire configure`

---

## ▶️ PASO 6 — Ejecutar la app

### Opción A: Con emulador Android (recomendado)

1. Abre Android Studio → **Device Manager** → clic en ▶ para encender el emulador
2. Espera a que el emulador cargue completamente
3. En la terminal (dentro de la carpeta del proyecto):
   ```bash
   flutter run
   ```
4. Flutter detectará el emulador y comenzará la compilación

> La **primera compilación** tarda 5-15 min porque descarga dependencias de
> Gradle. Las siguientes son mucho más rápidas.

### Opción B: Con tu celular físico Android

1. En tu celular: `Configuración → Acerca del teléfono` → toca **Número de compilación** 7 veces
2. Activa `Opciones de desarrollador → Depuración USB`
3. Conecta el celular por USB y confirma el permiso de depuración
4. En la terminal:
   ```bash
   flutter devices   # verifica que tu celular aparece en la lista
   flutter run
   ```

### Opción C: En el navegador (para probar UI rápido)

```bash
flutter run -d chrome
```

---

## 🎉 PASO 7 — Verificación final

Si la app abre y ves la pantalla de **login de BarberTurno**, ¡todo funciona!

Prueba estas acciones:
- La pantalla de login se muestra sin errores
- Puedes registrarte con un email nuevo
- Al iniciar sesión, la app te lleva a la pantalla correcta según tu rol

---

## ⌨️ Comandos útiles durante el desarrollo

```bash
flutter run           # correr la app
flutter analyze       # verificar errores de código (debe decir "No issues found!")
flutter clean         # limpiar compilación si algo falla raro
flutter pub get       # reinstalar dependencias
flutter devices       # ver dispositivos disponibles

# Mientras la app está corriendo (en la terminal):
# r → Hot reload (aplica cambios de UI al instante)
# R → Hot restart (reinicia la app completamente)
# q → Salir
```

---

## 🤝 Flujo de trabajo en equipo con Git

```bash
# Antes de empezar, siempre actualiza
git pull origin main

# Crear tu rama de trabajo
git checkout -b feature/nombre-de-tu-tarea

# Guardar tus cambios
git add .
git commit -m "feat: descripción de lo que hiciste"

# Subir tu rama
git push origin feature/nombre-de-tu-tarea
```

> Nunca hagas push directo a `main` sin revisión.
> Usa Pull Requests para que puedan revisar el código juntos.

---

## ❓ Problemas comunes

| Error | Causa | Solución |
|---|---|---|
| `flutter: command not found` | Flutter no está en el PATH | Agrega `C:\flutter\bin` al PATH |
| `Gradle build failed` | Java desactualizado | Instala JDK 17: https://adoptium.net |
| `flutter pub get` falla | Sin conexión o caché corrompida | `flutter clean` y luego `flutter pub get` |
| App no conecta a Firestore | `firebase_options.dart` incorrecto | Pídele a tu compañero el archivo actualizado |
| Emulador muy lento | Virtualización desactivada | Activa "Intel HAXM" o "Hyper-V" en BIOS |

---

## 📋 Checklist — Marcar cuando esté listo

- [ ] `flutter --version` → muestra 3.x o superior
- [ ] `dart --version` → muestra 3.2 o superior
- [ ] `git --version` → muestra 2.x
- [ ] `java -version` → muestra 17 o superior
- [ ] Android Studio instalado con plugins Flutter y Dart
- [ ] Emulador Android creado (o celular físico configurado)
- [ ] `flutter doctor -v` → sin errores críticos en rojo
- [ ] Repositorio clonado correctamente
- [ ] `flutter pub get` → `Got dependencies!`
- [ ] `flutter analyze` → `No issues found!`
- [ ] `flutter run` → La app abre y muestra la pantalla de login ✅

**Si todos están marcados, el entorno está 100% listo para trabajar!**
