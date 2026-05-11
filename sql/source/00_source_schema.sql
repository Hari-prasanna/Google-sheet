-- ---------- Reference tables ----------

CREATE TABLE regions (
    region_code   VARCHAR(10) PRIMARY KEY,
    region_name   VARCHAR(50) NOT NULL,
    region_vp     VARCHAR(100) NOT NULL
);

CREATE TABLE territories (
    territory_code     VARCHAR(10) PRIMARY KEY,
    territory_name     VARCHAR(50) NOT NULL,
    territory_manager  VARCHAR(100) NOT NULL,
    region_code        VARCHAR(10) NOT NULL REFERENCES regions(region_code)
);

CREATE TABLE categories (
    category_code   VARCHAR(10) PRIMARY KEY,
    category_name   VARCHAR(50) NOT NULL
);

CREATE TABLE brands (
    brand_code     VARCHAR(10) PRIMARY KEY,
    brand_name     VARCHAR(50) NOT NULL,
    brand_manager  VARCHAR(100) NOT NULL
);

-- ---------- Core entities ----------

CREATE TABLE customers (
    customer_id         INTEGER PRIMARY KEY,
    customer_name       VARCHAR(100) NOT NULL,
    headquarters_state  VARCHAR(2),
    billing_address     VARCHAR(200),
    billing_city        VARCHAR(100),
    billing_state       VARCHAR(2),
    billing_zip         VARCHAR(10),
    sic_code            VARCHAR(10),
    industry_name       VARCHAR(100)
);

CREATE TABLE salespeople (
    salesperson_id     INTEGER PRIMARY KEY,
    salesperson_name   VARCHAR(100) NOT NULL,
    territory_code     VARCHAR(10) NOT NULL REFERENCES territories(territory_code)
);

