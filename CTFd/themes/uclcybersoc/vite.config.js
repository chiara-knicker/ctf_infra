import { defineConfig } from "vite";
import { resolve } from "path";

// https://vitejs.dev/config/
export default defineConfig({
  build: {
    manifest: false,  // Don't generate manifest.json
    outDir: "static/js", // Output directory for the final bundle
    emptyOutDir: false,  // Prevent Vite from deleting existing files in the static folder
    rollupOptions: {
      input: {
        challenges: resolve(__dirname, "assets/js/challenges.js"),
      },
      output: {
        format: "iife",  // Use IIFE format for the JS (can be changed as needed)
        entryFileNames: "[name].min.js", // Output file name pattern
      },
    },
  },
});
