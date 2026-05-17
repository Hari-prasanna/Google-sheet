INSERT INTO dim_salesperson (salesperson_key, salesperson_id, salesperson_name,
                              territory_code, territory_name, territory_manager,
                              region_code, region_name, region_vp, is_current)
OVERRIDING SYSTEM VALUE
VALUES (-1, -1, 'Unknown',
        'UNK', 'Unknown', 'Unknown',
        'UNK', 'Unknown', 'Unknown',
        TRUE)
ON CONFLICT(salesperson_key) DO NOTHING; --- prevents the duplication flag for -1 sales_key

INSERT INTO dim_salesperson (
    salesperson_id, salesperson_name,
    territory_code, territory_name, territory_manager,
    region_code, region_name, region_vp,
    effective_date, expiry_date, is_current
)
SELECT
    s.salesperson_id, s.salesperson_name,
    t.territory_code, t.territory_name, t.territory_manager,
    r.region_code, r.region_name, r.region_vp,
    DATE '1900-01-01', DATE '9999-12-31', TRUE
FROM salespeople s
JOIN territories t ON t.territory_code = s.territory_code
JOIN regions     r ON r.region_code    = t.region_code
WHERE NOT EXISTS(SELECT 1 FROM dim_salesperson ds
					WHERE ds.salesperson_id = s.salesperson_id AND ds.is_current = TRUE); -- correlated subquery used for idempotent pattern