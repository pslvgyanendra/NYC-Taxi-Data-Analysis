-- NYC Yellow Taxi Analytics
-- 50 Business Questions with PostgreSQL Solutions
-- Role perspective: NYC Taxi company management / Senior Data Analyst
-- Scope: May 2026 Yellow Taxi final cleaned fact data
-- Fact table assumed: yellow_tripdata
-- Lookup tables assumed: taxi_zone_lookup, payment_lookup, ratecode_lookup, store_and_fwd_lookup, vendor_lookup
--
-- IMPORTANT:
-- 1) The uploaded 50,000-row sample is for syntax/development validation only.
-- 2) Final KPI/business results should be run against the complete 4,050,862-row fact table.
-- 3) This project defines Total Revenue as SUM(COALESCE(total_amount, expected_total)).
-- 4) total_amount/expected_total represent recorded/calculated trip amount under the project's cleaning logic; do not interpret it as profit.
-- 5) Airport Trip Share (Q37) uses Airport_fee > 0; Airport Rate Code Share (Q39) uses RatecodeID 2 and 3.
-- 6) PostgreSQL syntax is used.

-- SECTION 1 — BASIC BUSINESS KPIs
-- ----------------------------------------------------------------------
-- Q01. How many valid taxi trip records are in the final fact table?
SELECT COUNT(*) AS total_trips
FROM yellow_tripdata;

-- Q02. What is the total recorded revenue, using expected_total as a fallback where total_amount is NULL?
SELECT ROUND(SUM(COALESCE(total_amount, expected_total))::numeric, 2) AS total_revenue
FROM yellow_tripdata;

-- Q03. What is the average trip amount using total_amount with expected_total as the fallback?
SELECT ROUND(AVG(COALESCE(total_amount, expected_total))::numeric, 2) AS average_trip_amount
FROM yellow_tripdata;

-- Q04. What is the total fare amount?
SELECT ROUND(SUM(fare_amount)::numeric, 2) AS total_fare
FROM yellow_tripdata;

-- Q05. What is the average fare amount per trip?
SELECT ROUND(AVG(fare_amount)::numeric, 2) AS average_fare
FROM yellow_tripdata;

-- Q06. What is the total tip amount?
SELECT ROUND(SUM(tip_amount)::numeric, 2) AS total_tips
FROM yellow_tripdata;

-- Q07. What is the average tip amount per tipped/recorded-tip trip?
SELECT ROUND(AVG(tip_amount)::numeric, 2) AS average_recorded_tip
FROM yellow_tripdata;

-- Q08. What is the average trip duration in minutes?
SELECT ROUND(AVG(trip_duration_min)::numeric, 2) AS average_trip_duration_min
FROM yellow_tripdata;

-- Q09. What is the average trip distance in miles?
SELECT ROUND(AVG(trip_distance)::numeric, 2) AS average_trip_distance_miles
FROM yellow_tripdata;

-- Q10. What is each vendor's share of total trips?
SELECT
    v.vendors_name,
    COUNT(*) AS trips,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS trip_share_pct
FROM yellow_tripdata f
LEFT JOIN vendor_lookup v
    ON f.vendorid = v.vendorid
GROUP BY v.vendors_name
ORDER BY trips DESC;

-- SECTION 2 — DEMAND & TIME ANALYSIS
-- ----------------------------------------------------------------------
-- Q11. Which day of the week has the highest number of trips?
SELECT
    TO_CHAR(tpep_pickup_datetime, 'FMDay') AS day_of_week,
    COUNT(*) AS trips
FROM yellow_tripdata
GROUP BY EXTRACT(ISODOW FROM tpep_pickup_datetime),
         TO_CHAR(tpep_pickup_datetime, 'FMDay')
ORDER BY trips DESC
LIMIT 1;

-- Q12. Which pickup hour has the highest number of trips?
SELECT
    EXTRACT(HOUR FROM tpep_pickup_datetime)::int AS pickup_hour,
    COUNT(*) AS trips
