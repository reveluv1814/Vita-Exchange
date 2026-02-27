class Transaction < ApplicationRecord
  belongs_to :user
  
  STATUSES = %w[pending completed rejected].freeze
  CURRENCIES = %w[USD CLP BTC USDC USDT].freeze
  
  validates :status, inclusion: { in: STATUSES }
  validates :from_currency, :to_currency, presence: true, inclusion: { in: CURRENCIES }
  validates :amount_from, :amount_to, :rate, numericality: { greater_than: 0 }
  validates :uuid, uniqueness: true, allow_nil: true
  
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :recent, -> { order(created_at: :desc) }
end
