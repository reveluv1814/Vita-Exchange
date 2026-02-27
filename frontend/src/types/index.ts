export interface User {
  uuid: string;
  email: string;
}

export interface AuthContextType {
  token: string | null;
  user: User | null;
  isAuthenticated: boolean;
  setAuth: (token: string, user: User) => void;
  logout: () => void;
}

export interface UserAuthResponse {
  token: string;
  user: User;
}

export interface Balance {
  id: number;
  currency: string;
  amount: string;
  usd_value: string;
}

export interface BalancesResponse {
  balances: Balance[];
  total_usd: string;
  summary: {
    total_usd: string;
    currency_count: number;
    updated_at: string;
  };
}
