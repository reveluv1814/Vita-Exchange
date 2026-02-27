import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatRate(
  rate: number | string,
  decimals: number = 2,
): string {
  const num = typeof rate === "string" ? parseFloat(rate) : rate;
  return num.toLocaleString("es-CL", {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });
}

export function parseFloatSafe(value: string | number): number {
  if (typeof value === "number") return value;
  if (typeof value === "string") return parseFloat(value.replace(/,/g, ""));
  return NaN;
}

export function formatNumber(
  value: number | string,
  options?: {
    minDecimals?: number;
    maxDecimals?: number;
  },
): string {
  if (value === null || value === undefined || value === "") return "";

  const num = typeof value === "string" ? Number(value) : value;
  if (!Number.isFinite(num)) return String(value);

  const minDecimals = options?.minDecimals ?? 2;
  const maxDecimals = options?.maxDecimals ?? 12;

  if (Math.abs(num) < 0.0001 && num !== 0) {
    return num.toLocaleString("en-US", {
      minimumFractionDigits: 0,
      maximumFractionDigits: maxDecimals,
      useGrouping: false,
    });
  }

  return num.toLocaleString("en-US", {
    minimumFractionDigits: minDecimals,
    maximumFractionDigits: maxDecimals,
  });
}
