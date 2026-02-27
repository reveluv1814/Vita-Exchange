import type { ExchangePreviewResponse } from "@/hooks/types/exchangePreview";
import React, { useCallback, useEffect, useMemo, useState } from "react";
import { PreviewContext } from "./previewContext";

export type PreviewContextType = {
  preview: ExchangePreviewResponse | null;
  setPreview: (p: ExchangePreviewResponse | null) => void;
  clearPreview: () => void;
  isHydrated: boolean;
};

const STORAGE_KEY = "exchange_preview_only";

export const PreviewProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [preview, setPreviewState] = useState<ExchangePreviewResponse | null>(
    null,
  );
  const [isHydrated, setIsHydrated] = useState(false);

  useEffect(() => {
    try {
      const cached = sessionStorage.getItem(STORAGE_KEY);
      if (cached) {
        const parsed = JSON.parse(cached) as ExchangePreviewResponse;
        if (parsed) setPreviewState(parsed);
      }
    } catch (e) {
      // ignore errors during parsing
      console.log(e);
    } finally {
      setIsHydrated(true);
    }
  }, []);

  useEffect(() => {
    try {
      if (preview) {
        sessionStorage.setItem(STORAGE_KEY, JSON.stringify(preview));
      } else {
        sessionStorage.removeItem(STORAGE_KEY);
      }
    } catch {
      // ignore
    }
  }, [preview]);

  const setPreview = useCallback((p: ExchangePreviewResponse | null) => {
    setPreviewState(p);
  }, []);

  const clearPreview = useCallback(() => {
    setPreviewState(null);
    try {
      sessionStorage.removeItem(STORAGE_KEY);
    } catch (e) {
      // ignore errors during removal
      console.log(e);
    }
  }, []);

  const value = useMemo(
    () => ({ preview, setPreview, clearPreview, isHydrated }),
    [preview, setPreview, clearPreview, isHydrated],
  );

  return (
    <PreviewContext.Provider value={value}>{children}</PreviewContext.Provider>
  );
};
