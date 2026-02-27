class ExchangeService
  include CurrencyHelper
  
  MINIMUM_AMOUNTS = {
    'BTC' => BigDecimal('0.00000001'), # satoshi
    'USDC' => BigDecimal('0.01'),
    'USDT' => BigDecimal('0.01'),
    'USD' => BigDecimal('0.01'),
    'CLP' => BigDecimal('1')
  }.freeze

  STATUS={
    pending: 'pending',
    completed: 'completed',
    rejected: 'rejected'
  }
  
  def initialize(user:, from_currency:, to_currency:, amount:)
    @user = user
    @from_currency = from_currency.upcase
    @to_currency = to_currency.upcase
    @amount = to_decimal(amount)
  end

  def execute
    # validaciones
    return error('Invalid currencies') unless valid_currencies?
    return error('Cannot exchange same currency') if @from_currency == @to_currency
    return error('Amount must be positive') unless @amount > 0
    return error('Invalid amount format') unless valid_amount?(@amount)
    return error("Amount below minimum (#{MINIMUM_AMOUNTS[@from_currency]})") if below_minimum?
    return error('Amount precision too high') unless valid_precision?
    
    from_balance = @user.wallet_balances.find_by(currency: @from_currency)
    to_balance = @user.wallet_balances.find_by(currency: @to_currency)
    
    return error('Source balance not found') unless from_balance
    return error('Destination balance not found') unless to_balance
    return error('Insufficient balance') if from_balance.amount < @amount
    
    # calcular tasa y monto
    rate = calculate_rate(@from_currency, @to_currency)
    amount_to = @amount * rate
    
    # crear transaccion
    transaction = @user.transactions.new(
      from_currency: @from_currency,
      to_currency: @to_currency,
      amount_from: @amount,
      amount_to: amount_to,
      rate: rate,
      status: STATUS[:pending]
    )
    
    ActiveRecord::Base.transaction do
      # restar y sumar balance
      from_balance.update!(amount: from_balance.amount - @amount)
      
      to_balance.update!(amount: to_balance.amount + amount_to)
      
      # actualizar estado de transaccion
      transaction.status = STATUS[:completed]
      transaction.save!
    end
    
    { success: true, transaction: transaction }
  rescue StandardError => e
    Rails.logger.error("Exchange error: #{e.message}")
    transaction&.update(status: STATUS[:rejected], error_message: e.message)
    error(e.message)
  end

  
  def preview
    # validaciones
    return error('from_currency is required') if @from_currency.nil?
    return error('to_currency is required') if @to_currency.nil?
    return error('amount is required') if @amount.nil?
    return error('Invalid currencies') unless valid_currencies?
    return error('Cannot exchange same currency') if @from_currency == @to_currency
    return error('Amount must be positive') unless @amount > 0
    return error('Invalid amount format') unless valid_amount?(@amount)
    return error("Amount below minimum (#{MINIMUM_AMOUNTS[@from_currency]})") if below_minimum?
    return error('Amount precision too high') unless valid_precision?

    # calcular tasa y monto
    rate = calculate_rate(@from_currency, @to_currency)
    amount_to = @amount * rate

    rate_display = nil
    if rate && rate > 0
      rate_display = BigDecimal('1') / rate
    end
    {
      success: true,
      from_currency: @from_currency,
      to_currency: @to_currency,
      amount: @amount,
      amount_to: amount_to,
      rate: rate,
      total: amount_to,
      rate_display: rate_display
    }
  rescue StandardError => e
    Rails.logger.error("Exchange preview error: #{e.message}")
    error(e.message)
  end

  private

  def valid_currencies?
    WalletBalance::CURRENCIES.include?(@from_currency) &&
      WalletBalance::CURRENCIES.include?(@to_currency)
  end
  
  def below_minimum?
    min = MINIMUM_AMOUNTS[@from_currency] || BigDecimal('0.01')
    @amount < min
  end
  
  def valid_precision?
    # crypto 8 decimales, fiat 2 decimales clp sin decimales
    max_decimals = case @from_currency
                   when 'BTC' then 8
                   when 'CLP' then 0
                   when 'USD', 'USDC', 'USDT' then 2
                   else 2
                   end
    
    amount_str = @amount.to_s
    decimal_part = amount_str.split('.')[1]
    return true unless decimal_part
    
    # remover ceros finales
    significant_decimals = decimal_part.sub(/0+$/, '')
    return true if significant_decimals.empty?
    
    significant_decimals.length <= max_decimals
  end

  def calculate_rate(from, to)
    prices = PriceService.get_prices
    
    from_lower = from.downcase
    to_lower = to.downcase
    
    # misma moneda
    return BigDecimal('1') if from == to
    
    from_is_crypto = crypto_currency?(from)
    to_is_crypto = crypto_currency?(to)
    from_is_fiat = !from_is_crypto
    to_is_fiat = !to_is_crypto
    
    # crypto a fiat (vende crypto)
    if from_is_crypto && to_is_fiat
      # regla de tres para conversion
      ratio_key = "#{to_lower}_sell"
      ratio = prices.dig(from_lower, ratio_key)
      
      if ratio && ratio > 0
        return BigDecimal('1') / ratio
      else
        Rails.logger.error("Missing price: #{from_lower}.#{ratio_key}")
        raise "Price not available for #{from} to #{to}"
      end
    end
    
    # fiat a crypto (compra crypto)
    if from_is_fiat && to_is_crypto
      # conversión directa
      ratio_key = "#{from_lower}_buy"
      ratio = prices.dig(to_lower, ratio_key)
      
      if ratio && ratio > 0
        return ratio
      else
        Rails.logger.error("Missing price: #{to_lower}.#{ratio_key}")
        raise "Price not available for #{from} to #{to}"
      end
    end
    
    # crypto a crypto (vender o comprar crypto via usd)
    if from_is_crypto && to_is_crypto
      # btc a usdc = (btc a USD) * (usd a usdc)
      
      # vender btc
      btc_to_usd_ratio = prices.dig(from_lower, 'usd_sell')
      return BigDecimal('1') unless btc_to_usd_ratio && btc_to_usd_ratio > 0
      
      btc_to_usd = BigDecimal('1') / btc_to_usd_ratio
      
      # comprar usdc con usd
      usd_to_usdc = prices.dig(to_lower, 'usd_buy')
      return BigDecimal('1') unless usd_to_usdc && usd_to_usdc > 0
      
      return btc_to_usd * usd_to_usdc
    end
    
    # de fiat a fiat usando usdc como puente
    if from_is_fiat && to_is_fiat
      # clp a usd = (clp a usdc) * (usdc a usd)

      # comprar usdc con clp
      clp_to_usdc = prices.dig('usdc', "#{from_lower}_buy")
      return BigDecimal('1') unless clp_to_usdc && clp_to_usdc > 0
      
      # vender usdc por usd
      usdc_to_usd_ratio = prices.dig('usdc', "#{to_lower}_sell")
      return BigDecimal('1') unless usdc_to_usd_ratio && usdc_to_usd_ratio > 0
      
      usdc_to_usd = BigDecimal('1') / usdc_to_usd_ratio
      
      return clp_to_usdc * usdc_to_usd
    end
    
    BigDecimal('1')
  end
  
  def crypto_currency?(currency)
    %w[BTC USDC USDT].include?(currency.upcase)
  end

  def error(message)
    { success: false, error: message }
  end
end
