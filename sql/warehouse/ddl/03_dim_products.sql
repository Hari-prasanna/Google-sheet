CREATE TABLE products (
    sku                  VARCHAR(20) PRIMARY KEY,
    product_name         VARCHAR(100) NOT NULL,
    product_description  VARCHAR(500),
    brand_code           VARCHAR(10) NOT NULL REFERENCES brands(brand_code),
    category_code        VARCHAR(10) NOT NULL REFERENCES categories(category_code),
    unit_price           NUMERIC(10,2) NOT NULL,
    unit_cost            NUMERIC(10,2) NOT NULL
);
