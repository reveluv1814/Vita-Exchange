import type { PreviewContextType } from "@/context/previewContext.tsx";
import { PreviewContext } from "@/context/previewContext.ts";
import { useContext } from "react";

export function usePreviewContext(): PreviewContextType {
  const context = useContext(PreviewContext);
  if (!context)
    throw new Error("usePreviewContext must be used within <PreviewProvider>");
  return context;
}
