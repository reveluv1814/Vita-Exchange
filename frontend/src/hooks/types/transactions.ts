export interface Transaction {
  uuid: string;
  from_currency: string;
  to_currency: string;
  amount_from: string;
  amount_to: string;
  rate: string;
  status: string;
  error_message: string | null;
  created_at: string;
}

export interface TransactionsResponse {
  transactions: Transaction[];
  page: number;
  limit: number;
  total: number;
  total_pages: number;
  has_next: boolean;
  has_prev: boolean;
}
