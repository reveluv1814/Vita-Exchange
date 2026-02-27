import { useEffect, useState } from "react";
import { balancesService } from "@/services/balancesService";
import type { BalancesResponse } from "@/types";

export function useBalances() {
  const DATA_CARDS = ["CLP", "BTC", "USDC"];

  const [data, setData] = useState<BalancesResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchBalances() {
      setLoading(true);
      setError(null);
      try {
        const result = await balancesService.getBalances();
        const datosFormateados = formatBalances(result);
        setData(datosFormateados);
      } catch (e) {
        setError(e instanceof Error ? e.message : "Error al obtener balances");
      } finally {
        setLoading(false);
      }
    }
    fetchBalances();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const formatBalances = (
    data: BalancesResponse | null,
  ): BalancesResponse | null => {
    if (!data) return null;
    return {
      ...data,
      balances: data.balances
        .filter((balance) => DATA_CARDS.includes(balance.currency))
        .sort(
          (a, b) =>
            DATA_CARDS.indexOf(a.currency) - DATA_CARDS.indexOf(b.currency),
        ),
    };
  };

  return { data, loading, error };
}
