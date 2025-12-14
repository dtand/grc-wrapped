import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const apiTarget = process.env.VITE_DEV_API_TARGET || 'http://localhost:8080';
  return {
    plugins: [react()],
    server: {
      port: 5173,
      proxy: {
        '/api/v1': {
          target: apiTarget,
          changeOrigin: true,
          // keep /api/v1 path when proxying to the Go server
        },
      },
    },
  };
});