FROM yellow_tripdata
GROUP BY pickup_hour
ORDER BY trips DESC
LIMIT 1;

-- Q13. What is the trip volume for every pickup hour?
SELECT
    EXTRACT(HOUR FROM tpep_pickup_datetime)::int AS pickup_hour,
    COUNT(*) AS trips
FROM yellow_tripdata
GROUP BY pickup_hour
ORDER BY pickup_hour;

-- Q14. What percentage of trips occur on weekends?
SELECT ROUND(
    COUNT(*) FILTER (
        WHERE EXTRACT(ISODOW FROM tpep_pickup_datetime) IN (6, 7)
    ) * 100.0 / COUNT(*),
    2
) AS weekend_trip_share_pct
FROM yellow_tripdata;

-- Q15. What percentage of trips occur during peak hours (07:00–09:59 and 16:00–18:59)?
SELECT ROUND(
    COUNT(*) FILTER (
        WHERE EXTRACT(HOUR FROM tpep_pickup_datetime) BETWEEN 7 AND 9
           OR EXTRACT(HOUR FROM tpep_pickup_datetime) BETWEEN 16 AND 18
    ) * 100.0 / COUNT(*),
    2
) AS peak_hour_trip_share_pct
FROM yellow_tripdata;

-- Q16. Which calendar date has the highest number of trips?
SELECT
    tpep_pickup_datetime::date AS pickup_date,
    COUNT(*) AS trips
FROM yellow_tripdata
GROUP BY pickup_date
ORDER BY trips DESC
LIMIT 1;

-- Q17. Which calendar date generates the highest total revenue?
SELECT
    tpep_pickup_datetime::date AS pickup_date,
    ROUND(SUM(COALESCE(total_amount, expected_total))::numeric, 2) AS total_revenue
FROM yellow_tripdata
GROUP BY pickup_date
ORDER BY total_revenue DESC
LIMIT 1;

-- Q18. What is the average trip duration by day of the week?
SELECT
    TO_CHAR(tpep_pickup_datetime, 'FMDay') AS day_of_week,
    ROUND(AVG(trip_duration_min)::numeric, 2) AS avg_duration_min
FROM yellow_tripdata
GROUP BY EXTRACT(ISODOW FROM tpep_pickup_datetime),
         TO_CHAR(tpep_pickup_datetime, 'FMDay')
ORDER BY EXTRACT(ISODOW FROM tpep_pickup_datetime);

-- Q19. What is the average trip distance by pickup hour?
SELECT
    EXTRACT(HOUR FROM tpep_pickup_datetime)::int AS pickup_hour,
    ROUND(AVG(trip_distance)::numeric, 2) AS avg_distance_miles
FROM yellow_tripdata
GROUP BY pickup_hour
ORDER BY pickup_hour;

-- Q20. Which pickup hour has the highest average revenue per trip?
SELECT
    EXTRACT(HOUR FROM tpep_pickup_datetime)::int AS pickup_hour,
    ROUND(AVG(COALESCE(total_amount, expected_total))::numeric, 2) AS avg_revenue_per_trip
FROM yellow_tripdata
GROUP BY pickup_hour
ORDER BY avg_revenue_per_trip DESC
LIMIT 1;

-- SECTION 3 — LOCATION & ROUTE ANALYSIS
-- ----------------------------------------------------------------------
-- Q21. Which pickup zone has the highest trip volume?
SELECT
    COALESCE(z.zone, 'Unknown / Outside NYC') AS pickup_zone,
    COUNT(*) AS trips
FROM yellow_tripdata f
LEFT JOIN taxi_zone_lookup z
    ON f.pulocationid = z.locationid
GROUP BY COALESCE(z.zone, 'Unknown / Outside NYC')
ORDER BY trips DESC
LIMIT 1;

-- Q22. Which drop-off zone has the highest trip volume?
SELECT
    COALESCE(z.zone, 'Unknown / Outside NYC') AS dropoff_zone,
    COUNT(*) AS trips
