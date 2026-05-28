# GastoSmart — Estado del Proyecto

_Última actualización: 28 de mayo de 2026_

App de control de gastos personales. Documento de continuidad para retomar el proyecto en cualquier momento (incluso desde una PC nueva o una conversación nueva).

---

## 1. Accesos y enlaces

| Recurso | Valor |
|---|---|
| App en producción | https://gasto-smart-six.vercel.app |
| Repo GitHub (privado) | https://github.com/PEMOANG90/GastoSmart |
| Supabase URL | https://ekoojdgqizzdbcqkxgln.supabase.co |
| Carpeta local | `C:\Users\Pedro Molina\OneDrive\Desktop\GastoSmart\Scrpt\files` |

> La anon key va en el frontend a propósito (es pública por diseño). Lo que protege los datos son las políticas RLS (ya configuradas en transactions, tarjetas y profiles).

---

## 2. Stack

HTML + CSS + JavaScript vanilla (todo inline en `index.html`) · Supabase (auth + base de datos) · Chart.js · Vercel (hosting).

---

## 3. Cómo desplegar

1. Editar los archivos en la carpeta local.
2. Doble clic en `actualizar.bat` → inyecta versión, sube a GitHub, Vercel despliega.
3. Esperar a `[3/3] Listo!` y ~60 s. Recargar con Ctrl+Shift+R.

Archivos del proyecto: `index.html` (toda la app), `vercel.json` (control de caché), `actualizar.bat` (deploy).

---

## 4. Lo que funciona

- Login email/contraseña y Google OAuth (flujo PKCE, sesión se renueva sola).
- Cerrar sesión (determinista, sin colgarse).
- Dashboard: métricas, gráfica de categorías, presupuesto mensual (conectado a los límites reales), últimas transacciones, recomendaciones (reglas).
- Transacciones: alta con 50+ categorías + categoría personalizada.
- Presupuesto: editable por categoría, guardado en la nube (columna `budgets` en `profiles`).
- Tarjetas TC: guardado en la nube (tabla `tarjetas` con RLS).
- Caché: usuarios reciben siempre la versión fresca (vercel.json no-store).

---

## 5. Estado de la base de datos (Supabase)

Tablas y seguridad RLS (cada usuario solo accede a lo suyo):

- **transactions** — RLS activado. Política `transactions_own` (`auth.uid() = user_id`). Tiene columna `note`.
- **tarjetas** — creada con RLS. Política `tarjetas_own` (`auth.uid() = user_id`).
- **profiles** — RLS activado. Política `profiles_own` (`auth.uid() = id`). Tiene columna `budgets jsonb` (presupuestos del usuario).

SQL de referencia ya aplicado:
```sql
-- presupuestos
alter table profiles add column if not exists budgets jsonb default '{}'::jsonb;
-- tabla tarjetas
create table if not exists tarjetas(
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade,
  banco text, nombre text, digitos text,
  limite numeric default 0, saldo numeric default 0, minimo numeric default 0,
  dia_corte int, dia_pago int, tasa numeric, created_at timestamptz default now());
-- columna note en transactions
alter table transactions add column if not exists note text;
-- RLS
alter table transactions enable row level security;
create policy "transactions_own" on transactions for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
alter table tarjetas enable row level security;
create policy "tarjetas_own" on tarjetas for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
alter table profiles enable row level security;
create policy "profiles_own" on profiles for all using (auth.uid()=id) with check (auth.uid()=id);
```

---

## 6. Cambios hechos en la sesión del 28 may 2026

1. **Caché (versión vieja "pegada")** → `vercel.json` con `Cache-Control: no-store` en el HTML.
2. **Auto-versionado** → la versión se lee del meta tag `app-version`; `actualizar.bat` inyecta `YYYYMMDDHHMMSS` con regex flexible y `git add -A`.
3. **Mojibake (acentos/emojis)** → `actualizar.bat` lee y escribe en UTF-8 (`-Encoding UTF8`).
4. **Cerrar sesión** → `doSignOut` usa `signOut({scope:'local'})` (sin red, no se cuelga) + marca `gs_logout` en sessionStorage + recarga forzada con parámetro cambiante a URL limpia. `start()` respeta la marca y fuerza login.
5. **Presupuesto editable + nube** → página de presupuesto con inputs por categoría, agregar/quitar categorías, botón Guardar; funciones `loadBudgets`/`saveBudgets`; dashboard lee `userBudgets`.
6. **Tabla `tarjetas`** → creada con RLS (antes daba 404).
7. **RLS** → activado en `transactions`, `tarjetas` y `profiles`.
8. **Sesión que caducaba (causa raíz de fallos fantasma)** → cambio de `flowType:'implicit'` a **`flowType:'pkce'`**: el token se renueva automáticamente. Antes la app se veía logueada pero el servidor ya no reconocía la sesión, lo que causaba: datos en $0, no guardar transacciones y logout colgado.

---

## 7. Pendientes / próximos pasos

- [ ] Favicon: la consola muestra `404 /favicon.ico` (cosmético). Agregar un ícono para quitarlo.
- [ ] "Recomendaciones IA" del dashboard son reglas fijas, no IA real (mejora opcional).
- [ ] Gráfica de líneas en Reportes usa datos de ejemplo hardcodeados (Ago–Ene). Conectar a datos reales si se desea.
- [ ] Verificar de vez en cuando que la sesión PKCE se mantenga (no debería volver a caducar).

---

## 8. Diagnóstico rápido (si algo falla)

- **Datos en $0 / no guarda / logout colgado** → probable sesión inválida. Cerrar sesión y volver a entrar. Con PKCE debería ser raro.
- **Versión vieja tras deploy** → confirmar que `vercel.json` está en el repo; Ctrl+Shift+R.
- **Acentos/emojis rotos** → el `actualizar.bat` debe tener `-Encoding UTF8` en lectura y escritura.
- **Error al guardar (rojo en consola)** → revisar pestaña Network → request a la tabla → Status (401/403 = sesión/RLS; 400/PGRST204 = columna faltante).

---

## 9. Prompt de continuación (pegar en una conversación nueva)

> Continuamos el proyecto GastoSmart — app de control de gastos personales.
> App en producción: https://gasto-smart-six.vercel.app · GitHub: https://github.com/PEMOANG90/GastoSmart (privado) · Supabase URL: https://ekoojdgqizzdbcqkxgln.supabase.co
> Stack: HTML + CSS + JS vanilla (todo inline en index.html) + Supabase + Chart.js + Vercel. Deploy: doble clic en actualizar.bat → GitHub → Vercel.
> Estado: caché, deploy/encoding, cerrar sesión, presupuesto editable en la nube, tabla tarjetas, RLS en transactions/tarjetas/profiles, y sesión con PKCE (auto-refresh) ya están resueltos.
> Pendientes menores: favicon, recomendaciones IA reales, gráfica de líneas con datos reales.
> Adjunto mi index.html actual. Siguiente paso: [escribe aquí lo que quieres hacer].
