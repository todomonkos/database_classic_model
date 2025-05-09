CREATE SCHEMA ClassicModelsDW;
USE ClassicModelsDW;

-- CUSTOMER DIMENSION TABLE
-- Create `dim_customers` table
CREATE TABLE dim_customers (
    customerNumber INT PRIMARY KEY,
    customerName VARCHAR(50),
    salesRepEmployeeNumber INT,
    creditLimit DOUBLE
);

-- Insert into the `dim_customers` table
INSERT INTO dim_customers
SELECT DISTINCT
    customerNumber,
    customerName,
    salesRepEmployeeNumber,
    creditLimit
FROM classicmodels.Customers;

-- PRODUCTS DIMENSION TABLE
-- Create `dim_products` table
CREATE TABLE dim_products (
    productCode VARCHAR(15) PRIMARY KEY,
    productName VARCHAR(70),
    productLine VARCHAR(50),
    productVendor VARCHAR(50),
    productScale VARCHAR(10),
    productDescription TEXT,
    MSRP DOUBLE
);

-- Insert into the `dim_products` table
INSERT INTO dim_products
SELECT DISTINCT
    productCode,
    productName,
    productLine,
    productVendor,
    productScale,
    productDescription,
    MSRP
FROM classicmodels.Products;

-- ORDERS DIMENSION TABLE
-- Create `dim_orders` table
CREATE TABLE dim_orders (
    orderNumber INT PRIMARY KEY,
    orderDate DATE,
    requiredDate DATE,
    shippedDate DATE,
    status VARCHAR(15),
    customerNumber INT
);
-- Insert into the `dim_orders` table
INSERT INTO dim_orders
SELECT DISTINCT
    orderNumber,
    orderDate,
    requiredDate,
    shippedDate,
    status,
    customerNumber
FROM classicmodels.Orders;

-- TIME DIMENSION TABLE
-- Create `dim_time` table
CREATE TABLE dim_time (
    date DATE PRIMARY KEY,
    year INT,
    month INT,
    quarter INT,
    day INT,
    week INT
);

-- Insert into the `dim_time` table
INSERT INTO dim_time
SELECT DISTINCT
    orderDate AS date,
    YEAR(orderDate) AS year,
    MONTH(orderDate) AS month,
    QUARTER(orderDate) AS quarter,
    DAY(orderDate) AS day,
    WEEK(orderDate) AS week
FROM classicmodels.Orders;

-- REGIONS DIMENSION TABLE
-- Create `dim_regions` table
CREATE TABLE dim_regions (
    officeCode VARCHAR(10) PRIMARY KEY,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    territory VARCHAR(10)
);

-- Insert into the `dim_regions` table
INSERT INTO dim_regions
SELECT DISTINCT
    officeCode,
    city,
    state,
    country,
    territory
FROM classicmodels.Offices;

-- EMPLOYEES DIMESNION TABLE
-- Create `dim_employees` table
CREATE TABLE dim_employees (
    employeeNumber INT PRIMARY KEY,
    lastName VARCHAR(50),
    firstName VARCHAR(50),
    jobTitle VARCHAR(50),
    officeCode VARCHAR(10)
);

INSERT INTO dim_employees
SELECT DISTINCT
    employeeNumber,
    lastName,
    firstName,
    jobTitle,
    officeCode
FROM classicmodels.Employees;

-- FACT TABLE
-- Create `fact_sales` table
CREATE TABLE fact_sales (
    orderNumber INT,
    productCode VARCHAR(15),
    productLine VARCHAR(50),
    quantityOrdered INT,
    unit_price DOUBLE,
    total_revenue DOUBLE,
    total_profit DOUBLE,
    orderDate DATE,
    customerNumber INT,
    salesRepEmployeeNumber INT,
    officeCode VARCHAR(10),
    PRIMARY KEY (orderNumber, productCode)
);

