# db/seeds.rb

Transaction.destroy_all
WalletBalance.destroy_all
User.destroy_all

# usuario de prueba
puts "Creando usuario de prueba"
user = User.create!(
  email: 'usuario@email.com',
  password: '123456',
  password_confirmation: '123456'
)

# balances iniciales
puts "Creando balances iniciales"
balances_data = {
  'USD' => 1000.0,
  'CLP' => 500000.0,
  'BTC' => 0.05,
  'USDC' => 100.0,
  'USDT' => 100.0
}

balances_data.each do |currency, amount|
  user.wallet_balances.create!(
    currency: currency,
    amount: amount
  )
end

puts "creando transacciones de ejemplo"
[
  { from: 'USD', to: 'BTC', amount_from: 100, rate: 0.000022, status: 'completed' },
  { from: 'CLP', to: 'USD', amount_from: 89000, rate: 0.001123, status: 'completed' },
  { from: 'USD', to: 'USDC', amount_from: 50, rate: 1.0, status: 'pending' }
].each do |tx_data|
  user.transactions.create!(
    from_currency: tx_data[:from],
    to_currency: tx_data[:to],
    amount_from: tx_data[:amount_from],
    amount_to: tx_data[:amount_from] * tx_data[:rate],
    rate: tx_data[:rate],
    status: tx_data[:status]
  )
end

puts "balances:"
user.wallet_balances.each do |balance|
  puts "   #{balance.currency}: #{balance.amount}"
end
