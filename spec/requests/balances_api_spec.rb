require 'rails_helper'

RSpec.describe 'Balances API', type: :request do
  let!(:user) { User.create!(email: 'test@vitawallet.com', password: 'password123') }
  let!(:token) { JsonWebToken.encode(user_uuid: user.uuid) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    # balances de prueba
    user.wallet_balances.create!(currency: 'USD', amount: 1000.50)
    user.wallet_balances.create!(currency: 'CLP', amount: 890000.0)
    user.wallet_balances.create!(currency: 'BTC', amount: 0.12345678)
    user.wallet_balances.create!(currency: 'USDC', amount: 500.0)
    user.wallet_balances.create!(currency: 'USDT', amount: 250.75)

    # mock del api externo
    allow(PriceService).to receive(:get_prices).and_return(mock_vitawallet_prices)
  end

  describe 'GET /api/balances' do
    context 'con autenticacion valida' do
      it 'retorna todos los balances del usuario' do
        get '/api/balances', headers: headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json['balances']).to be_an(Array)
        expect(json['balances'].length).to eq(5)
        expect(json).to have_key('total_usd')
        expect(json).to have_key('summary')
      end

      it 'retorna el balance total en usd' do
        get '/api/balances', headers: headers
        
        json = JSON.parse(response.body)
        
        expect(json['total_usd']).to be_present
        total = BigDecimal(json['total_usd'])
        expect(total).to be > 0
      end

      it 'calcula correctamente el valor en usd de cada balance' do
        get '/api/balances', headers: headers
        
        json = JSON.parse(response.body)
        usd_balance = json['balances'].find { |b| b['currency'] == 'USD' }
        
        expect(usd_balance['usd_value']).to eq(usd_balance['amount'])
      end

      it 'retorna los balances en el formato correcto' do
        get '/api/balances', headers: headers
        
        json = JSON.parse(response.body)
        balance = json['balances'].find { |b| b['currency'] == 'USD' }
        
        expect(balance).to have_key('id')
        expect(balance).to have_key('currency')
        expect(balance).to have_key('amount')
        expect(balance['currency']).to eq('USD')
        expect(balance['amount'].to_f).to be_within(0.01).of(1000.50)
      end

      it 'retorna balances con la precision correcta para BTC' do
        get '/api/balances', headers: headers
        
        json = JSON.parse(response.body)
        btc_balance = json['balances'].find { |b| b['currency'] == 'BTC' }
        
        expect(btc_balance['amount']).to eq('0.12345678')
      end

      it 'no retorna balances de otros usuarios' do
        other_user = User.create!(email: 'other@vitawallet.com', password: 'password123')
        other_user.wallet_balances.create!(currency: 'USD', amount: 5000.0)
        
        get '/api/balances', headers: headers
        
        json = JSON.parse(response.body)
        total_amount_usd = json['balances'].find { |b| b['currency'] == 'USD' }['amount'].to_f
        
        expect(total_amount_usd).to be_within(0.01).of(1000.50)
        expect(total_amount_usd).not_to be_within(0.01).of(5000.0)
      end

      it 'retorna balances incluso si algunos son cero' do
        user.wallet_balances.find_by(currency: 'USDT').update(amount: 0)
        
        get '/api/balances', headers: headers
        
        json = JSON.parse(response.body)
        usdt_balance = json['balances'].find { |b| b['currency'] == 'USDT' }
        
        expect(usdt_balance).to be_present
        expect(usdt_balance['amount'].to_f).to eq(0.0)
      end
    end

    context 'sin autenticacion' do
      it 'retorna error 401' do
        get '/api/balances'
        
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to be_present
      end
    end

    context 'con token invalido' do
      it 'retorna error 401' do
        invalid_headers = { 'Authorization' => 'Bearer invalid_token' }
        get '/api/balances', headers: invalid_headers
        
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'con token expirado' do
      it 'retorna error 401' do
        expired_token = JsonWebToken.encode({ user_uuid: user.uuid }, Time.now - 1.day)
        expired_headers = { 'Authorization' => "Bearer #{expired_token}" }
        
        get '/api/balances', headers: expired_headers
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

end
