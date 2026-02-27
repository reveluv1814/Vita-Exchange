require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured, as per the Readme: https://github.com/rswag/rswag#20-configure-rswagapi
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the configured openapi_root, relative to the config.openapi_root path
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'VitaWallet API V1',
        version: 'v1',
        description: 'API para VitaWallet - Sistema de billetera digital con soporte para monedas fiat y criptomonedas.',
        contact: {
          name: 'VitaWallet Support',
          email: 'support@vitawallet.io'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://api.vitawallet.io',
          description: 'Production server (opcional)'
        }
      ],
      components: {
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'JWT token obtenido en /auth/login. Formato: Bearer {token}'
          }
        },
        schemas: {
          User: {
            type: :object,
            properties: {
              uuid: { type: :string, format: 'uuid', example: '550e8400-e29b-41d4-a916-446655440000' },
              email: { type: :string, example: 'user@example.com' }
            },
            required: ['uuid', 'email']
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string, example: 'Invalid email or password' }
            }
          },
          ValidationErrors: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string },
                example: ["Email can't be blank", "Password is too short"]
              }
            }
          },
          Balance: {
            type: :object,
            properties: {
              currency: { type: :string, enum: ['USD', 'CLP', 'BTC', 'USDC', 'USDT'], example: 'USD' },
              amount: { type: :string, description: 'Amount as string for precision', example: '1000.0' },
              usd_value: { type: :string, description: 'USD value as string', example: '1000.0' }
            }
          },
          Transaction: {
            type: :object,
            properties: {
              uuid: { type: :string, format: 'uuid', example: '550e8400-e29b-41d4-a916-446655440000' },
              from_currency: { type: :string, example: 'USD' },
              to_currency: { type: :string, example: 'BTC' },
              amount_from: { type: :string, description: 'Amount as string for precision', example: '100.0' },
              amount_to: { type: :string, description: 'Amount as string for precision', example: '0.00222' },
              rate: { type: :string, description: 'Rate as string for precision', example: '0.000022' },
              status: { type: :string, enum: ['pending', 'completed', 'rejected'], example: 'completed' },
              error_message: { type: :string, nullable: true },
              created_at: { type: :string, format: 'date-time' }
            }
          }
        }
      },
      tags: [
        { name: 'Auth', description: 'Endpoints de autenticación (Login/Register)' },
        { name: 'Balances', description: 'Consulta de balances del usuario' },
        { name: 'Prices', description: 'Consulta de precios de criptomonedas' },
        { name: 'Exchange', description: 'Intercambio de monedas' },
        { name: 'Transactions', description: 'Historial de transacciones' }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
