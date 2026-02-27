import IntercambiarForm from "@/components/intercambiar-form/IntercambiarForm";
import { useBalances } from "@/hooks/useBalances";

const Intercambiar = () => {
  const { data, loading } = useBalances();
  const clpBalance = data?.balances.find((b) => b.currency === "CLP");

  return (
    <div className="pt-20 pl-40 flex gap-8 flex-col">
      <div>
        <h2 className="text-subtitle-2 font-semibold mb-8">
          Resumen de transacción
        </h2>
      </div>

      <div className="mb-6 text-button text-vita-blue-2">
        Saldo disponible:{" "}
        <span className="font-semibold">
          {loading
            ? "Cargando..."
            : clpBalance
              ? `$ ${Number(clpBalance.amount).toLocaleString("es-CL", { minimumFractionDigits: 2 })} CLP`
              : "$ 0,00 CLP"}
        </span>
      </div>
      <div>
        <IntercambiarForm />
      </div>
    </div>
  );
};

export default Intercambiar;
