import { useState } from "react";
import { toast } from "sonner";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";
import type { LoginFormData } from "@/components/login-form/types";
import { authService } from "@/services/authService";

export function useLogin() {
  const [error, setError] = useState<string>("");
  const [isLoading, setIsLoading] = useState(false);
  const { setAuth } = useAuth();
  const navigate = useNavigate();

  const handleLogin = async (data: LoginFormData) => {
    setIsLoading(true);
    setError("");
    try {
      const response = await authService.login(data.email, data.password);
      setAuth(response.token, response.user);
      navigate("/home");
    } catch (e) {
      const errorMessage =
        e instanceof Error
          ? e.message
          : "Error al iniciar sesión. Verifica tus credenciales.";
      setError(errorMessage);
      toast.error("Error al iniciar sesión", {
        position: "top-right",
      });
    } finally {
      setIsLoading(false);
    }
  };

  return {
    handleLogin,
    isLoading,
    error,
  };
}
