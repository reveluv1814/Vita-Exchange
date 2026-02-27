require 'rails_helper'

RSpec.describe 'Transactions API', type: :request do
  let!(:user) { User.create!(email: 'test@vitawallet.com', password: 'password123') }
  let!(:token) { JsonWebToken.encode(user_uuid: user.uuid) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    # transaccion de prueba
    10.times do |i|
      user.transactions.create!(
        from_currency: 'USD',
        to_currency: 'USDC',
        amount_from: 100.0,
        amount_to: 100.0,
        rate: 1.0,
        status: i.even? ? 'completed' : 'pending'
      )
    end
  end

  describe 'GET /api/transactions' do
    context 'con autenticacion valida' do
      it 'retorna todas las transacciones del usuario' do
        get '/api/transactions', headers: headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json['transactions']).to be_an(Array)
        expect(json['transactions'].length).to eq(10)
      end

      it 'retorna las transacciones mas recientes primero' do
        get '/api/transactions', headers: headers
        
        json = JSON.parse(response.body)
        timestamps = json['transactions'].map { |t| Time.parse(t['created_at']) }
        
        expect(timestamps).to eq(timestamps.sort.reverse)
      end
    end

    context 'sin autenticacion' do
      it 'retorna error 401' do
        get '/api/transactions'
        
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'con token invalido' do
      it 'retorna error 401' do
        invalid_headers = { 'Authorization' => 'Bearer invalid_token' }
        get '/api/transactions', headers: invalid_headers
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/transactions/:id' do
    let!(:transaction) { user.transactions.first }

    context 'con autenticacion valida' do
      it 'retorna el detalle de la transaccion' do
        get "/api/transactions/#{transaction.uuid}", headers: headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json['uuid']).to eq(transaction.uuid)
        expect(json['from_currency']).to eq('USD')
        expect(json['to_currency']).to eq('USDC')
      end

      it 'retorna 404 si la transaccion no existe' do
        get '/api/transactions/99999', headers: headers
        
        expect(response).to have_http_status(:not_found)
      end

      it 'retorna 404 si la transaccion pertenece a otro usuario' do
        other_user = User.create!(email: 'other@vitawallet.com', password: 'password123')
        other_transaction = other_user.transactions.create!(
          from_currency: 'USD',
          to_currency: 'USDC',
          amount_from: 100.0,
          amount_to: 100.0,
          rate: 1.0,
          status: 'completed'
        )
        
        get "/api/transactions/#{other_transaction.id}", headers: headers
        
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'sin autenticacion' do
      it 'retorna error 401' do
        get "/api/transactions/#{transaction.id}"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