FROM yellow_tripdata f
LEFT JOIN taxi_zone_lookup z
    ON f.dolocationid = z.locationid
GROUP BY COALESCE(z.zone, 'Unknown / Outside NYC')
ORDER BY trips DESC
LIMIT 1;

-- Q23. Which pickup borough has the highest trip volume?
SELECT
    COALESCE(z.borough, 'Unknown / Outside NYC') AS pickup_borough,
    COUNT(*) AS trips
FROM yellow_tripdata f
LEFT JOIN taxi_zone_lookup z
    ON f.pulocationid = z.locationid
GROUP BY COALESCE(z.borough, 'Unknown / Outside NYC')
ORDER BY trips DESC
LIMIT 1;

-- Q24. Which drop-off borough has the highest trip volume?
SELECT
    COALESCE(z.borough, 'Unknown / Outside NYC') AS dropoff_borough,
    COUNT(*) AS trips
FROM yellow_tripdata f
LEFT JOIN taxi_zone_lookup z
    ON f.dolocationid = z.locationid
GROUP BY COALESCE(z.borough, 'Unknown / Outside NYC')
ORDER BY trips DESC
LIMIT 1;

-- Q25. What are the top 10 pickup zones by trip volume?
SELECT
    COALESCE(z.zone, 'Unknown / Outside NYC') AS pickup_zone,
    COUNT(*) AS trips
FROM yellow_tripdata f
LEFT JOIN taxi_zone_lookup z
    ON f.pulocationid = z.locationid
GROUP BY COALESCE(z.zone, 'Unknown / Outside NYC')
ORDER BY trips DESC
LIMIT 10;

-- Q26. What are the top 10 drop-off zones by trip volume?
SELECT
    COALESCE(z.zone, 'Unknown / Outside NYC') AS dropoff_zone,
    COUNT(*) AS trips
FROM yellow_tripdata f
LEFT JOIN taxi_zone_lookup z
    ON f.dolocationid = z.locationid
GROUP BY COALESCE(z.zone, 'Unknown / Outside NYC')
ORDER BY trips DESC
LIMIT 10;

-- Q27. What is the most frequent pickup-zone to drop-off-zone route?
SELECT
    COALESCE(p.zone, 'Unknown / Outside NYC') AS pickup_zone,
    COALESCE(d.zone, 'Unknown / Outside NYC') AS dropoff_zone,
    COUNT(*) AS trips
FROM yellow_tripdata f
LEFT JOIN taxi_zone_lookup p
    ON f.pulocationid = p.locationid
LEFT JOIN taxi_zone_lookup d
    ON f.dolocationid = d.locationid
GROUP BY
    COALESCE(p.zone, 'Unknown / Outside NYC'),
    COALESCE(d.zone, 'Unknown / Outside NYC')
ORDER BY trips DESC
LIMIT 1;

-- Q28. What are the top 10 routes by trip volume?
SELECT
    COALESCE(p.zone, 'Unknown / Outside NYC') AS pickup_zone,
    COALESCE(d.zone, 'Unknown / Outside NYC') AS dropoff_zone,
    COUNT(*) AS trips
FROM yellow_tripdata f
LEFT JOIN taxi_zone_lookup p
    ON f.pulocationid = p.locationid
LEFT JOIN taxi_zone_lookup d
    ON f.dolocationid = d.locationid
GROUP BY
    COALESCE(p.zone, 'Unknown / Outside NYC'),
    COALESCE(d.zone, 'Unknown / Outside NYC')
ORDER BY trips DESC
LIMIT 10;

-- Q29. Which pickup zone generates the highest total revenue?
SELECT
    COALESCE(z.zone, 'Unknown / Outside NYC') AS pickup_zone,
    ROUND(SUM(COALESCE(f.total_amount, f.expected_total))::numeric, 2) AS total_revenue
FROM yellow_tripdata f
LEFT JOIN taxi_zone_lookup z
    ON f.pulocationid = z.locationid
GROUP BY COALESCE(z.zone, 'Unknown / Outside NYC')
ORDER BY total_revenue DESC
LIMIT 1;

