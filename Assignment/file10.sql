CREATE TABLE STUDENT_MARKS (
    Roll_No INT,
    Student_Name VARCHAR(50),
    Subject VARCHAR(50),
    Marks INT,
    PRIMARY KEY (Roll_No, Subject)
);

INSERT INTO STUDENT_MARKS (Roll_No, Student_Name, Subject, Marks) VALUES
(101, 'Alex', 'DBMS', 95),
(102, 'Blake', 'DBMS', 95),
(103, 'Chris', 'DBMS', 85),
(104, 'Dana', 'DBMS', 70),
(105, 'Evan', 'DBMS', 60),
(101, 'Alex', 'OS', 90),
(102, 'Blake', 'OS', 82),
(103, 'Chris', 'OS', 78),
(101, 'Alex', 'Networks', 88),
(104, 'Dana', 'Networks', 88);

SELECT 
    Roll_No,
    Student_Name,
    Subject,
    Marks,
    FIRST_VALUE(Marks) OVER (
        PARTITION BY Subject 
        ORDER BY Marks DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS Highest_Marks,
    ROUND(Marks - AVG(Marks) OVER (PARTITION BY Subject), 2) AS Diff_From_Avg
FROM STUDENT_MARKS;

WITH SubjectRanks AS (
    SELECT 
        Roll_No,
        Student_Name,
        Subject,
        DENSE_RANK() OVER (
            PARTITION BY Subject 
            ORDER BY Marks DESC
        ) AS Subject_Rank
    FROM STUDENT_MARKS
)
SELECT 
    Roll_No,
    Student_Name
FROM SubjectRanks
WHERE Subject_Rank = 1
GROUP BY Roll_No, Student_Name
HAVING COUNT(Subject) > 1;

WITH PerformanceBands AS (
    SELECT 
        Roll_No,
        Student_Name,
        Subject,
        NTILE(4) OVER (
            PARTITION BY Subject 
            ORDER BY Marks DESC
        ) AS Performance_Band
    FROM STUDENT_MARKS
)
SELECT 
    COUNT(*) AS Band_1_DBMS_Student_Count
FROM PerformanceBands
WHERE Subject = 'DBMS' 
  AND Performance_Band = 1;