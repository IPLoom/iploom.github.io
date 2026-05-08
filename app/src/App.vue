<script setup>
import { Shield, Github, Book, Home } from 'lucide-vue-next'
</script>

<template>
  <div class="min-h-screen flex flex-col">
    <!-- Navigation -->
    <nav class="fixed top-0 left-0 right-0 z-50 glass border-b border-white/10">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <router-link to="/" class="flex items-center space-x-2 group">
            <Shield class="w-8 h-8 text-primary-500 group-hover:scale-110 transition-transform" />
            <span class="font-bold text-xl tracking-tight">HNMS</span>
          </router-link>
          
          <div class="hidden md:flex items-center space-x-8">
            <router-link to="/" class="text-sm font-medium text-slate-300 hover:text-white transition-colors flex items-center">
              <Home class="w-4 h-4 mr-1" /> Home
            </router-link>
            <router-link to="/docs" class="text-sm font-medium text-slate-300 hover:text-white transition-colors flex items-center">
              <Book class="w-4 h-4 mr-1" /> Documentation
            </router-link>
            <a href="https://github.com/IPLoom/iploom.github.io" target="_blank" class="text-sm font-medium text-slate-300 hover:text-white transition-colors flex items-center">
              <Github class="w-4 h-4 mr-1" /> GitHub
            </a>
          </div>
          
          <div class="flex items-center space-x-4">
             <router-link to="/docs/setup_guide" class="bg-primary-600 hover:bg-primary-500 text-white px-4 py-2 rounded-lg text-sm font-semibold transition-all shadow-lg shadow-primary-900/20">
              Get Started
            </router-link>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="flex-grow pt-16">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>

    <!-- Footer -->
    <footer class="bg-slate-950 border-t border-white/5 py-12">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <div class="flex items-center justify-center space-x-2 mb-4">
          <Shield class="w-6 h-6 text-primary-500" />
          <span class="font-bold text-lg">HNMS</span>
        </div>
        <p class="text-slate-500 text-sm mb-6">Built with ❤️ for the Home Automation Community</p>
        <div class="flex justify-center space-x-6">
          <a href="#" class="text-slate-400 hover:text-white"><Github class="w-5 h-5" /></a>
        </div>
      </div>
    </footer>
  </div>
</template>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
