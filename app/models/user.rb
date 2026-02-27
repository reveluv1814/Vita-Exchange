class User < ApplicationRecord
  has_secure_password
  
  has_many :wallet_balances, dependent: :destroy
  has_many :transactions, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :uuid, uniqueness: true, allow_nil: true
  
  # poner el uuid en el payload
  def to_token_payload
    { user_uuid: uuid }
  end
end
