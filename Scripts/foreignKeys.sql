USE classicmodels;

-- Employees Table Relationships
ALTER TABLE Employees
ADD CONSTRAINT fk_officeCode
FOREIGN KEY (officeCode) REFERENCES Offices(officeCode) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Employees
ADD CONSTRAINT fk_reportsTo
FOREIGN KEY (reportsTo) REFERENCES Employees(employeeNumber) ON DELETE SET NULL ON UPDATE CASCADE;

-- Customers Table Relationships
ALTER TABLE Customers
ADD CONSTRAINT fk_salesRepEmployeeNumber
FOREIGN KEY (salesRepEmployeeNumber) REFERENCES Employees(employeeNumber) ON DELETE SET NULL ON UPDATE CASCADE;

-- Orders Table Relationships
ALTER TABLE Orders
ADD CONSTRAINT fk_customerNumber
FOREIGN KEY (customerNumber) REFERENCES Customers(customerNumber) ON DELETE CASCADE ON UPDATE CASCADE;

-- OrderDetails Table Relationships
ALTER TABLE OrderDetails
ADD CONSTRAINT fk_orderNumber
FOREIGN KEY (orderNumber) REFERENCES Orders(orderNumber) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE OrderDetails
ADD CONSTRAINT fk_productCode
FOREIGN KEY (productCode) REFERENCES Products(productCode) ON DELETE CASCADE ON UPDATE CASCADE;

-- Payments Table Relationships
ALTER TABLE Payments
ADD CONSTRAINT fk_payment_customerNumber
FOREIGN KEY (customerNumber) REFERENCES Customers(customerNumber) ON DELETE CASCADE ON UPDATE CASCADE;

-- Products Table Relationships
ALTER TABLE Products
ADD CONSTRAINT fk_productLine
FOREIGN KEY (productLine) REFERENCES ProductLines(productLine) ON DELETE CASCADE ON UPDATE CASCADE;
