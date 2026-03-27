import tailwindcss from "@tailwindcss/vite";
import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";
import path from "node:path";

export default defineConfig({
    plugins: [tailwindcss(), sveltekit()],
    optimizeDeps: {
        exclude: ["@wenyan-md/ui"],
    },
    resolve: {
        alias: {
            "@wenyan-md/ui": path.resolve(__dirname, "./wenyan-ui/src/lib/index.ts"),
        },
    },
    server: {
        fs: {
            allow: ["./wenyan-ui"],
        },
    },
});
