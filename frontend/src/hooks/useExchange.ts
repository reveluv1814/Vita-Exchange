import { useCallback, useRef, useState } from "react";
import { exchangeService } from "@/services/exchangeService";
import type { ExchangeResponse } from "./types/exchange";
import type { ExchangePreviewRequest } from "./types/exchangePreview";
import { usePreviewContext } from "./usePreviewContext";

export function useExchange() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<ExchangeResponse | null>(null);

  const [loadingPreview, setLoadingPreview] = useState(false);
  const [errorPreview, setErrorPreview] = useState<string | null>(null);

  const { preview, setPreview, clearPreview } = usePreviewContext();

  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const exchange = async ({
    from_currency,
    to_currency,
    amount,
  }: {
    from_currency: string;
    to_currency: string;
    amount: number;
  }) => {
    setLoading(true);
    setError(null);
    setResult(null);
    try {
      const res = await exchangeService.exchange(
        from_currency,
        to_currency,
        amount,
      );
      setResult(res);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Error al intercambiar");
    } finally {
      setLoading(false);
    }
  };

  const getPreview = useCallback(async (data: ExchangePreviewRequest) => {
    setLoadingPreview(true);
    setErrorPreview(null);
    try {
      const response = await exchangeService.preview(data);
      setPreview(response);
    } catch (e) {
      setErrorPreview(
        e instanceof Error ? e.message : "Error al obtener preview",
      );
      clearPreview();
    } finally {
      setLoadingPreview(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const getPreviewDebounced = useCallback(
    (data: ExchangePreviewRequest, delay = 400) => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
      setLoadingPreview(true);
      setErrorPreview(null);

      debounceRef.current = setTimeout(async () => {
        try {
          const response = await exchangeService.preview(data);
          setPreview(response);
        } catch (e) {
          setErrorPreview(
            e instanceof Error ? e.message : "Error al obtener preview",
          );
          clearPreview();
        } finally {
          setLoadingPreview(false);
        }
      }, delay);
    },
    [setPreview, clearPreview],
  );

  const cancelPreviewDebounce = useCallback(() => {
    if (debounceRef.current) {
      clearTimeout(debounceRef.current);
      debounceRef.current = null;
    }
  }, []);

  return {
    exchange,
    loading,
    error,
    result,

    getPreview,
    getPreviewDebounced,
    cancelPreviewDebounce,

    preview,
    loadingPreview,
    errorPreview,
    clearPreview,
  };
}
