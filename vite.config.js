import { defineConfig } from "vite"
import RubyPlugin from "vite-plugin-ruby"
import FullReload from "vite-plugin-full-reload"
import StimulusHMR from "vite-plugin-stimulus-hmr"
import vue from "@vitejs/plugin-vue"

export default defineConfig({
  plugins: [
    RubyPlugin(),
    FullReload(["config/routes.rb", "app/views/**/*"], { delay: 200 }),
    vue(),
    StimulusHMR()
  ],
  resolve: {
    alias: {
      'vue': 'vue/dist/vue.esm-bundler',
    },
  }
})