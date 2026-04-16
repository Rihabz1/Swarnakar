import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { prettyJSON } from 'hono/pretty-json'
import { authRoutes } from './routes/auth.ts'
import { profileRoutes } from './routes/profile.ts'

const app = new Hono()

// Middleware
app.use('*', logger())
app.use('*', prettyJSON())
app.use('*', cors({
  origin: (origin) => {
    if (!origin) return 'http://localhost:3000'
    if (origin.includes('localhost') || origin.includes('127.0.0.1')) return origin
    return origin
  },
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
  exposeHeaders: ['Content-Length'],
  maxAge: 600,
  credentials: true,
}))

// Routes
app.route('/api/auth', authRoutes)
app.route('/auth', authRoutes)
app.route('/api/profile', profileRoutes)

// Health check
app.get('/health', (c) => c.json({ status: 'ok', timestamp: new Date().toISOString() }))

// Error handling
app.onError((err, c) => {
  console.error('Error:', err)
  return c.json({ success: false, error: err.message }, 500)
})

// 404 handler
app.notFound((c) => c.json({ success: false, error: 'Route not found' }, 404))

const port = Number(process.env.PORT ?? 8787)

if (typeof Bun !== 'undefined') {
  Bun.serve({
    fetch: app.fetch,
    port,
  })

  console.log(`Swarnakar backend running at http://localhost:${port}`)
}

export default app