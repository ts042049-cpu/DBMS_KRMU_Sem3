CREATE TABLE TRANSACTIONS (
    Txn_ID INT PRIMARY KEY,
    Acc_No INT NOT NULL,
    Txn_Date DATE NOT NULL,
    Txn_Type CHAR(1) CHECK (Txn_Type IN ('D', 'W')),
    Amount DECIMAL(10, 2) NOT NULL
);

-- Sample Data Insertion
INSERT INTO TRANSACTIONS (Txn_ID, Acc_No, Txn_Date, Txn_Type, Amount) VALUES
(1, 1001, '2026-01-05', 'D', 1000.00),
(2, 1001, '2026-01-15', 'W', 200.00),
(3, 1001, '2026-02-10', 'W', 900.00),
(4, 1002, '2026-01-12', 'D', 500.00),
(5, 1002, '2026-01-20', 'W', 700.00);

-- (a) Using two CTEs to compute monthly total deposits and total withdrawals
WITH MonthlyDeposits AS (
    SELECT 
        Acc_No, 
        DATE_FORMAT(Txn_Date, '%Y-%m-01') AS Txn_Month, 
        SUM(Amount) AS Total_Deposits
    FROM TRANSACTIONS
    WHERE Txn_Type = 'D'
    GROUP BY Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01')
),
MonthlyWithdrawals AS (
    SELECT 
        Acc_No, 
        DATE_FORMAT(Txn_Date, '%Y-%m-01') AS Txn_Month, 
        SUM(Amount) AS Total_Withdrawals
    FROM TRANSACTIONS
    WHERE Txn_Type = 'W'
    GROUP BY Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01')
)
SELECT * FROM MonthlyDeposits;


WITH MonthlyDeposits AS (
    SELECT 
        Acc_No, 
        DATE_FORMAT(Txn_Date, '%Y-%m-01') AS Txn_Month, 
        SUM(Amount) AS Total_Deposits
    FROM TRANSACTIONS
    WHERE Txn_Type = 'D'
    GROUP BY Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01')
),
MonthlyWithdrawals AS (
    SELECT 
        Acc_No, 
        DATE_FORMAT(Txn_Date, '%Y-%m-01') AS Txn_Month, 
        SUM(Amount) AS Total_Withdrawals
    FROM TRANSACTIONS
    WHERE Txn_Type = 'W'
    GROUP BY Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01')
),
NetMonthlyChange AS (
    SELECT 
        d.Acc_No AS Acc_No,
        d.Txn_Month AS Txn_Month,
        d.Total_Deposits AS Total_Deposits,
        COALESCE(w.Total_Withdrawals, 0) AS Total_Withdrawals,
        (d.Total_Deposits - COALESCE(w.Total_Withdrawals, 0)) AS Net_Change
    FROM MonthlyDeposits d
    LEFT JOIN MonthlyWithdrawals w 
        ON d.Acc_No = w.Acc_No AND d.Txn_Month = w.Txn_Month

    UNION

    SELECT 
        w.Acc_No AS Acc_No,
        w.Txn_Month AS Txn_Month,
        COALESCE(d.Total_Deposits, 0) AS Total_Deposits,
        w.Total_Withdrawals AS Total_Withdrawals,
        (COALESCE(d.Total_Deposits, 0) - w.Total_Withdrawals) AS Net_Change
    FROM MonthlyDeposits d
    RIGHT JOIN MonthlyWithdrawals w 
        ON d.Acc_No = w.Acc_No AND d.Txn_Month = w.Txn_Month
)
SELECT * FROM NetMonthlyChange
ORDER BY Acc_No, Txn_Month;


