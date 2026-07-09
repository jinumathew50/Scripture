import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true,
    proxy: {
      '/api': {
        target: 'https://api.dbt.org',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
        configure: (proxy, _options) => {
          proxy.on('proxyReq', (proxyReq, req, res) => {
            // Add API Key to headers automatically for all proxied requests
            proxyReq.setHeader('X-API-Key', '39cf40d2-bdb9-4a47-9f7e-e2d0ba021c93');
            proxyReq.setHeader('Accept', 'application/json');
          });
        }
      }
    }
  },
  build: {
    outDir: 'dist'
  }
})
