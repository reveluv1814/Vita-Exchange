import { httpClient } from "./httpWrapper";
import type { TransactionsResponse } from "@/hooks/types/transactions";

export const transactionsService = {
  getTransactions: async (): Promise<TransactionsResponse> => {
    return httpClient.get("/api/transactions", {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
  },
};
