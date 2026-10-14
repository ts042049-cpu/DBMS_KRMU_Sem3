CREATE TABLE PRODUCT (
    Prod_ID INT PRIMARY KEY,
    Prod_Name VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE ORDERS (
    Order_ID INT PRIMARY KEY,
    Order_Date DATE NOT NULL,
    Cust_ID INT NOT NULL
);

CREATE TABLE ORDER_ITEM (
    Order_ID INT,
    Prod_ID INT,
    Qty INT NOT NULL,
    PRIMARY KEY (Order_ID, Prod_ID),
    FOREIGN KEY (Order_ID) REFERENCES ORDERS(Order_ID),
    FOREIGN KEY (Prod_ID) REFERENCES PRODUCT(Prod_ID)
);

INSERT INTO PRODUCT VALUES 
(1, 'Laptop', 'Electronics', 1000.00),
(2, 'Mouse', 'Electronics', 25.00);

INSERT INTO ORDERS VALUES 
(101, CURRENT_DATE - INTERVAL 1 DAY, 501);

INSERT INTO ORDER_ITEM VALUES 
(101, 1, 2),
(101, 2, 5);

CREATE VIEW PRODUCT_SALES AS
SELECT 
    p.Prod_Name, 
    p.Category, 
    SUM(oi.Qty) AS Total_Qty, 
    SUM(oi.Qty * p.Price) AS Total_Revenue
FROM PRODUCT p
JOIN ORDER_ITEM oi ON p.Prod_ID = oi.Prod_ID
JOIN ORDERS o ON oi.Order_ID = o.Order_ID
WHERE o.Order_Date = CURRENT_DATE - INTERVAL 1 DAY
GROUP BY p.Prod_ID, p.Prod_Name, p.Category;

CREATE TABLE PRODUCT_SALES_SUMMARY AS
SELECT 
    p.Prod_Name, 
    p.Category, 
    SUM(oi.Qty) AS Total_Qty, 
    SUM(oi.Qty * p.Price) AS Total_Revenue
FROM PRODUCT p
JOIN ORDER_ITEM oi ON p.Prod_ID = oi.Prod_ID
JOIN ORDERS o ON oi.Order_ID = o.Order_ID
WHERE o.Order_Date = CURRENT_DATE - INTERVAL 1 DAY
GROUP BY p.Prod_ID, p.Prod_Name, p.Category;