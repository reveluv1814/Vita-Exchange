import type { BalancesResponse } from "@/types";
import { httpClient } from "./httpWrapper";

export const balancesService = {
  getBalances: async (): Promise<BalancesResponse> => {
    return httpClient.get("/api/balances", {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
  },
};
