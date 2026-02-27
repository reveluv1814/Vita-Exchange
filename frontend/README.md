
# Frontend - VitaWallet

Aplicación web para consultar, intercambiar y gestionar balances de usuario. Parte de la prueba técnica para la posición de FullStack Developer.

## Stack Tecnológico

- React 19 con TypeScript
- Vite como build tool
- React Router DOM para navegación
- React Hook Form + Zod para validación de formularios
- shadcn/ui para componentes y skeletons
- Playwright para pruebas E2E
- CSS con variables y diseño responsivo
- Lucide para iconografía

## Funcionalidades

La aplicación permite:

- Autenticación de usuario
- Visualización de balances en diferentes monedas
- Intercambio de monedas con confirmación y feedback
- Historial de transacciones
- Skeletons y loaders para estados de carga
- Notificaciones tipo toast para feedback
- Validación robusta de formularios

## Estructura del Proyecto

```
src/
├── components/           # Componentes Shadcn y custom reutilizables
├── config/               # Configuración
│   └── config.ts         # Constantes de la aplicación 
├── pages/                # Vistas principales
├── routes/               # Configuración de rutas
├── services/             # Capa de servicios
├── hooks/                # Custom hooks 
├── context/              # Contextos
├── types/                # Tipos TypeScript
├── lib/                  # Utilidades
├── assets/               # Recursos estáticos
├── tests/                # Pruebas E2E con Playwright
```

## Inicio Rápido

Todos los pasos para poner en marcha el proyecto están detallados en la sección [📦 Instalación](INSTALL.md).

Luego de seguir esos pasos, abre en tu navegador:  `http://localhost:5173`

## Uso de la Aplicación

### Datos de prueba

El backend incluye usuarios y balances de ejemplo.

El usuario de prueba es:
- **Email:** `usuario@email.com`
- **Password:** `123456`

### Flujo básico

1. Inicia sesión con el usuario de prueba
2. Visualiza tus balances y transacciones
3. Usa el formulario para intercambiar monedas
4. Confirma la operación en el modal
5. Visualiza el resultado y el historial actualizado

## Detalles Técnicos

### Sobre la implementación

El frontend sigue buenas prácticas de arquitectura, estados, separación de responsabilidades y uso de custom hooks. Los formularios usan validación con Zod y feedback visual inmediato.

### Arquitectura

El proyecto está organizado en capas, con componentes reutilizables, hooks para lógica de negocio y servicios para acceso a datos.

### Skeletons y Loaders

Se usan componentes Skeleton de shadcn/ui para mejorar la experiencia de usuario durante la carga de datos.

### Validación y formularios

`React Hook Form` maneja el estado de los formularios y `Zod` define los esquemas de validación. Esto asegura datos consistentes y feedback inmediato.

## Testing

El proyecto incluye pruebas End-to-End (E2E) con Playwright para validar los flujos principales.

### Ejecutar tests

```bash
# Ejecutar todos los tests
npm run test:e2e
```

Para más información sobre configuración de tests, consulta [INSTALL.md](../INSTALL.md#testing)

## Notas

- Los datos de usuario y balances se reinician al resetear la base de datos
- El frontend asume que el backend está corriendo y accesible
- Las montos se muestran en formato amigable

---

## Contacto
Para más información, contacta a: **neilgraneros11@gmail.com**
