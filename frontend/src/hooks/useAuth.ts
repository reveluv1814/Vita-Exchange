import { AuthContext } from "@/context/authContext";
import type { AuthContextType } from "@/types";
import { useContext } from "react";

export function useAuth(): AuthContextType {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth debe usarse dentro de AuthProvider");
  }
  return context;
}
