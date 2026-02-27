Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # rutas sin autenticación
  post '/auth/register', to: 'auth#register'
  post '/auth/login', to: 'auth#login'
  
  # rutas protegidas
  scope '/api' do
    get '/balances', to: 'balances#index'
    
    get '/prices', to: 'prices#index'
    
    post '/exchange', to: 'exchange#create'
    post '/exchange/preview', to: 'exchange#preview'
    
    get '/transactions', to: 'transactions#index'
    get '/transactions/:id', to: 'transactions#show'
  end
end
