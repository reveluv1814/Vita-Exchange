import {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardHeader,
} from "@/components/ui/card";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableCell,
  TableHead,
} from "@/components/ui/table";
import coin from "../assets/coin.svg";
import { Skeleton } from "@/components/ui/skeleton";
import { useBalances } from "@/hooks/useBalances";
import { useTransactions } from "@/hooks/useTransactions";
import chile from "../assets/chile.svg";
import bitcoin from "../assets/bitcoin.svg";
import dolar from "../assets/tether.svg";

const user = { name: "Juan Pérez" };

const Home = () => {
  const { data, loading, error } = useBalances();
  const {
    data: tableData,
    loading: tableLoading,
    error: tableError,
  } = useTransactions();

  type CoinType = "CLP" | "BTC" | "USDC";
  const iconosCoin: Record<CoinType, { icono: string; title: string }> = {
    CLP: { icono: chile, title: "Peso Chileno" },
    BTC: { icono: bitcoin, title: "Bitcoin" },
    USDC: { icono: dolar, title: "Tether" },
  };

  return (
    <div className="p-6 flex gap-8 flex-col ">
      <div className="flex items-left items-center mb-10 gap-2">
        <div style={{ width: "46px", height: "46.5px" }}>
          <img
            src={coin}
            alt="Coin"
            className="hidden md:block w-full h-full object-cover"
          />
        </div>
        <span className="text-subtitle text-vita-black font-semibold text-left">
          ¡Hola{" "}
          <span className="bg-vita-gradient bg-clip-text text-transparent">
            {" "}
            {user.name}!
          </span>
        </span>
      </div>

      <div className="mb-8">
        <h2 className="text-subtitle-2 font-medium mb-8">Mis saldos</h2>
        <div className="flex gap-4">
          {loading &&
            [1, 2, 3].map((i) => (
              <Card
                key={i}
                className="flex-1 py-4 px-0 bg-vita-gray-3 border-vita-gray-2 border-2"
              >
                <CardHeader>
                  <Skeleton className="h-2 w-2/3 mb-2" />
                  <Skeleton className="h-2 w-6 rounded-full" />
                </CardHeader>
                <CardContent>
                  <Skeleton className="h-2 w-1/2 mb-2" />
                  <Skeleton className="h-2 w-2/3" />
                </CardContent>
              </Card>
            ))}
          {!loading &&
            data &&
            data.balances.map((b) => (
              <Card
                key={b.id}
                className="flex-1 py-4 px-0 bg-vita-gray-3 border-vita-gray-2 border-2"
              >
                <CardHeader>
                  <CardDescription>
                    {iconosCoin[b.currency as CoinType].title}
                  </CardDescription>
                  <CardAction>
                    <div style={{ width: "24px", height: "24px" }}>
                      <img
                        src={iconosCoin[b.currency as CoinType].icono}
                        alt={`${b.currency} icon`}
                        className="hidden md:block w-full h-full object-cover"
                      />
                    </div>
                  </CardAction>
                </CardHeader>

                <CardContent>
                  <div className="text-subtitle-2-semibold text-vita-black font-bold">
                    {b.amount}
                  </div>
                </CardContent>
              </Card>
            ))}
        </div>
        {error && <div className="text-vita-red mt-2">{error}</div>}
      </div>

      <div>
        <h2 className="text-subtitle-2 mb-4">Historial</h2>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Tipo</TableHead>
              <TableHead className="text-right">Monto</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {tableLoading &&
              [1, 2, 3].map((i) => (
                <TableRow key={i}>
                  <TableCell className="text-left text-vita-black">
                    Cargando...
                  </TableCell>
                  <TableCell className="text-right text-vita-blue-2 font-semibold">
                    ---
                  </TableCell>
                </TableRow>
              ))}
            {!tableLoading &&
              tableData?.transactions.map((tx) => (
                <TableRow key={tx.uuid} className="">
                  <TableCell className="text-body text-left text-vita-black py-4">
                    Intercambiaste
                  </TableCell>
                  <TableCell className="text-button text-right text-vita-blue-2 font-semibold py-4">
                    ${tx.amount_to} {tx.to_currency}
                  </TableCell>
                </TableRow>
              ))}
            {tableError && (
              <TableRow>
                <TableCell colSpan={2} className="text-center text-vita-red">
                  {tableError}
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
};

export default Home;
