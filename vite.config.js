import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [
    RubyPlugin(),
    vue()
  ],
  build: {
    manifest: true,
    outDir: 'public/assets'
  },
  resolve: {
    alias: {
      'vue': 'vue/dist/vue.esm-bundler',
    },
  }
})