# Prueba Técnica FullStack VitaWallet

Sistema Web de billetera digital con soporte para intercambio entre monedas fiat (USD, CLP) y criptomonedas (BTC, USDC, USDT). Parte de la prueba técnica para la posición de FullStack Developer.

## Stack Tecnológico

- **Backend:**
  - Ruby on Rails 8.1.2 como Framework principal en modo API
  - PostgreSQL 16.0 como base de datos
  - JWT para la autenticación de usuarios
  - RSpec para el testing unitario e integración
  - HTTParty como cliente HTTP para integración con API externa
  - Swagger/OpenAPI para la documentación de la API
  - bcrypt para el hashing de contraseñas
- **Frontend:**
   - React 19 con TypeScript y Vite
   - React Router DOM para navegación
   - React Hook Form + Zod para validación de formularios
   - shadcn/ui para componentes
   - Playwright para pruebas E2E
   - Uso de Context patrara cide para iconografía
   - Arquitectura modular con hooks, servicios y contextos
   - Arquitectura modular con hooks, servicios y contextos

## Características principales

- Autenticación de usuarios con JWT y expiración segura
- Consulta y visualización de balances en múltiples monedas
- Intercambio de monedas fiat y criptomonedas con lógica de spreads buy/sell
- Historial de transacciones con estados
- Precisión decimal avanzada usando BigDecimal
- Validaciones robustas en modelos, controllers y servicios
- Arquitectura modular y desacoplada (controllers, services, models, helpers)
- Documentación automática de la API con Swagger/OpenAPI
- Sistema de caché para precios con TTL y reintentos automáticos
- Uso de UUIDs como identificadores para mayor seguridad
- Frontend moderno con React 19, Vite y TypeScript
- Formularios con validación instantánea usando React Hook Form + Zod
- Skeletons y loaders para mejorar la experiencia de usuario
- Uso de Context para manejo global de estado
- Pruebas unitarias, de integración y E2E (RSpec y Playwright)
- Seeds de datos para pruebas rápidas y flujo demo

## Instalación (Setup)

Todos los pasos para la instalación y configuración del proyecto estan detallados en  [📦INSTALL.md](INSTALL.md).

## Documentación

Para ver la documentación de la API, ejecutar el proyecto localmente y acceder a:
```bash
http://localhost:3000/api-docs
```

## Estructura del Proyecto

```
app/
├── controllers/
│   ├── application_controller.rb     # Controller base
│   ├── auth_controller.rb            # Registro y login
│   ├── balances_controller.rb        # Consulta de balances
│   ├── exchange_controller.rb        # Exchange entre monedas
│   ├── prices_controller.rb          # Precios actuales
│   ├── transactions_controller.rb    # Historial de transacciones
│   └── concerns/
│       └── authenticatable.rb        # Autenticación JWT
├── models/
│   ├── user.rb                       # Modelo de usuario
│   ├── wallet_balance.rb             # Modelo de balance por moneda
│   └── transaction.rb                # Modelo de exchanges
├── services/
│   ├── exchange_service.rb           # Servicio de lógica de exchange
│   ├── price_service.rb              # Servicio de precios
│   └── json_web_token.rb             # Servicio Encode/decode JWT
└── helpers/
    └── currency_helper.rb            # Utilidad de validaciones y conversiones

config/
├── routes.rb                         # Definición de rutas
├── database.yml                      # Configuración de base de datos
└── initializers/
    └── cors.rb                       # CORS

db/
├── migrate/                          # Migraciones
│   ├── *_enable_uuid.rb
│   ├── *_create_users.rb
│   ├── *_create_wallet_balances.rb
│   └── *_create_transactions.rb
└── seeds.rb                          # Usuario y balances de prueba


frontend/                             # Frontend del proyecto
├── src/
│   ├──components/                    # Componentes Shadcn y custom reutilizables
│   ├── config/                       # Configuración
│   │   └── config.ts                 # Constantes de la aplicación 
│   ├── pages/                        # Vistas principales
│   ├── routes/                       # Configuración de rutas
│   ├── services/                     # Capa de servicios
│   ├── hooks/                        # Custom hooks 
│   ├── context/                      # Contextos
│   ├── types/                        # Tipos TypeScript
│   ├── lib/                          # Utilidades
│   ├── assets/                       # Recursos estáticos
│   ├── tests/                        # Pruebas E2E con Playwright
├── INSTALL.md                        # Guía de instalación del frontend
└── README.md                         # Documentación del frontend

spec/
├── models/                           # Tests unitarios de modelos
├── services/                         # Tests de servicios
├── requests/                         # Tests de integración API
├── requests/swagger/                 # Tests que generan docs
├── support/                          # Tests de utilitarios
└── swagger_helper.rb                 # Config Swagger
```

