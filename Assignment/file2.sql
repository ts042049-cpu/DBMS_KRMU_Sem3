CREATE TABLE STAFF_A (
    Emp_Code INT PRIMARY KEY,
    Full_Name VARCHAR(50),
    Email VARCHAR(50),
    Dept VARCHAR(50)
);

CREATE TABLE STAFF_B (
    Emp_Code INT PRIMARY KEY,
    Full_Name VARCHAR(50),
    Email VARCHAR(50),
    Dept VARCHAR(50)
);

INSERT INTO STAFF_A VALUES 
(1, 'John Doe', 'john@company.com', 'HR'),
(2, 'Jane Smith', 'jane@company.com', 'IT');

INSERT INTO STAFF_B VALUES 
(101, 'Johnathan Doe', 'john@company.com', 'Operations'),
(102, 'Alex Ray', 'alex@company.com', 'Finance');

SELECT Email FROM STAFF_A
WHERE Email IN (SELECT Email FROM STAFF_B);

SELECT Full_Name, Email, Dept FROM STAFF_A
UNION
SELECT Full_Name, Email, Dept FROM STAFF_B
ORDER BY Full_Name;

SELECT Email FROM STAFF_B
WHERE Email NOT IN (SELECT Email FROM STAFF_A);

SELECT Full_Name, Email, Dept, 'A' AS Source FROM STAFF_A
UNION ALL
SELECT Full_Name, Email, Dept, 'B' AS Source FROM STAFF_B;