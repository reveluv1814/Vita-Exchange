import { Button } from "@/components/ui/button";
import { ArrowLeft } from "lucide-react";
import { useExchange } from "@/hooks/useExchange";
import { usePreviewContext } from "@/hooks/usePreviewContext";
import { useEffect, useState } from "react";
import { parseFloatSafe } from "@/lib/utils";
import { useNavigate } from "react-router-dom";
import {
  Dialog,
  DialogContent,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { Card, CardContent } from "@/components/ui/card";
import { Spinner } from "@/components/ui/spinner";
import amicoFinish from "../assets/amico-finish.svg";

const ResumenTransaccion = () => {
  const { preview, isHydrated, clearPreview } = usePreviewContext();
  const { exchange, loading, error, result } = useExchange();
  const navigate = useNavigate();

  const [open, setOpen] = useState(false);
  const [showResult, setShowResult] = useState(false);

  const handleBack = () => {
    clearPreview();
    navigate("/intercambiar");
  };

  const handleOpenModal = () => {
    setOpen(true);
    setShowResult(false);
  };

  useEffect(() => {
    if (!isHydrated) return;
    if (!preview) {
      navigate("/intercambiar", { replace: true });
    }
  }, [isHydrated, preview, navigate]);

  const handleCloseModal = () => {
    if (result) clearPreview();

    setOpen(false);
    setShowResult(false);
  };

  if (!preview) return <div>Datos no disponibles. Redirigiendo...</div>;

  return (
    <div className="pt-20 pl-40 flex gap-8 flex-col">
      <div className="flex items-center gap-4 mb-8">
        <Button
          type="button"
          variant="link"
          className="text-vita-blue-1 hover:bg-vita-blue-1/10"
          onClick={handleBack}
        >
          <ArrowLeft className="w-5 h-5" />
        </Button>
        <h2 className="text-subtitle-2 font-semibold ">
          ¿Qué deseas intercambiar?
        </h2>
      </div>
      <Card className="bg-vita-gray-3 w-3/5 mb-20">
        <CardContent>
          <div className="flex justify-between">
            <div>
              <span className="text-caption-1">Monto a intercambiar</span>
            </div>
            <div>
              <span className="text-button">
                {preview.amount} {preview.from_currency}
              </span>
            </div>
          </div>
          <div className="flex justify-between">
            <div>
              <span className="text-caption-1">Tasa de cambio</span>
            </div>
            <div>
              <span className="text-button">
                {preview.rate_display} {preview.to_currency}
              </span>
            </div>
          </div>
          <div className="flex justify-between">
            <div>
              <span className="text-caption-1">Total a recibir</span>
            </div>
            <div>
              <span className="text-button text-vita-blue-1">
                {preview.total} {preview.to_currency}
              </span>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="h-64" />

      <div className="flex gap-8">
        <Button
          type="button"
          style={{ width: "183px" }}
          variant={"outline"}
          className="border-vita-blue-1 text-vita-blue-1 hover:bg-vita-blue-1/10"
          onClick={handleBack}
        >
          Atrás
        </Button>

        <Button
          type="button"
          disabled={!preview}
          style={{ width: "183px" }}
          className={!preview ? "bg-vita-gray-2 " : "cursor-pointer"}
          onClick={handleOpenModal}
        >
          Continuar
        </Button>
      </div>

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent>
          {!showResult && !loading && (
            <>
              <DialogTitle>Confirmar intercambio</DialogTitle>
              <DialogDescription>
                ¿Estás seguro que deseas realizar el intercambio?
              </DialogDescription>
              <div className="flex gap-2 justify-end mt-4">
                <Button variant="outline" onClick={() => setOpen(false)}>
                  Cancelar
                </Button>
                <Button
                  onClick={async () => {
                    await exchange({
                      from_currency: preview.from_currency,
                      to_currency: preview.to_currency,
                      amount: parseFloatSafe(preview.amount),
                    });
                    setShowResult(true);
                  }}
                >
                  Confirmar
                </Button>
              </div>
            </>
          )}
          {loading && (
            <div className="flex flex-col items-center  justify-center gap-6">
              <Spinner className="size-8 text-vita-blue-1" />
              <span className="flex-col">Procesando intercambio...</span>
            </div>
          )}
          {showResult && !loading && (
            <div className="flex flex-col items-center justify-center py-8 gap-4">
              {result ? (
                <>
                  <div style={{ width: "308px", height: "304px" }}>
                    <img
                      src={amicoFinish}
                      alt="Imagen de finalización"
                      className="hidden md:block w-full h-full object-cover"
                    />
                  </div>

                  <span className="text-subtitle text-vita-blue-1">
                    ¡Intercambio exitoso!
                  </span>
                  <span className="text-body ">
                    Ya cuentas con los {preview.to_currency} en tu saldo.
                  </span>
                </>
              ) : (
                <span className="text-button mb-4">Operación finalizada.</span>
              )}

              {error && (
                <span className="text-caption-1 text-vita-red mb-4">
                  {error}
                </span>
              )}

              <Button onClick={handleCloseModal}>Cerrar</Button>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default ResumenTransaccion;
