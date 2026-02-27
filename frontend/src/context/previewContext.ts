import { createContext } from "react";
import type { PreviewContextType } from "./previewContext.tsx";

export const PreviewContext = createContext<PreviewContextType | undefined>(
  undefined,
);
