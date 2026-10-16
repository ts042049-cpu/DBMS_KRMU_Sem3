CREATE TABLE SALES (
    Sale_ID INT PRIMARY KEY,
    Region VARCHAR(50),
    Salesperson VARCHAR(50),
    Sale_Date DATE,
    Amount DECIMAL(10, 2)
);

INSERT INTO SALES (Sale_ID, Region, Salesperson, Sale_Date, Amount) VALUES
(1, 'North', 'Alice', '2024-01-05', 500.00),
(2, 'North', 'Alice', '2024-01-15', 700.00),
(3, 'North', 'Bob', '2024-01-10', 1200.00),
(4, 'North', 'Charlie', '2024-02-01', 800.00),
(5, 'South', 'David', '2024-01-12', 1500.00),
(6, 'South', 'Eve', '2024-01-20', 1500.00),
(7, 'South', 'David', '2024-02-10', 600.00),
(8, 'South', 'Frank', '2024-02-15', 400.00),
(9, 'South', 'Eve', '2024-02-18', 900.00);

SELECT 
    Region,
    Salesperson,
    SUM(Amount) AS Total_Sales,
    DENSE_RANK() OVER (
        PARTITION BY Region 
        ORDER BY SUM(Amount) DESC
    ) AS Sales_Rank
FROM SALES
GROUP BY Region, Salesperson;

WITH MonthlySales AS (
    SELECT 
        Region,
        DATE_FORMAT(Sale_Date, '%Y-%m-01') AS Sale_Month,
        SUM(Amount) AS Monthly_Total
    FROM SALES
    GROUP BY Region, DATE_FORMAT(Sale_Date, '%Y-%m-01')
)
SELECT 
    Region,
    Sale_Month,
    Monthly_Total,
    SUM(Monthly_Total) OVER (
        PARTITION BY Region 
        ORDER BY Sale_Month 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Running_Total
FROM MonthlySales;

WITH SalesWithLag AS (
    SELECT 
        Sale_ID,
        Salesperson,
        Sale_Date,
        Amount,
        LAG(Amount, 1, 0) OVER (
            PARTITION BY Salesperson 
            ORDER BY Sale_Date
        ) AS Previous_Sale_Amount
    FROM SALES
)
SELECT 
    Sale_ID,
    Salesperson,
    Sale_Date,
    Amount,
    Previous_Sale_Amount,
    CASE 
        WHEN Previous_Sale_Amount = 0 THEN 0
        ELSE ROUND(((Amount - Previous_Sale_Amount) / Previous_Sale_Amount) * 100, 2)
    END AS Percentage_Change
FROM SalesWithLag;

WITH RankedSalespersons AS (
    SELECT 
        Region,
        Salesperson,
        SUM(Amount) AS Total_Sales,
        DENSE_RANK() OVER (
            PARTITION BY Region 
            ORDER BY SUM(Amount) DESC
        ) AS Sales_Rank
    FROM SALES
    GROUP BY Region, Salesperson
)
SELECT 
    Region,
    Salesperson,
    Total_Sales,
    Sales_Rank
FROM RankedSalespersons
WHERE Sales_Rank <= 3;