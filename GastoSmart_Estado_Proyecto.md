# GastoSmart — Estado del Proyecto

_Última actualización: 29 de mayo de 2026_

App de control de gastos personales. Documento de continuidad para retomar el proyecto en cualquier momento (incluso desde una PC nueva o una conversación nueva).

---

## 1. Accesos y enlaces

| Recurso | Valor |
|---|---|
| App en producción | https://gasto-smart-six.vercel.app |
| Repo GitHub (privado) | https://github.com/PEMOANG90/GastoSmart |
| Supabase URL | https://ekoojdgqizzdbcqkxgln.supabase.co |
| Carpeta local | `C:\Users\Pedro Molina\OneDrive\Desktop\GastoSmart\Scrpt\files` |

> La anon key va en el frontend a propósito (es pública por diseño). Lo que protege los datos son las políticas RLS (configuradas en transactions, tarjetas y profiles).

---

## 2. Stack

HTML + CSS + JavaScript vanilla (todo inline en `index.html`) · Supabase (auth + base de datos) · Chart.js · Vercel. Archivos: `index.html`, `vercel.json` (caché), `actualizar.bat` (deploy).

---

## 3. Cómo desplegar

1. Editar archivos en la carpeta local.
2. Doble clic en `actualizar.bat` → inyecta versión (UTF-8), `git add -A`, push a GitHub → Vercel despliega.
3. Esperar a `[3/3] Listo!` + ~60 s. Recargar con Ctrl+Shift+R.

---

## 4. Lo que funciona

- Login email/contraseña y Google OAuth (flujo PKCE, sesión se renueva sola).
- Cerrar sesión determinista (scope local, no se cuelga).
- Cierre automático por inactividad (30 min) con aviso al volver.
- Validación de sesión al cargar (si el token no sirve, manda a login en vez de mostrar $0).
- Dashboard: métricas, gráfica de categorías, presupuesto (conectado a límites reales), últimas transacciones, recomendaciones (reglas).
- Transacciones: alta con 50+ categorías + categoría personalizada.
- Presupuesto editable por categoría, guardado en la nube (columna `budgets` en `profiles`).
- Tarjetas TC: bloqueada como función Premium (pantalla 🔒, badge "PRO"). Código real intacto detrás de la bandera `isPremium`.
- Restablecer datos a 0 (Ajustes → Zona de peligro): borra transacciones + tarjetas + presupuestos.
- Caché: 3 capas para que el usuario nunca vea versión vieja (ver sección 6).
- Favicon (ícono de barras moradas).

---

## 5. Base de datos (Supabase) — RLS aplicado

- **transactions** — RLS activado, política `transactions_own` (`auth.uid() = user_id`). Columna `note`.
- **tarjetas** — RLS activado, política `tarjetas_own` (`auth.uid() = user_id`).
- **profiles** — RLS activado, política `profiles_own` (`auth.uid() = id`). Columna `budgets jsonb`.

SQL ya aplicado: ver historial; políticas `for all using (auth.uid()=user_id/id) with check (...)`.

**Auditoría de seguridad RLS (29 may 2026) — APROBADA:**
- RLS activado (`true`) en las 3 tablas.
- Una sola política limpia por tabla (`profiles_own`, `tarjetas_own`, `transactions_own`), todas `ALL`, con lectura Y escritura correctas (sin NULL).
- Se eliminaron 2 políticas duplicadas viejas ("Users see own profile", "Users see own transactions") que tenían `with_check` en NULL.
- Verificado: cada usuario solo accede a sus propios datos. Modelo anon key pública + RLS estricto = correcto.

**Otros chequeos de seguridad (29 may 2026):**
- Confirmación de correo (Authentication → Sign In/Providers → Email → "Confirm email"): **ON** ✅. Nadie puede registrarse con un correo ajeno. Anonymous sign-ins OFF, manual linking OFF.
- Validación de datos reforzada en `saveTx` y `saveTc`: monto > 0 y con tope, longitudes máximas de texto, fecha válida, dígitos de tarjeta numéricos (máx 4), día corte/pago 1–31, tasa 0–200%.
- Pendiente: respaldo de datos (plan FREE, sin respaldos automáticos completos). Hacer respaldo manual o subir a Pro al monetizar. Revisar Attack Protection y Rate Limits (defaults de Supabase).

---

## 6. Cambios hechos (mayo 2026)

1. Caché ("versión pegada") → `vercel.json`.
2. Auto-versionado por meta tag + `actualizar.bat` con regex flexible y `git add -A`.
3. Encoding UTF-8 en `actualizar.bat` (acentos/emojis).
4. Cerrar sesión → `signOut({scope:'local'})` + marca `gs_logout` + recarga forzada a URL limpia.
5. Presupuesto editable + guardado en la nube; dashboard usa `userBudgets`.
6. Tabla `tarjetas` creada con RLS.
7. RLS en transactions, tarjetas y profiles.
8. Sesión que caducaba → `flowType:'pkce'` (auto-refresh del token).
9. **Caché a prueba de usuarios no técnicos (3 capas):**
   - `vercel.json` `source:"/(.*)"` con `Cache-Control: no-store, no-cache, must-revalidate, max-age=0`.
   - Auto-actualización: la app consulta la versión del servidor (`fetch` no-store) al cargar, al volver a la app (`visibilitychange`) y cada 5 min; si hay versión nueva, recarga sola. Guard `gs_vcheck` evita bucles.
   - El usuario final no borra nada.
