# Integrar Claude Code en Visual Studio Code

## Requisitos previos

- VS Code version 1.98.0 o superior
- Node.js instalado (ya lo necesitas para Firebase CLI)
- Suscripcion Anthropic: Pro ($20/mes), Max ($100/mes), Team ($30/user/mes) o Enterprise

## Paso 1: Instalar Claude Code CLI

Abrir terminal y ejecutar:

```bash
npm install -g @anthropic-ai/claude-code
```

## Paso 2: Instalar la extension en VS Code

1. Abrir VS Code
2. Ir a Extensions (Ctrl+Shift+X)
3. Buscar **"Claude Code"**
4. Instalar la extension del publisher **Anthropic** (verificado, 2M+ instalaciones)

## Paso 3: Activar

1. Click en el icono de chispa (spark) en la barra superior del editor
2. O abrir Command Palette (Ctrl+Shift+P) y escribir "Claude Code: Open"
3. Iniciar sesion con tu cuenta Anthropic la primera vez

## Como usarlo en BarberTurno

### Comandos utiles

- **Explicar codigo**: Seleccionar codigo y preguntar que hace
- **Generar codigo**: Pedir que implemente un BLoC, repositorio o widget
- **Debugging**: Pegar un error y pedir solucion
- **Refactoring**: Pedir que mejore o reestructure codigo existente

### Ejemplos practicos para el proyecto

```
"Implementa el AuthBloc con estados para login, register y logout usando firebase_auth"

"Crea el repositorio de appointments que se conecte a Firestore con metodos crear, cancelar y listar por usuario"

"Genera un widget reutilizable de tarjeta de servicio que muestre nombre, precio y duracion"

"Escribe tests unitarios para el AppointmentModel"
```

### Tips

- Abrir el archivo que quieres modificar ANTES de pedirle algo a Claude Code
- Ser especifico con los nombres de clases y paquetes que usa el proyecto
- Claude Code tiene acceso al contexto de los archivos abiertos en VS Code
- Puedes pedirle que siga la arquitectura Clean Architecture del proyecto

## Nota importante

Si el equipo ya tiene acceso a Claude (como ahora con Cowork), pueden usarlo para desarrollo sin costo adicional de la extension. La extension de VS Code es una opcion complementaria para tener el asistente directamente integrado en el editor.
