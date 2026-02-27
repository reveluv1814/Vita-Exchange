import { test, expect } from "@playwright/test";

const USER = {
  email: "usuario@email.com",
  password: "123456",
};

test.describe("Flujo de Intercambio", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/login");

    await page.getByRole("textbox", { name: "Correo electrónico" }).click();
    await page
      .getByRole("textbox", { name: "Correo electrónico" })
      .fill(USER.email);
    await page.getByRole("textbox", { name: "Contraseña" }).click();
    await page.getByRole("textbox", { name: "Contraseña" }).fill(USER.password);

    await page.locator("#login-button").click();

    await expect(page.getByText(/Hola /i)).toBeVisible();
  });

  test("Debería loguearse", async ({ page }) => {
    await expect(page.getByText(/Hola /i)).toBeVisible();
  });

  test("Debería dirigirse al apartado de Intercambio", async ({ page }) => {
    await expect(page.getByText(/Hola /i)).toBeVisible();
    await page.getByRole("link", { name: "Intercambiar" }).click();

    const pathname = new URL(page.url()).pathname;
    expect(pathname).toBe("/intercambiar");

    await page
      .getByRole("spinbutton", { name: "Monto a intercambiar" })
      .fill("10");

    await page.getByRole("combobox", { name: "Quiero recibir" }).click();
    await page.getByRole("option", { name: "USDC" }).click();
    await page.getByRole("button", { name: "Continuar" }).click();

    await expect(page.getByRole("button", { name: "Continuar" })).toBeVisible();

    await page.getByRole("button", { name: "Continuar" }).click();

    await expect(page.getByRole("button", { name: "Confirmar" })).toBeVisible();
    await page.getByRole("button", { name: "Confirmar" }).click();

    await expect(page.getByText("¡Intercambio exitoso!")).toBeVisible();

    await page.getByRole("button", { name: "Cerrar" }).click();
  });
});
