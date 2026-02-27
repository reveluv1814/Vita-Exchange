class PricesController < ApplicationController
  # GET /api/prices
  def index
    prices = PriceService.get_prices
    
    if prices
      render json: { prices: prices }
    else
      render json: { error: 'Unable to fetch prices' }, status: :service_unavailable
    end
  end
end