-- Q30. Which pickup borough has the highest average trip amount?
SELECT
    COALESCE(z.borough, 'Unknown / Outside NYC') AS pickup_borough,
    ROUND(AVG(COALESCE(f.total_amount, f.expected_total))::numeric, 2) AS avg_trip_amount
FROM yellow_tripdata f
LEFT JOIN taxi_zone_lookup z
    ON f.pulocationid = z.locationid
GROUP BY COALESCE(z.borough, 'Unknown / Outside NYC')
ORDER BY avg_trip_amount DESC
LIMIT 1;

-- SECTION 4 — REVENUE, PAYMENT & AIRPORT ANALYSIS
-- ----------------------------------------------------------------------
-- Q31. What is total revenue by payment method?
SELECT
    COALESCE(p.payment_categories, 'Unknown') AS payment_method,
    ROUND(SUM(COALESCE(f.total_amount, f.expected_total))::numeric, 2) AS total_revenue
FROM yellow_tripdata f
LEFT JOIN payment_lookup p
    ON f.payment_type = p.payment_type
GROUP BY COALESCE(p.payment_categories, 'Unknown')
ORDER BY total_revenue DESC;

-- Q32. What share of total trips does each payment method represent?
SELECT
    COALESCE(p.payment_categories, 'Unknown') AS payment_method,
    COUNT(*) AS trips,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS trip_share_pct
FROM yellow_tripdata f
LEFT JOIN payment_lookup p
    ON f.payment_type = p.payment_type
GROUP BY COALESCE(p.payment_categories, 'Unknown')
ORDER BY trip_share_pct DESC;

-- Q33. Which payment method has the highest average trip amount?
SELECT
    COALESCE(p.payment_categories, 'Unknown') AS payment_method,
    ROUND(AVG(COALESCE(f.total_amount, f.expected_total))::numeric, 2) AS avg_trip_amount
FROM yellow_tripdata f
LEFT JOIN payment_lookup p
    ON f.payment_type = p.payment_type
GROUP BY COALESCE(p.payment_categories, 'Unknown')
ORDER BY avg_trip_amount DESC
LIMIT 1;

-- Q34. Which payment method generates the highest total tips?
SELECT
    COALESCE(p.payment_categories, 'Unknown') AS payment_method,
    ROUND(SUM(f.tip_amount)::numeric, 2) AS total_tips
FROM yellow_tripdata f
LEFT JOIN payment_lookup p
    ON f.payment_type = p.payment_type
GROUP BY COALESCE(p.payment_categories, 'Unknown')
ORDER BY total_tips DESC
LIMIT 1;

-- Q35. What is the overall tip amount as a percentage of total revenue?
SELECT ROUND(
    SUM(tip_amount) * 100.0 /
    NULLIF(SUM(COALESCE(total_amount, expected_total)), 0),
    2
) AS tip_revenue_share_pct
FROM yellow_tripdata;

-- Q36. What percentage of trips have a recorded tip greater than zero?
SELECT ROUND(
    COUNT(*) FILTER (WHERE tip_amount > 0) * 100.0 / COUNT(*),
    2
) AS tipped_trip_share_pct
FROM yellow_tripdata;

-- Q37. What percentage of trips have Airport_fee greater than zero?
SELECT ROUND(
    COUNT(*) FILTER (WHERE airport_fee > 0) * 100.0 / COUNT(*),
    2
) AS airport_trip_share_pct
FROM yellow_tripdata;

-- Q38. Which rate type has the highest trip volume?
SELECT
    COALESCE(r.rate_type, 'Unknown') AS rate_type,
    COUNT(*) AS trips
FROM yellow_tripdata f
LEFT JOIN ratecode_lookup r
    ON f.ratecodeid = r.ratecodeid
GROUP BY COALESCE(r.rate_type, 'Unknown')
ORDER BY trips DESC
LIMIT 1;

