import { useEffect, useState } from 'react'
import { getItems, createItem } from './api.js'

export default function App() {
  const [items, setItems] = useState([])
  const [name, setName] = useState('')
  const [error, setError] = useState(null)

  useEffect(() => {
    getItems().then(setItems).catch((e) => setError(e.message))
  }, [])

  async function handleSubmit(e) {
    e.preventDefault()
    if (!name.trim()) return
    try {
      const created = await createItem(name)
      setItems((prev) => [...prev, created])
      setName('')
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <main>
      <h1>Items</h1>
      <form onSubmit={handleSubmit}>
        <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Naziv" />
        <button type="submit">Dodaj</button>
      </form>
      {error && <p style={{ color: 'crimson' }}>Greška: {error}</p>}
      <ul>
        {items.map((i) => (
          <li key={i.id}>{i.name}</li>
        ))}
      </ul>
    </main>
  )
}
