<script setup>
import { Shield, Activity, Zap, Lock, Globe, Server, ArrowRight } from 'lucide-vue-next'

const features = [
  {
    icon: Activity,
    title: 'Real-time Monitoring',
    description: 'Sub-second precision tracking of every device on your network with historical uptime trends.'
  },
  {
    icon: Zap,
    title: 'Dual-Mode Discovery',
    description: 'Combines Scapy ARP and ICMP Ping sweeps for 100% device parity across all environments.'
  },
  {
    icon: Lock,
    title: 'Security Auditing',
    description: 'Automated port scanning and service identification to keep your smart home secure.'
  },
  {
    icon: Globe,
    title: 'Smart Home Ready',
    description: 'Seamless MQTT and Home Assistant integration with automatic entity discovery.'
  },
  {
    icon: Server,
    title: 'Analytical Core',
    description: 'Powered by DuckDB for high-performance processing of network traffic and events.'
  },
  {
    icon: Shield,
    title: 'Privacy First',
    description: 'All your network data stays local. No cloud dependencies, no tracking.'
  }
]
</script>

<template>
  <div class="relative overflow-hidden">
    <!-- Background Accents -->
    <div class="absolute top-0 left-1/2 -translate-x-1/2 w-full h-[600px] bg-gradient-to-b from-primary-600/20 to-transparent blur-3xl -z-10 opacity-50"></div>
    
    <!-- Hero Section -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-24 pb-32 text-center">
      <div class="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-primary-500/10 border border-primary-500/20 text-primary-400 text-sm font-medium mb-8 animate-fade-in">
        <span class="relative flex h-2 w-2">
          <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary-400 opacity-75"></span>
          <span class="relative inline-flex rounded-full h-2 w-2 bg-primary-500"></span>
        </span>
        <span>Version 1.0.0 Now Available</span>
      </div>
      
      <h1 class="text-5xl md:text-7xl font-extrabold tracking-tight mb-8">
        Take Control of Your <br/>
        <span class="gradient-text">Home Network</span>
      </h1>
      
      <p class="text-xl text-slate-400 max-w-3xl mx-auto mb-12 leading-relaxed">
        HNMS is a professional-grade, web-based network monitoring and security suite. 
        Gain total visibility over your local devices with real-time analytics and intelligent discovery.
      </p>
      
      <div class="flex flex-col sm:flex-row items-center justify-center gap-4">
        <router-link to="/docs/setup_guide" class="w-full sm:w-auto bg-primary-600 hover:bg-primary-500 text-white px-8 py-4 rounded-xl text-lg font-bold transition-all flex items-center justify-center shadow-xl shadow-primary-900/40">
          Get Started <ArrowRight class="ml-2 w-5 h-5" />
        </router-link>
        <a href="https://github.com/IPLoom/iploom.github.io" target="_blank" class="w-full sm:w-auto glass hover:bg-white/10 text-white px-8 py-4 rounded-xl text-lg font-bold transition-all flex items-center justify-center">
          View on GitHub
        </a>
      </div>
    </section>

    <!-- Features Grid -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-32">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <div v-for="feature in features" :key="feature.title" class="glass-card p-8 group">
          <div class="w-12 h-12 rounded-xl bg-primary-500/10 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
            <component :is="feature.icon" class="w-6 h-6 text-primary-500" />
          </div>
          <h3 class="text-xl font-bold text-white mb-4">{{ feature.title }}</h3>
          <p class="text-slate-400 leading-relaxed">{{ feature.description }}</p>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pb-32">
      <div class="glass-card p-12 text-center bg-gradient-to-br from-primary-600/10 to-indigo-600/10">
        <h2 class="text-3xl md:text-4xl font-bold text-white mb-6">Ready to secure your network?</h2>
        <p class="text-lg text-slate-400 mb-10 max-w-2xl mx-auto">
          Deploy HNMS today and get a bird's-eye view of your connected home. 
          Works on Raspberry Pi, NAS, and standard Linux servers.
        </p>
        <router-link to="/docs/setup_guide" class="inline-flex items-center bg-white text-slate-950 px-8 py-4 rounded-xl text-lg font-bold hover:bg-slate-200 transition-all">
          Explore the Setup Guide
        </router-link>
      </div>
    </section>
  </div>
</template>

<style scoped>
@keyframes fade-in {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}
.animate-fade-in {
  animation: fade-in 0.8s ease-out forwards;
}
</style>