10. Validación de sesión al cargar con `getUser()` (evita estado "logueado pero muerto").
11. Favicon (SVG inline).
12. Restablecer datos a 0 (`resetAllData` en Ajustes).
13. Tarjetas TC como Premium (`renderPremiumLock` + bandera `isPremium`).
14. Cierre por inactividad (`IDLE_MINUTES=30`, listeners de actividad, aviso al volver) y redirect de Google a URL limpia.
15. **Logout colgado SOLO con Google (causa raíz)** → `doSignOut` ya NO espera (`await`) la revocación de red de Supabase. Esa llamada se cuelga con sesiones OAuth de Google (con correo era rápida, por eso solo fallaba Google). Ahora dispara `signOut({scope:'local'})` sin esperar, borra el token local y recarga de inmediato. El logout ya no depende de la red.

---

## 7. Lección importante: migrar testers atascados

**Causa:** usuarios que abrieron la app ANTES de los arreglos de caché tienen una versión vieja guardada en su navegador móvil. Esa versión no tiene la auto-actualización, así que no se arregla sola.

**Punto clave (lo que pasó):** al mandar el link `?v=2` por WhatsApp, lo abrían en el **navegador interno de WhatsApp**, que es distinto del Chrome/Safari donde usan la app. Por eso "no funcionaba": arreglaban un navegador que no usaban.

**Procedimiento para migrarlos (una sola vez):**
1. Abrir su navegador real (Chrome/Safari), NO desde WhatsApp.
2. Entrar a `gasto-smart-six.vercel.app` y recargar 2-3 veces.
3. Si sigue viejo, borrar datos del sitio: Android (Chrome) → candado junto a la URL → Información del sitio → Borrar. iPhone (Safari) → Ajustes → Safari → Borrar historial y datos.

**A futuro:** compartir el link normal; los usuarios nuevos reciben la versión con auto-actualización desde el inicio y nunca se atascan. No se puede automatizar el rescate de un cliente ya atascado desde el servidor (su código viejo no tiene la lógica nueva).

> Verificado: NO hay Service Worker registrado ni Cache Storage (descartado como causa).

---

## 8. Pendientes / próximos pasos

- [x] Verificación B: RLS aislando datos entre usuarios — CONFIRMADO en la práctica (cada cuenta ve solo lo suyo).
- [x] Recomendaciones IA mejoradas (basadas en datos reales: tasa de ahorro, mayor gasto, presupuestos excedidos, comparación mes anterior, pagos de tarjeta próximos). Siguen siendo reglas, no IA generativa.
- [x] Gráfica de Reportes (tendencia 6 meses) con datos reales vía `last6Months()`.
- [x] Tarjetas TC reactivado para pruebas: `isPremium=true`. Para monetizar, cambiar a `false` (vuelve el bloqueo Premium).
- [ ] (Futuro) IA generativa real (chat financiero) como función premium — requiere conectar un servicio de IA.
- [ ] (Opcional) Service Worker si se va por el camino de PWA instalable.
- [ ] **Completar textos legales** (campos `[ ]` en el modal legal): `[NOMBRE/RAZÓN SOCIAL DEL RESPONSABLE]`, `[CORREO DE CONTACTO]`, `[FECHA]`. Y que un ABOGADO revise/valide el texto antes de abrir al público.
- [ ] Respaldo de datos (plan FREE): respaldo manual o subir a Pro al monetizar.

## Estructura legal en la app (29 may 2026)
- Modal `legalModal` con Aviso de Privacidad + Términos de Uso (texto base/borrador con placeholders, marcado con nota de "revisar con abogado").
- Casilla obligatoria de aceptación (`authConsent`) en el registro por correo: sin marcarla no se crea la cuenta.
- Nota de aceptación junto al botón de Google (OAuth no pasa por la casilla).
- Enlace a los documentos en Ajustes → "📄 Legal".
- Validación de datos reforzada en saveTx/saveTc (ya descrita arriba).

---

## 9. Diagnóstico rápido (si algo falla)

- **Datos en $0 / no guarda / logout colgado** → sesión inválida. Cerrar sesión y entrar de nuevo. Con PKCE + validación getUser debería ser raro.
- **Versión vieja tras deploy** → confirmar `vercel.json` en el repo; en móvil, abrir en navegador real (no WhatsApp) y recargar; último recurso: borrar datos del sitio.
- **Acentos/emojis rotos** → `actualizar.bat` debe leer y escribir con `-Encoding UTF8`.
- **Error al guardar (rojo en consola)** → pestaña Network → request a la tabla → Status (401/403 = sesión/RLS; 400/PGRST204 = columna faltante).

---

## 10. Prompt de continuación (pegar en una conversación nueva)

> Continuamos el proyecto GastoSmart — app de control de gastos personales.
> App: https://gasto-smart-six.vercel.app · GitHub: https://github.com/PEMOANG90/GastoSmart (privado) · Supabase: https://ekoojdgqizzdbcqkxgln.supabase.co
> Stack: HTML + CSS + JS vanilla (todo inline en index.html) + Supabase + Chart.js + Vercel. Deploy: actualizar.bat → GitHub → Vercel.
> Resuelto: caché (3 capas), deploy/encoding, cerrar sesión, presupuesto editable en la nube, tabla tarjetas, RLS en las 3 tablas, sesión PKCE con validación, cierre por inactividad (30 min), TC como Premium, restablecer datos a 0, favicon.
> Pendientes: verificar RLS con 2 cuentas, recomendaciones IA reales, gráfica de reportes con datos reales.
> Adjunto mi index.html actual. Siguiente paso: [escribe lo que quieras hacer].
