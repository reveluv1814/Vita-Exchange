require 'rails_helper'

RSpec.describe WalletBalance, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123') }

  describe 'validaciones' do
    it 'es válido con atributos válidos' do
      balance = WalletBalance.new(
        user: user,
        currency: 'USD',
        amount: 100.0
      )
      expect(balance).to be_valid
    end

    it 'es inválido sin currency' do
      balance = WalletBalance.new(user: user, amount: 100.0)
      expect(balance).not_to be_valid
    end

    it 'es inválido con currency no permitida' do
      balance = WalletBalance.new(
        user: user,
        currency: 'INVALID',
        amount: 100.0
      )
      expect(balance).not_to be_valid
    end

    it 'es inválido con amount negativo' do
      balance = WalletBalance.new(
        user: user,
        currency: 'USD',
        amount: -10.0
      )
      expect(balance).not_to be_valid
    end

    it 'valida unicidad de currency por usuario' do
      WalletBalance.create!(
        user: user,
        currency: 'USD',
        amount: 100.0
      )
      
      duplicate = WalletBalance.new(
        user: user,
        currency: 'USD',
        amount: 200.0
      )
      expect(duplicate).not_to be_valid
    end
  end

end
