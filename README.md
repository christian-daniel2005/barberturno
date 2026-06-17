# BarberTurno — MVP v1

Aplicación móvil de gestión de citas para barberías independientes. Permite a
los **clientes** reservar citas, a los **barberos** administrar su agenda y a los
**administradores** gestionar el negocio.

Construida con **Flutter** (multiplataforma) y **Firebase** (backend en la nube).

---

## 🚀 Cómo ejecutar el proyecto (guía para el equipo)

Si vas a correr este proyecto por primera vez en tu laptop, sigue estos pasos.
No necesitas configurar Firebase: ya viene conectado.

### 1. Requisitos previos

Instala estas herramientas (ver detalle en [docs/ENTORNO_DESARROLLO.md](docs/ENTORNO_DESARROLLO.md)):

| Herramienta | Versión | Para qué |
|---|---|---|
| Flutter SDK | 3.44.2 o superior | Framework de la app |
| Android Studio | última | Emulador Android + SDK |
| Git | cualquiera | Clonar el repositorio |

Verifica que Flutter esté listo:
```bash
flutter doctor
```

### 2. Clonar el repositorio

```bash
git clone https://github.com/christian-daniel2005/barberturno.git
cd barberturno
```

### 3. Instalar dependencias

```bash
flutter pub get
```

### 4. Ejecutar la app

Abre un emulador Android (o usa Chrome) y corre:

```bash
flutter run
```

Si tienes varios dispositivos, Flutter te pedirá elegir uno. También puedes:
```bash
flutter run -d chrome      # en el navegador (más rápido para probar)
flutter run -d emulator    # en el emulador Android
```

> ⏱️ La **primera compilación para Android tarda varios minutos** (descarga
> dependencias nativas). Las siguientes son mucho más rápidas.

---

## 👤 Cómo probar los 3 roles

La app dirige a cada usuario a una pantalla distinta según su rol.

1. **Regístrate** en la app → quedas como **cliente**.
2. Para tener un **administrador**: en
   [Firebase Console](https://console.firebase.google.com) → proyecto
   `barberturno-d3ec6` → Firestore → colección `users` → tu usuario → cambia
   el campo `role` de `client` a `admin` (sin espacios). Cierra sesión y vuelve a entrar.
3. El **admin** promueve a un usuario registrado a **barbero** desde
   *Panel de administración → Barberos* (por su correo).

### Flujo de demostración recomendado
```
Admin   → crea servicios, configura horarios, promueve un barbero
Cliente → reserva una cita (servicio → barbero → día → hora)
Barbero → confirma o rechaza la cita en su agenda
```

---

## 📚 Documentación

| Documento | Contenido |
|---|---|
| [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) | Estructura del proyecto: frontend, backend, módulos y flujo de datos |
| [docs/ENTORNO_DESARROLLO.md](docs/ENTORNO_DESARROLLO.md) | Instalación completa del entorno de desarrollo |
| [docs/TRELLO.md](docs/TRELLO.md) | Organización del trabajo en equipo (tablero Trello) |
| [CLAUDE.md](CLAUDE.md) | Contexto técnico y alcance del MVP |

---

## 🧱 Stack tecnológico

- **Flutter / Dart** — interfaz multiplataforma (Android, iOS, Web)
- **Firebase Authentication** — registro e inicio de sesión (email/contraseña)
- **Cloud Firestore** — base de datos en tiempo real
- **flutter_bloc** — manejo de estado (patrón BLoC)
- **go_router** — navegación y control de acceso por rol
- **get_it** — inyección de dependencias
- Arquitectura: **Clean Architecture** por funcionalidad

---

## ✅ Estado: MVP v1 completo

Los 4 módulos (Cliente, Barbero, Administrador, Sistema) están implementados.
Ver el detalle de funciones en [CLAUDE.md](CLAUDE.md).
