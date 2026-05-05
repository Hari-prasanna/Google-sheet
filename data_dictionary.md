# Data Dictionary — Operational Source System

This document describes the **source** (OLTP-style) database used throughout the
Star Schema learning journey. It is **not** a data warehouse — it represents
the kind of transactional system that a real warehouse would extract from.

> Domain: A fictional office supplies distributor. Sells packaging, pens,
> folders, and notebooks via a regional sales force to wholesale and retail
> customers.

---

## Conventions

| Concept | Convention | Example |
|---|---|---|
| Primary key (numeric, system-generated) | `<entity>_id` | `customer_id`, `order_id` |
| Primary key (short business code) | `<entity>_code` | `region_code`, `brand_code` |
| Primary key (real-world identifier) | named after the identifier | `sku` |
| Foreign key | same name as the parent's PK | `customer_id` in `orders` |
| Money | `NUMERIC(10,2)` in USD | `unit_price` = `2.50` |
| Dates | `DATE` (no time component yet) | `order_date` = `2025-01-15` |

The schema is in **roughly third normal form** — no redundant data,
each attribute lives in exactly one place. Brand info is in `brands`,
not repeated on every product. This is intentional: the OLTP world
optimizes for writes and integrity. The warehouse will deliberately
*denormalize* this in Day 2.

---

## Tables

### `regions`
The top of the geographic sales hierarchy. A small, slow-changing list.

| Column | Type | Role | Purpose |
|---|---|---|---|
| `region_code` | VARCHAR(10) | PK | Short business code (`E`, `W`, `C`). |
| `region_name` | VARCHAR(50) | attribute | Human-readable name (`East`, `West`, `Central`). |
| `region_vp` | VARCHAR(100) | attribute | Vice President responsible for the region. *Slowly changes — when the VP is replaced, only this value changes.* |

### `territories`
Mid-level geographic unit. Each territory rolls up to exactly one region.

| Column | Type | Role | Purpose |
|---|---|---|---|
| `territory_code` | VARCHAR(10) | PK | Short business code (`NE`, `SE`, etc.). |
| `territory_name` | VARCHAR(50) | attribute | Human-readable name. |
| `territory_manager` | VARCHAR(100) | attribute | Manager responsible for the territory. |
| `region_code` | VARCHAR(10) | FK → `regions` | Which region this territory belongs to. |

### `salespeople`
Individual sales reps. Each one is assigned to exactly one territory at a time.

| Column | Type | Role | Purpose |
|---|---|---|---|
| `salesperson_id` | INTEGER | PK | System-generated identifier. |
| `salesperson_name` | VARCHAR(100) | attribute | Full name. |
| `territory_code` | VARCHAR(10) | FK → `territories` | Current territory assignment. *This is exactly the kind of value that triggers SCD discussions in Ch 3 and 8 — what happens to old orders if a salesperson moves territory?* |

### `brands`
Product manufacturer brands.

| Column | Type | Role | Purpose |
|---|---|---|---|
| `brand_code` | VARCHAR(10) | PK | Short brand code. |
| `brand_name` | VARCHAR(50) | attribute | Display name. |
| `brand_manager` | VARCHAR(100) | attribute | Internal brand manager (employee). |

### `categories`
Top-level product groupings. Deliberately small and flat for now —
hierarchies (subcategory, department) get added when we hit Chapter 7.

| Column | Type | Role | Purpose |
|---|---|---|---|
| `category_code` | VARCHAR(10) | PK | Short code (`PKG`, `PEN`, `FLD`, `NTB`). |
| `category_name` | VARCHAR(50) | attribute | Display name. |

### `products`
The catalog. Each row is one SKU available for sale.

| Column | Type | Role | Purpose |
|---|---|---|---|
| `sku` | VARCHAR(20) | PK | The real-world SKU identifier (the **natural key**). |
| `product_name` | VARCHAR(100) | attribute | Short display name. |
| `product_description` | VARCHAR(500) | attribute | Longer description. |
| `brand_code` | VARCHAR(10) | FK → `brands` | Manufacturer. |
| `category_code` | VARCHAR(10) | FK → `categories` | Classification. |
| `unit_price` | NUMERIC(10,2) | attribute / *fact source* | Selling price per unit, in USD. *Will be used to compute the `extended_price` fact.* |
| `unit_cost` | NUMERIC(10,2) | attribute / *fact source* | Cost per unit, in USD. *Will be used to compute the `extended_cost` and margin facts.* |

