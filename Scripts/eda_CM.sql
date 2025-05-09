USE classicmodels;

-- Exploratory data analysis
-- Check for Total Sales by Year
SELECT 
    YEAR(OrderDate) AS year, 
    SUM(OrderDetails.priceEach * OrderDetails.quantityOrdered) AS totalSales
FROM Orders
JOIN OrderDetails USING (orderNumber)
GROUP BY YEAR(OrderDate)
ORDER BY YEAR(OrderDate);

-- Check for Average Shipping Time by Region
SELECT 
    Offices.territory, 
    AVG(DATEDIFF(Orders.shippedDate, Orders.orderDate)) AS avgShippingTime
FROM Orders
JOIN Customers USING (customerNumber)
JOIN Employees ON Customers.salesRepEmployeeNumber = Employees.employeeNumber
JOIN Offices ON Employees.officeCode = Offices.officeCode
GROUP BY Offices.territory;

SELECT 
    Orders.status, 
    COUNT(Orders.orderNumber) AS totalOrders,
    ROUND((COUNT(Orders.orderNumber) * 100.0 / (SELECT COUNT(*) FROM Orders)), 2) AS percentage
FROM Orders
GROUP BY Orders.status
ORDER BY percentage DESC;

-- Check for nulls in key tables
SELECT 'Orders' AS tableName, COUNT(*) AS nullCount
FROM Orders
WHERE OrderDate IS NULL OR customerNumber IS NULL
UNION ALL
SELECT 'OrderDetails', COUNT(*)
FROM OrderDetails
WHERE orderNumber IS NULL OR productCode IS NULL
UNION ALL
SELECT 'Customers', COUNT(*)
FROM Customers
WHERE customerName IS NULL OR salesRepEmployeeNumber IS NULL;

-- Check for duplicate orders
SELECT orderNumber, COUNT(*) AS duplicateCount
FROM Orders
GROUP BY orderNumber
HAVING COUNT(*) > 1;

-- Check for duplicate customers
SELECT customerNumber, COUNT(*) AS duplicateCount
FROM Customers
GROUP BY customerNumber
HAVING COUNT(*) > 1;

-- Detect outliers in priceEach
SELECT 
    productCode, 
    priceEach, 
    COUNT(*) 
FROM OrderDetails
GROUP BY productCode, priceEach
HAVING priceEach < 0 OR priceEach > 1000;

-- Check for unusually high or low order quantities
SELECT 
    orderNumber, 
    productCode, 
    quantityOrdered 
FROM OrderDetails
WHERE quantityOrdered < 1 OR quantityOrdered > 1000;

SELECT 
    YEAR(OrderDate) AS year, 
    SUM(OrderDetails.priceEach * OrderDetails.quantityOrdered) AS totalSales
FROM Orders
JOIN OrderDetails USING (orderNumber)
GROUP BY YEAR(OrderDate);

SELECT 
    Products.productCode, 
    Products.productName
FROM Products
LEFT JOIN OrderDetails USING (productCode)
WHERE OrderDetails.productCode IS NULL;

SELECT 
    Customers.territory, 
    AVG(DATEDIFF(Orders.shippedDate, Orders.orderDate)) AS avgShippingTime
FROM Orders
JOIN Customers USING (customerNumber)
WHERE Customers.territory = 'Japan'
GROUP BY Customers.territory;