-- Q39. What share of trips are associated with airport rate codes (JFK and Newark)?
SELECT ROUND(
    COUNT(*) FILTER (WHERE f.ratecodeid IN (2, 3)) * 100.0 / COUNT(*),
    2
) AS airport_rate_code_trip_share_pct
FROM yellow_tripdata f;

-- Q40. What is the total revenue generated by airport-fee trips versus non-airport-fee trips?
SELECT
    CASE
        WHEN airport_fee > 0 THEN 'Airport Fee Trip'
        ELSE 'Non-Airport Fee Trip'
    END AS trip_category,
    COUNT(*) AS trips,
    ROUND(SUM(COALESCE(total_amount, expected_total))::numeric, 2) AS total_revenue
FROM yellow_tripdata
GROUP BY trip_category
ORDER BY total_revenue DESC;

-- SECTION 5 — TRIP BEHAVIOR & OPERATIONS
-- ----------------------------------------------------------------------
-- Q41. What is the average passenger count by payment method?
SELECT
    COALESCE(p.payment_categories, 'Unknown') AS payment_method,
    ROUND(AVG(passenger_count)::numeric, 2) AS avg_passenger_count
FROM yellow_tripdata f
LEFT JOIN payment_lookup p
    ON f.payment_type = p.payment_type
GROUP BY COALESCE(p.payment_categories, 'Unknown')
ORDER BY avg_passenger_count DESC;

-- Q42. Which vendor has the highest average trip distance?
SELECT
    COALESCE(v.vendors_name, 'Unknown') AS vendor,
    ROUND(AVG(f.trip_distance)::numeric, 2) AS avg_distance_miles
FROM yellow_tripdata f
LEFT JOIN vendor_lookup v
    ON f.vendorid = v.vendorid
GROUP BY COALESCE(v.vendors_name, 'Unknown')
ORDER BY avg_distance_miles DESC
LIMIT 1;

-- Q43. Which vendor has the highest average trip duration?
SELECT
    COALESCE(v.vendors_name, 'Unknown') AS vendor,
    ROUND(AVG(f.trip_duration_min)::numeric, 2) AS avg_duration_min
FROM yellow_tripdata f
LEFT JOIN vendor_lookup v
    ON f.vendorid = v.vendorid
GROUP BY COALESCE(v.vendors_name, 'Unknown')
ORDER BY avg_duration_min DESC
LIMIT 1;

-- Q44. What percentage of trips are store-and-forward trips?
SELECT ROUND(
    COUNT(*) FILTER (WHERE store_and_fwd_flag = 'Y') * 100.0 / COUNT(*),
    2
) AS store_and_forward_trip_share_pct
FROM yellow_tripdata;

-- Q45. Which rate type has the highest average fare amount?
SELECT
    COALESCE(r.rate_type, 'Unknown') AS rate_type,
    ROUND(AVG(f.fare_amount)::numeric, 2) AS avg_fare
FROM yellow_tripdata f
LEFT JOIN ratecode_lookup r
    ON f.ratecodeid = r.ratecodeid
GROUP BY COALESCE(r.rate_type, 'Unknown')
ORDER BY avg_fare DESC
LIMIT 1;

-- SECTION 6 — ADVANCED ANALYTICS & MANAGEMENT QUESTIONS
-- ----------------------------------------------------------------------
-- Q46. What are the top 10 pickup zones by total revenue, along with their percentage contribution to total revenue?
WITH zone_revenue AS (
    SELECT
        COALESCE(z.zone, 'Unknown / Outside NYC') AS pickup_zone,
        SUM(COALESCE(f.total_amount, f.expected_total)) AS revenue
    FROM yellow_tripdata f
    LEFT JOIN taxi_zone_lookup z
        ON f.pulocationid = z.locationid
    GROUP BY COALESCE(z.zone, 'Unknown / Outside NYC')
),
total AS (
    SELECT SUM(revenue) AS total_revenue
    FROM zone_revenue
)
SELECT
    pickup_zone,
    ROUND(revenue::numeric, 2) AS total_revenue,
    ROUND(revenue * 100.0 / NULLIF(total_revenue, 0), 2) AS revenue_share_pct
