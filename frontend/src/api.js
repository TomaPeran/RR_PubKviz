const BASE = '/api'

async function request(path, options) {
  const res = await fetch(`${BASE}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  })
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return res.json()
}

export const getItems = () => request('/items')
export const createItem = (name) =>
  request('/items', { method: 'POST', body: JSON.stringify({ name }) })
