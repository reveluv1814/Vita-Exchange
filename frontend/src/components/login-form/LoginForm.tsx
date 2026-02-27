import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Eye, EyeOff } from "lucide-react";
import { Field, FieldLabel, FieldDescription } from "@/components/ui/field";
import { loginSchema, type LoginFormData } from "./types";
import { useLogin } from "@/hooks/useLogin";

export function LoginForm() {
  const [showPassword, setShowPassword] = useState(false);
  const { handleLogin, isLoading } = useLogin();
  const {
    register,
    handleSubmit,
    formState: { errors, isValid },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  return (
    <form
      onSubmit={handleSubmit(handleLogin)}
      className="space-y-6"
      style={{ width: "387px" }}
    >
      <Field data-invalid={!!errors.email}>
        <FieldLabel htmlFor="email" className="text-caption-1 text-vita-black">
          Correo electrónico
        </FieldLabel>
        <Input
          id="email"
          type="email"
          {...register("email")}
          disabled={isLoading}
          aria-invalid={!!errors.email}
          placeholder="juan@gmail.com"
        />
        {errors.email && (
          <FieldDescription>{errors.email.message}</FieldDescription>
        )}
      </Field>

      <Field data-invalid={!!errors.password} className="relative mb-0">
        <FieldLabel
          htmlFor="password"
          className="text-caption-1 text-vita-black"
        >
          Contraseña
        </FieldLabel>
        <Input
          id="password"
          type={showPassword ? "text" : "password"}
          className="border-vita-gray-1"
          {...register("password")}
          disabled={isLoading}
          aria-invalid={!!errors.password}
          placeholder="Escribe tu contraseña"
        />
        <button
          type="button"
          className="absolute top-11 -right-88 text-black aria-disabled:opacity-50"
          onClick={() => setShowPassword((v) => !v)}
        >
          {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
        </button>
        {errors.password && (
          <FieldDescription>{errors.password.message}</FieldDescription>
        )}
      </Field>

      <div className="mt-2.5 text-right mb-0">
        <p className="text-caption-2 text-vita-black">
          ¿Olvidaste tu contaseña?
        </p>
      </div>

      <div className="mt-2 text-right">
        <p className="text-caption-1 text-vita-gray-1">
          ¿No tienes cuenta?{" "}
          <a href="#" className="text-vita-blue-2 hover:underline">
            Regístrate
          </a>
        </p>
      </div>

      <Button
        id="login-button"
        type="submit"
        disabled={isLoading || !isValid}
        className="w-full bg-vita-gradient"
      >
        {isLoading ? "Iniciando sesión..." : "Iniciar Sesión"}
      </Button>
    </form>
  );
}
