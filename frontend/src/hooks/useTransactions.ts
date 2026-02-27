import { useEffect, useState } from "react";
import { transactionsService } from "@/services/transactionsService";
import type { TransactionsResponse } from "./types/transactions";

export function useTransactions() {
  const [data, setData] = useState<TransactionsResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchTransactions() {
      setLoading(true);
      setError(null);
      try {
        const result = await transactionsService.getTransactions();
        setData(result);
      } catch (e) {
        setError(e instanceof Error ? e.message : "Error al obtener historial");
      } finally {
        setLoading(false);
      }
    }
    fetchTransactions();
  }, []);

  return { data, loading, error };
}
