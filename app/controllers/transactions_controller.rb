class TransactionsController < ApplicationController
  # GET /api/transactions
  def index
    transactions = current_user.transactions.recent
    
    # filtros
    transactions = apply_filters(transactions)
    
    # paginacion
    page = [params[:page]&.to_i || 1, 1].max
    limit = [[params[:limit]&.to_i || 20, 1].max, 100].min
    
    total = transactions.count
    total_pages = (total.to_f / limit).ceil
    
    paginated_transactions = transactions.limit(limit).offset((page - 1) * limit)
    
    render json: {
      transactions: paginated_transactions.map { |t| transaction_json(t) },
      page: page,
      limit: limit,
      total: total,
      total_pages: total_pages,
      has_next: page < total_pages,
      has_prev: page > 1
    }
  end

  # GET /api/transactions/:id
  def show
    transaction = current_user.transactions.find_by!(uuid: params[:id])
    render json: transaction_json(transaction)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Transaction not found' }, status: :not_found
  end

  private
  
  def apply_filters(transactions)
    # filtros
    transactions = transactions.by_status(params[:status]) if params[:status].present?
    
    if params[:from_currency].present?
      transactions = transactions.where(from_currency: params[:from_currency].upcase)
    end
    
    if params[:to_currency].present?
      transactions = transactions.where(to_currency: params[:to_currency].upcase)
    end
    
    if params[:from_date].present?
      begin
        from_date = Date.parse(params[:from_date])
        transactions = transactions.where('created_at >= ?', from_date.beginning_of_day)
      rescue ArgumentError
      end
    end
    
    if params[:to_date].present?
      begin
        to_date = Date.parse(params[:to_date])
        transactions = transactions.where('created_at <= ?', to_date.end_of_day)
      rescue ArgumentError
      end
    end
    
    transactions
  end

  def transaction_json(transaction)
    {
      uuid: transaction.uuid,
      from_currency: transaction.from_currency,
      to_currency: transaction.to_currency,
      amount_from: transaction.amount_from.to_s,
      amount_to: transaction.amount_to.to_s,
      rate: transaction.rate.to_s,
      status: transaction.status,
      error_message: transaction.error_message,
      created_at: transaction.created_at
    }
  end
end
