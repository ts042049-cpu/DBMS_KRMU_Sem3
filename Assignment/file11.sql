CREATE TABLE CATEGORY (
    Cat_ID INT PRIMARY KEY,
    Cat_Name VARCHAR(100) NOT NULL,
    Parent_Cat_ID INT,
    FOREIGN KEY (Parent_Cat_ID) REFERENCES CATEGORY(Cat_ID)
);

CREATE TABLE PRODUCT (
    Prod_ID INT PRIMARY KEY,
    Prod_Name VARCHAR(100) NOT NULL,
    Cat_ID INT,
    FOREIGN KEY (Cat_ID) REFERENCES CATEGORY(Cat_ID)
);

INSERT INTO CATEGORY (Cat_ID, Cat_Name, Parent_Cat_ID) VALUES
(1, 'Electronics', NULL),
(2, 'Mobiles', 1),
(3, 'Smartphones', 2),
(4, 'Android Phones', 3),
(5, 'Laptops', 1),
(6, 'Gaming Laptops', 5);

INSERT INTO PRODUCT (Prod_ID, Prod_Name, Cat_ID) VALUES
(101, 'Pixel 8', 4),
(102, 'Galaxy S23', 4),
(103, 'iPhone 15', 3),
(104, 'ROG Strix', 6),
(105, 'MacBook Pro', 5);

WITH RECURSIVE CategoryTree AS (
    -- Anchor Member
    SELECT 
        Cat_ID, 
        Cat_Name, 
        Parent_Cat_ID, 
        0 AS depth, 
        CAST(Cat_Name AS CHAR(1000)) AS full_path
    FROM CATEGORY
    WHERE Cat_Name = 'Electronics'

    UNION ALL

    -- Recursive Member
    SELECT 
        c.Cat_ID, 
        c.Cat_Name, 
        c.Parent_Cat_ID, 
        ct.depth + 1, 
        CAST(CONCAT(ct.full_path, ' > ', c.Cat_Name) AS CHAR(1000))
    FROM CATEGORY c
    JOIN CategoryTree ct ON c.Parent_Cat_ID = ct.Cat_ID
)
SELECT Cat_ID, Cat_Name, depth, full_path 
FROM CategoryTree;

WITH RECURSIVE CategorySubtree AS (
    -- Pair every category with itself (depth 0)
    SELECT Cat_ID AS Ancestor_ID, Cat_ID AS Descendant_ID
    FROM CATEGORY

    UNION ALL

    -- Recursively pair every category with all lower descendants
    SELECT cs.Ancestor_ID, c.Cat_ID AS Descendant_ID
    FROM CategorySubtree cs
    JOIN CATEGORY c ON c.Parent_Cat_ID = cs.Descendant_ID
)
SELECT 
    c.Cat_ID, 
    c.Cat_Name, 
    COUNT(p.Prod_ID) AS Total_Product_Count
FROM CATEGORY c
JOIN CategorySubtree cs ON c.Cat_ID = cs.Ancestor_ID
LEFT JOIN PRODUCT p ON p.Cat_ID = cs.Descendant_ID
GROUP BY c.Cat_ID, c.Cat_Name
ORDER BY c.Cat_ID;