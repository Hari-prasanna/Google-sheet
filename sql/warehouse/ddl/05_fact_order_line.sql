CREATE TABLE fact_order_lines (
    -- Surrogate FKs to dimensions:
    date_key            INTEGER         NOT NULL REFERENCES dim_date(date_key),
    customer_key        INTEGER         NOT NULL REFERENCES dim_customer(customer_key),
    salesperson_key     INTEGER         NOT NULL REFERENCES dim_salesperson(salesperson_key),
    product_key         INTEGER         NOT NULL REFERENCES dim_product(product_key),

    -- Degenerate dimensions:
    order_id            INTEGER         NOT NULL,
    line_no             INTEGER         NOT NULL,

    -- Facts:
    quantity            INTEGER         NOT NULL,
    extended_price      NUMERIC(12,2)   NOT NULL,    -- quantity * unit_price
    extended_cost       NUMERIC(12,2)   NOT NULL,    -- quantity * unit_cost
    margin_dollars      NUMERIC(12,2)   NOT NULL,    -- extended_price - extended_cost

    PRIMARY KEY (order_id, line_no)
);

CREATE INDEX idx_fact_date     ON fact_order_lines (date_key);
CREATE INDEX idx_fact_customer ON fact_order_lines (customer_key);
CREATE INDEX idx_fact_product  ON fact_order_lines (product_key);
CREATE INDEX idx_fact_sp       ON fact_order_lines (salesperson_key);
