class BalancesController < ApplicationController
  include CurrencyHelper

  # GET /api/balances
  def index
    balances = current_user.wallet_balances.order(:currency)
    prices = PriceService.get_prices
    
    balances_data = balances.map do |balance|
      usd_value = calculate_usd_value(balance.currency, balance.amount, prices)
      
      {
        id: balance.id,
        currency: balance.currency,
        amount: balance.amount.to_s,
        usd_value: usd_value.to_s # valor en usd
      }
    end
    
    total_usd = balances_data.sum { |b| BigDecimal(b[:usd_value]) }
    
    render json: {
      balances: balances_data,
      total_usd: total_usd.to_s,
      summary: {
        total_usd: total_usd.to_s,
        currency_count: balances.count,
        updated_at: Time.current
      }
    }
  end

  private

  def calculate_usd_value(currency, amount, prices)
    case currency.upcase
    when 'USD'
      amount
    when 'CLP'
      # 890 clp = 1 aproximado
      amount / BigDecimal('890')
    when 'BTC'
      btc_price = BigDecimal(prices.dig('BTC', 'USD')&.to_s || '45000')
      amount * btc_price
    when 'USDC', 'USDT'
      # stablecoins: 1:1 con usd
      amount * BigDecimal('1')
    else
      BigDecimal('0')
    end
  end
end
