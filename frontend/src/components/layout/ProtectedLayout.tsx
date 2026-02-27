import type { ReactNode } from "react";
import { Sidebar } from "./Sidebar";

export function ProtectedLayout({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-screen bg-muted/40">
      <Sidebar />
      <main className="flex-1 p-8">{children}</main>
    </div>
  );
}
