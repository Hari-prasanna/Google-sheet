CREATE TABLE dim_salesperson (
    salesperson_key     SERIAL          PRIMARY KEY,
    salesperson_id      INTEGER         NOT NULL,
    salesperson_name    VARCHAR(100)    NOT NULL,
    -- Territory (flattened):
    territory_code      VARCHAR(10)     NOT NULL,
    territory_name      VARCHAR(50)     NOT NULL,
    territory_manager   VARCHAR(100)    NOT NULL,
    -- Region (flattened):
    region_code         VARCHAR(10)     NOT NULL,
    region_name         VARCHAR(50)     NOT NULL,
    region_vp           VARCHAR(100)    NOT NULL,
    -- SCD Type 2 housekeeping:
    effective_date      DATE            NOT NULL DEFAULT DATE '1900-01-01',
    expiry_date         DATE            NOT NULL DEFAULT DATE '9999-12-31',
    is_current          BOOLEAN         NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_dim_salesperson_natural ON dim_salesperson (salesperson_id, is_current);