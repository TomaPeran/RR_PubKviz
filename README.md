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

## Baza podataka
Shema je opisana u [docs/ER_dijagram.md](docs/ER_dijagram.md). Tablice se ne kreiraju ručno: pri pokretanju backenda **Flyway** sam izvrši sve migracije iz `backend/src/main/resources/db/migration/` redom:

| Migracija | Što radi |
|---|---|
| `V1__create_item.sql` | primjer tablice iz kostura projekta |
| `V2__create_schema.sql` | sve tablice prema ER dijagramu + uloge (Administrator, Organizer, Participant) |
| `V3__test_data.sql` | testni korisnici (vidi ispod) |

Postojeće migracije se **ne mijenjaju** nakon što su spojene u `master` – svaka promjena sheme ide u novu datoteku (`V4__...sql`, `V5__...sql`…), inače Flyway javlja grešku zbog promijenjenog checksuma.

### Testni korisnici
Svi imaju lozinku **`PubKviz123!`**

| Uloga | Korisničko ime | E-mail |
|---|---|---|
| Administrator | `admin` | admin@example.com |
| Organizator | `organizer` | org@example.com |
| Sudionik | `player1` | player1@example.com |
| Sudionik | `player2` | player2@example.com |
| Sudionik | `player3` | player3@example.com |

### Pristup bazi
Podaci za spajanje (npr. iz DBeavera, pgAdmina ili IntelliJ-a): host `localhost`, port `5432`, baza `appdb`, korisnik `app`, lozinka `change_me`.
```bash
docker compose exec db psql -U app -d appdb -c "\dt"     # popis tablica
```

### Reset baze (brisanje svih podataka)
```bash
docker compose down -v      # -v briše volumen s podacima
docker compose up db        # migracije se izvrše ispočetka pri sljedećem pokretanju backenda
```
