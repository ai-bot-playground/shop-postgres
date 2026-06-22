-- Wykonywane automatycznie przez obraz postgres przy pierwszym starcie
-- (montowane w /docker-entrypoint-initdb.d). Realizuje wzorzec
-- database-per-service: każdy serwis dostaje własną, izolowaną bazę.

CREATE DATABASE catalog_db;       -- shop-catalog
CREATE DATABASE inventory_db;     -- shop-inwentory
CREATE DATABASE order_db;         -- shop-order
CREATE DATABASE payment_db;       -- shop-payment
CREATE DATABASE notification_db;  -- shop-notification

-- Uwaga produkcyjna: w realnym wdrożeniu każda z tych baz to osobna
-- instancja, aby serwisy skalowały i przełączały się awaryjnie niezależnie.
-- Tu, dla wygody dema, dzielą jeden silnik.
