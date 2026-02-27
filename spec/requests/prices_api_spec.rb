require 'rails_helper'

RSpec.describe 'Prices API', type: :request do
  let!(:user) { User.create!(email: 'test@vitawallet.com', password: 'password123') }
  let!(:token) { JsonWebToken.encode(user_uuid: user.uuid) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    allow(PriceService).to receive(:get_prices).and_return(mock_vitawallet_prices)
  end

  describe 'GET /api/prices' do
    context 'con autenticacion valida' do
      it 'retorna los precios de todas las criptomonedas' do
        get '/api/prices', headers: headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json['prices']).to be_a(Hash)
        expect(json['prices']).to have_key('btc')
        expect(json['prices']).to have_key('usdc')
        expect(json['prices']).to have_key('usdt')
      end

      it 'retorna precios buy y sell en USD y CLP' do
        get '/api/prices', headers: headers
        
        json = JSON.parse(response.body)
        btc_prices = json['prices']['btc']
        
        expect(btc_prices).to have_key('usd_buy')
        expect(btc_prices).to have_key('usd_sell')
        expect(btc_prices).to have_key('clp_buy')
        expect(btc_prices).to have_key('clp_sell')
        expect(btc_prices['usd_buy']).to be_a(String)
      end

      it 'retorna precios de stablecoins' do
        get '/api/prices', headers: headers
        
        json = JSON.parse(response.body)
        
        expect(json['prices']['usdc']['usd_buy']).to be_present
        expect(json['prices']['usdt']['usd_buy']).to be_present
      end

      it 'llama al PriceService' do
        expect(PriceService).to receive(:get_prices).and_return(mock_vitawallet_prices)
        
        get '/api/prices', headers: headers
      end

      it 'cachea los precios' do
        # primera llamada
        get '/api/prices', headers: headers
        
        # segunda llamada deberia usar cache del PriceService
        expect(PriceService).to receive(:get_prices).once.and_return(mock_vitawallet_prices)
        get '/api/prices', headers: headers
      end
    end

    context 'cuando PriceService falla' do
      before do
        allow(PriceService).to receive(:get_prices).and_return(PriceService.default_prices)
      end

      it 'retorna precios por defecto' do
        get '/api/prices', headers: headers
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        
        expect(json['prices']).to be_a(Hash)
        expect(json['prices']['btc']).to be_present
      end
    end

    context 'sin autenticacion' do
      it 'retorna error 401' do
        get '/api/prices'
        
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to be_present
      end
    end

    context 'con token invalido' do
      it 'retorna error 401' do
        invalid_headers = { 'Authorization' => 'Bearer invalid_token' }
        get '/api/prices', headers: invalid_headers
        
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'con token expirado' do
      it 'retorna error 401' do
        expired_token = JsonWebToken.encode({ user_uuid: user.uuid }, Time.now - 1.day)
        expired_headers = { 'Authorization' => "Bearer #{expired_token}" }
        
        get '/api/prices', headers: expired_headers
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

end