CREATE TABLE products (
    sku                  VARCHAR(20) PRIMARY KEY,
    product_name         VARCHAR(100) NOT NULL,
    product_description  VARCHAR(500),
    brand_code           VARCHAR(10) NOT NULL REFERENCES brands(brand_code),
    category_code        VARCHAR(10) NOT NULL REFERENCES categories(category_code),
    unit_price           NUMERIC(10,2) NOT NULL,
    unit_cost            NUMERIC(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id         INTEGER PRIMARY KEY,
    order_date       DATE NOT NULL,
    customer_id      INTEGER NOT NULL REFERENCES customers(customer_id),
    salesperson_id   INTEGER NOT NULL REFERENCES salespeople(salesperson_id)
);

CREATE TABLE order_lines (
    order_id         INTEGER NOT NULL REFERENCES orders(order_id),
    line_no          INTEGER NOT NULL,
    sku              VARCHAR(20) NOT NULL REFERENCES products(sku),
    quantity         INTEGER NOT NULL,
    PRIMARY KEY (order_id, line_no)
);

-- ============================================================
-- Sample data
-- ============================================================

INSERT INTO regions VALUES
  ('E',  'East',    'Sarah Chen'),
  ('W',  'West',    'Marco Delgado'),
  ('C',  'Central', 'Priya Nair');

INSERT INTO territories VALUES
  ('NE',  'Northeast',  'James Park',     'E'),
  ('SE',  'Southeast',  'Rita Morales',   'E'),
  ('NW',  'Northwest',  'Dan O''Connor',  'W'),
  ('SW',  'Southwest',  'Leah Goldberg',  'W'),
  ('MW',  'Midwest',    'Tom Becker',     'C');

INSERT INTO categories VALUES
  ('PKG', 'Packaging'),
  ('PEN', 'Pens'),
  ('FLD', 'Folders'),
  ('NTB', 'Notebooks');

INSERT INTO brands VALUES
  ('ACME',  'Acme Office',  'Ken Walsh'),
  ('ZENI',  'Zenith',       'Maya Sorensen'),
  ('CORE',  'CorePro',      'Luis Beltran');

INSERT INTO customers VALUES
  (10711, 'ABC Wholesalers',      'NY', '100 Hudson St',     'New York',  'NY', '10013', '5113', 'Office Supplies Wholesale'),
  (10712, 'BrightMart Stores',    'CA', '55 Market Ave',     'San Jose',  'CA', '95110', '5211', 'Retail Building Materials'),
  (10713, 'Cornerstone Retail',   'TX', '900 Congress Blvd', 'Austin',    'TX', '78701', '5311', 'Department Stores'),
  (10714, 'Dalton Office Supply', 'IL', '12 Wacker Pl',      'Chicago',   'IL', '60601', '5112', 'Stationery'),
  (10715, 'Evergreen Paper Co',   'WA', '48 Pine Way',       'Seattle',   'WA', '98101', '5112', 'Stationery'),
  (10716, 'FirstLine Partners',   'MA', '7 Beacon Row',      'Boston',    'MA', '02108', '5113', 'Office Supplies Wholesale'),
  (10717, 'Greenfield Markets',   'GA', '210 Peachtree St',  'Atlanta',   'GA', '30303', '5411', 'Grocery Stores');

INSERT INTO salespeople VALUES
  (201, 'Alex Rivera',   'NE'),
  (202, 'Bianca Shah',   'SE'),
  (203, 'Carlos Nguyen', 'NW'),
  (204, 'Dana Okafor',   'SW'),
  (205, 'Ethan Reilly',  'MW');

INSERT INTO products VALUES
  ('SKU-1001', 'Box - Small',      'Small corrugated box, 20cm',    'ACME', 'PKG', 2.50, 0.90),
  ('SKU-1002', 'Box - Medium',     'Medium corrugated box, 30cm',   'ACME', 'PKG', 3.80, 1.40),
  ('SKU-1003', 'Box - Large',      'Large corrugated box, 45cm',    'ACME', 'PKG', 5.20, 2.10),
  ('SKU-1004', 'Clasp Letter',     'Clasp envelope, letter size',   'ACME', 'PKG', 0.75, 0.20),
  ('SKU-1005', 'Envelope #10',     'Standard #10 envelope',         'ACME', 'PKG', 0.35, 0.08),
  ('SKU-1006', 'Envelope Bubble',  'Padded bubble mailer',          'ACME', 'PKG', 1.10, 0.35),
  ('SKU-2001', 'Gel Pen Black',    'Black gel ink, medium tip',     'ZENI', 'PEN', 1.20, 0.30),
  ('SKU-2002', 'Gel Pen Blue',     'Blue gel ink, medium tip',      'ZENI', 'PEN', 1.20, 0.30),
  ('SKU-2003', 'Silver Pen',       'Silver metallic pen',           'ZENI', 'PEN', 2.40, 0.70),
  ('SKU-3001', 'Manila Folder',    'Manila folder, letter size',    'CORE', 'FLD', 0.45, 0.12),
  ('SKU-3002', 'Hanging Folder',   'Hanging file folder',           'CORE', 'FLD', 0.85, 0.25),
  ('SKU-4001', 'Spiral Notebook',  '100-page spiral notebook',      'CORE', 'NTB', 2.60, 0.80),
  ('SKU-4002', 'Composition Book', 'Marble cover composition book', 'CORE', 'NTB', 1.90, 0.55);

-- Orders span Nov 2024 - Feb 2025 so you can filter by month meaningfully.
INSERT INTO orders VALUES
  (9001, DATE '2024-11-04', 10711, 201),
  (9002, DATE '2024-11-09', 10712, 203),
  (9003, DATE '2024-11-15', 10713, 204),
  (9004, DATE '2024-12-02', 10714, 205),
  (9005, DATE '2024-12-11', 10715, 203),
  (9006, DATE '2024-12-20', 10711, 201),
  (9007, DATE '2024-12-28', 10716, 201),
  (9008, DATE '2025-01-03', 10712, 203),
  (9009, DATE '2025-01-07', 10717, 202),
  (9010, DATE '2025-01-14', 10713, 204),
  (9011, DATE '2025-01-19', 10714, 205),
  (9012, DATE '2025-01-22', 10711, 201),
  (9013, DATE '2025-01-28', 10715, 203),
  (9014, DATE '2025-02-05', 10716, 201),
  (9015, DATE '2025-02-12', 10717, 202);

INSERT INTO order_lines VALUES
  (9001, 1, 'SKU-1001', 100),
  (9001, 2, 'SKU-1002', 50),
  (9001, 3, 'SKU-2001', 200),
  (9002, 1, 'SKU-1003', 40),
  (9002, 2, 'SKU-3001', 500),
  (9003, 1, 'SKU-4001', 80),
  (9003, 2, 'SKU-4002', 120),
  (9003, 3, 'SKU-2002', 150),
  (9004, 1, 'SKU-1004', 1000),
  (9004, 2, 'SKU-1005', 2000),
  (9005, 1, 'SKU-1006', 300),
  (9005, 2, 'SKU-2003', 60),
  (9006, 1, 'SKU-1001', 80),
  (9006, 2, 'SKU-3002', 400),
  (9007, 1, 'SKU-4001', 200),
  (9007, 2, 'SKU-4002', 150),
  (9008, 1, 'SKU-1002', 90),
  (9008, 2, 'SKU-2001', 300),
  (9009, 1, 'SKU-1003', 55),
  (9009, 2, 'SKU-1005', 1500),
  (9010, 1, 'SKU-3001', 600),
  (9010, 2, 'SKU-4002', 100),
  (9011, 1, 'SKU-2002', 200),
  (9011, 2, 'SKU-2003', 80),
  (9012, 1, 'SKU-1001', 120),
  (9012, 2, 'SKU-1006', 250),
  (9012, 3, 'SKU-4001', 90),
  (9013, 1, 'SKU-1004', 1200),
  (9013, 2, 'SKU-3002', 350),
  (9014, 1, 'SKU-2001', 400),
  (9014, 2, 'SKU-4002', 180),
  (9015, 1, 'SKU-1002', 70),
  (9015, 2, 'SKU-1003', 30),
  (9015, 3, 'SKU-3001', 550);

-- Quick smoke test
SELECT 'regions'     AS table_name, COUNT(*) AS row_count FROM regions
UNION ALL SELECT 'territories', COUNT(*) FROM territories
UNION ALL SELECT 'categories',  COUNT(*) FROM categories
UNION ALL SELECT 'brands',      COUNT(*) FROM brands
UNION ALL SELECT 'customers',   COUNT(*) FROM customers
UNION ALL SELECT 'salespeople', COUNT(*) FROM salespeople
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_lines', COUNT(*) FROM order_lines;