FROM zone_revenue
CROSS JOIN total
ORDER BY revenue DESC
LIMIT 10;

-- Q47. For each pickup borough, what are total trips, total revenue, average trip amount, and revenue share?
WITH borough_kpi AS (
    SELECT
        COALESCE(z.borough, 'Unknown / Outside NYC') AS pickup_borough,
        COUNT(*) AS trips,
        SUM(COALESCE(f.total_amount, f.expected_total)) AS revenue,
        AVG(COALESCE(f.total_amount, f.expected_total)) AS avg_trip_amount
    FROM yellow_tripdata f
    LEFT JOIN taxi_zone_lookup z
        ON f.pulocationid = z.locationid
    GROUP BY COALESCE(z.borough, 'Unknown / Outside NYC')
)
SELECT
    pickup_borough,
    trips,
    ROUND(revenue::numeric, 2) AS total_revenue,
    ROUND(avg_trip_amount::numeric, 2) AS avg_trip_amount,
    ROUND(revenue * 100.0 / NULLIF(SUM(revenue) OVER (), 0), 2) AS revenue_share_pct
FROM borough_kpi
ORDER BY revenue DESC;

-- Q48. What are the top 10 routes by total revenue, and what is their average trip duration?
SELECT
    COALESCE(p.zone, 'Unknown / Outside NYC') AS pickup_zone,
    COALESCE(d.zone, 'Unknown / Outside NYC') AS dropoff_zone,
    ROUND(SUM(COALESCE(f.total_amount, f.expected_total))::numeric, 2) AS total_revenue,
    ROUND(AVG(f.trip_duration_min)::numeric, 2) AS avg_duration_min
FROM yellow_tripdata f
LEFT JOIN taxi_zone_lookup p
    ON f.pulocationid = p.locationid
LEFT JOIN taxi_zone_lookup d
    ON f.dolocationid = d.locationid
GROUP BY
    COALESCE(p.zone, 'Unknown / Outside NYC'),
    COALESCE(d.zone, 'Unknown / Outside NYC')
ORDER BY total_revenue DESC
LIMIT 10;

-- Q49. For each pickup hour, calculate trips, total revenue, average trip amount, and revenue per kilometer.
SELECT
    EXTRACT(HOUR FROM tpep_pickup_datetime)::int AS pickup_hour,
    COUNT(*) AS trips,
    ROUND(SUM(COALESCE(total_amount, expected_total))::numeric, 2) AS total_revenue,
    ROUND(AVG(COALESCE(total_amount, expected_total))::numeric, 2) AS avg_trip_amount,
    ROUND(
        SUM(COALESCE(total_amount, expected_total)) /
        NULLIF(SUM(trip_distance_km), 0)::numeric,
        2
    ) AS revenue_per_km
FROM yellow_tripdata
GROUP BY pickup_hour
ORDER BY pickup_hour;

-- Q50. Within each pickup borough, rank the top 3 pickup zones by trip volume using a window function.
WITH zone_trips AS (
    SELECT
        COALESCE(z.borough, 'Unknown / Outside NYC') AS pickup_borough,
        COALESCE(z.zone, 'Unknown / Outside NYC') AS pickup_zone,
        COUNT(*) AS trips
    FROM yellow_tripdata f
    LEFT JOIN taxi_zone_lookup z
        ON f.pulocationid = z.locationid
    GROUP BY
        COALESCE(z.borough, 'Unknown / Outside NYC'),
        COALESCE(z.zone, 'Unknown / Outside NYC')
),
ranked AS (
    SELECT
        pickup_borough,
        pickup_zone,
        trips,
        ROW_NUMBER() OVER (
            PARTITION BY pickup_borough
            ORDER BY trips DESC, pickup_zone
        ) AS zone_rank
    FROM zone_trips
)
SELECT
    pickup_borough,
    pickup_zone,
    trips,
    zone_rank
FROM ranked
WHERE zone_rank <= 3
ORDER BY pickup_borough, zone_rank;
