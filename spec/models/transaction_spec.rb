require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123') }

  describe 'validaciones' do
    it 'con atributos válidos' do
      transaction = Transaction.new(
        user: user,
        from_currency: 'USD',
        to_currency: 'BTC',
        amount_from: 100.0,
        amount_to: 0.0022,
        rate: 0.000022,
        status: 'completed'
      )
      expect(transaction).to be_valid
    end

    it 'valida que el status sea uno de los permitidos' do
      transaction = Transaction.new(
        user: user,
        from_currency: 'USD',
        to_currency: 'BTC',
        amount_from: 100.0,
        amount_to: 0.0022,
        rate: 0.000022,
        status: 'invalid_status'
      )
      expect(transaction).not_to be_valid
    end

    it 'valida que amount_from sea positivo' do
      transaction = Transaction.new(
        user: user,
        from_currency: 'USD',
        to_currency: 'BTC',
        amount_from: -100.0,
        amount_to: 0.0022,
        rate: 0.000022,
        status: 'pending'
      )
      expect(transaction).not_to be_valid
    end
  end

end
