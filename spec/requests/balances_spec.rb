require 'swagger_helper'

RSpec.describe 'Balances API', type: :request do
  path '/api/balances' do
    get 'Obtener balances del usuario' do
      tags 'Balances'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Retorna todos los balances de monedas del usuario autenticado'

      response '200', 'Balances obtenidos exitosamente' do
        schema type: :object,
          properties: {
            balances: {
              type: :array,
              items: { '$ref' => '#/components/schemas/Balance' }
            },
            total_usd: { type: :string, description: 'Total in USD', example: '1000.0' },
            summary: {
              type: :object,
              properties: {
                total_usd: { type: :string },
                currency_count: { type: :integer },
                updated_at: { type: :string, format: 'date-time' }
              }
            }
          }
        
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123') }
        let!(:balance) { user.wallet_balances.create!(currency: 'USD', amount: 1000.0) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_uuid: user.uuid)}" }
        
        before do
          allow(PriceService).to receive(:get_prices).and_return(mock_vitawallet_prices)
        end
        
        run_test!
      end

      response '401', 'No autorizado - Token inválido o faltante' do
        schema '$ref' => '#/components/schemas/Error'
        
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end
end
