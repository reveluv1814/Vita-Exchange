import type { UserAuthResponse } from "@/types";
import { httpClient } from "./httpWrapper";

export const authService = {
  login: async (email: string, password: string): Promise<UserAuthResponse> => {
    return httpClient.post("/auth/login", { email, password });
  },
  register: async (
    email: string,
    password: string,
    password_confirmation: string,
  ): Promise<UserAuthResponse> => {
    return httpClient.post("/auth/register", {
      email,
      password,
      password_confirmation,
    });
  },
};
