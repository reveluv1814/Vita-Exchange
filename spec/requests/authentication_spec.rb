require 'rails_helper'

RSpec.describe 'Authentication API', type: :request do
  describe 'POST /auth/register' do
    let(:valid_params) do
      {
        email: 'newuser@vitawallet.com',
        password: 'SecurePass123!',
        password_confirmation: 'SecurePass123!'
      }
    end

    context 'con parámetros válidos' do
      it 'crea un nuevo usuario' do
        expect {
          post '/auth/register', params: valid_params, as: :json
        }.to change(User, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end

      it 'retorna un token JWT' do
        post '/auth/register', params: valid_params, as: :json
        
        json = JSON.parse(response.body)
        expect(json['token']).to be_present
        expect(json['user']).to be_present
        expect(json['user']['email']).to eq('newuser@vitawallet.com')
      end

      it 'crea balances iniciales para el usuario' do
        post '/auth/register', params: valid_params, as: :json
        
        user = User.find_by(email: 'newuser@vitawallet.com')
        expect(user.wallet_balances.count).to eq(5) # USD, CLP, BTC, USDC, USDT
        
        currencies = user.wallet_balances.pluck(:currency)
        expect(currencies).to contain_exactly('USD', 'CLP', 'BTC', 'USDC', 'USDT')
      end

      it 'establece balances iniciales correctos' do
        post '/auth/register', params: valid_params, as: :json
        
        user = User.find_by(email: 'newuser@vitawallet.com')
        usd_balance = user.wallet_balances.find_by(currency: 'USD')
        clp_balance = user.wallet_balances.find_by(currency: 'CLP')
        btc_balance = user.wallet_balances.find_by(currency: 'BTC')
        
        expect(usd_balance.amount).to eq(BigDecimal('1000.0'))
        expect(clp_balance.amount).to eq(BigDecimal('500000.0'))
        expect(btc_balance.amount).to eq(BigDecimal('0.0'))
      end
    end

    context 'con parámetros inválidos' do
      it 'retorna error 422 si el email ya existe' do
        User.create!(email: 'existing@vitawallet.com', password: 'password123')
        
        post '/auth/register', params: {
          email: 'existing@vitawallet.com',
          password: 'password123',
          password_confirmation: 'password123'
        }, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_an(Array)
        expect(json['errors'].first).to include('Email')
      end

      it 'retorna error 422 si las contraseñas no coinciden' do
        post '/auth/register', params: {
          email: 'newuser@vitawallet.com',
          password: 'password123',
          password_confirmation: 'differentpassword'
        }, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end

      it 'retorna error 422 si el email es inválido' do
        post '/auth/register', params: {
          email: 'invalid-email',
          password: 'password123',
          password_confirmation: 'password123'
        }, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_an(Array)
        expect(json['errors'].first).to include('Email')
      end

      it 'retorna error 422 si faltan parámetros' do
        post '/auth/register', params: {}, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /auth/login' do
    let!(:user) { User.create!(email: 'test@vitawallet.com', password: 'TestPassword123!') }

    context 'con credenciales válidas' do
      it 'retorna un token JWT' do
        post '/auth/login', params: {
          email: 'test@vitawallet.com',
          password: 'TestPassword123!'
        }, as: :json
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['token']).to be_present
        expect(json['user']).to be_present
        expect(json['user']['email']).to eq('test@vitawallet.com')
      end

      it 'el token puede decodificarse correctamente' do
        post '/auth/login', params: {
          email: 'test@vitawallet.com',
          password: 'TestPassword123!'
        }, as: :json
        
        json = JSON.parse(response.body)
        token = json['token']
        
        decoded = JsonWebToken.decode(token)
        expect(decoded).to be_present
        expect(decoded['user_uuid']).to eq(user.uuid)
      end

    end

    context 'con credenciales inválidas' do
      it 'retorna error 401 con contraseña incorrecta' do
        post '/auth/login', params: {
          email: 'test@vitawallet.com',
          password: 'WrongPassword'
        }, as: :json
        
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to be_present
      end

      it 'retorna error 401 con email inexistente' do
        post '/auth/login', params: {
          email: 'nonexistent@vitawallet.com',
          password: 'TestPassword123!'
        }, as: :json
        
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to be_present
      end

      it 'retorna error 401 si faltan parámetros' do
        post '/auth/login', params: { email: 'test@vitawallet.com' }, as: :json
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'Seguridad de tokens' do
    let!(:user) { User.create!(email: 'test@vitawallet.com', password: 'password123') }

    it 'el token expira después de 24 horas' do
      post '/auth/login', params: {
        email: 'test@vitawallet.com',
        password: 'password123'
      }, as: :json
      
      json = JSON.parse(response.body)
      token = json['token']
      decoded = JsonWebToken.decode(token)
      
      expiration_time = Time.at(decoded['exp'])
      expected_expiration = Time.now + 24.hours
      
      expect(expiration_time).to be_within(1.minute).of(expected_expiration)
    end
  end
end