> **Note:** `unit_price` and `unit_cost` are stored as current values on the
> product. In real OLTP systems, when prices change the value is overwritten.
> This is a planned breakage point for SCD lessons.

### `customers`
The companies that buy from us. The **most interesting** table — many planned
SCD scenarios center here.

| Column | Type | Role | Purpose |
|---|---|---|---|
| `customer_id` | INTEGER | PK | Source system identifier (the **natural key**). |
| `customer_name` | VARCHAR(100) | attribute | Legal name. |
| `headquarters_state` | VARCHAR(2) | attribute | US state of HQ — used for some geographic reports. |
| `billing_address` | VARCHAR(200) | attribute | Street address for invoices. *Changes over time — SCD Type 2 candidate.* |
| `billing_city` | VARCHAR(100) | attribute | Same — changes when the customer relocates. |
| `billing_state` | VARCHAR(2) | attribute | Same. |
| `billing_zip` | VARCHAR(10) | attribute | Same. |
| `sic_code` | VARCHAR(10) | attribute | Standard Industrial Classification code. *In Ch 9 we'll discover that real customers can belong to multiple industries — bridge table candidate.* |
| `industry_name` | VARCHAR(100) | attribute | Human-readable industry. |

### `orders`
Order header. One row per customer order. Header-level facts and FKs only.

| Column | Type | Role | Purpose |
|---|---|---|---|
| `order_id` | INTEGER | PK | Order number from the source system. |
| `order_date` | DATE | attribute / dimension | The date the order was placed. *Becomes a foreign key to `dim_date` in the warehouse.* |
| `customer_id` | INTEGER | FK → `customers` | Who placed it. |
| `salesperson_id` | INTEGER | FK → `salespeople` | Who took it. |

### `order_lines`
Order detail. One row per line item on an order. **This is the lowest grain
in the source — it's where the future fact table will live.**

| Column | Type | Role | Purpose |
|---|---|---|---|
| `order_id` | INTEGER | PK / FK → `orders` | Which order this line belongs to. |
| `line_no` | INTEGER | PK | Sequence number on the order (1, 2, 3, …). |
| `sku` | VARCHAR(20) | FK → `products` | What was ordered. |
| `quantity` | INTEGER | *fact source* | How many units. The base measurement. |

> **What's missing here that the warehouse will compute:**
> `extended_price` (= `quantity × unit_price`),
> `extended_cost` (= `quantity × unit_cost`),
> and `margin_dollars` (= `extended_price − extended_cost`).
> The source doesn't store these because they can always be derived.
> The warehouse *will* store them, because pre-computing them avoids
> repeated joins and aligns with the **performance** principle from Ch 1.

---

## Known Limitations / Planned Evolution

These are deliberate gaps that future chapters will fix:

1. **No order-line price snapshot.** If `unit_price` changes in `products`, historical orders re-priced themselves. (Fixed when we introduce SCD Type 2 in Ch 3.)
2. **No date dimension.** Date attributes (year, quarter, month, day-of-week, fiscal period) don't exist yet. (Fixed Day 2.)
3. **No shipment tracking.** Orders go in, nothing comes out. (Fixed in Ch 4–5 to demonstrate conformed dimensions.)
4. **No customer hierarchy.** ABC Wholesalers might own BrightMart — we can't represent that. (Fixed Ch 10, recursive bridge.)
5. **One industry per customer.** Real customers operate in many. (Fixed Ch 9, multi-valued bridge.)
6. **No inventory.** No way to ask "how much do we have on hand?" (Fixed Ch 11, periodic snapshot fact.)
7. **No order-pipeline tracking.** Order placed → picked → packed → shipped → delivered → invoiced → paid is invisible. (Fixed Ch 12, accumulating snapshot fact.)

