import { defineConfig } from "vite";
import shopify from "vite-plugin-shopify";
import shopifyClean from "@driver-digital/vite-plugin-shopify-clean";
import tailwindcss from "@tailwindcss/vite";
import pageReload from "vite-plugin-page-reload";

export default defineConfig({
  plugins: [
    pageReload(["**/*.liquid", "**/*.css", "**/*.js"], { delay: 2000 }),
    shopifyClean(),
    shopify({
      snippetFile: "vite-tag.liquid",
      tunnel: true,
    }),
    tailwindcss(),
  ],
  build: {
    emptyOutDir: false,
  },
});
