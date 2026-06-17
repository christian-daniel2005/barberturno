# BarberTurno - Configuracion del Tablero Trello

## Crear el tablero

1. Ir a https://trello.com y crear cuenta (o iniciar sesion)
2. Crear tablero: **BarberTurno MVP v1**
3. Invitar al companero de equipo

## Listas (columnas)

Crear estas 5 listas en orden:

| # | Lista | Descripcion |
|---|---|---|
| 1 | **Backlog** | Todas las funcionalidades pendientes del MVP |
| 2 | **Sprint Actual** | Lo que se esta trabajando esta semana |
| 3 | **En Revision** | Code review y testing antes de merge |
| 4 | **Completado** | Features terminadas y validadas |
| 5 | **Bugs** | Errores encontrados durante desarrollo |

## Etiquetas (labels)

Crear estas etiquetas de colores:

| Color | Nombre | Uso |
|---|---|---|
| Rojo | AUTH | Autenticacion y registro |
| Azul oscuro | CLIENTE | Funcionalidades del modulo cliente |
| Verde | BARBERO | Funcionalidades del modulo barbero |
| Naranja | ADMIN | Funcionalidades del modulo administrador |
| Negro | SISTEMA | Infraestructura y configuracion |
| Morado | BUG | Errores y correcciones |

## Tarjetas del MVP v1

### Sprint 1 - Auth + Servicios (Semana 1-2)

1. **[SISTEMA] Configurar proyecto Flutter + Firebase**
   - Checklist: Flutter SDK, Firebase Console, FlutterFire configure, Security Rules
   - Miembro: Ambos

2. **[AUTH] Implementar registro de usuarios**
   - Firebase Auth email/password
   - Crear documento en coleccion users con rol
   - UI: RegisterPage con validacion de campos

3. **[AUTH] Implementar inicio de sesion**
   - Login con email/password
   - Redireccion segun rol (cliente/barbero/admin)
   - UI: LoginPage

4. **[ADMIN] CRUD de servicios**
   - Crear, editar, eliminar servicios en Firestore
   - UI: lista de servicios + formulario

5. **[SISTEMA] Modelo de datos Firestore**
   - Crear colecciones: users, services, appointments, schedules
   - Implementar modelos Dart con serialization

### Sprint 2 - Reservas + Barbero (Semana 3-4)

6. **[CLIENTE] Ver servicios disponibles**
   - Lista de servicios con precio y duracion
   - UI con cards atractivas

7. **[CLIENTE] Seleccionar barbero**
   - Lista de barberos disponibles
   - Ver perfil basico del barbero

8. **[CLIENTE] Reservar cita**
   - Seleccionar fecha y hora disponible
   - Motor de disponibilidad (verificar slots libres)
   - Crear appointment en Firestore

9. **[CLIENTE] Ver y cancelar citas activas**
   - Lista de citas del usuario
   - Boton cancelar con confirmacion

10. **[BARBERO] Vista de agenda diaria**
    - Lista de citas del dia
    - Indicadores de estado por color

11. **[BARBERO] Confirmar/Rechazar citas**
    - Botones de accion en cada cita pendiente
    - Actualizar status en Firestore

12. **[BARBERO] Bloquear horarios**
    - Marcar slots como no disponibles
    - Actualizar coleccion schedules

### Sprint 3 - Admin + Pulido (Semana 5-6)

13. **[ADMIN] Gestion de barberos**
    - Agregar/editar barberos
    - Asignar rol barbero a usuarios

14. **[ADMIN] Ver citas programadas**
    - Dashboard con todas las citas
    - Filtros por fecha y barbero

15. **[ADMIN] Configurar horarios generales**
    - Hora apertura/cierre
    - Dias habiles

16. **[ADMIN] Consulta basica de ingresos**
    - Suma de servicios completados del dia
    - Vista simple de ingresos

17. **[SISTEMA] Notificaciones de confirmacion**
    - Firebase Cloud Messaging
    - Notificar al cliente cuando barbero confirma/rechaza

18. **[SISTEMA] Testing y correccion de bugs**
    - Pruebas en dispositivo fisico
    - Corregir errores encontrados

## Reglas del tablero

1. **Cada tarjeta debe tener**: etiqueta de modulo, miembro asignado, checklist de subtareas
2. **Mover tarjetas** de izquierda a derecha conforme avanzan
3. **Comentar en la tarjeta** los avances o problemas
4. **No mover a Completado** sin revision del companero
5. **Reunirse 2 veces por semana** para revisar el tablero (lunes y jueves recomendado)

## Automatizaciones utiles (Butler de Trello)

- Cuando una tarjeta se mueve a "Completado", agregar fecha de finalizacion
- Cuando se crea una tarjeta en "Bugs", asignar etiqueta morada automaticamente
