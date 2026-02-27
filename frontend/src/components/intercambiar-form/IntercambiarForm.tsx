import { Field, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import { useExchange } from "@/hooks/useExchange";
import { Controller, useForm, useWatch } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { exchangeSchema } from "./types";
import { useEffect } from "react";
import { Button } from "../ui/button";
import { useNavigate } from "react-router-dom";
import chile from "../../assets/chile.svg";
import bitcoin from "../../assets/bitcoin.svg";
import dolar from "../../assets/tether.svg";
import usdc from "../../assets/usdc.svg";
import { formatNumber } from "@/lib/utils";

const valoresCoin = [
  { icono: bitcoin, value: "BTC" },
  { icono: usdc, value: "USDC" },
  { icono: dolar, value: "USDT" },
  { icono: dolar, value: "USD" },
  { icono: chile, value: "CLP" },
];

const IntercambiarForm = () => {
  const navigate = useNavigate();

  const {
    preview,
    loadingPreview,
    errorPreview,
    getPreviewDebounced,
    cancelPreviewDebounce,
    clearPreview,
  } = useExchange();

  const {
    control,
    register,
    formState: { errors, touchedFields },
  } = useForm({
    resolver: zodResolver(exchangeSchema),
    defaultValues: {
      from_currency: "CLP",
      to_currency: "BTC",
      amount: undefined,
    },
    mode: "onChange",
  });

  const from_currency = useWatch({ control, name: "from_currency" });
  const to_currency = useWatch({ control, name: "to_currency" });
  const amount = useWatch({ control, name: "amount" });

  useEffect(() => {
    const isValidNumber =
      typeof amount === "number" && Number.isFinite(amount) && amount > 0;

    if (!from_currency || !to_currency || !isValidNumber) {
      clearPreview();
      return () => cancelPreviewDebounce();
    }

    getPreviewDebounced({ from_currency, to_currency, amount }, 400);

    return () => cancelPreviewDebounce();
  }, [
    from_currency,
    to_currency,
    amount,
    getPreviewDebounced,
    cancelPreviewDebounce,
    clearPreview,
  ]);

  const showCustomAmountError = touchedFields.amount && amount === undefined;

  return (
    <form className="space-y-8">
      <div className="flex flex-col gap-4">
        <FieldLabel htmlFor="from-amount">Monto a intercambiar</FieldLabel>
        <div className="flex gap-4 flex-row">
          <Field className="w-auto" data-invalid={!!errors.from_currency}>
            <Controller
              name="from_currency"
              control={control}
              render={({ field }) => (
                <Select value={field.value} onValueChange={field.onChange}>
                  <SelectTrigger id="from-currency" className="max-w-16 py-5.5">
                    <SelectValue placeholder="Selecciona moneda" />
                  </SelectTrigger>
                  <SelectContent className="w-16">
                    {valoresCoin.map((option) => (
                      <SelectItem key={option.value} value={option.value}>
                        <div className="">
                          <img
                            src={option.icono}
                            alt={option.value}
                            className="w-4 h-4"
                          />
                        </div>
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              )}
            />
          </Field>
          <Field
            className="flex-1"
            data-invalid={!!errors.amount || showCustomAmountError}
          >
            <Input
              id="from-amount"
              type="number"
              inputMode="decimal"
              placeholder="Monto"
              min={1}
              step={"any"}
              {...register("amount", {
                setValueAs: (v) => {
                  if (v === "" || v === null || v === undefined)
                    return undefined;
                  const n = typeof v === "number" ? v : Number(v);
                  return Number.isFinite(n) ? n : undefined;
                },
              })}
            />

            {showCustomAmountError ? (
              <div className="text-caption-1 text-vita-red mt-1">
                Seleccione un monto válido
              </div>
            ) : errors.amount ? (
              <div className="text-caption-1 text-vita-red mt-1">
                {errors.amount.message}
              </div>
            ) : null}
          </Field>
        </div>
      </div>

      <div className="flex flex-col gap-4">
        <FieldLabel htmlFor="to-currency">Quiero recibir</FieldLabel>
        <div className="flex gap-4 flex-row">
          <Field className="w-auto" data-invalid={!!errors.to_currency}>
            <Controller
              name="to_currency"
              control={control}
              render={({ field }) => (
                <Select value={field.value} onValueChange={field.onChange}>
                  <SelectTrigger id="to-currency" className="max-w-16 py-5.5">
                    <SelectValue placeholder="Selecciona moneda" />
                  </SelectTrigger>
                  <SelectContent className="w-16">
                    {valoresCoin.map((option) => (
                      <SelectItem
                        key={option.value}
                        value={option.value}
                        disabled={option.value === from_currency}
                      >
                        <div className="">
                          <img
                            src={option.icono}
                            alt={option.value}
                            className="w-4 h-4"
                          />
                        </div>
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              )}
            />
          </Field>
          <Field className="flex-1">
            <Input
              id="to-amount"
              type="text"
              placeholder="Monto"
              value={
                preview?.total
                  ? formatNumber(preview.total, { maxDecimals: 12 })
                  : ""
              }
              readOnly
            />
            {loadingPreview && (
              <div className="text-caption-2 text-vita-black mt-1">
                Calculando tasa...
              </div>
            )}
            {errorPreview && (
              <div className="text-caption-1 text-vita-red mt-1">
                {errorPreview}
              </div>
            )}
          </Field>
        </div>
      </div>

      <div className="h-40" />

      <div className="flex gap-8 ">
        <Button
          type="button"
          disabled={loadingPreview}
          style={{ width: "183px" }}
          variant={"outline"}
          className="border-vita-blue-1 text-vita-blue-1 hover:bg-vita-blue-1/10"
          onClick={() => navigate("/home")}
        >
          Atrás
        </Button>

        <Button
          type="button"
          disabled={
            loadingPreview || Object.keys(errors).length > 0 || !preview
          }
          style={{ width: "183px" }}
          className={
            loadingPreview || Object.keys(errors).length > 0 || !preview
              ? "bg-vita-gray-2 "
              : "cursor-pointer"
          }
          onClick={() => navigate("/resumen-transaccion")}
        >
          Continuar
        </Button>
      </div>
    </form>
  );
};

export default IntercambiarForm;
