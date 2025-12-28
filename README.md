<h1 align="center" style="position: relative;">
  <br>
    <img src="./assets/shoppy-x-ray.svg" alt="logo" width="200">
  <br>
  Supernova Blue Shopify Theme
</h1>

Tema Shopify modulare e leggero, costruito per sviluppo veloce con Vite e Tailwind CSS, mantenendo una struttura pulita e coerente con le best practice di Shopify.

<p align="center">
  <a href="./LICENSE.md"><img src="https://img.shields.io/badge/License-ISC-blue.svg" alt="License"></a>
</p>

## Prerequisiti

- Installa [Shopify CLI](https://shopify.dev/docs/api/shopify-cli) per preview, upload e check del tema
- Installa Node.js (versione LTS consigliata)

Se usi VS Code, installa:
- [Shopify Liquid VS Code Extension](https://shopify.dev/docs/storefronts/themes/tools/shopify-liquid-vscode)

## Installazione

Esegui questi passaggi una sola volta quando configuri il progetto in locale.

```bash
npm install
```

## Come lavorare sul tema (sviluppo, build, deploy)

Questa sezione spiega cosa fare, in quale ordine e perche.

### Sviluppo (quando vuoi vedere le modifiche in tempo reale)

**Quando usarlo:** usalo ogni volta che modifichi il tema e vuoi vedere subito il risultato nel browser.

**Cosa fa:** avvia un server locale (Vite) che genera gli asset al volo e apre un tunnel pubblico per Shopify. Poi avvia Shopify CLI in modalita sviluppo.

**Cosa eseguire:**

```bash
npm run dev
```

**Per vedere le modifiche in tempo reale:** apri il link di preview di Shopify generato da `shopify theme dev` (ti viene mostrato in console).

### Build (quando devi preparare gli asset finali)

**Quando usarlo:** usalo prima di un deploy o quando vuoi avere i file compilati stabili in `assets/`.

**Cosa fa:** compila i file sorgenti in `frontend/entrypoints/` e crea gli asset finali (JS/CSS) in `assets/`.

**Cosa eseguire:**

```bash
npm run vite:build
```

### Deploy (quando devi inviare il tema su Shopify)

**Quando usarlo:** usalo quando vuoi pubblicare o caricare il tema sul tuo store (o su uno store di sviluppo).

**Cosa fa:** esegue prima la build Vite e poi fa il push del tema con Shopify CLI.

**Cosa eseguire:**

```bash
npm run deploy
```

## Comandi principali

- `npm run dev` - usalo per sviluppo con tunnel + `shopify theme dev`
- `npm run shopify:dev` - usalo se vuoi avviare solo Shopify CLI (senza Vite)
- `npm run vite:dev` - usalo se vuoi avviare solo Vite
- `npm run deploy` - usalo per build Vite + push tema
- `npm run shopify:check` - usalo per lint/validazione tema
- `npm run format` - usalo per formattare con Prettier

## Cosa e installato (dipendenze)

### Tooling e build

- `vite` - server dev e build veloce installato per gestire asset e build
- `vite-plugin-shopify` - integrato per generare lo snippet `vite-tag.liquid`
- `@driver-digital/vite-plugin-shopify-clean` - aggiunto per evitare file obsoleti nel tema
- `vite-plugin-page-reload` - configurato per reload automatico su Liquid/CSS/JS
- `@tailwindcss/vite` + `tailwindcss` - installati per usare Tailwind dentro Vite

### Qualita e automazione

- `prettier` + `@shopify/prettier-plugin-liquid` - installati per formattazione coerente di Liquid e asset
- `npm-run-all` - installato per eseguire script in sequenza per `deploy`

## Configurazioni principali

### `vite.config.js`

- `tunnel: true` e stato impostato per sviluppare via URL pubblico
- `snippetFile: "vite-tag.liquid"` e stato impostato per l'iniezione degli asset Vite nel tema
- `pageReload(["**/*.liquid", "**/*.css", "**/*.js"], { delay: 2000 })` e stato impostato per un reload piu stabile su file Liquid
- `shopifyClean()` e stato aggiunto per rimuovere output non piu usato
- `build.emptyOutDir = false` e stato impostato per non cancellare asset gestiti dal tema

### Cartella `frontend/`

- `frontend/entrypoints/` contiene i file sorgente usati da Vite (JS/CSS). Questi file sono i punti di ingresso degli asset del tema.
- In build, Vite genera gli output compilati dentro `assets/` (JS/CSS). Shopify serve questi file come asset del tema.
- Durante lo sviluppo con tunnel, i file vengono serviti direttamente dal dev server Vite (non da `assets/`).

### `tailwind.config.js`

- `content: ["./**/*.{liquid,js,css}"]` e stato impostato per includere Liquid e asset nel purge

### `.prettierrc`

- Il plugin `@shopify/prettier-plugin-liquid` e stato configurato per mantenere Liquid pulito e consistente

### `snippets/vite-tag.liquid`

- Snippet generato automaticamente da `vite-plugin-shopify` (non editarlo a mano).
- In `layout/theme.liquid` e `layout/password.liquid` viene renderizzato per includere `critical.css`, `main.css` e `main.js`.
- In dev inserisce gli URL del tunnel Vite; in build punta ai file compilati in `assets/`.
- L'inclusione avviene nel `<head>` tramite `{% render 'vite-tag', entry: '...' %}` presente in quei layout.

Se in futuro devi aggiungere o ripristinare l'inclusione nello `<head>`, usa questo codice in `layout/theme.liquid` e `layout/password.liquid`:

```liquid
{%- render 'vite-tag', entry: 'critical.css', preload_stylesheet: true -%}
{%- render 'vite-tag', entry: 'main.css', preload_stylesheet: true -%}
{%- render 'vite-tag', entry: 'main.js' -%}
```

### `scripts/dev-with-tunnel.sh`

- Avvia Vite con tunnel e aspetta che l'URL Cloudflare sia pronto
- Avvia Shopify CLI solo dopo che `snippets/vite-tag.liquid` contiene il tunnel
- Forza la sincronizzazione del file snippet con `touch` per evitare race condition
- Supporta logging con `ENABLE_LOGS=1`

## Problemi affrontati e correzioni

### Shopify CLI avviata prima del tunnel Vite

**Problema:** `shopify theme dev` partiva prima che il tunnel di Vite fosse pronto, con snippet non aggiornato o asset non caricati.

**Correzione:** e stato creato `scripts/dev-with-tunnel.sh` che aspetta che `snippets/vite-tag.liquid` contenga `trycloudflare.com` e forza una sincronizzazione con `touch` prima di proseguire.

## Architettura tema

```bash
.
├── assets          # Asset statici (CSS, JS, immagini, font)
├── blocks          # Componenti riutilizzabili e annidabili
├── config          # Impostazioni globali del tema
├── layout          # Layout principali
├── locales         # Traduzioni
├── sections        # Sezioni modulari
├── snippets        # Snippet Liquid riutilizzabili
└── templates       # Template JSON
```

## License

Supernova Blue Theme e rilasciato sotto licenza [ISC](./LICENSE.md).
