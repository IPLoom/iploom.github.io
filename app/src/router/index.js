import { createRouter, createWebHashHistory } from 'vue-router'
import Landing from '../views/Landing.vue'
import DocViewer from '../views/DocViewer.vue'

const routes = [
  {
    path: '/',
    name: 'landing',
    component: Landing
  },
  {
    path: '/docs/:doc?',
    name: 'docs',
    component: DocViewer
  }
]

const router = createRouter({
  history: createWebHashHistory(), // Use hash history for easy deployment on GH Pages
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

export default router
