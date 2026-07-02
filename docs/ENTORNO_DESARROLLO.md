   # Configuración del Entorno de Desarrollo — BarberTurno

Guía completa para dejar una laptop lista para desarrollar y ejecutar el
proyecto. Pensada para Windows (que es donde se desarrolló), con notas para otros
sistemas.
edu kbro

---

## 1. Herramientas necesarias

| Herramienta | Versión usada | Para qué sirve |
|---|---|---|
| Flutter SDK | 3.44.2 | Framework de la app (incluye Dart 3.12.2) |
| Dart SDK | 3.12.2 | Lenguaje (viene dentro de Flutter) |
| Android Studio | última | Emulador Android, SDK de Android, editor |
| Git | 2.x | Control de versiones / clonar el repo |
| Node.js | 18+ | Solo si vas a usar Firebase CLI (opcional) |

> Para **solo ejecutar** el proyecto necesitas: Flutter + Android Studio + Git.
> Firebase ya está configurado en el repo (no hace falta Firebase CLI).

---

## 2. Instalar Flutter

### Windows
1. Descarga Flutter desde https://docs.flutter.dev/get-started/install/windows
2. Descomprime en una ruta sin espacios, por ejemplo `C:\flutter`
3. Agrega `C:\flutter\bin` al **PATH** del sistema:
   - Buscar "Variables de entorno" → Editar variables del usuario → `Path` → Nuevo
   - Pegar `C:\flutter\bin`
4. Abre una terminal nueva y verifica:
   ```bash
   flutter --version
   ```

### Verificar el estado del entorno
```bash
flutter doctor
```
Debe mostrar ✓ en Flutter, Android toolchain y un dispositivo disponible.
Es normal que falte "Visual Studio" si no desarrollas para Windows desktop.

---

## 3. Instalar Android Studio + Emulador

1. Descarga Android Studio: https://developer.android.com/studio
2. Durante la instalación, acepta instalar el **Android SDK**.
3. Instala los plugins de Flutter y Dart:
   `Settings → Plugins → Marketplace` → buscar **Flutter** → Install (incluye Dart).
4. Crea un emulador:
   `Device Manager → Create Device` → elige un Pixel → descarga una imagen
   de Android (API 34/35) → Finish.
5. Acepta las licencias del SDK desde la terminal:
   ```bash
   flutter doctor --android-licenses
   ```

---

## 4. Clonar y ejecutar el proyecto

```bash
git clone https://github.com/christian-daniel2005/barberturno.git
cd barberturno
flutter pub get
flutter run
```

Elige el dispositivo (emulador Android o Chrome). La primera compilación para
Android descarga dependencias nativas (NDK, Gradle) y **tarda varios minutos**.

### Comandos útiles
```bash
flutter run -d chrome     # ejecutar en el navegador (rápido para probar)
flutter run -d emulator   # ejecutar en el emulador Android
flutter analyze           # revisar errores de código (debe decir "No issues found!")
flutter clean             # limpiar compilación si algo se corrompe
flutter pub get           # reinstalar dependencias
```

Dentro de `flutter run`, mientras corre:
- `r` → hot reload (recarga cambios al instante)
- `R` → hot restart (reinicia la app)
- `q` → salir

---

## 5. Conexión con Firebase (ya configurada)

El proyecto **ya viene conectado** al proyecto Firebase `barberturno-d3ec6`
mediante el archivo `lib/firebase_options.dart`, que está incluido en el repo.

> **No necesitas** crear un proyecto de Firebase ni ejecutar `flutterfire
> configure`. Al clonar y correr, la app se conecta sola a la base de datos
> compartida del equipo.

### Si en el futuro quieres tu propio Firebase
Solo en caso de querer una base de datos independiente:
1. Instala las CLI:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```
2. Inicia sesión: `firebase login`
3. Reconfigura: `flutterfire configure`
4. Activa **Authentication (Email/Password)** y **Cloud Firestore** en la consola.
5. Publica las reglas de `firestore.rules` en la consola (pestaña Rules).

---

## 6. Notas importantes para Windows

- **Ejecuta los comandos de Firebase/Flutter en CMD**, no en PowerShell, si
  PowerShell bloquea scripts (política de ejecución).
- Si `flutter` no se reconoce, revisa que `C:\flutter\bin` esté en el PATH y
  abre una terminal nueva.
- Para el build de Android, si aparece un error de NDK corrupto, elimina la
  carpeta `...\Android\sdk\ndk\<version>` y vuelve a compilar (Gradle la
  re-descarga).

---

## 7. Estructura tras la instalación

```
barberturno/
├── lib/                  → Código de la app (frontend)
├── android/ ios/ web/    → Proyectos nativos por plataforma (autogenerados)
├── docs/                 → Documentación del proyecto
├── firestore.rules       → Reglas de seguridad de Firestore
├── pubspec.yaml          → Dependencias del proyecto
└── README.md             → Punto de entrada
```

---

## 8. Verificación final (checklist)

- [ ] `flutter --version` muestra 3.44.2 o superior
- [ ] `flutter doctor` sin errores críticos
- [ ] Un emulador Android creado y encendido
- [ ] `flutter pub get` se ejecutó sin errores
- [ ] `flutter analyze` dice "No issues found!"
- [ ] `flutter run` abre la app y muestra la pantalla de login

Si todos están ✓, el entorno está listo para desarrollar.
