class ExchangeController < ApplicationController
  # POST /api/exchange
  def create
    # dto
    unless params[:from_currency].present? && params[:to_currency].present? && params[:amount].present?
      return render json: { error: 'Missing required parameters' }, status: :unprocessable_entity
    end

    result = ExchangeService.new(
      user: current_user,
      from_currency: params[:from_currency],
      to_currency: params[:to_currency],
      amount: params[:amount]
    ).execute
    
    if result[:success]
      render json: { 
        transaction: {
          uuid: result[:transaction].uuid,
          from_currency: result[:transaction].from_currency,
          to_currency: result[:transaction].to_currency,
          amount_from: result[:transaction].amount_from.to_s,
          amount_to: result[:transaction].amount_to.to_s,
          rate: result[:transaction].rate.to_s,
          status: result[:transaction].status
        }
      }, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # POST /api/exchange/preview
  def preview
    unless params[:from_currency].present? && params[:to_currency].present? && params[:amount].present?
      return render json: { error: 'Missing required parameters' }, status: :unprocessable_entity
    end

    # Solo calcular, no ejecutar ni persistir transacción
    preview_result = ExchangeService.new(
      user: current_user,
      from_currency: params[:from_currency],
      to_currency: params[:to_currency],
      amount: params[:amount]
    ).preview

    if preview_result[:success]
      render json: {
        from_currency: preview_result[:from_currency],
        to_currency: preview_result[:to_currency],
        amount: preview_result[:amount].to_f,
        rate: preview_result[:rate].to_f,
        rate_display: preview_result[:rate_display].to_f,
        total: preview_result[:amount_to].to_f
      }, status: :ok
    else
      render json: { error: preview_result[:error] }, status: :unprocessable_entity
    end
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
