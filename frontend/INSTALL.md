# Guía de Instalación - Frontend VitaWallet

Esta guía cubre el proceso completo de instalación, configuración y ejecución del proyecto.

## Requisitos del Sistema

### Software necesario

- **Node.js**: Versión 22.x o superior
- **npm**: Versión 10.x o superior (incluido con Node.js)
- **Git**: Para clonar el repositorio (opcional)

### Verificar versiones instaladas

```bash
node --version
npm --version
```

Si no tienes Node.js instalado, descárgalo desde [nodejs.org](https://nodejs.org/)

## Instalación

### 1. Obtener el proyecto

**Clonar repositorio**
```bash
git clone https://github.com/reveluv1814/Vita-Exchange.git
cd Vita-Exchange/frontend
```
Si ya clonaste el repositorio, simplemente navega a la carpeta `frontend`:
```bash
cd Vita-Exchange/frontend
```

### 2. Configuración de variables de entorno

```bash
cp .env.sample .env
```

### 3. Instalar dependencias

```bash
npm ci
```

Este comando instalará todas las dependencias listadas en `package.json`, incluyendo:
- React 19
- TypeScript
- Vite
- React Router DOM
- React Hook Form
- Zod
- shadcn/ui
- Playwright
- Lucide

### 4. Variables de entorno

Esta variable define la URL de la API backend. Configurarla si es necesario.
```env
# .env
VITE_API_URL="http://localhost:3000"
```

## Ejecución

### Modo desarrollo

```bash
npm run dev
```

La aplicación estará disponible en: `http://localhost:5173`

El servidor de desarrollo se recargará automáticamente cuando hagas cambios en el código.

### Modo producción

**Compilar el proyecto y ejecutar:**
```bash
npm run start
```

La vista estará disponible en: `http://localhost:5173`


## Scripts Disponibles

| Comando | Descripción |
|---------|-------------|
| `npm run dev` | Inicia el servidor de desarrollo con hot reload |
| `npm run build` | Compila el proyecto para producción |
| `npm run preview` | Previsualiza el build de producción localmente |
| `npm run lint` | Ejecuta ESLint para verificar el código |
| `npm run format` | Formatea el código con Prettier |
| `npm run format-check` | Verifica el formato del código sin modificar archivos |
| `npm run test:e2e` | Ejecuta tests E2E con Playwright |
| `npm run test:codegen` | Genera tests manuales con Playwright Codegen |

## Testing

### Configuración de Playwright

El proyecto incluye tests End-to-End (E2E) con Playwright que validan los flujos principales de la aplicación.

### Ejecutar tests

```bash
npm run test:e2e
```

### Estructura de tests

```
tests/
├── flujo.spec.ts   # Test principal de flujo de usuario
```

### Configuración

La configuración de Playwright está en `playwright.config.ts`:
- Puerto base: `http://localhost:5173`
- Servidor automático: Se inicia automáticamente al ejecutar tests
- Screenshots: Solo en fallos
- Traces: Solo en retry

## Notas

1. Abre `http://localhost:5173` en tu navegador
2. Inicia sesión con los datos de prueba
3. Consulta [README.md](README.md) para más información sobre el uso
