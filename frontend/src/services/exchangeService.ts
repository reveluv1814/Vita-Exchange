import type { ExchangeResponse } from "@/hooks/types/exchange";
import { httpClient } from "./httpWrapper";
import type {
  ExchangePreviewRequest,
  ExchangePreviewResponse,
} from "@/hooks/types/exchangePreview";

export const exchangeService = {
  exchange: async (
    from_currency: string,
    to_currency: string,
    amount: number,
  ): Promise<ExchangeResponse> => {
    return httpClient.post(
      "/api/exchange",
      {
        from_currency,
        to_currency,
        amount,
      },
      {
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      },
    );
  },

  preview: async (
    data: ExchangePreviewRequest,
  ): Promise<ExchangePreviewResponse> => {
    return httpClient.post("/api/exchange/preview", data, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
      },
    });
  },
};