-- Inserting into `fact_sales` table
INSERT INTO fact_sales
SELECT 
    od.orderNumber,
    od.productCode, 
    p.productLine,
    od.quantityOrdered,
    od.priceEach AS unit_price,
    (od.quantityOrdered * od.priceEach) AS total_revenue,
    (od.quantityOrdered * (p.MSRP - od.priceEach)) AS total_profit,
    o.orderDate,
    c.customerNumber,
    c.salesRepEmployeeNumber,
    e.officeCode
FROM classicmodels.OrderDetails od
JOIN classicmodels.Orders o ON od.orderNumber = o.orderNumber
JOIN classicmodels.Products p ON od.productCode = p.productCode
JOIN classicmodels.Customers c ON o.customerNumber = c.customerNumber
JOIN classicmodels.Employees e ON c.salesRepEmployeeNumber = e.employeeNumber;

-- INSERTING FOREIGN KEYS FOR IMPROVED REFERNTIAL INTEGRITY
-- Fact Sales → Dim Orders
ALTER TABLE fact_sales
ADD CONSTRAINT fk_fact_sales_orderNumber
FOREIGN KEY (orderNumber) REFERENCES dim_orders(orderNumber);

-- Fact Sales → Dim Products
ALTER TABLE fact_sales
ADD CONSTRAINT fk_fact_sales_productCode
FOREIGN KEY (productCode) REFERENCES dim_products(productCode);

-- Fact Sales → Dim Time
ALTER TABLE fact_sales
ADD CONSTRAINT fk_fact_sales_orderDate
FOREIGN KEY (orderDate) REFERENCES dim_time(date);

-- Fact Sales → Dim Customers
ALTER TABLE fact_sales
ADD CONSTRAINT fk_fact_sales_customerNumber
FOREIGN KEY (customerNumber) REFERENCES dim_customers(customerNumber);

-- Fact Sales → Dim Employees
ALTER TABLE fact_sales
ADD CONSTRAINT fk_fact_sales_salesRepEmployeeNumber
FOREIGN KEY (salesRepEmployeeNumber) REFERENCES dim_employees(employeeNumber);

-- Fact Sales → Dim Regions
ALTER TABLE fact_sales
ADD CONSTRAINT fk_fact_sales_officeCode
FOREIGN KEY (officeCode) REFERENCES dim_regions(officeCode);

-- Dim Customers → Dim Employees
ALTER TABLE dim_customers
ADD CONSTRAINT fk_dim_customers_salesRepEmployeeNumber
FOREIGN KEY (salesRepEmployeeNumber) REFERENCES dim_employees(employeeNumber);

-- Dim Employees → Dim Regions
ALTER TABLE dim_employees
ADD CONSTRAINT fk_dim_employees_officeCode
FOREIGN KEY (officeCode) REFERENCES dim_regions(officeCode);

-- ADDING INDECIES FOR IMPORVED QUERY PERFORMANCE
-- Adding indecies on primary keys
CREATE UNIQUE INDEX idx_customerNumber ON dim_customers(customerNumber);
CREATE UNIQUE INDEX idx_productCode ON dim_products(productCode);
CREATE UNIQUE INDEX idx_orderNumber ON dim_orders(orderNumber);
CREATE UNIQUE INDEX idx_date ON dim_time(date);
CREATE UNIQUE INDEX idx_officeCode ON dim_regions(officeCode);
CREATE UNIQUE INDEX idx_employeeNumber ON dim_employees(employeeNumber);

-- Adding foreign key indexes 
CREATE INDEX idx_fact_sales_customerNumber ON fact_sales(customerNumber);
CREATE INDEX idx_fact_sales_productCode ON fact_sales(productCode);
CREATE INDEX idx_fact_sales_orderDate ON fact_sales(orderDate);
CREATE INDEX idx_fact_sales_officeCode ON fact_sales(officeCode);
CREATE INDEX idx_fact_sales_salesRepEmployeeNumber ON fact_sales(salesRepEmployeeNumber);

