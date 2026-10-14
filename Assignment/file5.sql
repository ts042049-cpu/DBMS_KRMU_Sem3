CREATE TABLE CUSTOMER (
    Cust_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    Join_Date DATE NOT NULL
);

CREATE TABLE ORDERS (
    Order_ID INT PRIMARY KEY,
    Cust_ID INT,
    Order_Date DATE NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Cust_ID) REFERENCES CUSTOMER(Cust_ID) ON DELETE SET NULL
);

INSERT INTO CUSTOMER VALUES 
(1, 'Alice', 'Mumbai', '2023-01-10'),
(2, 'Bob', 'Mumbai', '2023-02-15'),
(3, 'Charlie', 'Delhi', '2023-03-20'),
(4, 'David', 'Delhi', '2023-04-25'),
(5, 'Eve', 'Mumbai', '2023-05-01'); 

INSERT INTO ORDERS VALUES 
(101, 1, '2024-01-05', 5000.00),
(102, 1, '2024-01-10', 12000.00),
(103, 2, '2024-01-12', 3000.00),
(104, 3, '2024-01-15', 15000.00),
(105, 4, '2024-01-18', 8000.00),
(106, NULL, '2024-01-20', 2000.00); 


SELECT * 
FROM CUSTOMER
WHERE Cust_ID IN (
    SELECT Cust_ID
    FROM ORDERS
    WHERE Amount > (SELECT AVG(Amount) FROM ORDERS)
);

SELECT * 
FROM CUSTOMER
WHERE Cust_ID NOT IN (
    SELECT Cust_ID 
    FROM ORDERS 
    WHERE Cust_ID IS NOT NULL
);

SELECT * 
FROM CUSTOMER c
WHERE NOT EXISTS (
    SELECT 1 
    FROM ORDERS o 
    WHERE o.Cust_ID = c.Cust_ID
);

SELECT c.City, c.Cust_ID, c.Name, SUM(o.Amount) AS Total_Order_Value
FROM CUSTOMER c
JOIN ORDERS o ON c.Cust_ID = o.Cust_ID
GROUP BY c.City, c.Cust_ID, c.Name
HAVING SUM(o.Amount) >= ALL (
    SELECT SUM(o2.Amount)
    FROM CUSTOMER c2
    JOIN ORDERS o2 ON c2.Cust_ID = o2.Cust_ID
    WHERE c2.City = c.City
    GROUP BY c2.Cust_ID
);