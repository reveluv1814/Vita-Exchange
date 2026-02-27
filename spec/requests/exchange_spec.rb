require 'swagger_helper'

RSpec.describe 'Exchange API', type: :request do
  path '/api/exchange' do
    post 'Realizar intercambio de monedas' do
      tags 'Exchange'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Intercambia una cantidad de una moneda a otra. Valida saldo suficiente y actualiza balances automáticamente.'

      parameter name: :exchange, in: :body, schema: {
        type: :object,
        properties: {
          from_currency: { 
            type: :string, 
            enum: ['USD', 'CLP', 'BTC', 'USDC', 'USDT'],
            example: 'USD',
            description: 'Moneda origen'
          },
          to_currency: { 
            type: :string, 
            enum: ['USD', 'CLP', 'BTC', 'USDC', 'USDT'],
            example: 'BTC',
            description: 'Moneda destino'
          },
          amount: { 
            type: :number, 
            format: :float,
            example: 100.0,
            description: 'Cantidad a intercambiar'
          }
        },
        required: ['from_currency', 'to_currency', 'amount']
      }

      response '200', 'Exchange realizado exitosamente' do
        schema type: :object,
          properties: {
            transaction: { '$ref' => '#/components/schemas/Transaction' }
          }
        
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123') }
        let!(:from_balance) { user.wallet_balances.create!(currency: 'USD', amount: 1000.0) }
        let!(:to_balance) { user.wallet_balances.create!(currency: 'BTC', amount: 0.0) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_uuid: user.uuid)}" }
        let(:exchange) { { from_currency: 'USD', to_currency: 'BTC', amount: 100 } }
        
        before do
          allow(PriceService).to receive(:get_prices).and_return(mock_vitawallet_prices)
        end
        
        run_test! do |response|
          expect(response).to have_http_status(:ok)
        end
      end

      response '422', 'Error en el intercambio (saldo insuficiente, moneda inválida, etc.)' do
        schema '$ref' => '#/components/schemas/Error'
        
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123') }
        let!(:from_balance) { user.wallet_balances.create!(currency: 'USD', amount: 10.0) }
        let!(:to_balance) { user.wallet_balances.create!(currency: 'BTC', amount: 0.0) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_uuid: user.uuid)}" }
        let(:exchange) { { from_currency: 'USD', to_currency: 'BTC', amount: 1000 } }
        
        run_test!
      end

      response '401', 'No autorizado' do
        schema '$ref' => '#/components/schemas/Error'
        
        let(:Authorization) { 'Bearer invalid_token' }
        let(:exchange) { { from_currency: 'USD', to_currency: 'BTC', amount: 100 } }
        
        run_test!
      end
    end
  end

  path '/api/exchange/preview' do
    post 'Previsualizar intercambio de monedas' do
      tags 'Exchange'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      description 'Devuelve monto a intercambiar, tasa de cambio y total a recibir, sin modificar balances.'

      parameter name: :exchange_preview, in: :body, schema: {
        type: :object,
        properties: {
          from_currency: { type: :string, enum: ['USD', 'CLP', 'BTC', 'USDC', 'USDT'], example: 'USD', description: 'Moneda origen' },
          to_currency: { type: :string, enum: ['USD', 'CLP', 'BTC', 'USDC', 'USDT'], example: 'BTC', description: 'Moneda destino' },
          amount: { type: :number, format: :float, example: 100.0, description: 'Cantidad a intercambiar' }
        },
        required: ['from_currency', 'to_currency', 'amount']
      }

      response '200', 'Preview exitoso' do
        schema type: :object,
          properties: {
            amount: { type: :number, format: :float, example: 100.0 },
            rate: { type: :number, format: :float, example: 0.000022 },
            total: { type: :number, format: :float, example: 0.0022 }
          },
          required: ['amount', 'rate', 'total']

        let!(:user) { User.create!(email: 'test@example.com', password: 'password123') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_uuid: user.uuid)}" }
        let(:exchange_preview) { { from_currency: 'USD', to_currency: 'BTC', amount: 100 } }

        before do
          allow(PriceService).to receive(:get_prices).and_return(mock_vitawallet_prices)
        end

        run_test! do |response|
          expect(response).to have_http_status(:ok)
        end
      end

      response '422', 'Error en la previsualización (parámetros inválidos, etc.)' do
        schema '$ref' => '#/components/schemas/Error'

        let!(:user) { User.create!(email: 'test@example.com', password: 'password123') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_uuid: user.uuid)}" }
        let(:exchange_preview) { { from_currency: '', to_currency: '', amount: nil } }

        run_test!
      end

      response '401', 'No autorizado' do
        schema '$ref' => '#/components/schemas/Error'

        let(:Authorization) { 'Bearer invalid_token' }
        let(:exchange_preview) { { from_currency: 'USD', to_currency: 'BTC', amount: 100 } }

        run_test!
      end
    end
  end
end
