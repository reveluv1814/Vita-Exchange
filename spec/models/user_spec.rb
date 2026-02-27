require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validaciones' do
    it 'es válido con atributos válidos' do
      user = User.new(
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
      expect(user).to be_valid
    end

    it 'es inválido sin email' do
      user = User.new(password: 'password123')
      expect(user).not_to be_valid
    end

    it 'es inválido con email duplicado' do
      User.create!(
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
      
      user = User.new(
        email: 'test@example.com',
        password: 'password123'
      )
      expect(user).not_to be_valid
    end
  end

  describe 'password encryption' do
    it 'password encriptado' do
      user = User.create!(
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
      expect(user.password_digest).not_to eq('password123')
      expect(user.password_digest).to be_present
    end

    it 'se autentica con el correo y password' do
      user = User.create!(
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'no se autentica con credenciales incorrectas' do
      user = User.create!(
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
      expect(user.authenticate('wrongpassword')).to be_falsey
    end
  end
end
