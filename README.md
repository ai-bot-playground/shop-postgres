# PostgreSQL — źródło prawdy (database-per-service)

Standardowy obraz `postgres`, ale to repo trzyma jego konfigurację inicjującą.
`docker-compose.yml` (w repo shop-documentation) montuje stąd skrypt zakładający
bazy. Każdy serwis ma **własną bazę** i nikt nie zagląda do cudzej — luźne
sprzężenie i niezależne wdrożenia. W demie jeden silnik z wieloma bazami;
produkcyjnie osobne instancje.

## Co skonfigurować

- Bazy tworzy `01-create-databases.sql` (w korzeniu tego repo) przy pierwszym
  starcie — compose montuje go do `/docker-entrypoint-initdb.d/`:
  `catalog_db` (shop-catalog), `inventory_db` (shop-inwentory), `order_db`
  (shop-order), `payment_db` (shop-payment), `notification_db` (shop-notification).
- Poświadczenia w demie: `appuser` / `apppass`. **Produkcyjnie sekrety**, osobni
  użytkownicy per baza i TLS.
- Wolumen `postgres-data` trzyma dane między restartami.

## Migracje
Każdy serwis zarządza swoim schematem migracjami (Flyway/Liquibase) przy starcie —
wersjonowanymi w repo danego serwisu, nie tworzonymi ręcznie.

## Schematy (zarys, szczegóły w README serwisów)

- **inventory_db** (shop-inwentory): `products(id, name, total_stock, version)` z
  blokadą optymistyczną; `reservations`; `outbox`; `processed_events`.
- **order_db** (shop-order): `orders(..., idempotency_key UNIQUE)`; `order_items`;
  `saga_state`; `outbox`; `processed_events`.
- **payment_db** (shop-payment): `payments(..., idempotency_key UNIQUE)`; `outbox`.
- **catalog_db** (shop-catalog): `products`, `categories`.
- **notification_db** (shop-notification): `sent_notifications(event_id PK, ...)`.

## Pula połączeń i tuning

- HikariCP per serwis; suma pul wszystkich instancji ≤ `max_connections`.
- Przy wielu instancjach dołóż **PgBouncer**, inaczej połączenia staną się wąskim
  gardłem.
- Gorącej ścieżki rezerwacji **nie** trzymaj w SQL — od tego jest Redis.

## Skalowanie
Read replicas (zwłaszcza dla shop-catalog), osobne instancje per serwis.
Healthcheck: `pg_isready`.
