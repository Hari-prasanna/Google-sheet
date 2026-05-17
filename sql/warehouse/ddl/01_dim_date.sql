-- ============================================================
-- DIMENSION 1: dim_date
--
-- Grain: one row per calendar day.
-- Source: built from scratch (no source table for dates).
-- SCD: not applicable (a date never "changes").
-- Date keys are integer YYYYMMDD for human readability.
-- ============================================================

CREATE TABLE dim_date (
    date_key        INTEGER     PRIMARY KEY,        -- YYYYMMDD, e.g. 20250115
    full_date       DATE        NOT NULL UNIQUE,    -- the actual date
    day_of_month    SMALLINT    NOT NULL,           -- 1..31
    day_of_week     SMALLINT    NOT NULL,           -- 0=Sun .. 6=Sat
    day_name        VARCHAR(10) NOT NULL,           -- 'Monday' etc.
    month_number    SMALLINT    NOT NULL,           -- 1..12
    month_name      VARCHAR(10) NOT NULL,           -- 'January' etc.
    quarter         SMALLINT    NOT NULL,           -- 1..4
    year            SMALLINT    NOT NULL,           -- 2024, 2025...
    year_month      CHAR(7)     NOT NULL,           -- '2025-01' (sortable)
    year_quarter    CHAR(7)     NOT NULL,           -- '2025-Q1'
    is_weekend      BOOLEAN     NOT NULL
);