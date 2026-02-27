module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    attr_reader :current_user
  end

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header.present?
    
    if token.blank?
      render json: { error: 'Missing token' }, status: :unauthorized
      return
    end

    decoded = JsonWebToken.decode(token)
    
    if decoded.nil?
      render json: { error: 'Invalid token' }, status: :unauthorized
      return
    end

    @current_user = User.find_by(uuid: decoded[:user_uuid])
    
    if @current_user.nil?
      render json: { error: 'User not found' }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :unauthorized
  end
end
