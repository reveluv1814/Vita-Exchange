export interface ExchangeResponse {
  from_currency: string;
  to_currency: string;
  amount: number;
  amount_to: string;
  rate: string;
  status: string;
  error_message?: string | null;
}
