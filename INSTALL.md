# Guía de Instalación

Esta guía describe el proceso completo de instalación, configuración y ejecución del proyecto.

# Instalación:

- **Backend:** [Instalación Backend](#instalación-backend)

- **Frontend:** [Instalación Frontend](/frontend/README.md)


## Instalación Backend

### Requisitos Previos

- **Ruby:** 3.2.2 o superior
- **PostgreSQL** 16.0 o superior
- **Bundler** 2.0 o superior
- **Git**: Para clonar el repositorio

Opcionalmente:
- Docker (para ejecutar PostgreSQL en contenedor)

### 1 Clonar el repositorio

```bash
git clone git clone https://github.com/reveluv1814/Vita-Exchange.git
cd Vita-Exchange
```

### 2 Configuración de variables de entorno

Copia el archivo de ejemplo `.env.sample` a `.env`:

```bash
cp .env.sample .env
```

Agrega las siguientes variables al archivo `.env`:

| Variable | Descripción | Valor de Ejemplo | Requerido |
|----------|-------------|------------------|-----------|
| `DATABASE_HOST` | Host del servidor PostgreSQL | `localhost` | Sí |
| `DATABASE_USERNAME` | Usuario de PostgreSQL | `postgres` | Sí |
| `DATABASE_PASSWORD` | Contraseña de PostgreSQL | `postgres` | Sí |
| `JWT_SECRET_KEY` | Clave secreta para firmar tokens JWT | `secret_key` | Sí |
| `VITAWALLET_API_URL` | URL del API de VitaWallet | `https://api.com` | Si |
| `API_TIMEOUT` | Timeout en segundos para llamadas HTTP | `10` | Si |
| `RAILS_ENV` | Entorno de ejecución de Rails | `development` | No |

**Notas importantes:**
- En producción, genera un `JWT_SECRET_KEY` seguro usando: `rails secret`
- Si no configuras `VITAWALLET_API_URL`, el sistema usará datos mockeados por defecto para precios.
- `API_TIMEOUT` controla el tiempo máximo de espera para llamadas al API externa (default: 10 segundos)
- `RAILS_ENV` puede ser `development`, `test` o `production`
- Ajusta las credenciales de PostgreSQL según tu configuración local o de Docker

### 3 Instalar dependencias de Ruby

```bash
bundle install
```

Este comando instalará todas las gemas necesarias definidas en el archivo `Gemfile`, incluyendo:
- Rails 8.1.2
- PostgreSQL adapter
- JWT para autenticación
- RSpec para testing
- HTTParty para llamadas HTTP
- Swagger

### 4 Creación y configuración de la Base de Datos

Para esta prueba se uso `Docker` para ejecutar PostgreSQL.

Crear un contenedor y la base de datos con el siguiente comando:

```bash
docker run --name db_vita -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 postgres:16.0
```

Donde: `db_vita` es el nombre del contenedor.



### 5 Configurar Base de Datos

Una vez configurado PostgreSQL y las variables de entorno se debe ejecutar las migraciones para crear las tablas necesarias:

```bash
rails db:create # Crea la base de datos
rails db:migrate # Ejecuta las migraciones para crear tablas
rails db:seed # Carga datos de prueba (opcional)
```

El seed creará un usuario de prueba con credenciales:
- **Email:** `usuario@email.com`
- **Password:** `123456`

Y le asignará balances iniciales en todas las monedas soportadas (USD, CLP, BTC, USDC, USDT).

### 6 Ejecución

```bash
rails server
```

O usando el alias:

```bash
rails s
```

El servidor estará disponible en `http://localhost:3000`

`NOTA:` Puede ingresar con el usuario de prueba para probar el sistema.

O crear un nuevo usuario usando el endpoint de registro:

```bash
http://localhost:3000/auth/register
```

### 7 Ejecutar tests

Ejecuta los test con el siguiente comando:

```bash
bundle exec rspec
```

### 8 Documentación de la API

```
http://localhost:3000/api-docs/
```
