import { defineConfig } from "vite";
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
   plugins: [
    tailwindcss(),
  ],
  build: {
    outDir: "assets",
    emptyOutDir: false,
    rollupOptions: {
      input: {
        app: "src/scripts/main.js",
        main: "src/styles/main.css"
      },
      output: {
        entryFileNames: (chunk) => (chunk.name === "app" ? "main.js" : "[name].js"),
        chunkFileNames: "[name].js",
        assetFileNames: "[name][extname]"
      }
    }
  },
  publicDir: false
});
