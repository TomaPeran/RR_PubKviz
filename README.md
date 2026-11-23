# Web App

Stack: React (Vite) · Java 21 + Spring Boot 3 · PostgreSQL 16

## Struktura
```
backend/    Spring Boot API (Maven, Flyway migracije)
frontend/   React SPA (Vite)
docker-compose.yml
```

## Pokretanje (sve u Dockeru)
```bash
# opcionalno: cp .env.example .env  (bez toga se koriste zadane vrijednosti)
docker compose up --build
```
- Frontend: http://localhost:3000
- API: http://localhost:8080/api/items
- Health: http://localhost:8080/actuator/health

### Podman
Slike u `docker-compose.yml` i `Dockerfile`-ovima koriste puna imena (`docker.io/library/...`), pa isto radi i s Dockerom i s Podmanom.
```bash
podman compose up --build      # ili: podman-compose up --build
```
Ako `depends_on: condition: service_healthy` ne radi u tvojoj verziji `podman-compose`, koristi `podman compose` (s docker-compose providerom) ili prvo pokreni `podman compose up -d db`.

## Lokalni razvoj
```bash
# 1) baza
docker compose up db

# 2) backend (Java 21, Maven)
cd backend && mvn spring-boot:run

# 3) frontend
cd frontend && npm install && npm run dev   # http://localhost:5173
```
Vite dev server proxya `/api` na `localhost:8080`.
