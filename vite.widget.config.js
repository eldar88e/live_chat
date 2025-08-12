import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
    publicDir: false,
    build: {
        outDir: 'public/widget',
        emptyOutDir: true,
        cssCodeSplit: false,
        rollupOptions: {
            input: 'app/frontend/entrypoints/live-chat.js',
            output: {
                manualChunks: undefined,
                inlineDynamicImports: true,
                entryFileNames: 'live-chat.js'
            }
        }
    }
});