## Decisiones técnicas

### 1. Arquitectura de Capas

Se implementó una separación clara de responsabilidades, tanto en el backend como en el frontend:

- **Controllers**: Validación de parámetros y manejo de HTTP
- **Services**: Lógica de negocio compleja (ExchangeService, PriceService, JsonWebToken)
- **Models**: Validaciones de datos y relaciones
- **Helpers**: Utilidades compartidas (CurrencyHelper con validaciones y conversiones)
- **Frontend**: Componentes, hooks, servicios y contextos organizados por responsabilidad

### 2. Precisión Decimal con BigDecimal

Todos los montos se manejan con `BigDecimal` en lugar de Float para evitar errores de redondeo.

### 3. Caché de Precios

`PriceService` implementa caché en memoria con TTL de 5 minutos:

- Reduce latencia de respuesta
- Disminuye carga al API externa de VitaWallet
- Implementado con `Rails.cache.fetch` usando ActiveSupport::Cache
- Reintentos automáticos con exponential backoff ante fallos

### 4. Modelo de Datos Simplificado

Se optó por un diseño minimalista sin sobre-ingeniería:

- **User** - has_many :wallet_balances, has_many :transactions
- **WalletBalance** - belongs_to :user (un registro por moneda)
- **Transaction** - belongs_to :user (historial de exchanges)

No se creó una entidad `Wallet` intermedia porque cada usuario tiene exactamente una billetera. Esto reduce joins y simplifica queries.

### 5. Autenticación con JWT

- Tokens con expiración de 24 horas
- Payload incluye `user_id` y `exp` (expiration time)
- Verificación en concern `Authenticatable` aplicado a controllers protegidos
- No requiere almacenamiento de sesiones en servidor (ideal para APIs)

### 6. UUIDs como Identificadores

Todos los modelos usan UUIDs en lugar de IDs incrementales:

- Mayor seguridad (no se pueden enumerar recursos)

### 7. Validaciones en Capas

Se agregaron validaciones (DTO) en cada capa para asegurar integridad de datos

### 8. Integración con API Real de VitaWallet

Implementación de api externa:

- Parsing de estructura compleja de respuesta (nested crypto prices)
- Manejo de errores de red con reintentos (3 intentos, exponential backoff)
- Timeouts configurados (10 segundos)
- Transformación de claves lowercase a uppercase para compatibilidad interna

### 9. Documentación como Código

Tests de Swagger doubles como:
- Suite de tests de integración
- Generador automático de documentación OpenAPI
- Contrato de API versionado con el código

Ejecutar `rake rswag:specs:swaggerize` regenera la documentación desde los tests

### 10. Manejo de estados
Se uso un manejo global de estado con Context para un mejor manejo de datos compartidos 

### 11. Tets E2E con Playwright
Se crearon pruebas End-to-End con Playwright para validar el flujos principal

### 12. Libertades de diseño
Se tomaron algunas libertades de diseño para mejorar la experiencia de usuario

### 13. Wrappers de servicios
Se crearon wrappers de servicios para desacoplar la lógica de negocio de la implementación específica del servicio en el Frontend

## Testing

### Test unitarios e integración con RSpec

Los comandos para ejecutar los tests con RSpec:

```bash
bundle exec rspec                # Todos los tests
bundle exec rspec spec/models    # Solo tests de modelos
bundle exec rspec spec/services  # Solo tests de servicios
bundle exec rspec spec/requests  # Solo tests de API
```

### Tests E2E con Playwright
Los tests E2E se ejecutan dentro de la carpeta `frontend` con el siguiente comando:

```bash
cd frontend
npm run test:e2e
```
## Qué Quedó Pendiente

- Quedó pendiente el manejo de logs
- El despliegue en producción no está configurado
- Dockerización completa de la aplicación (solo PostgreSQL usa Docker)
- En cuanto al frontend, no se implementó la páginación de la tabla,  pero el endpoint en backend si soporta paginación

## Video

## Contacto
Para más información, contacta a: **neilgraneros11@gmail.com**