-- (c) Flag 'OVERDRAWN' and compute Running Balance via Window Function
WITH MonthlyDeposits AS (
    SELECT 
        Acc_No, 
        DATE_FORMAT(Txn_Date, '%Y-%m-01') AS Txn_Month, 
        SUM(Amount) AS Total_Deposits
    FROM TRANSACTIONS
    WHERE Txn_Type = 'D'
    GROUP BY Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01')
),
MonthlyWithdrawals AS (
    SELECT 
        Acc_No, 
        DATE_FORMAT(Txn_Date, '%Y-%m-01') AS Txn_Month, 
        SUM(Amount) AS Total_Withdrawals
    FROM TRANSACTIONS
    WHERE Txn_Type = 'W'
    GROUP BY Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01')
),
NetMonthlyChange AS (
    SELECT 
        d.Acc_No AS Acc_No,
        d.Txn_Month AS Txn_Month,
        d.Total_Deposits AS Total_Deposits,
        COALESCE(w.Total_Withdrawals, 0) AS Total_Withdrawals,
        (d.Total_Deposits - COALESCE(w.Total_Withdrawals, 0)) AS Net_Change
    FROM MonthlyDeposits d
    LEFT JOIN MonthlyWithdrawals w 
        ON d.Acc_No = w.Acc_No AND d.Txn_Month = w.Txn_Month

    UNION

    SELECT 
        w.Acc_No AS Acc_No,
        w.Txn_Month AS Txn_Month,
        COALESCE(d.Total_Deposits, 0) AS Total_Deposits,
        w.Total_Withdrawals AS Total_Withdrawals,
        (COALESCE(d.Total_Deposits, 0) - w.Total_Withdrawals) AS Net_Change
    FROM MonthlyDeposits d
    RIGHT JOIN MonthlyWithdrawals w 
        ON d.Acc_No = w.Acc_No AND d.Txn_Month = w.Txn_Month
)
SELECT 
    Acc_No,
    Txn_Month,
    Total_Deposits,
    Total_Withdrawals,
    Net_Change,
    CASE 
        WHEN Total_Withdrawals > Total_Deposits THEN 'OVERDRAWN'
        ELSE 'OK'
    END AS Status,
    SUM(Net_Change) OVER (
        PARTITION BY Acc_No 
        ORDER BY Txn_Month 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Running_Balance
FROM NetMonthlyChange
ORDER BY Acc_No, Txn_Month;


-- (d) Derived Table Version (Subqueries in FROM)
SELECT 
    d.Acc_No AS Acc_No,
    d.Txn_Month AS Txn_Month,
    d.Total_Deposits AS Total_Deposits,
    COALESCE(w.Total_Withdrawals, 0) AS Total_Withdrawals
FROM (
    SELECT Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01') AS Txn_Month, SUM(Amount) AS Total_Deposits
    FROM TRANSACTIONS
    WHERE Txn_Type = 'D'
    GROUP BY Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01')
) d
LEFT JOIN (
    SELECT Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01') AS Txn_Month, SUM(Amount) AS Total_Withdrawals
    FROM TRANSACTIONS
    WHERE Txn_Type = 'W'
    GROUP BY Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01')
) w ON d.Acc_No = w.Acc_No AND d.Txn_Month = w.Txn_Month

UNION

SELECT 
    w.Acc_No AS Acc_No,
    w.Txn_Month AS Txn_Month,
    COALESCE(d.Total_Deposits, 0) AS Total_Deposits,
    w.Total_Withdrawals AS Total_Withdrawals
FROM (
    SELECT Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01') AS Txn_Month, SUM(Amount) AS Total_Deposits
    FROM TRANSACTIONS
    WHERE Txn_Type = 'D'
    GROUP BY Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01')
) d
RIGHT JOIN (
    SELECT Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01') AS Txn_Month, SUM(Amount) AS Total_Withdrawals
    FROM TRANSACTIONS
    WHERE Txn_Type = 'W'
    GROUP BY Acc_No, DATE_FORMAT(Txn_Date, '%Y-%m-01')
) w ON d.Acc_No = w.Acc_No AND d.Txn_Month = w.Txn_Month;