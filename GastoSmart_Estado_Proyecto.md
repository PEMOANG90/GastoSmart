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
| Supabase anon key | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrb29qZGdxaXp6ZGJjcWt4Z2xuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5MTAwMjksImV4cCI6MjA5NTQ4NjAyOX0.Ya1IqJuccG7D0nEfFeZ1ZXBSAWAyzIHhDYkfutZpkzI` |
| Carpeta local | `C:\Users\Pedro Molina\OneDrive\Desktop\GastoSmart\Scrpt\files` |

> La anon key va en el frontend a propósito (es pública por diseño). Lo que protege los datos son las políticas RLS en Supabase (ver pendientes).

---

## 2. Stack

HTML + CSS + JavaScript vanilla · Supabase (auth + base de datos) · Chart.js · Vercel (hosting). Todo el CSS y JS está **inline dentro de `index.html`** (un solo archivo).

---

## 3. Cómo desplegar

1. Editar los archivos en la carpeta local.
2. Doble clic en `actualizar.bat` → sube a GitHub → Vercel despliega automáticamente.
3. Esperar a `[3/3] Listo!` en la consola y ~60 segundos para que Vercel publique.

El `actualizar.bat`:
- Inyecta un timestamp único `YYYYMMDDHHMMSS` en `<meta name="app-version">`.
- Hace `git add -A` (sube todos los archivos, incluido `vercel.json`).
- Hace commit y `git push --force` a la rama `main`.

---

## 4. Lo que ya funciona

- Login email/contraseña y Google OAuth.
- Dashboard con métricas (ingresos, gastos, balance, tasa de ahorro).
- Registro de transacciones con 50+ categorías + categoría personalizada.
- Presupuesto por categorías.
- Módulo Tarjetas de Crédito (TC) con bancos mexicanos y digitales.
- Asistente IA con recomendaciones.
- Cerrar sesión (corregido en esta sesión — ver abajo).
- Auto-versionado de caché para usuarios finales (corregido en esta sesión).
- Script `actualizar.bat` que automatiza el deploy.

---

## 5. Cambios realizados en esta sesión (28 may 2026)

### 5.1 Bug de caché (versión vieja "pegada") — RESUELTO
**Síntoma:** tras cada deploy, los usuarios veían la versión anterior (layout roto: nav móvil arriba + hueco negro) hasta borrar datos de navegación.

**Causa raíz:** no había control de caché del lado del servidor, así que el navegador guardaba el `index.html` completo (y como todo el CSS/JS es inline, servía todo viejo).

**Fix:** se creó `vercel.json` que fuerza `Cache-Control: no-store` en el HTML, para que el navegador siempre descargue la versión fresca.

```json
{
  "headers": [
    { "source": "/", "headers": [{ "key": "Cache-Control", "value": "no-store, max-age=0" }] },
    { "source": "/index.html", "headers": [{ "key": "Cache-Control", "value": "no-store, max-age=0" }] }
  ]
}
```

### 5.2 Auto-versionado roto — RESUELTO
**Causa:** el JS usaba una constante fija `const BUILD='1779984183'` que nunca cambiaba, y el `actualizar.bat` tenía una regex `[0-9]{10}` que ya no coincidía con la versión de 14 dígitos.

**Fix (en `index.html`, bloque final):** ahora la versión se lee directo del meta tag (fuente única de verdad). Además, ya **no** cierra la sesión en cada update (antes hacía `localStorage.clear()`).

```js
(function(){
  var meta = document.querySelector('meta[name="app-version"]');
  var BUILD = meta ? meta.getAttribute('content') : '0';
  var stored = localStorage.getItem('gs_version');
  if (stored && stored !== BUILD) { /* nueva versión; se conserva la sesión */ }
  try { localStorage.setItem('gs_version', BUILD); } catch(e){}
  start();
})();
```

**Fix (en `actualizar.bat`):** regex flexible `[0-9]+` anclada al meta tag de versión.

### 5.3 Mojibake (acentos y emojis corruptos) — RESUELTO
**Síntoma:** "transacciÃ³n", "DÃ©ficit", "Hola Pedro ðŸ'‹".

**Causa:** el `actualizar.bat` leía el archivo con `Get-Content` sin especificar codificación; en PowerShell 5.1 leía el UTF-8 como ANSI y reescribía doble-codificado.

**Fix:** se agregó `-Encoding UTF8` tanto a la lectura como a la escritura en el `.bat`:
```
powershell -NoProfile -Command "(Get-Content '%~dp0index.html' -Raw -Encoding UTF8) -replace '...' | Set-Content '%~dp0index.html' -NoNewline -Encoding UTF8"
```

### 5.4 No se podía cerrar sesión — RESUELTO
**Síntoma:** clic en "Cerrar sesión" y no pasaba nada.

**Causa:** `await sb.auth.signOut()` usaba `scope:'global'` (hace llamada de red). Si esa petición se colgaba, el `await` nunca terminaba y las líneas de limpiar sesión + recargar nunca se ejecutaban.

**Fix (función `doSignOut` en `index.html`):** usar `scope:'local'` (cierre instantáneo, sin red) + redirección a URL limpia.

```js
async function doSignOut(){
  try{await sb.auth.signOut({scope:'local'})}catch(e){}
  try{localStorage.removeItem('gs_auth')}catch(e){}
  try{sessionStorage.removeItem('gs_auth')}catch(e){}
  try{store.clear()}catch(e){}
  try{localStorage.clear()}catch(e){}
  user=null;txs=[];tarjetas=[];
  window.location.replace(window.location.origin+window.location.pathname);
}
```

### Nota sobre comportamiento esperado
"Entrar directo sin login" ahora es **normal**: la sesión de Supabase persiste (como Gmail). Antes parecía que pedía login siempre porque se borraba la caché manualmente, lo que también borraba la sesión.

---

## 6. Archivos clave (en la carpeta local / repo)

- `index.html` — toda la app (HTML + CSS + JS inline). Secciones relevantes:
  - Init Supabase: ~línea 475 (`createClient`, `storageKey:'gs_auth'`, `flowType:'implicit'`).
  - `doSignOut()`: ~línea 537.
  - `onAuthStateChange` / `start()`: ~líneas 576–593.
  - Bloque de versionado (IIFE final): ~línea 1135.
- `vercel.json` — control de caché (no-store en HTML).
- `actualizar.bat` — script de deploy (inyecta versión UTF-8 + push a GitHub).

---

## 7. Pendientes / próximos pasos

- [ ] **Revisar políticas RLS (Row Level Security) en Supabase** — lo más importante para la seguridad. Confirmar que en las tablas `transactions`, `tarjetas` y `profiles` cada usuario solo pueda leer/escribir sus propios registros (filtro por `user_id = auth.uid()`). Esto es lo que de verdad protege los datos, no ocultar la anon key.
- [ ] Confirmar en producción que el deploy final (con fix de logout) quedó: versión nueva + textos correctos + cerrar sesión funcionando.
- [ ] (Opcional) Considerar quitar `no-store` global y dejar caché en assets futuros si se separan CSS/JS del HTML.

---

## 8. Prompt de continuación (pegar en una conversación nueva)

> Continuamos el proyecto GastoSmart — app de control de gastos personales.
> App en producción: https://gasto-smart-six.vercel.app · GitHub: https://github.com/PEMOANG90/GastoSmart (privado) · Supabase URL: https://ekoojdgqizzdbcqkxgln.supabase.co
> Stack: HTML + CSS + JS vanilla (todo inline en index.html) + Supabase + Chart.js + Vercel. Deploy: doble clic en actualizar.bat → sube a GitHub → Vercel despliega.
> Estado: caché (vercel.json no-store), versionado del .bat, encoding UTF-8 y cerrar sesión (scope:'local') ya están resueltos. Pendiente principal: revisar las políticas RLS en Supabase (tablas transactions, tarjetas, profiles).
> Adjunto mi index.html actual. Siguiente paso: [escribe aquí lo que quieres hacer].
