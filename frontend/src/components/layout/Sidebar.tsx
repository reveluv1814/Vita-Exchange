import { Link, useLocation } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { useAuth } from "@/hooks/useAuth";

const navItems = [
  { name: "Inicio", path: "/home" },
  { name: "Transferir", path: "" },
  { name: "Recargar", path: "" },
  { name: "Intercambiar", path: "/intercambiar" },
  { name: "Perfil", path: "" },
  { name: "Ayuda", path: "" },
];

export function Sidebar() {
  const location = useLocation();
  const { logout } = useAuth();
  return (
    <aside className="h-screen w-93 border-r bg-vita-blue-1 flex flex-col py-20">
      <div className="p-6 text-subtitle-2-semibold text-vita-white mb-10 text-center">
        VitaWallet
      </div>

      <nav className="flex flex-col text-subtitle-2 text-vita-white gap-5">
        {navItems.map((item) => {
          const isActive = location.pathname === item.path;

          return (
            <Link
              key={item.path}
              to={item.path ? item.path : "#"}
              className="pr-24"
            >
              <div
                className={cn(
                  "w-full pr-10 bg-vita-blue-1 rounded-tr-[32.5px] rounded-br-[32.5px] flex items-center mr-10 py-4 pl-12 transition-colors cursor-pointer group",
                  isActive
                    ? "bg-vita-blue-2 text-vita-white "
                    : "hover:text-vita-white text-vita-white/80",
                )}
              >
                <span className="">{item.name}</span>
              </div>
            </Link>
          );
        })}
      </nav>

      <div className="mt-auto p-4 ">
        <Button
          variant="link"
          className="w-full bg-transparent text-subtitle-2 text-vita-white cursor-pointer"
          onClick={() => logout()}
        >
          Cerrar sesión
        </Button>
      </div>
    </aside>
  );
}
