require 'rails_helper'
require 'webmock/rspec'

RSpec.describe PriceService, type: :service do
  let(:api_url) { 'https://api.stage.vitawallet.io/api/prices_quote' }

  before do
    ENV['VITAWALLET_API_URL'] = api_url
    ENV['API_TIMEOUT'] = '10'
    Rails.cache.clear
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  after do
    WebMock.reset!
  end

  describe '.get_prices' do
    context 'cuando los precios estan en cache' do
      it 'retorna los precios del cache sin llamar a la API' do
        cached_prices = mock_vitawallet_prices
        Rails.cache.write(PriceService::CACHE_KEY, cached_prices, expires_in: 5.minutes)
        
        allow(PriceService).to receive(:fetch_from_api).and_call_original
        
        result = PriceService.get_prices
        
        expect(result).to be_present
        expect(result).to include('btc', 'usdc', 'usdt')
        expect(PriceService).not_to have_received(:fetch_from_api)
      end
    end

    context 'cuando los precios no estan en cache' do
      it 'llama a la API y retorna precios' do
        api_response = mock_vitawallet_api_response
        
        stub_request(:get, api_url)
          .to_return(status: 200, body: api_response.to_json, headers: { 'Content-Type' => 'application/json' })
        
        result = PriceService.get_prices
        
        expect(result).to include('btc', 'usdc', 'usdt')
        expect(result['btc']).to have_key('usd_buy')
        expect(result['btc']).to have_key('usd_sell')
      end
    end
  end

  describe '.fetch_from_api' do
    context 'cuando la API responde exitosamente' do
      it 'retorna y cachea los precios' do
        api_response = mock_vitawallet_api_response
        
        stub_request(:get, api_url)
          .to_return(status: 200, body: api_response.to_json, headers: { 'Content-Type' => 'application/json' })
        
        result = PriceService.fetch_from_api
        
        expect(result).to be_a(Hash)
        expect(result).to include('btc', 'usdc', 'usdt')
        expect(result['btc']['usd_buy']).to be_a(BigDecimal)
        expect(result['btc']['usd_sell']).to be_a(BigDecimal)
      end
    end

    context 'cuando la API retorna 401 (no autorizado)' do
      it 'retorna precios por defecto' do
        stub_request(:get, api_url)
          .to_return(status: 401, body: 'Unauthorized')
        
        result = PriceService.fetch_from_api
        
        expect(result).to eq(PriceService.default_prices)
      end
    end

    context 'cuando la API retorna 403 (prohibido)' do
      it 'retorna precios por defecto' do
        stub_request(:get, api_url)
          .to_return(status: 403, body: 'Forbidden')
        
        result = PriceService.fetch_from_api
        
        expect(result).to eq(PriceService.default_prices)
      end
    end

    context 'cuando hay timeout' do
      it 'reintenta y eventualmente retorna precios por defecto' do
        stub_request(:get, api_url)
          .to_timeout
        
        result = PriceService.fetch_from_api
        
        expect(result).to eq(PriceService.default_prices)
      end
    end

    context 'cuando hay error de conexion' do
      it 'reintenta y eventualmente retorna precios por defecto' do
        stub_request(:get, api_url)
          .to_raise(SocketError.new('Connection refused'))
        
        result = PriceService.fetch_from_api
        
        expect(result).to eq(PriceService.default_prices)
      end
    end

    context 'cuando la respuesta no tiene las monedas requeridas' do
      it 'retorna precios por defecto' do
        invalid_data = { 'btc' => { 'usd_buy' => '0.000015507' } }
        
        stub_request(:get, api_url)
          .to_return(status: 200, body: invalid_data.to_json)
        
        result = PriceService.fetch_from_api
        
        expect(result).to eq(PriceService.default_prices)
      end
    end

    context 'reintentos' do
      it 'reintenta hasta MAX_RETRIES veces en caso de timeout' do
        stub = stub_request(:get, api_url)
          .to_timeout
        
        PriceService.fetch_from_api
        
        expect(stub).to have_been_requested.times(4)
      end

      it 'se detiene al primer exito sin agotar los reintentos' do
        api_response = mock_vitawallet_api_response
        
        stub = stub_request(:get, api_url)
          .to_timeout.times(2)
          .then.to_return(status: 200, body: api_response.to_json)
        
        result = PriceService.fetch_from_api
        
        expect(result).to include('btc', 'usdc', 'usdt')
        expect(stub).to have_been_requested.times(3)
      end
    end
  end

  describe '.default_prices' do
    it 'retorna un hash con precios para todas las criptomonedas' do
      prices = PriceService.default_prices
      
      expect(prices).to be_a(Hash)
      expect(prices.keys).to match_array(%w[btc usdc usdt])
      expect(prices['btc']).to have_key('usd_buy')
      expect(prices['btc']).to have_key('usd_sell')
      expect(prices['btc']).to have_key('clp_buy')
      expect(prices['btc']).to have_key('clp_sell')
    end
  end
end
