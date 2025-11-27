-- 1. Standardize quantity values, Handle missing quantity values

SELECT DISTINCT Quantity
FROM Warehouse.dbo.warehouse_messy_data
ORDER BY Quantity;

SELECT DISTINCT Quantity
FROM Warehouse.dbo.warehouse_messy_data
WHERE TRY_CAST(Quantity AS INT) IS NULL;

UPDATE Warehouse.dbo.warehouse_messy_data
SET Quantity = NULL
WHERE Quantity = 'NaN';

UPDATE Warehouse.dbo.warehouse_messy_data
SET Quantity = 200
WHERE Quantity = 'two hundred';

ALTER TABLE Warehouse.dbo.warehouse_messy_data
ALTER COLUMN Quantity INT;

SELECT *
FROM Warehouse.dbo.warehouse_messy_data
WHERE TRY_CAST(Quantity AS INT) IS NULL;

UPDATE w
SET Quantity = CAST(f.Avg_Quantity AS INT)
FROM Warehouse.dbo.warehouse_messy_data w
JOIN (
    SELECT Product_Name,
           AVG(CAST(Quantity AS FLOAT)) AS Avg_Quantity
    FROM Warehouse.dbo.warehouse_messy_data
    WHERE Quantity IS NOT NULL
    GROUP BY Product_Name
) f
ON w.Product_Name = f.Product_Name
WHERE w.Quantity IS NULL;
-- 2. Clean inconsistent product names

SELECT DISTINCT Product_Name
FROM Warehouse.dbo.warehouse_messy_data;

UPDATE Warehouse.dbo.warehouse_messy_data
SET Product_Name = LTRIM(RTRIM(Product_Name));


-- 3. Standardize category values
SELECT DISTINCT Category
FROM Warehouse.dbo.warehouse_messy_data;

UPDATE Warehouse.dbo.warehouse_messy_data
SET Category = UPPER(LEFT(Category, 1)) + LOWER(SUBSTRING(Category, 2, LEN(Category)-1));

-- 4.Validate Product ID uniqueness

SELECT COUNT(Product_ID)
FROM Warehouse.dbo.warehouse_messy_data;

SELECT COUNT(DISTINCT(Product_ID))
FROM Warehouse.dbo.warehouse_messy_data;

SELECT *
FROM Warehouse.dbo.warehouse_messy_data
WHERE Product_ID IN (
SELECT Product_ID
FROM Warehouse.dbo.warehouse_messy_data
GROUP BY Product_ID
HAVING COUNT(*) > 1)
ORDER BY Product_ID DESC;


ALTER TABLE Warehouse.dbo.warehouse_messy_data
ADD New_Product_ID INT IDENTITY(1,1);

SELECT Product_ID, New_Product_ID, Product_Name, Category
FROM Warehouse.dbo.warehouse_messy_data
ORDER BY New_Product_ID;

-- 5.Clean the 'Price' column 

SELECT DISTINCT(Price)
FROM Warehouse.dbo.warehouse_messy_data;

UPDATE Warehouse.dbo.warehouse_messy_data
SET Price = NULL
WHERE Price = 'NaN';

ALTER TABLE Warehouse.dbo.warehouse_messy_data
ALTER COLUMN Price DECIMAL(10, 2);

SELECT *
FROM Warehouse.dbo.warehouse_messy_data
WHERE TRY_CAST(Price AS DECIMAL) IS NULL
AND Price IS NOT NULL;

UPDATE b
SET Price = CAST(c.Avg_Price AS float)
FROM Warehouse.dbo.warehouse_messy_data b
JOIN(
SELECT Product_Name,
AVG(CAST(Price AS FLOAT)) AS Avg_Price
FROM Warehouse.dbo.warehouse_messy_data
WHERE Price IS NOT NULL
GROUP BY Product_Name) c
ON b.Product_Name = c.Product_Name
WHERE b.Price IS NULL;

-- 6. Detect inconsistent product information 
SELECT *
FROM Warehouse.dbo.warehouse_messy_data
WHERE Product_Name IN (
SELECT Product_Name
FROM Warehouse.dbo.warehouse_messy_data
GROUP BY Product_Name
HAVING COUNT(DISTINCT Category) > 1
OR COUNT(DISTINCT Supplier) > 1 
OR COUNT(DISTINCT Price) > 1)
ORDER BY Product_Name;

UPDATE Warehouse.dbo.warehouse_messy_data
SET Product_Name = LEFT(Product_Name, LEN(Product_Name) - 1);

UPDATE Warehouse.dbo.warehouse_messy_data
SET Product_Name = LEFT(Product_Name, LEN(Product_Name) - 1)  
                   + UPPER(RIGHT(Product_Name, 1));
SELECT Product_Name
FROM Warehouse.dbo.warehouse_messy_data;

-- 7. Standardize supplier names
-- -- All supplier names are already correctly formatted, no standardization needed
SELECT DISTINCT(Supplier)
FROM Warehouse.dbo.warehouse_messy_data;

-- 8. Clean the "Status" column

-- -- All status values in the dataset are already consistent and correctly formatted. No changes or standardization are required.
SELECT DISTINCT(Status)
FROM Warehouse.dbo.warehouse_messy_data;


-- 9. Convert "Last Restocked" to date format

SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'warehouse_messy_data'
  AND COLUMN_NAME = 'Last_Restocked';

SELECT *
FROM Warehouse.dbo.warehouse_messy_data
WHERE TRY_CONVERT(DATE, Last_Restocked, 103) IS NULL
AND Last_Restocked IS NOT NULL
AND LTRIM(RTRIM(Last_Restocked)) <> '';

UPDATE Warehouse.dbo.warehouse_messy_data
SET Last_Restocked = NULL
WHERE Last_Restocked = 'NaN';

ALTER TABLE Warehouse.dbo.warehouse_messy_data
ADD Last_Restocked_Date DATE;

UPDATE Warehouse.dbo.warehouse_messy_data
SET Last_Restocked_Date = TRY_CONVERT(DATE, Last_Restocked, 103);

SELECT Last_Restocked_Date
FROM Warehouse.dbo.warehouse_messy_data;

ALTER TABLE Warehouse.dbo.warehouse_messy_data
DROP COLUMN Last_Restocked;


SELECT * 
FROM Warehouse.dbo.warehouse_messy_data;
 

-- 10. Detect possible inventory errors


SELECT *
FROM Warehouse.dbo.warehouse_messy_data
WHERE 
(Quantity > 0 AND Status = 'Out of Stock')
OR 
((Quantity IS NULL OR Quantity = 0) AND Status IN ('In Stock', 'Low Stock'));

SELECT MIN(Quantity), MAX(Quantity)
FROM Warehouse.dbo.warehouse_messy_data;


ALTER TABLE Warehouse.dbo.warehouse_messy_data
ADD Stock_Level NVARCHAR(50);

UPDATE Warehouse.dbo.warehouse_messy_data
SET Stock_Level = CASE
WHEN Quantity IS NULL THEN 'Out of Stock'
WHEN Quantity < 150 THEN 'Low Stock'
ELSE 'In Stock'
END;

SELECT *
FROM Warehouse.dbo.warehouse_messy_data;

ALTER TABLE Warehouse.dbo.warehouse_messy_data
DROP COLUMN Status;


SELECT *
INTO Warehouse.dbo.warehouse_clean_data
FROM Warehouse.dbo.warehouse_messy_data;

