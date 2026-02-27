module CurrencyHelper
  # valida que un monto sea correcto
  def valid_amount?(amount)
    return false if amount.nil?
    
    begin
      amount = BigDecimal(amount.to_s)
      amount > 0
    rescue ArgumentError, TypeError
      false
    end
  end

  # convierte un float a BigDecimal
  def to_decimal(value)
    return BigDecimal('0') if value.nil?
    
    begin
      BigDecimal(value.to_s)
    rescue ArgumentError, TypeError
      BigDecimal('0')
    end
  end

end
