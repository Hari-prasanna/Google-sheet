-- dim_date creation

CREATE TABLE dim_date(
	date_key INTEGER PRIMARY KEY, 
	full_date DATE NOT NULL UNIQUE,
	day_of_month SMALLINT NOT NULL, 
	day_of_week SMALLINT NOT NULL,
	day_name VARCHAR(10) NOT NULL,
	month_number SMALLINT NOT NULL,
	month_name VARCHAR NOT NULL,
	quarter SMALLINT NOT NULL,
	year SMALLINT NOT NULL,
	year_month VARCHAR(7) NOT NULL,
	year_quarter VARCHAR(7) NOT NULL,
	is_weekend BOOLEAN NOT NULL
)


INSERT INTO dim_date(
	date_key, full_date, day_of_month, day_of_week, day_name,
    month_number, month_name, quarter, year, year_month, year_quarter, is_weekend
)

SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER          AS date_key,
    d                                        AS full_date,
    EXTRACT(DAY  FROM d)::SMALLINT           AS day_of_month,
    EXTRACT(DOW  FROM d)::SMALLINT           AS day_of_week,
    TRIM(TO_CHAR(d, 'Day'))                  AS day_name,
    EXTRACT(MONTH FROM d)::SMALLINT          AS month_number,
    TRIM(TO_CHAR(d, 'Month'))                AS month_name,
    EXTRACT(QUARTER FROM d)::SMALLINT        AS quarter,
    EXTRACT(YEAR  FROM d)::SMALLINT          AS year,
    TO_CHAR(d, 'YYYY-MM')                    AS year_month,
    TO_CHAR(d, 'YYYY"-Q"Q')                  AS year_quarter,
    EXTRACT(DOW FROM d) IN (0, 6)            AS is_weekend
FROM generate_series(DATE '2023-01-01', DATE '2026-12-31', INTERVAL '1 day') AS d;



-- check -- 
SELECT *
FROM dim_date dd 