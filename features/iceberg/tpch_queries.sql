-- Official TPC-H Benchmark Queries (Q1–Q22)
-- Adapted for Iceberg demo: table names use iceberg_* views.
--
-- Prerequisites:
--   - Run 01_create_locations_tpch.sql (creates LOCATIONs for all 8 TPC-H tables).
--   - Run 02_create_view.sql (creates all 8 iceberg_* views: lineitem, orders, customer,
--     part, partsupp, supplier, nation, region).

USE iceberg_demo;

-- =============================================================================
-- Q1 - Pricing Summary Report
-- =============================================================================
SELECT
    l_returnflag,
    l_linestatus,
    sum(l_quantity) AS sum_qty,
    sum(l_extendedprice) AS sum_base_price,
    sum(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
    sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
    avg(l_quantity) AS avg_qty,
    avg(l_extendedprice) AS avg_price,
    avg(l_discount) AS avg_disc,
    count(*) AS count_order
FROM iceberg_lineitem
WHERE l_shipdate <= date '1998-12-01' - INTERVAL '90' day
GROUP BY l_returnflag, l_linestatus
ORDER BY l_returnflag, l_linestatus;

-- =============================================================================
-- Q2 - Minimum Cost Supplier
-- =============================================================================
SELECT
    s_acctbal,
    s_name,
    n_name,
    p_partkey,
    p_mfgr,
    s_address,
    s_phone,
    s_comment
FROM iceberg_part
JOIN iceberg_partsupp ON p_partkey = ps_partkey
JOIN iceberg_supplier ON s_suppkey = ps_suppkey
JOIN iceberg_nation ON s_nationkey = n_nationkey
JOIN iceberg_region ON n_regionkey = r_regionkey
WHERE p_size = 15
  AND p_type LIKE '%BRASS'
  AND r_name = 'EUROPE'
  AND ps_supplycost = (
      SELECT min(ps_supplycost)
      FROM iceberg_partsupp
      JOIN iceberg_supplier ON s_suppkey = ps_suppkey
      JOIN iceberg_nation ON s_nationkey = n_nationkey
      JOIN iceberg_region ON n_regionkey = r_regionkey
      WHERE p_partkey = ps_partkey
        AND r_name = 'EUROPE'
  )
ORDER BY s_acctbal DESC, n_name, s_name, p_partkey;

-- =============================================================================
-- Q3 - Shipping Priority
-- =============================================================================
SELECT
    l_orderkey,
    sum(l_extendedprice * (1 - l_discount)) AS revenue,
    o_orderdate,
    o_shippriority
FROM iceberg_customer
JOIN iceberg_orders ON c_custkey = o_custkey
JOIN iceberg_lineitem ON l_orderkey = o_orderkey
WHERE c_mktsegment = 'BUILDING'
  AND o_orderdate < date '1995-03-15'
  AND l_shipdate > date '1995-03-15'
GROUP BY l_orderkey, o_orderdate, o_shippriority
ORDER BY revenue DESC, o_orderdate;

-- =============================================================================
-- Q4 - Order Priority Checking
-- =============================================================================
SELECT
    o_orderpriority,
    count(*) AS order_count
FROM iceberg_orders
WHERE o_orderdate >= date '1993-07-01'
  AND o_orderdate < date '1993-07-01' + INTERVAL '3' month
  AND EXISTS (
      SELECT 1
      FROM iceberg_lineitem
      WHERE l_orderkey = o_orderkey
        AND l_commitdate < l_receiptdate
  )
GROUP BY o_orderpriority
ORDER BY o_orderpriority;

-- =============================================================================
-- Q5 - Local Supplier Volume
-- =============================================================================
SELECT
    n_name,
    sum(l_extendedprice * (1 - l_discount)) AS revenue
FROM iceberg_customer
JOIN iceberg_orders ON c_custkey = o_custkey
JOIN iceberg_lineitem ON l_orderkey = o_orderkey
JOIN iceberg_supplier ON l_suppkey = s_suppkey AND c_nationkey = s_nationkey
JOIN iceberg_nation ON s_nationkey = n_nationkey
JOIN iceberg_region ON n_regionkey = r_regionkey
WHERE r_name = 'ASIA'
  AND o_orderdate >= date '1994-01-01'
  AND o_orderdate < date '1994-01-01' + INTERVAL '1' year
GROUP BY n_name
ORDER BY revenue DESC;

-- =============================================================================
-- Q6 - Forecasting Revenue Change
-- =============================================================================
SELECT sum(l_extendedprice * l_discount) AS revenue
FROM iceberg_lineitem
WHERE l_shipdate >= date '1994-01-01'
  AND l_shipdate < date '1994-01-01' + INTERVAL '1' year
  AND l_discount BETWEEN 0.06 - 0.01 AND 0.06 + 0.01
  AND l_quantity < 24;

-- =============================================================================
-- Q7 - Volume Shipping
-- =============================================================================
SELECT
    supp_nation,
    cust_nation,
    l_year,
    sum(volume) AS revenue
FROM (
    SELECT
        n1.n_name AS supp_nation,
        n2.n_name AS cust_nation,
        extract(year FROM l_shipdate) AS l_year,
        l_extendedprice * (1 - l_discount) AS volume
    FROM iceberg_supplier
    JOIN iceberg_lineitem ON s_suppkey = l_suppkey
    JOIN iceberg_orders ON o_orderkey = l_orderkey
    JOIN iceberg_customer ON c_custkey = o_custkey
    JOIN iceberg_nation n1 ON s_nationkey = n1.n_nationkey
    JOIN iceberg_nation n2 ON c_nationkey = n2.n_nationkey
    WHERE ((n1.n_name = 'FRANCE' AND n2.n_name = 'GERMANY')
       OR (n1.n_name = 'GERMANY' AND n2.n_name = 'FRANCE'))
      AND l_shipdate BETWEEN date '1995-01-01' AND date '1996-12-31'
) AS shipping
GROUP BY supp_nation, cust_nation, l_year
ORDER BY supp_nation, cust_nation, l_year;

-- =============================================================================
-- Q8 - National Market Share
-- =============================================================================
SELECT
    o_year,
    sum(CASE WHEN nation = 'BRAZIL' THEN volume ELSE 0 END) / sum(volume) AS mkt_share
FROM (
    SELECT
        extract(year FROM o_orderdate) AS o_year,
        l_extendedprice * (1 - l_discount) AS volume,
        n2.n_name AS nation
    FROM iceberg_part
    JOIN iceberg_lineitem ON p_partkey = l_partkey
    JOIN iceberg_supplier ON s_suppkey = l_suppkey
    JOIN iceberg_orders ON l_orderkey = o_orderkey
    JOIN iceberg_customer ON o_custkey = c_custkey
    JOIN iceberg_nation n1 ON c_nationkey = n1.n_nationkey
    JOIN iceberg_nation n2 ON s_nationkey = n2.n_nationkey
    JOIN iceberg_region ON n1.n_regionkey = r_regionkey
    WHERE r_name = 'AMERICA'
      AND o_orderdate BETWEEN date '1995-01-01' AND date '1996-12-31'
      AND p_type = 'ECONOMY ANODIZED STEEL'
) AS all_nations
GROUP BY o_year
ORDER BY o_year;

-- =============================================================================
-- Q9 - Product Type Profit Measure
-- =============================================================================
SELECT
    nation,
    o_year,
    sum(amount) AS sum_profit
FROM (
    SELECT
        n_name AS nation,
        extract(year FROM o_orderdate) AS o_year,
        l_extendedprice * (1 - l_discount) - ps_supplycost * l_quantity AS amount
    FROM iceberg_part
    JOIN iceberg_lineitem ON p_partkey = l_partkey
    JOIN iceberg_supplier ON s_suppkey = l_suppkey
    JOIN iceberg_partsupp ON ps_suppkey = l_suppkey AND ps_partkey = l_partkey
    JOIN iceberg_orders ON o_orderkey = l_orderkey
    JOIN iceberg_nation ON s_nationkey = n_nationkey
    WHERE p_name LIKE '%green%'
) AS profit
GROUP BY nation, o_year
ORDER BY nation, o_year DESC;

-- =============================================================================
-- Q10 - Returned Item Reporting
-- =============================================================================
SELECT
    c_custkey,
    c_name,
    sum(l_extendedprice * (1 - l_discount)) AS revenue,
    c_acctbal,
    n_name,
    c_address,
    c_phone,
    c_comment
FROM iceberg_customer
JOIN iceberg_orders ON c_custkey = o_custkey
JOIN iceberg_lineitem ON l_orderkey = o_orderkey
JOIN iceberg_nation ON c_nationkey = n_nationkey
WHERE o_orderdate >= date '1993-10-01'
  AND o_orderdate < date '1993-10-01' + INTERVAL '3' month
  AND l_returnflag = 'R'
GROUP BY c_custkey, c_name, c_acctbal, c_phone, n_name, c_address, c_comment
ORDER BY revenue DESC;

-- =============================================================================
-- Q11 - Important Stock Identification
-- =============================================================================
SELECT
    ps_partkey,
    sum(ps_supplycost * ps_availqty) AS value
FROM iceberg_partsupp
JOIN iceberg_supplier ON ps_suppkey = s_suppkey
JOIN iceberg_nation ON s_nationkey = n_nationkey
WHERE n_name = 'SAUDI ARABIA'
GROUP BY ps_partkey
HAVING sum(ps_supplycost * ps_availqty) > (
    SELECT sum(ps_supplycost * ps_availqty) * 0.0000000333
    FROM iceberg_partsupp
    JOIN iceberg_supplier ON ps_suppkey = s_suppkey
    JOIN iceberg_nation ON s_nationkey = n_nationkey
    WHERE n_name = 'SAUDI ARABIA'
)
ORDER BY value DESC;

-- =============================================================================
-- Q12 - Shipping Modes and Order Priority
-- =============================================================================
SELECT
    l_shipmode,
    sum(CASE WHEN o_orderpriority = '1-URGENT' OR o_orderpriority = '2-HIGH' THEN 1 ELSE 0 END) AS high_line_count,
    sum(CASE WHEN o_orderpriority <> '1-URGENT' AND o_orderpriority <> '2-HIGH' THEN 1 ELSE 0 END) AS low_line_count
FROM iceberg_orders
JOIN iceberg_lineitem ON o_orderkey = l_orderkey
WHERE l_shipmode IN ('MAIL', 'SHIP')
  AND l_commitdate < l_receiptdate
  AND l_shipdate < l_commitdate
  AND l_receiptdate >= date '1994-01-01'
  AND l_receiptdate < date '1994-01-01' + INTERVAL '1' year
GROUP BY l_shipmode
ORDER BY l_shipmode;

-- =============================================================================
-- Q13 - Customer Distribution
-- =============================================================================
SELECT
    c_count,
    count(*) AS custdist
FROM (
    SELECT
        c_custkey,
        count(o_orderkey) AS c_count
    FROM iceberg_customer
    LEFT OUTER JOIN iceberg_orders ON c_custkey = o_custkey AND o_comment NOT LIKE '%special%requests%'
    GROUP BY c_custkey
) AS c_orders
GROUP BY c_count
ORDER BY custdist DESC, c_count DESC;

-- =============================================================================
-- Q14 - Promotion Effect
-- =============================================================================
SELECT
    100.00 * sum(CASE WHEN p_type LIKE 'PROMO%' THEN l_extendedprice * (1 - l_discount) ELSE 0 END)
        / sum(l_extendedprice * (1 - l_discount)) AS promo_revenue
FROM iceberg_lineitem
JOIN iceberg_part ON l_partkey = p_partkey
WHERE l_shipdate >= date '1995-09-01'
  AND l_shipdate < date '1995-09-01' + INTERVAL '1' month;

-- =============================================================================
-- Q15 - Top Supplier
-- =============================================================================
SELECT
    s_suppkey,
    s_name,
    s_address,
    s_phone,
    total_revenue
FROM iceberg_supplier
JOIN (
    SELECT
        l_suppkey AS supplier_no,
        sum(l_extendedprice * (1 - l_discount)) AS total_revenue
    FROM iceberg_lineitem
    WHERE l_shipdate >= date '1996-01-01'
      AND l_shipdate < date '1996-01-01' + INTERVAL '3' month
    GROUP BY l_suppkey
) AS revenue ON s_suppkey = supplier_no
WHERE total_revenue = (
    SELECT max(total_revenue)
    FROM (
        SELECT
            l_suppkey AS supplier_no,
            sum(l_extendedprice * (1 - l_discount)) AS total_revenue
        FROM iceberg_lineitem
        WHERE l_shipdate >= date '1996-01-01'
          AND l_shipdate < date '1996-01-01' + INTERVAL '3' month
        GROUP BY l_suppkey
    ) AS revenue
)
ORDER BY s_suppkey;

-- =============================================================================
-- Q16 - Parts/Supplier Relationship
-- =============================================================================
SELECT
    p_brand,
    p_type,
    p_size,
    count(DISTINCT ps_suppkey) AS supplier_cnt
FROM iceberg_partsupp
JOIN iceberg_part ON p_partkey = ps_partkey
WHERE p_brand <> 'Brand#45'
  AND p_type NOT LIKE 'MEDIUM POLISHED%'
  AND p_size IN (49, 14, 23, 45, 19, 3, 36, 9)
  AND ps_suppkey NOT IN (
      SELECT s_suppkey
      FROM iceberg_supplier
      WHERE s_comment LIKE '%Customer%Complaints%'
  )
GROUP BY p_brand, p_type, p_size
ORDER BY supplier_cnt DESC, p_brand, p_type, p_size;

-- =============================================================================
-- Q17 - Small-Quantity-Order Revenue
-- =============================================================================
SELECT sum(l_extendedprice) / 7.0 AS avg_yearly
FROM iceberg_lineitem
JOIN iceberg_part ON p_partkey = l_partkey
WHERE p_brand = 'Brand#23'
  AND p_container = 'MED BOX'
  AND l_quantity < (
      SELECT 0.2 * avg(l_quantity)
      FROM iceberg_lineitem
      WHERE l_partkey = p_partkey
  );

-- =============================================================================
-- Q18 - Large Volume Customer
-- =============================================================================
SELECT
    c_name,
    c_custkey,
    o_orderkey,
    o_orderdate,
    o_totalprice,
    sum(l_quantity) AS quantity
FROM iceberg_customer
JOIN iceberg_orders ON c_custkey = o_custkey
JOIN iceberg_lineitem ON o_orderkey = l_orderkey
WHERE o_orderkey IN (
    SELECT l_orderkey
    FROM iceberg_lineitem
    GROUP BY l_orderkey
    HAVING sum(l_quantity) > 300
)
GROUP BY c_name, c_custkey, o_orderkey, o_orderdate, o_totalprice
ORDER BY o_totalprice DESC, o_orderdate;

-- =============================================================================
-- Q19 - Discounted Revenue
-- =============================================================================
SELECT sum(l_extendedprice * (1 - l_discount)) AS revenue
FROM iceberg_lineitem
JOIN iceberg_part ON p_partkey = l_partkey
WHERE (p_brand = 'Brand#12'
  AND p_container IN ('SM CASE', 'SM BOX', 'SM PACK', 'SM PKG')
  AND l_quantity >= 1 AND l_quantity <= 1 + 10
  AND p_size BETWEEN 1 AND 5
  AND l_shipmode IN ('AIR', 'AIR REG')
  AND l_shipinstruct = 'DELIVER IN PERSON')
OR (p_brand = 'Brand#23'
  AND p_container IN ('MED BAG', 'MED BOX', 'MED PKG', 'MED PACK')
  AND l_quantity >= 10 AND l_quantity <= 10 + 10
  AND p_size BETWEEN 1 AND 10
  AND l_shipmode IN ('AIR', 'AIR REG')
  AND l_shipinstruct = 'DELIVER IN PERSON')
OR (p_brand = 'Brand#34'
  AND p_container IN ('LG CASE', 'LG BOX', 'LG PACK', 'LG PKG')
  AND l_quantity >= 20 AND l_quantity <= 20 + 10
  AND p_size BETWEEN 1 AND 15
  AND l_shipmode IN ('AIR', 'AIR REG')
  AND l_shipinstruct = 'DELIVER IN PERSON');

-- =============================================================================
-- Q20 - Potential Part Promotion
-- =============================================================================
SELECT
    s_name,
    s_address
FROM iceberg_supplier
JOIN iceberg_nation ON s_nationkey = n_nationkey
WHERE s_suppkey IN (
    SELECT ps_suppkey
    FROM iceberg_partsupp
    WHERE ps_partkey IN (
        SELECT p_partkey
        FROM iceberg_part
        WHERE p_name LIKE 'forest%'
    )
    AND ps_availqty > (
        SELECT 0.5 * sum(l_quantity)
        FROM iceberg_lineitem
        WHERE l_partkey = ps_partkey
          AND l_suppkey = ps_suppkey
          AND l_shipdate >= date '1994-01-01'
          AND l_shipdate < date '1994-01-01' + INTERVAL '1' year
    )
)
AND n_name = 'CANADA'
ORDER BY s_name;

-- =============================================================================
-- Q21 - Suppliers Who Kept Orders Waiting
-- =============================================================================
SELECT
    s_name,
    count(*) AS numwait
FROM iceberg_supplier
JOIN iceberg_lineitem l1 ON s_suppkey = l1.l_suppkey
JOIN iceberg_orders ON o_orderkey = l1.l_orderkey
JOIN iceberg_nation ON s_nationkey = n_nationkey
WHERE o_orderstatus = 'F'
  AND l1.l_receiptdate > l1.l_commitdate
  AND EXISTS (
      SELECT 1
      FROM iceberg_lineitem l2
      WHERE l2.l_orderkey = l1.l_orderkey
        AND l2.l_suppkey <> l1.l_suppkey
  )
  AND NOT EXISTS (
      SELECT 1
      FROM iceberg_lineitem l3
      WHERE l3.l_orderkey = l1.l_orderkey
        AND l3.l_suppkey <> l1.l_suppkey
        AND l3.l_receiptdate > l3.l_commitdate
  )
  AND n_name = 'SAUDI ARABIA'
GROUP BY s_name
ORDER BY numwait DESC, s_name;

-- =============================================================================
-- Q22 - Global Sales Opportunity
-- =============================================================================
SELECT
    cntrycode,
    count(*) AS numcust,
    sum(c_acctbal) AS totacctbal
FROM (
    SELECT
        substring(c_phone FROM 1 FOR 2) AS cntrycode,
        c_acctbal
    FROM iceberg_customer
    WHERE substring(c_phone FROM 1 FOR 2) IN ('13', '31', '23', '29', '30', '18', '17')
      AND c_acctbal > (
          SELECT avg(c_acctbal)
          FROM iceberg_customer
          WHERE c_acctbal > 0.00
            AND substring(c_phone FROM 1 FOR 2) IN ('13', '31', '23', '29', '30', '18', '17')
      )
      AND NOT EXISTS (
          SELECT 1
          FROM iceberg_orders
          WHERE o_custkey = c_custkey
      )
) AS custsale
GROUP BY cntrycode
ORDER BY cntrycode;
