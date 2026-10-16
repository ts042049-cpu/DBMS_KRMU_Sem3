CREATE TABLE DOCTOR (
    Doc_ID INT PRIMARY KEY,
    Doc_Name VARCHAR(100) NOT NULL,
    Specialization VARCHAR(50) NOT NULL
);

CREATE TABLE PATIENT (
    Pat_ID INT PRIMARY KEY,
    Pat_Name VARCHAR(100) NOT NULL,
    Doc_ID INT,
    Admit_Date DATE NOT NULL,
    Bill_Amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Doc_ID) REFERENCES DOCTOR(Doc_ID) ON DELETE SET NULL
);

INSERT INTO DOCTOR VALUES 
(101, 'Dr. Sharma', 'Cardiology'),
(102, 'Dr. Mehta', 'Cardiology'),
(103, 'Dr. Gupta', 'Orthopedics');

INSERT INTO PATIENT VALUES 
(1, 'John Doe', 101, '2024-02-01', 60000.00),
(2, 'Jane Smith', 101, '2024-02-05', 50000.00),
(3, 'Mark Taylor', 102, '2024-02-10', 15000.00),
(4, 'Lucy Heart', 103, '2024-02-12', 12000.00),
(5, 'Sam Brown', 103, '2024-02-14', 11000.00);


SELECT p1.Pat_ID, p1.Pat_Name, p1.Doc_ID, p1.Bill_Amount
FROM PATIENT p1
WHERE p1.Bill_Amount > (
    SELECT AVG(p2.Bill_Amount)
    FROM PATIENT p2
    WHERE p2.Doc_ID = p1.Doc_ID
);

SELECT * 
FROM DOCTOR d
WHERE 10000 < ALL (
    SELECT p.Bill_Amount
    FROM PATIENT p
    WHERE p.Doc_ID = d.Doc_ID
);

SELECT * 
FROM DOCTOR d
WHERE NOT EXISTS (
    SELECT 1 
    FROM PATIENT p
    WHERE p.Doc_ID = d.Doc_ID 
      AND p.Bill_Amount <= 10000
);

SELECT 
    summary.Specialization,
    summary.Doctor_Count,
    summary.Total_Bill
FROM (
    SELECT 
        d.Specialization,
        COUNT(DISTINCT d.Doc_ID) AS Doctor_Count,
        SUM(p.Bill_Amount) AS Total_Bill
    FROM DOCTOR d
    JOIN PATIENT p ON d.Doc_ID = p.Doc_ID
    GROUP BY d.Specialization
) summary
WHERE summary.Total_Bill > 100000;