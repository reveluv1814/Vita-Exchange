import Login from "../pages/Login";
import { createBrowserRouter, Navigate, Outlet } from "react-router-dom";
import { ProtectedRoute } from "./ProtectedRoute";
import Home from "../pages/Home";
import Intercambiar from "@/pages/Intercambiar";
import ResumenTransaccion from "@/pages/ResumenTransaccion";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <Navigate to="/login" replace />,
  },
  {
    path: "/login",
    element: <Login />,
  },
  // Rutas protegidas (agregaremos después)
  {
    element: (
      <ProtectedRoute>
        <ProtectedLayout>
          <Outlet />
        </ProtectedLayout>
      </ProtectedRoute>
    ),
    children: [
      {
        path: "/home",
        element: <Home />,
      },
      {
        path: "/intercambiar",
        element: <Intercambiar />,
      },
      {
        path: "/resumen-transaccion",
        element: <ResumenTransaccion />,
      },
    ],
  },
]);
