class AuthController < ApplicationController
  skip_before_action :authenticate_request
  skip_before_action :verify_authenticity_token, raise: false
  
  # POST /auth/register
  def register
    user = User.new(user_params)
    
    if user.save
      # crear balances iniciales
      create_initial_balances(user)
      
      token = JsonWebToken.encode(user_uuid: user.uuid)
      render json: { 
        token: token, 
        user: { 
          uuid: user.uuid, 
          email: user.email 
        } 
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /auth/login
  def login
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_uuid: user.uuid)
      render json: { 
        token: token, 
        user: { 
          uuid: user.uuid, 
          email: user.email 
        } 
      }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end

  def create_initial_balances(user)
    WalletBalance::CURRENCIES.each do |currency|
      user.wallet_balances.create!(
        currency: currency,
        amount: initial_amount_for(currency)
      )
    end
  end

  def initial_amount_for(currency)
    # montos iniciales de prueba
    case currency
    when 'USD' then 1000.0
    when 'CLP' then 500000.0
    when 'BTC' then 0.0
    when 'USDC' then 0.0
    when 'USDT' then 0.0
    else 0.0
    end
  end
end
