require 'swagger_helper'

RSpec.describe 'Transactions API', type: :request do
  path '/api/transactions' do
    get 'Obtener historial de transacciones' do
      tags 'Transactions'
      produces 'application/json'
      security [Bearer: []]
      
      description 'Retorna el historial de transacciones del usuario con filtros opcionales y paginación'
      
      parameter name: :status, in: :query, type: :string, required: false, 
                description: 'Filtrar por estado', enum: ['pending', 'completed', 'rejected']
      parameter name: :from_currency, in: :query, type: :string, required: false,
                description: 'Filtrar por moneda de origen'
      parameter name: :to_currency, in: :query, type: :string, required: false,
                description: 'Filtrar por moneda de destino'
      parameter name: :from_date, in: :query, type: :string, required: false,
                description: 'Filtrar desde fecha (YYYY-MM-DD)'
      parameter name: :to_date, in: :query, type: :string, required: false,
                description: 'Filtrar hasta fecha (YYYY-MM-DD)'
      parameter name: :page, in: :query, type: :integer, required: false, 
                description: 'Número de página (default: 1)'
      parameter name: :limit, in: :query, type: :integer, required: false, 
                description: 'Resultados por página (default: 20, max: 100)'

      response '200', 'Transacciones obtenidas exitosamente' do
        schema type: :object,
          properties: {
            transactions: {
              type: :array,
              items: { '$ref' => '#/components/schemas/Transaction' }
            },
            page: { type: :integer, example: 1 },
            limit: { type: :integer, example: 20 },
            total: { type: :integer, example: 100 },
            total_pages: { type: :integer, example: 5 },
            has_next: { type: :boolean, example: true },
            has_prev: { type: :boolean, example: false }
          }
        
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123') }
        let!(:transaction) do
          user.transactions.create!(
            from_currency: 'USD',
            to_currency: 'BTC',
            amount_from: 100.0,
            amount_to: 0.00222,
            rate: 0.000022,
            status: 'completed'
          )
        end
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_uuid: user.uuid)}" }
        
        run_test!
      end

      response '200', 'Transacciones filtradas por estado' do
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_uuid: user.uuid)}" }
        let(:status) { 'completed' }
        
        run_test!
      end

      response '401', 'No autorizado' do
        schema '$ref' => '#/components/schemas/Error'
        
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end

  path '/api/transactions/{id}' do
    get 'Obtener detalle de transacción' do
      tags 'Transactions'
      produces 'application/json'
      security [Bearer: []]
      
      parameter name: :id, in: :path, type: :string, format: 'uuid', description: 'UUID de la transacción'

      response '200', 'Transacción obtenida exitosamente' do
        schema type: :object,
          properties: {
            transaction: { '$ref' => '#/components/schemas/Transaction' }
          }
        
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123') }
        let!(:transaction) do
          user.transactions.create!(
            from_currency: 'USD',
            to_currency: 'BTC',
            amount_from: 100.0,
            amount_to: 0.00222,
            rate: 0.000022,
            status: 'completed'
          )
        end
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_uuid: user.uuid)}" }
        let(:id) { transaction.uuid }
        
        run_test!
      end

      response '404', 'Transacción no encontrada' do
        schema '$ref' => '#/components/schemas/Error'
        
        let!(:user) { User.create!(email: 'test@example.com', password: 'password123') }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_uuid: user.uuid)}" }
        let(:id) { 999999 }
        
        run_test!
      end

      response '401', 'No autorizado' do
        schema '$ref' => '#/components/schemas/Error'
        
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { 1 }
        
        run_test!
      end
    end
  end
end
