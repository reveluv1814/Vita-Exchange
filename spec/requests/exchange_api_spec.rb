require 'rails_helper'

RSpec.describe 'Exchange API', type: :request do
  let!(:user) { User.create!(email: 'test@vitawallet.com', password: 'password123') }
  let!(:token) { JsonWebToken.encode(user_uuid: user.uuid) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    user.wallet_balances.create!(currency: 'USD', amount: 1000.0)
    user.wallet_balances.create!(currency: 'CLP', amount: 1000000.0)
    user.wallet_balances.create!(currency: 'BTC', amount: 0.1)
    user.wallet_balances.create!(currency: 'USDC', amount: 500.0)
    user.wallet_balances.create!(currency: 'USDT', amount: 500.0)

    allow(PriceService).to receive(:get_prices).and_return(mock_vitawallet_prices)
  end

  describe 'POST /api/exchange' do
    context 'con parámetros válidos' do
      it 'realiza el intercambio correctamente' do
        expect {
          post '/api/exchange', params: {
            from_currency: 'USD',
            to_currency: 'USDC',
            amount: 100.0
          }, headers: headers, as: :json
        }.to change(Transaction, :count).by(1)
        
        expect(response).to have_http_status(:ok)
      end

      it 'actualiza los balances correctamente' do
        post '/api/exchange', params: {
          from_currency: 'USD',
          to_currency: 'USDC',
          amount: 100.0
        }, headers: headers, as: :json
        
        user.reload
        usd_balance = user.wallet_balances.find_by(currency: 'USD')
        usdc_balance = user.wallet_balances.find_by(currency: 'USDC')
        
        expect(usd_balance.amount).to eq(BigDecimal('900.0'))
        expect(usdc_balance.amount).to eq(BigDecimal('600.0'))
      end

      it 'crea una transacción con estado completed' do
        post '/api/exchange', params: {
          from_currency: 'USD',
          to_currency: 'USDC',
          amount: 100.0
        }, headers: headers, as: :json
        
        transaction = Transaction.last
        expect(transaction.status).to eq('completed')
        expect(transaction.user_id).to eq(user.id)
        expect(transaction.from_currency).to eq('USD')
        expect(transaction.to_currency).to eq('USDC')
      end

      it 'retorna los detalles de la transacción' do
        post '/api/exchange', params: {
          from_currency: 'USD',
          to_currency: 'USDC',
          amount: 100.0
        }, headers: headers, as: :json
        
        json = JSON.parse(response.body)
        expect(json['transaction']).to be_present
        expect(json['transaction']['from_currency']).to eq('USD')
        expect(json['transaction']['to_currency']).to eq('USDC')
        expect(json['transaction']['status']).to eq('completed')
      end

      it 'permite convertir crypto a fiat' do
        post '/api/exchange', params: {
          from_currency: 'BTC',
          to_currency: 'USD',
          amount: 0.01
        }, headers: headers, as: :json
        
        expect(response).to have_http_status(:ok)
        
        user.reload
        btc_balance = user.wallet_balances.find_by(currency: 'BTC')
        usd_balance = user.wallet_balances.find_by(currency: 'USD')
        
        expect(btc_balance.amount).to eq(BigDecimal('0.09'))
        
        expect(usd_balance.amount).to be_within(1).of(1651.38)
      end

      it 'permite convertir entre stablecoins' do
        post '/api/exchange', params: {
          from_currency: 'USDC',
          to_currency: 'USDT',
          amount: 100.0
        }, headers: headers, as: :json
        
        expect(response).to have_http_status(:ok)
        
        user.reload
        usdc_balance = user.wallet_balances.find_by(currency: 'USDC')
        usdt_balance = user.wallet_balances.find_by(currency: 'USDT')
        
        expect(usdc_balance.amount).to eq(BigDecimal('400.0'))
        expect(usdt_balance.amount).to be_within(0.5).of(600.35)
      end
    end

    context 'con parámetros inválidos' do
      it 'retorna error 422 si falta parámetro from_currency' do
        post '/api/exchange', params: {
          to_currency: 'USDC',
          amount: 100.0
        }, headers: headers, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si falta parámetro to_currency' do
        post '/api/exchange', params: {
          from_currency: 'USD',
          amount: 100.0
        }, headers: headers, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si falta parámetro amount' do
        post '/api/exchange', params: {
          from_currency: 'USD',
          to_currency: 'USDC'
        }, headers: headers, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si amount es negativo' do
        post '/api/exchange', params: {
          from_currency: 'USD',
          to_currency: 'USDC',
          amount: -100.0
        }, headers: headers, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si amount es cero' do
        post '/api/exchange', params: {
          from_currency: 'USD',
          to_currency: 'USDC',
          amount: 0.0
        }, headers: headers, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si from_currency no es válida' do
        post '/api/exchange', params: {
          from_currency: 'INVALID',
          to_currency: 'USD',
          amount: 100.0
        }, headers: headers, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si to_currency no es válida' do
        post '/api/exchange', params: {
          from_currency: 'USD',
          to_currency: 'INVALID',
          amount: 100.0
        }, headers: headers, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si no hay saldo suficiente' do
        post '/api/exchange', params: {
          from_currency: 'USD',
          to_currency: 'USDC',
          amount: 10000.0 # Más de lo que tiene
        }, headers: headers, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Insufficient balance')
      end
    end

    context 'sin autenticación' do
      it 'retorna error 401' do
        post '/api/exchange', params: {
          from_currency: 'USD',
          to_currency: 'USDC',
          amount: 100.0
        }, as: :json
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
    
  end

  describe 'POST /api/exchange/preview' do
    context 'con parámetros válidos' do
      it 'devuelve preview exitoso y no modifica balances' do
        initial_usd = user.wallet_balances.find_by(currency: 'USD').amount
        initial_usdc = user.wallet_balances.find_by(currency: 'USDC').amount
        post '/api/exchange/preview', params: {
          from_currency: 'USD',
          to_currency: 'USDC',
          amount: 100.0
        }, headers: headers, as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['amount']).to eq(100.0)
        expect(json['rate']).to be_a(Float)
        expect(json['total']).to be_a(Float)
        user.reload
        usd_balance = user.wallet_balances.find_by(currency: 'USD').amount
        usdc_balance = user.wallet_balances.find_by(currency: 'USDC').amount
        expect(usd_balance).to eq(initial_usd)
        expect(usdc_balance).to eq(initial_usdc)
      end
    end

    context 'con parámetros inválidos' do
      it 'retorna error 422 si falta parámetro from_currency' do
        post '/api/exchange/preview', params: {
          to_currency: 'USDC',
          amount: 100.0
        }, headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si falta parámetro to_currency' do
        post '/api/exchange/preview', params: {
          from_currency: 'USD',
          amount: 100.0
        }, headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si falta parámetro amount' do
        post '/api/exchange/preview', params: {
          from_currency: 'USD',
          to_currency: 'USDC'
        }, headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si amount es negativo' do
        post '/api/exchange/preview', params: {
          from_currency: 'USD',
          to_currency: 'USDC',
          amount: -100.0
        }, headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si amount es cero' do
        post '/api/exchange/preview', params: {
          from_currency: 'USD',
          to_currency: 'USDC',
          amount: 0.0
        }, headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si from_currency no es válida' do
        post '/api/exchange/preview', params: {
          from_currency: 'INVALID',
          to_currency: 'USD',
          amount: 100.0
        }, headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna error 422 si to_currency no es válida' do
        post '/api/exchange/preview', params: {
          from_currency: 'USD',
          to_currency: 'INVALID',
          amount: 100.0
        }, headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'sin autenticación' do
      it 'retorna error 401' do
        post '/api/exchange/preview', params: {
          from_currency: 'USD',
          to_currency: 'USDC',
          amount: 100.0
        }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end