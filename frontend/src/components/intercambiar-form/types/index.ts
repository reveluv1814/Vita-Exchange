import { z } from "zod";

export const exchangeSchema = z
  .object({
    from_currency: z.string().min(1, "Selecciona moneda origen"),
    to_currency: z.string().min(1, "Selecciona moneda destino"),
    amount: z.union([
      z.number().min(1, "Seleccione un monto válido"),
      z.undefined(),
    ]),
  })
  .superRefine((data, ctx) => {
    const { from_currency, to_currency } = data;
    if (from_currency && to_currency && from_currency === to_currency) {
      ctx.addIssue({
        path: ["from-amount"],
        code: "custom",
        message: "Las monedas deben ser diferentes",
      });
    }
  });

export type ExchangeFormData = z.infer<typeof exchangeSchema>;
