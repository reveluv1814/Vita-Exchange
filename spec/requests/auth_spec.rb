require 'swagger_helper'

RSpec.describe 'Auth API', type: :request do
  path '/auth/register' do
    post 'Registrar nuevo usuario' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'user@example.com' },
          password: { type: :string, example: 'password123' },
          password_confirmation: { type: :string, example: 'password123' }
        },
        required: ['email', 'password', 'password_confirmation']
      }

      response '201', 'Usuario creado exitosamente' do
        schema type: :object,
          properties: {
            token: { type: :string, description: 'JWT token para autenticación' },
            user: { '$ref' => '#/components/schemas/User' }
          }
        
        let(:user) { { email: 'newuser@example.com', password: 'password123', password_confirmation: 'password123' } }
        run_test!
      end

      response '422', 'Error de validación' do
        schema '$ref' => '#/components/schemas/ValidationErrors'
        
        let(:user) { { email: '', password: 'short' } }
        run_test!
      end
    end
  end

  path '/auth/login' do
    post 'Iniciar sesión' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'test@vitawallet.com' },
          password: { type: :string, example: 'password123' }
        },
        required: ['email', 'password']
      }

      response '200', 'Login exitoso' do
        schema type: :object,
          properties: {
            token: { type: :string, description: 'JWT token para autenticación' },
            user: { '$ref' => '#/components/schemas/User' }
          }
        
        let!(:existing_user) { User.create!(email: 'test@vitawallet.com', password: 'password123') }
        let(:credentials) { { email: 'test@vitawallet.com', password: 'password123' } }
        run_test!
      end

      response '401', 'Credenciales inválidas' do
        schema '$ref' => '#/components/schemas/Error'
        
        let(:credentials) { { email: 'test@vitawallet.com', password: 'wrongpassword' } }
        run_test!
      end
    end
  end
end
