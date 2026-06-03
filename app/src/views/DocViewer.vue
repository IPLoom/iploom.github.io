<script setup>
import { ref, watch, onMounted, computed, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { marked } from 'marked'
import { createHighlighter } from 'shiki'
import mermaid from 'mermaid'
import { ChevronRight, List, ExternalLink, ChevronLeft } from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const content = ref('')
const loading = ref(true)
const error = ref(null)

const menuItems = [
  { id: 'setup_guide', title: 'Installation & Setup' },
  { id: 'architecture', title: 'Architecture Overview' },
  { id: 'scanning_engine', title: 'Scanning Engine' },
  { id: 'classification_rules', title: 'Device Classification' },
  { id: 'mqtt_integration', title: 'MQTT & Home Assistant' },
  { id: 'home_assistant_integration', title: 'Home Assistant Integration' },
  { id: 'openwrt_integration', title: 'OpenWrt Integration' },
  { id: 'internet_access_scheduling', title: 'Internet Access Scheduling' },
  { id: 'internet_data_quotas', title: 'Internet Data Quotas' },
  { id: 'adguard_integration', title: 'AdGuard Home Integration' },
  { id: 'database_schema', title: 'Database Schema' },
  { id: 'api_reference', title: 'API Reference' }
]

const currentDoc = computed(() => route.params.doc || 'setup_guide')

// Configure Shiki
let highlighter = null
const initShiki = async () => {
  if (highlighter) return
  highlighter = await createHighlighter({
    themes: ['github-dark'],
    langs: ['bash', 'yaml', 'json', 'python', 'javascript', 'sql']
  })
}

// Configure Mermaid
mermaid.initialize({
  startOnLoad: false,
  theme: 'dark',
  securityLevel: 'loose',
  fontFamily: 'Inter, system-ui, sans-serif',
  themeVariables: {
    noteBkgColor: '#1e293b',
    noteBorderColor: '#334155',
    noteTextColor: '#f8fafc',
    actorBkg: '#0f172a',
    actorBorder: '#334155',
    actorTextColor: '#f8fafc',
    signalColor: '#f8fafc',
    signalLineColor: '#64748b',
    labelBoxBkgColor: '#1e293b',
    labelBoxBorderColor: '#334155',
    labelTextColor: '#f8fafc',
    loopBkgColor: '#1e293b',
    background: '#0f172a'
  }
})

const unescapeHtml = (str) => {
  if (!str) return ''
  const txt = document.createElement('textarea')
  txt.innerHTML = str
  return txt.value
}

const renderMarkdown = async (md) => {
  await initShiki()
  
  const renderer = new marked.Renderer()
  renderer.code = (token) => {
    const { text, lang } = token
    if (lang === 'mermaid') {
      const cleanText = unescapeHtml(text)
      return `<pre class="mermaid">${cleanText}</pre>`
    }
    try {
      return highlighter.codeToHtml(text, { lang, theme: 'github-dark' })
    } catch {
      return `<pre><code>${text}</code></pre>`
    }
  }
  
  marked.setOptions({ renderer })
  return marked.parse(md)
}

const fetchDoc = async (docId) => {
  loading.value = true
  error.value = null
  try {
    // In production, we assume these are at /docs/*.md
    // Since this is a static site, we fetch the relative .md file
    const response = await fetch(`./docs/${docId}.md`)
    if (!response.ok) throw new Error('Document not found')
    const rawMd = await response.text()
    
    // Fix relative links in MD
    const fixedMd = rawMd.replace(/\.\/docs\/(.*)\.md/g, '#/docs/$1')
    
    content.value = await renderMarkdown(fixedMd)
    loading.value = false
    
    // Render Mermaid diagrams after content is injected
    await nextTick()
    try {
      const mermaidNodes = document.querySelectorAll('.mermaid')
      if (mermaidNodes.length > 0) {
        await mermaid.run({
          querySelector: '.mermaid',
          suppressErrors: true
        })
      }
    } catch (e) {
      console.warn("Mermaid render failed:", e)
    }
  } catch (err) {
    error.value = err.message
    loading.value = false
  }
}

watch(() => route.params.doc, (newDoc) => {
  if (route.name === 'docs') {
    fetchDoc(newDoc || 'setup_guide')
  }
}, { immediate: true })

onMounted(async () => {
  await initShiki()
  if (route.name === 'docs') {
    fetchDoc(currentDoc.value)
  }
})
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <div class="flex flex-col lg:flex-row gap-12">
      <!-- Sidebar -->
      <aside class="w-full lg:w-64 flex-shrink-0">
        <div class="sticky top-24">
          <h2 class="text-sm font-bold text-slate-500 uppercase tracking-widest mb-6 px-4">Documentation</h2>
          <nav class="space-y-1">
            <router-link 
              v-for="item in menuItems" 
              :key="item.id"
              :to="'/docs/' + item.id"
              class="flex items-center justify-between px-4 py-2 rounded-lg transition-all group"
              :class="currentDoc === item.id ? 'bg-primary-500/10 text-primary-400 font-semibold' : 'text-slate-400 hover:bg-white/5 hover:text-white'"
            >
              <span>{{ item.title }}</span>
              <ChevronRight class="w-4 h-4 opacity-0 group-hover:opacity-100 transition-opacity" />
            </router-link>
          </nav>
        </div>
      </aside>

      <!-- Main Content -->
      <article class="flex-grow min-w-0">
        <div v-if="loading" class="space-y-4 animate-pulse">
          <div class="h-10 bg-white/5 rounded-lg w-1/3"></div>
          <div class="h-4 bg-white/5 rounded-lg w-full"></div>
          <div class="h-4 bg-white/5 rounded-lg w-full"></div>
          <div class="h-4 bg-white/5 rounded-lg w-2/3"></div>
          <div class="h-64 bg-white/5 rounded-xl w-full"></div>
        </div>
        
        <div v-else-if="error" class="glass-card p-12 text-center">
          <div class="text-red-400 font-bold text-xl mb-4">Error</div>
          <p class="text-slate-400">{{ error }}</p>
          <router-link to="/docs" class="mt-6 inline-block text-primary-400 hover:underline">Back to Setup Guide</router-link>
        </div>
        
        <div v-else class="glass-card p-8 md:p-12">
          <div class="markdown-body" v-html="content"></div>
          
          <!-- Navigation Buttons -->
          <div class="mt-12 pt-8 border-t border-white/10 flex justify-between">
            <button v-if="menuItems.findIndex(m => m.id === currentDoc) > 0" 
              @click="router.push('/docs/' + menuItems[menuItems.findIndex(m => m.id === currentDoc) - 1].id)"
              class="flex items-center text-slate-400 hover:text-white"
            >
              <ChevronLeft class="w-5 h-5 mr-2" /> Previous
            </button>
            <div v-else></div>
            
            <button v-if="menuItems.findIndex(m => m.id === currentDoc) < menuItems.length - 1" 
              @click="router.push('/docs/' + menuItems[menuItems.findIndex(m => m.id === currentDoc) + 1].id)"
              class="flex items-center text-slate-400 hover:text-white"
            >
              Next <ChevronRight class="w-5 h-5 ml-2" />
            </button>
          </div>
        </div>
      </article>
    </div>
  </div>
</template>

<style>
/* Mermaid Diagram Basic Styling */
.mermaid {
  @apply bg-slate-900 p-4 rounded-xl mb-6;
}
</style>
