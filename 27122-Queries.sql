-- 3: DATABASE SCHEMA
-- ==================

-- Table for storing customer information
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    name        VARCHAR2(100),
    region      VARCHAR2(50) 
);

-- Table for the product catalog
CREATE TABLE products (
    product_id  NUMBER PRIMARY KEY,
    name        VARCHAR2(100),
    category    VARCHAR2(50) 
);

-- Table for recording all sales transactions
CREATE TABLE transactions (
    transaction_id NUMBER PRIMARY KEY,
    customer_id    NUMBER,
    product_id     NUMBER,
    sale_date      DATE,
    amount         NUMBER(10, 2),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_product  FOREIGN KEY (product_id)  REFERENCES products(product_id)
);


-- INSERTING DATA INTO DATABASE TABLE. 
-- __________________________________

-- Insert data into the 'customers' table
INSERT INTO customers (customer_id, name, region) VALUES (101, 'Inzozi Cafe', 'Kigali');
INSERT INTO customers (customer_id, name, region) VALUES (102, 'Bourbon Coffee', 'Kigali');
INSERT INTO customers (customer_id, name, region) VALUES (103, 'Question Coffee', 'Eastern');
INSERT INTO customers (customer_id, name, region) VALUES (104, 'Shokola Cafe', 'Western');
INSERT INTO customers (customer_id, name, region) VALUES (105, 'Cafe Neo', 'Kigali');

-- Insert data into the 'products' table
INSERT INTO products (product_id, name, category) VALUES (201, 'Arabica Beans (1kg)', 'Coffee Beans');
INSERT INTO products (product_id, name, category) VALUES (202, 'Robusta Beans (1kg)', 'Coffee Beans');
INSERT INTO products (product_id, name, category) VALUES (203, 'Branded Mugs', 'Merchandise');
INSERT INTO products (product_id, name, category) VALUES (204, 'Espresso Machine Cleaner', 'Supplies');

-- Insert data into the 'transactions' table
-- Note: TO_DATE function is used for Oracle SQL compatibility.
-- JANUARY 2024 Sales (Total: 90,000)
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3001, 101, 201, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 45000);
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3002, 103, 201, TO_DATE('2024-01-20', 'YYYY-MM-DD'), 25000);
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3003, 104, 202, TO_DATE('2024-01-25', 'YYYY-MM-DD'), 20000);

-- FEBRUARY 2024 Sales (Total: 110,000)
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3004, 102, 201, TO_DATE('2024-02-10', 'YYYY-MM-DD'), 60000);
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3005, 105, 203, TO_DATE('2024-02-18', 'YYYY-MM-DD'), 28000);
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3006, 101, 202, TO_DATE('2024-02-22', 'YYYY-MM-DD'), 22000);

-- MARCH 2024 Sales (Total: 105,000)
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3007, 103, 201, TO_DATE('2024-03-05', 'YYYY-MM-DD'), 55000);
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3008, 104, 203, TO_DATE('2024-03-15', 'YYYY-MM-DD'), 50000);

-- APRIL 2024 Sales (Total: 125,000)
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3009, 101, 201, TO_DATE('2024-04-12', 'YYYY-MM-DD'), 58000);
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3010, 102, 202, TO_DATE('2024-04-20', 'YYYY-MM-DD'), 40000);
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3011, 105, 204, TO_DATE('2024-04-28', 'YYYY-MM-DD'), 27000);

-- MAY 2024 Sales (Total: 130,000)
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3012, 103, 201, TO_DATE('2024-05-09', 'YYYY-MM-DD'), 40000);
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3013, 101, 203, TO_DATE('2024-05-19', 'YYYY-MM-DD'), 30000);
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3014, 102, 201, TO_DATE('2024-05-21', 'YYYY-MM-DD'), 20000);
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3015, 104, 202, TO_DATE('2024-05-25', 'YYYY-MM-DD'), 25000);
INSERT INTO transactions (transaction_id, customer_id, product_id, sale_date, amount) VALUES (3016, 105, 201, TO_DATE('2024-05-30', 'YYYY-MM-DD'), 15000);

COMMIT;






-- 4. WINDOWS FUNCTION IMPLEMENTATION
-- ==================================

-- 1. Ranking Functions
-- This query ranks customers by their total sales amount.
-- ROW_NUMBER(): Assigns a unique number to each row.
-- RANK(): Assigns a rank with gaps for ties.
-- DENSE_RANK(): Assigns a rank without gaps for ties.
-- PERCENT_RANK(): Shows the relative rank of the current row.
SELECT
    c.name,
    SUM(t.amount) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(t.amount) DESC) AS row_num_rank,
    RANK() OVER (ORDER BY SUM(t.amount) DESC) AS rank_with_gaps,
    DENSE_RANK() OVER (ORDER BY SUM(t.amount) DESC) AS dense_rank_no_gaps,
    TO_CHAR(PERCENT_RANK() OVER (ORDER BY SUM(t.amount) DESC) * 100, '990.99') || '%' AS percentile_rank
FROM
    transactions t
JOIN
    customers c ON t.customer_id = c.customer_id
GROUP BY
    c.name
ORDER BY
    total_revenue DESC;



-- 2. Aggregate Functions
-- This query calculates monthly sales, a cumulative running total for the year,
-- and a 3-month moving average to show trends.
-- The ROWS BETWEEN 2 PRECEDING AND CURRENT ROW clause defines the moving window.
WITH monthly_sales AS (
    SELECT
        TRUNC(sale_date, 'MM') AS sale_month,
        SUM(amount) AS monthly_total
    FROM
        transactions
    GROUP BY
        TRUNC(sale_date, 'MM')
)
SELECT
    TO_CHAR(sale_month, 'YYYY-MM') AS month,
    monthly_total,
    SUM(monthly_total) OVER (ORDER BY sale_month) AS running_total,
    AVG(monthly_total) OVER (ORDER BY sale_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3m
FROM
    monthly_sales
ORDER BY
    sale_month;



-- 3. Navigation Functions
-- This query uses the LAG function to fetch the previous month's sales
-- and calculate the percentage growth from one month to the next.
WITH monthly_sales AS (
    SELECT
        TRUNC(sale_date, 'MM') AS sale_month,
        SUM(amount) AS monthly_total
    FROM
        transactions
    GROUP BY
        TRUNC(sale_date, 'MM')
)
SELECT
    TO_CHAR(sale_month, 'YYYY-MM') AS month,
    monthly_total,
    LAG(monthly_total, 1, 0) OVER (ORDER BY sale_month) AS previous_month_sales,
    TO_CHAR(
        ((monthly_total - LAG(monthly_total, 1, 0) OVER (ORDER BY sale_month)) / LAG(monthly_total, 1, 1) OVER (ORDER BY sale_month)) * 100,
        '990.99'
    ) || '%' AS mom_growth
FROM
    monthly_sales
ORDER BY
    sale_month;



-- 4. Distribution Functions
-- This query uses NTILE(4) to divide customers into four quartiles
-- and CUME_DIST to show the cumulative distribution of customers.
WITH customer_revenue AS (
    SELECT
        c.name,
        SUM(t.amount) AS total_revenue
    FROM
        transactions t
    JOIN
        customers c ON t.customer_id = c.customer_id
    GROUP BY
        c.name
)
SELECT
    name,
    total_revenue,
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS spending_quartile,
    CUME_DIST() OVER (ORDER BY total_revenue DESC) AS cumulative_distribution
FROM
    customer_revenue
ORDER BY
    total_revenue DESC;