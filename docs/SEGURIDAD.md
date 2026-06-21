# Seguridad — BarberTurno MVP v1

Documento que describe las medidas de seguridad implementadas y las decisiones
de diseño. Pensado para la revisión técnica del proyecto.

---

## 1. Autenticación

- Se usa **Firebase Authentication** (email + contraseña).
- Las contraseñas **nunca** se guardan ni se manejan en nuestro código ni en la
  base de datos: Firebase las almacena cifradas (hash + salt) en su
  infraestructura. La app solo recibe un token de sesión.
- Los correos se normalizan a minúsculas para evitar cuentas duplicadas.
- La sesión se mantiene de forma segura mediante el SDK de Firebase.

---

## 2. Autorización (control de acceso)

El control de permisos se hace en **dos capas**:

### Capa 1 — En la app (UX)
`config/app_router.dart` envía a cada usuario a su pantalla según el rol
(client / barber / admin) y le impide navegar a secciones que no le tocan.

### Capa 2 — En el servidor (seguridad real)
`firestore.rules` es la barrera de seguridad **autoritativa**. Aunque alguien
modificara la app, no podría saltarse estas reglas porque se evalúan en los
servidores de Firebase.

| Colección | Lectura | Escritura |
|---|---|---|
| `users` | Solo el dueño o admin | Crear solo tu propio doc; editar sin cambiar rol; admin gestiona roles |
| `services` | Autenticados | Solo admin |
| `barbers` | Autenticados | Crear/eliminar solo admin; el barbero edita su perfil |
| `appointments` | Autenticados (ver nota) | Cliente crea las suyas; cliente/barbero/admin actualizan |
| `schedules` | Autenticados | Admin y barberos |

---

## 3. Vulnerabilidades prevenidas

### Escalada de privilegios (corregido)
Antes, un usuario podía editar su propio documento e incluir
`role: "admin"`, auto-convirtiéndose en administrador. La regla ahora **impide
cambiar el campo `role`** salvo que quien edite sea admin:

```
allow update: if isAdmin() ||
  (isOwner(userId) && request.resource.data.role == resource.data.role);
```

### Acceso a datos de otros usuarios (corregido)
La colección `users` ya **no es legible por cualquiera**: solo el dueño del
perfil o un admin pueden leerla. Así no se exponen teléfonos ni correos de
terceros. Los barberos que el cliente necesita ver para reservar están en una
colección aparte (`barbers`) con datos no sensibles.

### Creación de documentos arbitrarios (corregido)
Un usuario solo puede crear **su propio** documento (`uid == auth.uid`), no
documentos de otras personas.

### Reservas a nombre de otro (prevenido)
Al crear una cita, la regla exige `clientId == auth.uid`: nadie puede reservar
suplantando a otro cliente.

---

## 4. Validación de entradas

- Los formularios (login, registro, servicios) validan campos antes de enviar:
  correo con formato válido, contraseña mínima de 6 caracteres, precios y
  duraciones numéricas, campos obligatorios.
- La validación de la app es de **usabilidad**; la seguridad real la imponen las
  reglas de Firestore en el servidor.

---

## 5. Sobre `firebase_options.dart` en el repositorio

Este archivo está versionado a propósito. Contiene la **API key de Firebase**,
que **no es un secreto**: es un identificador público del proyecto del lado del
cliente (así lo documenta Google). La seguridad **no** depende de ocultarla,
sino de las reglas de Firestore. Por eso es seguro incluirla para que el equipo
pueda clonar y ejecutar el proyecto.

Referencia: la documentación oficial de Firebase indica que las API keys de
cliente pueden incluirse en el código y que la protección se hace con Security
Rules (y, en producción, App Check).

---

## 6. Limitación conocida (decisión consciente del MVP)

**Lectura de `appointments` por cualquier autenticado.**

Para calcular los horarios disponibles, el cliente necesita saber qué horas ya
están ocupadas con el barbero elegido, por lo que actualmente puede leer las
citas. Esto expone metadatos de otras citas (nombres, horas).

- **Por qué se aceptó en V1:** evitar montar un backend adicional. El objetivo
  del MVP es validar la propuesta de valor.
- **Plan para V2:** mover el cálculo de disponibilidad a una **Cloud Function**
  o a un documento agregado de "horas ocupadas" que no exponga datos de las
  citas. Así la lectura de `appointments` se restringiría a
  dueño / barbero / admin.

---

## 7. Recomendaciones para producción (futuro)

Si la app se publica en Play Store con usuarios reales:

1. **Firebase App Check** — impedir que clientes no autorizados (bots) usen la API.
2. **Cloud Functions** — para la disponibilidad y para las notificaciones push.
3. **Verificación de correo** — confirmar el email al registrarse.
4. **Reglas de contraseña más estrictas** y recuperación de contraseña.
5. **Monitoreo** — alertas de uso anómalo en Firebase.

---

## 8. Resumen

- Autenticación gestionada por Firebase (contraseñas cifradas, fuera de nuestro código).
- Autorización por rol aplicada en el servidor con Firestore Security Rules.
- Corregidas: escalada de privilegios, fuga de datos de usuarios, creación arbitraria.
- Una limitación conocida (lectura de citas) está documentada con su plan de mejora.
