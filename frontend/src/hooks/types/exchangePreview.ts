export interface ExchangePreviewRequest {
  from_currency: string;
  to_currency: string;
  amount: number | string;
}

export interface ExchangePreviewResponse {
  from_currency: string;
  to_currency: string;
  amount: string;
  amount_to: string;
  rate: string;
  total: string;
  rate_display: string;
}
