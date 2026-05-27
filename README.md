# 💰 GastoSmart — Sistema de Control de Gastos Personales

> Aplicación web de finanzas personales con modo Free y Premium, diseñada para web y móvil.

![Version](https://img.shields.io/badge/versión-1.0.0--beta-green)
![License](https://img.shields.io/badge/licencia-MIT-blue)
![Status](https://img.shields.io/badge/estado-Activo-brightgreen)

---

## 🚀 Demo rápida

Abre `index.html` en tu navegador — ¡funciona sin instalación!

---

## ✨ Funciones incluidas (Plan Free)

| Función | Descripción |
|---|---|
| 📊 Dashboard | Resumen mensual con métricas clave |
| 💳 Transacciones | Registro de gastos e ingresos con búsqueda y filtros |
| 🏷️ Categorías | 10 categorías (Alimentación, Renta, Transporte...) |
| 🎯 Presupuesto | Límites mensuales por categoría con alertas visuales |
| 📈 Reportes | Gráficas de pastel, barras y tendencia histórica |
| 🤖 Recomendaciones IA | Consejos automáticos basados en tus patrones |
| 👥 Cuenta Compartida | Hasta 1 usuario adicional (pareja/familiar) |
| 🌙 Modo Oscuro | Interfaz clara y oscura |
| 📱 Responsivo | Funciona en celular y escritorio |

---

## ⭐ Funciones Premium (monetización)

| Función | Precio sugerido |
|---|---|
| IA avanzada + chat financiero | $99 MXN/mes |
| Exportar PDF y Excel | Incluido en Premium |
| Hasta 6 usuarios compartidos | Incluido en Premium |
| Alertas por WhatsApp/Email | Incluido en Premium |
| Metas de ahorro con IA | Incluido en Premium |
| Predicciones del siguiente mes | Incluido en Premium |
| Análisis de inversiones | Incluido en Premium |

---

## 🗂️ Estructura del proyecto

```
GastoSmart/
├── index.html          ← App completa (todo en un archivo)
├── README.md           ← Este archivo
└── (próximamente)
    ├── backend/        ← Node.js / Supabase
    ├── api/            ← Endpoints REST
    └── mobile/         ← React Native (versión app)
```

---

## 🌐 Cómo publicar en GitHub Pages (gratis, sin código)

### Paso 1 — Crear cuenta en GitHub
1. Ve a [github.com](https://github.com) y crea una cuenta gratuita
2. Haz clic en **"New repository"** (botón verde)
3. Nombre: `gastosmart` — marca **"Public"** — clic en **"Create repository"**

### Paso 2 — Subir el archivo
1. Dentro del repositorio, haz clic en **"uploading an existing file"**
2. Arrastra el archivo `index.html` y el `README.md`
3. Clic en **"Commit changes"** (botón verde)

### Paso 3 — Activar GitHub Pages
1. Ve a **Settings** (pestaña superior del repositorio)
2. Menú izquierdo: **Pages**
3. Source: **"Deploy from a branch"**
4. Branch: **main** → carpeta **/ (root)**
5. Clic en **Save**

### ✅ ¡Listo!
En 2-3 minutos tu app estará en:
```
https://TU-USUARIO.github.io/gastosmart
```

---

## 📱 Para hacerla instalable en celular (PWA)

Agrega estas líneas dentro del `<head>` del `index.html`:

```html
<link rel="manifest" href="manifest.json">
<meta name="theme-color" content="#22c77a">
```

Crea un archivo `manifest.json`:
```json
{
  "name": "GastoSmart",
  "short_name": "GastoSmart",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#f0f2f5",
  "theme_color": "#22c77a",
  "icons": [
    { "src": "icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

---

## 💰 Hoja de ruta para monetizar

### Fase 1 — Beta (ahora) ✅
- [x] App web funcional
- [x] Almacenamiento local (sin servidor)
- [x] Modo Free con todas las funciones básicas
- [ ] Publicar en GitHub Pages

### Fase 2 — Crecimiento (1-3 meses)
- [ ] Agregar base de datos con [Supabase](https://supabase.com) (gratis)
- [ ] Login con Google (Firebase Auth — gratis)
- [ ] Sincronización entre dispositivos
- [ ] Notificaciones push

### Fase 3 — Monetización (3-6 meses)
- [ ] Integrar pagos con [Stripe](https://stripe.com) o [Conekta](https://conekta.com) (México)
- [ ] Activar Plan Premium $99 MXN/mes
- [ ] Integrar API de IA (Claude/OpenAI) para chat financiero
- [ ] Sistema de referidos (gana 1 mes gratis por cada amigo)

### Fase 4 — Escala (6-12 meses)
- [ ] App nativa iOS/Android con React Native
- [ ] Plan Empresas ($499 MXN/mes por equipo)
- [ ] Marketplace de plantillas de presupuesto
- [ ] Afiliados y comisiones

---

## 🛠️ Tecnologías usadas

- **HTML5 + CSS3 + JavaScript** — sin frameworks, máxima compatibilidad
- **Chart.js** — gráficas interactivas
- **LocalStorage** — datos persistentes en el navegador
- **Google Fonts (Sora)** — tipografía moderna

---

## 📊 Proyección de ingresos (estimado conservador)

| Usuarios | Conversión Free→Premium | Ingreso mensual |
|---|---|---|
| 500 | 5% (25 usuarios) | $2,475 MXN |
| 2,000 | 5% (100 usuarios) | $9,900 MXN |
| 10,000 | 5% (500 usuarios) | $49,500 MXN |
| 50,000 | 5% (2,500 usuarios) | $247,500 MXN |

---

## 📄 Licencia

MIT — puedes usar, modificar y vender libremente.

---

## 🙋 Soporte

¿Tienes dudas? Abre un **Issue** en GitHub o escríbeme.

---

*Diseñado para tomar el control de tus finanzas*
