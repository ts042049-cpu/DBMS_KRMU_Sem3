CREATE TABLE ACCOUNT (
    Acc_No INT PRIMARY KEY,
    Cust_Name VARCHAR(100) NOT NULL,
    Branch_Code VARCHAR(10) NOT NULL,
    Balance DECIMAL(12, 2) NOT NULL,
    PIN VARCHAR(6) NOT NULL,
    Aadhaar_No VARCHAR(12) NOT NULL,
    Opened_On DATE NOT NULL
);
CREATE USER 'mumbai_manager'@'localhost' IDENTIFIED BY 'Password@123';

CREATE VIEW mumbai_accounts AS 
SELECT Acc_No, Cust_Name, Branch_Code, Balance, Opened_On
FROM ACCOUNT
WHERE Branch_Code = 'MUM';
GRANT SELECT ON mumbai_accounts TO 'mumbai_manager'@'localhost';

CREATE VIEW BRANCH_TOTALS AS
SELECT 
    Branch_Code, 
    COUNT(Acc_No) AS Total_Accounts, 
    SUM(Balance) AS Total_Balance
FROM ACCOUNT
GROUP BY Branch_Code;

CREATE VIEW mumbai_accounts AS
SELECT Acc_No, Cust_Name, Branch_Code, Balance, Opened_On
FROM ACCOUNT
WHERE Branch_Code = 'MUM'
WITH CHECK OPTION;