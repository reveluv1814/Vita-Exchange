require 'swagger_helper'

RSpec.describe 'Prices API', type: :request do
  path '/api/prices' do
    get 'Obtener precios de criptomonedas' do
      tags 'Prices'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Consulta precios actuales de criptomonedas desde API externa (con caché de 5 minutos)'

      response '200', 'Precios obtenidos exitosamente' do
        schema type: :object,
          properties: {
            prices: {
              type: :object,
              description: 'Precios de criptomonedas',
              example: {
                'BTC' => { 'USD' => 45000.0, 'CLP' => 40000000.0 },
                'USDC' => { 'USD' => 1.0, 'CLP' => 890.0 },
                'USDT' => { 'USD' => 1.0, 'CLP' => 890.0 }
              }
            }
          }
        
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_uuid: user.uuid)}" }
        
        before do
          allow(PriceService).to receive(:get_prices).and_return(mock_vitawallet_prices)
        end
        
        run_test!
      end

      response '401', 'No autorizado' do
        schema '$ref' => '#/components/schemas/Error'
        
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end

      response '503', 'Servicio no disponible (API externa con error)' do
        schema '$ref' => '#/components/schemas/Error'
        
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_uuid: user.uuid)}" }
        
        before do
          allow(PriceService).to receive(:get_prices).and_return(nil)
        end
        
        run_test!
      end
    end
  end
end
