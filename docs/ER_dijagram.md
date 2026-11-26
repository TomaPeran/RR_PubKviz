# Pub Kviz – ER dijagram baze podataka (T-02)

Dijagram je u Mermaid formatu – GitHub ga automatski iscrtava kad se ova datoteka otvori u repozitoriju. Tipovi stupaca odgovaraju PostgreSQL-u 16 (baza projekta); `bigint` ključevi se u Flyway migracijama pišu kao `BIGSERIAL`, kao u `V1__create_item.sql`.

![ER dijagram](ER_dijagram.png)

```mermaid
erDiagram
    ULOGA ||--o{ KORISNIK : "ima"
    KORISNIK ||--o{ ZAHTJEV_ULOGE : "šalje"
    KORISNIK ||--o{ KVIZ : "organizira"
    KORISNIK ||--o{ TIM : "vodi"
    KORISNIK ||--o{ CLAN_TIMA : "je član"
    TIM ||--|{ CLAN_TIMA : "sadrži"
    TIM ||--o{ PRIJAVA_TIMA : "prijavljuje se"
    KVIZ ||--o{ PRIJAVA_TIMA : "prima"
    KVIZ ||--o{ PITANJE : "sadrži"
    KATEGORIJA ||--o{ PITANJE : "grupira"
    PRIJAVA_TIMA ||--o{ BODOVI : "osvaja"
    PITANJE ||--o{ BODOVI : "boduje se"

    ULOGA {
        bigint id PK
        varchar naziv UK "Administrator, Organizator, Sudionik"
    }
    KORISNIK {
        bigint id PK
        varchar ime
        varchar korisnicko_ime UK
        varchar email UK
        varchar lozinka_hash
        bigint uloga_id FK
        boolean aktivan
        timestamptz datum_registracije
    }
    ZAHTJEV_ULOGE {
        bigint id PK
        bigint korisnik_id FK
        varchar status "na_cekanju, odobren, odbijen"
        timestamptz datum_zahtjeva
        bigint obradio_admin_id FK "nullable"
        timestamptz datum_obrade "nullable"
    }
    KVIZ {
        bigint id PK
        bigint organizator_id FK
        varchar naziv
        varchar opis "nullable"
        timestamptz datum_vrijeme
        varchar lokacija
        bigint max_timova
        varchar status "otvoren, u_tijeku, zavrsen, otkazan"
        timestamptz datum_kreiranja
    }
    KATEGORIJA {
        bigint id PK
        varchar naziv UK
    }
    PITANJE {
        bigint id PK
        bigint kviz_id FK
        bigint kategorija_id FK
        varchar tekst
        varchar tocan_odgovor
        bigint bodovi "zadano 1"
        bigint redni_broj
    }
    TIM {
        bigint id PK
        varchar naziv UK
        bigint voditelj_id FK
        timestamptz datum_kreiranja
    }
    CLAN_TIMA {
        bigint tim_id PK,FK
        bigint korisnik_id PK,FK
        timestamptz datum_pridruzivanja
    }
    PRIJAVA_TIMA {
        bigint id PK
        bigint tim_id FK
        bigint kviz_id FK
        timestamptz datum_prijave
        varchar status "aktivna, otkazana"
    }
    BODOVI {
        bigint id PK
        bigint prijava_id FK
        bigint pitanje_id FK
        numeric bodovi ">= 0"
    }
```

## Ključevi i pravila

| Tablica | PK | FK | Jedinstvenost / pravila |
|---|---|---|---|
| ULOGA | id | – | naziv jedinstven |
| KORISNIK | id | uloga_id → ULOGA | email i korisnicko_ime jedinstveni; lozinka samo kao hash (T-06); `aktivan = false` blokira prijavu (T-33) |
| ZAHTJEV_ULOGE | id | korisnik_id, obradio_admin_id → KORISNIK | US-27 / T-32 |
| KVIZ | id | organizator_id → KORISNIK | max_timova > 0; novi kviz ima status `otvoren` (T-12) |
| KATEGORIJA | id | – | naziv jedinstven |
| PITANJE | id | kviz_id → KVIZ, kategorija_id → KATEGORIJA | redni_broj određuje redoslijed prikaza (T-25) |
| TIM | id | voditelj_id → KORISNIK | naziv jedinstven (T-20); voditelj se upisuje i u CLAN_TIMA |
| CLAN_TIMA | (tim_id, korisnik_id) | tim_id → TIM, korisnik_id → KORISNIK | spojna tablica M:N korisnik–tim |
| PRIJAVA_TIMA | id | tim_id → TIM, kviz_id → KVIZ | UNIQUE (tim_id, kviz_id) – tim se ne prijavljuje dvaput (T-21) |
| BODOVI | id | prijava_id → PRIJAVA_TIMA, pitanje_id → PITANJE | UNIQUE (prijava_id, pitanje_id); bodovi ≥ 0 (T-26) |

## Odluke koje tim treba potvrditi

1. **Bodovi po pitanju, ne po rundi.** BODOVI veže prijavu tima i pitanje, pa se ukupni zbroj tima dobije kao `SUM(bodovi)`. Ako želite bodovanje po rundama, dodajte tablicu RUNDA i zamijenite `pitanje_id` s `runda_id`.
2. **Rang se ne sprema, nego se računa** iz zbroja bodova (T-28). Ako povijest kvizova (T-31) postane spora, može se dodati stupac `plasman` u PRIJAVA_TIMA koji se popuni pri završetku kviza.
3. **Kategorije su zajedničke** svim organizatorima. Ako svaki organizator treba svoje, dodajte `organizator_id FK` u KATEGORIJA.
4. **Ponovna prijava nakon otkazivanja**: zbog UNIQUE (tim_id, kviz_id) otkazana prijava se ponovno aktivira promjenom statusa, a ne novim retkom.
5. **Broj slobodnih mjesta** = `max_timova − COUNT(aktivnih prijava)`; ne sprema se posebno.
