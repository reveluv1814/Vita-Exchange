class WalletBalance < ApplicationRecord
  belongs_to :user
  
  CURRENCIES = %w[USD CLP BTC USDC USDT].freeze
  
  validates :currency, presence: true, inclusion: { in: CURRENCIES }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, uniqueness: { scope: :user_id }
end
