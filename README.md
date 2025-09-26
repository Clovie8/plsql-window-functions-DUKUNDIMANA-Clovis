# plsql-window-functions-DUKUNDIMANA-Clovis

### 1. Problem
**Business Context:** This check is for Rwanda Bean Masters, a group that sends coffee all around, from Kigali, Rwanda. The data is in the hands of the Sales and Marketing team, who look over sales within the country, in many areas.

**Data Challenge:** The company gets a lot of sale data yet doesn't have the right tools to make sense of it. They struggle to spot the best-selling items in main areas, see how sales change each month, or break down their customers for special deals.

**Insights:** This study will give clear tips to help manage stock by filling up on items that many want. It will guide the marketing plan by pointing out which groups of buyers bring in the most money. Also, it will aid leaders to check on how well the business is doing by looking at growth over time.



### 2. Schema 
![image alt](https://github.com/Clovie8/plsql-window-functions-DUKUNDIMANA-Clovis/blob/21e0baa5b98d6578b26983dee0ebd5dcd2bb0ee8/Screenshots/ER%20Diagram.png)
### 3. Queries
<pre>
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
</pre>

    
### 4. References

- Oracle Corporation. (2023). Oracle Database SQL Language Reference, 23c. Retrieved from https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/

- https://www.youtube.com/watch?v=Ww71knvhQ-s

- https://www.youtube.com/watch?v=rIcB4zMYMas

- Celko, J. (2012). Joe Celko's SQL for Smarties: Advanced SQL Programming. Morgan Kaufmann.

- Itzik, B. (2020). T-SQL Window Functions: For data analysis and beyond. Itzik Ben-Gan.

- Sharma, N., et al. (2010). PL/SQL for Developers: A Programmer's Guide to Oracle PL/SQL. O'Reilly Media.
  
- https://www.youtube.com/watch?v=J5wjIf4gdq4&list=PLWPirh4EWFpHj0kKqqYudPNOrGEa0fFIr

- Molinaro, A. (2006). SQL Cookbook: Query Solutions and Techniques for All SQL Users. O'Reilly Media.

- "Window Functions in SQL." GeeksforGeeks, 2023, https://www.geeksforgeeks.org/window-functions-in-sql/.

- https://www.youtube.com/watch?v=xofpqdU3cD4

- Date, C. J. (2004). An Introduction to Database Systems (8th ed.). Addison-Wesley.

- "LAG Function in Oracle." Oracle Tutorial, https://www.oracletutorial.com/oracle-analytic-functions/oracle-lag/

- Feuerstein, S., & Pribyl, B. (2014). Oracle PL/SQL Programming (6th ed.). O'Reilly Media.
