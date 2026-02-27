# spec/services/exchange_service_spec.rb
require 'rails_helper'

RSpec.describe ExchangeService, type: :service do
  let(:user) { create(:user) }
  let!(:usd_balance) { create(:wallet_balance, user: user, currency: 'USD', amount: 1000) }
  let!(:btc_balance) { create(:wallet_balance, user: user, currency: 'BTC', amount: 0.1) }
  let!(:clp_balance) { create(:wallet_balance, user: user, currency: 'CLP', amount: 500_000) }

  before do
    # Mock del API de precios (ajusta el helper si es necesario)
    allow(PriceService).to receive(:get_prices).and_return(mock_vitawallet_prices)
  end

  describe '#execute' do
    context 'con parametros validos' do
      it 'ejecuta correctamente el intercambio' do
        result = described_class.new(
          user: user,
          from_currency: 'USD',
          to_currency: 'BTC',
          amount: 500
        ).execute

        expect(result[:success]).to be true
        expect(result[:transaction]).to be_persisted
        expect(result[:transaction].status).to eq('completed')
        expect(result[:transaction].from_currency).to eq('USD')
        expect(result[:transaction].to_currency).to eq('BTC')
      end

      it 'actualiza correctamente los balances' do
        initial_usd = usd_balance.amount
        initial_btc = btc_balance.amount

        described_class.new(
          user: user,
          from_currency: 'USD',
          to_currency: 'BTC',
          amount: 100
        ).execute

        usd_balance.reload
        btc_balance.reload

        expect(usd_balance.amount).to eq(initial_usd - 100)
        expect(btc_balance.amount).to be > initial_btc
      end

      it 'calcula correctamente el monto convertido' do
        result = described_class.new(
          user: user,
          from_currency: 'BTC',
          to_currency: 'USD',
          amount: '0.02'
        ).execute

        # ajusta el delta si tus precios mockeados difieren
        expect(result[:transaction].amount_to).to be_within(5).of(1302.5)
      end
    end

    context 'con validacion de precision' do
      it 'acepta precision de BTC (8 decimales)' do
        result = described_class.new(
          user: user,
          from_currency: 'BTC',
          to_currency: 'USD',
          amount: '0.01234567'
        ).execute

        expect(result[:success]).to be true
      end

      it 'rechaza precision excesiva de BTC (>8 decimales)' do
        result = described_class.new(
          user: user,
          from_currency: 'BTC',
          to_currency: 'USD',
          amount: '0.123456789'
        ).execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('precision')
      end

      it 'acepta precision valida de USD (2 decimales)' do
        result = described_class.new(
          user: user,
          from_currency: 'USD',
          to_currency: 'BTC',
          amount: '100.50'
        ).execute

        expect(result[:success]).to be true
      end

      it 'rechaza precision excesiva de USD (>2 decimales)' do
        result = described_class.new(
          user: user,
          from_currency: 'USD',
          to_currency: 'BTC',
          amount: '100.505'
        ).execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('precision')
      end

      it 'acepta precision valida de CLP (0 decimales)' do
        result = described_class.new(
          user: user,
          from_currency: 'CLP',
          to_currency: 'USD',
          amount: '1000'
        ).execute

        expect(result[:success]).to be true
      end

      it 'rechaza CLP con decimales' do
        result = described_class.new(
          user: user,
          from_currency: 'CLP',
          to_currency: 'USD',
          amount: '1000.50'
        ).execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('precision')
      end
    end

    context 'con validacion de cantidad minima' do
      it 'rechaza cantidad menor al minimo para BTC (1 satoshi)' do
        result = described_class.new(
          user: user,
          from_currency: 'BTC',
          to_currency: 'USD',
          amount: '0.000000001'
        ).execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('minimum')
      end

      it 'acepta cantidad minima para BTC (1 satoshi)' do
        result = described_class.new(
          user: user,
          from_currency: 'BTC',
          to_currency: 'USD',
          amount: '0.00000001'
        ).execute

        expect(result[:success]).to be true
      end

      it 'rechaza cantidad menor al minimo para USD' do
        result = described_class.new(
          user: user,
          from_currency: 'USD',
          to_currency: 'BTC',
          amount: '0.001'
        ).execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('minimum')
      end
    end

    context 'con validacion de saldo' do
      it 'rechaza intercambio con saldo insuficiente' do
        result = described_class.new(
          user: user,
          from_currency: 'USD',
          to_currency: 'BTC',
          amount: 2000
        ).execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('Insufficient balance')
      end

      it 'acepta intercambio con saldo exacto' do
        exact_amount = usd_balance.amount
        result = described_class.new(
          user: user,
          from_currency: 'USD',
          to_currency: 'BTC',
          amount: exact_amount
        ).execute

        expect(result[:success]).to be true
      end

      it 'rechaza si el saldo fuente no existe' do
        user_without_usdc = create(:user)
        create(:wallet_balance, user: user_without_usdc, currency: 'USD', amount: 100)

        result = described_class.new(
          user: user_without_usdc,
          from_currency: 'USDC',
          to_currency: 'USD',
          amount: 10
        ).execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('Source balance not found')
      end

      it 'rechaza si el saldo destino no existe' do
        user_without_btc = create(:user)
        create(:wallet_balance, user: user_without_btc, currency: 'USD', amount: 100)

        result = described_class.new(
          user: user_without_btc,
          from_currency: 'USD',
          to_currency: 'BTC',
          amount: 10
        ).execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('Destination balance not found')
      end
    end

    context 'con validacion de cantidad' do
      it 'rechaza cantidad cero' do
        result = described_class.new(
          user: user,
          from_currency: 'USD',
          to_currency: 'BTC',
          amount: 0
        ).execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('positive')
      end

      it 'rechaza cantidad negativa' do
        result = described_class.new(
          user: user,
          from_currency: 'USD',
          to_currency: 'BTC',
          amount: -100
        ).execute

        expect(result[:success]).to be false
        expect(result[:error]).to include('positive')
      end
    end
  end

  describe '#preview' do
    context 'con parametros validos' do
      it 'devuelve preview exitoso sin modificar balances' do
        initial_usd = usd_balance.amount
        initial_btc = btc_balance.amount

        result = described_class.new(
          user: user,
          from_currency: 'USD',
          to_currency: 'BTC',
          amount: 100
        ).preview

        expect(result[:success]).to be true
        expect(result[:amount]).to eq(BigDecimal('100.0'))
        expect(result[:rate]).to be_a(BigDecimal)
        expect(result[:total]).to be_a(BigDecimal)

        usd_balance.reload
        btc_balance.reload
        expect(usd_balance.amount).to eq(initial_usd)
        expect(btc_balance.amount).to eq(initial_btc)
      end
    end

    context 'con parametros inválidos' do
      it 'devuelve error si falta moneda origen' do
        expect {
          described_class.new(
            user: user,
            from_currency: nil,
            to_currency: 'BTC',
            amount: 100
          ).preview
        }.to raise_error(NoMethodError)
      end

      it 'devuelve error si falta moneda destino' do
        expect {
          described_class.new(
            user: user,
            from_currency: 'USD',
            to_currency: nil,
            amount: 100
          ).preview
        }.to raise_error(NoMethodError)
      end

      it 'devuelve error si falta cantidad' do
        result = described_class.new(
          user: user,
          from_currency: 'USD',
          to_currency: 'BTC',
          amount: nil
        ).preview

          expect(result[:success]).to be false
          expect(result[:error]).to include('positive')
      end
    end
  end
end