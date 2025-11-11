-- Step 1. Imported 4 CSV files into 4 separate tables in PostgreSQL, through GUI (pgAdmin).
-- Tables Imported: sales_Canada, sales_US, sales_UK, sales_India

-- Step 2. Combined the 4 tables into a single consolidated table named 'Sales Data'
CREATE TABLE public."Sales Data" as
select * from public."Sales Canada"
UNION ALL
SELECT * FROM public."Sales India"
UNION ALL
SELECT * FROM public."Sales UK"
UNION ALL
SELECT * FROM public."Sales US"

-- Step 3. Handled missing values 
-- Identified missing values in key columns
SELECT * 
FROM public."Sales Data"
WHERE
    "Country" IS NULL
	OR "Price Per Unit" IS NULL
	OR "Quantity Purchased" IS NULL
	OR "Cost Price" IS NULL

-- Updated missing values with mean values
UPDATE public."Sales Data"
SET "Price Per Unit" = (
    SELECT AVG("Price Per Unit")
    FROM public."Sales Data"
    WHERE "Price Per Unit" IS NOT NULL
)
WHERE "Price Per Unit" IS NULL

--  Step 5. Handled duplicates
-- Identified duplicates based on Transaction ID
SELECT "Transaction ID", Count(*)
FROM public."Sales Data"
GROUP BY "Transaction ID"
HAVING count(*)>1;

-- Removed duplicates, keeping the first occurrence based on Transaction ID
DELETE FROM public."Sales Data" a 
USING public."Sales Data" b
WHERE a.ctid < b.ctid       
AND a."Transaction ID" = b."Transaction ID";


-- Step 6. Added "Total Amount" column
ALTER TABLE public."Sales Data"
ADD COLUMN "Total Amount" NUMERIC(10,2);

UPDATE public."Sales Data"
SET "Total Amount" = ("Price Per Unit" * "Quantity Purchased") - "Discount Applied";

-- Step 7. Added "Profit" column
ALTER TABLE public."Sales Data"
ADD COLUMN "Profit" NUMERIC(10,2);

UPDATE public."Sales Data"
SET "Profit" = "Total Amount" - ("Cost Price" * "Quantity Purchased");

-- Step 8. Final check for missing values
SELECT *                                                    
FROM public."Sales Data"
WHERE
    "Country" IS NULL
    OR "Price Per Unit" IS NULL
    OR "Quantity Purchased" IS NULL
    OR "Cost Price" IS NULL;

-- No records returned, indicating no missing values remain

-- Step 9. Sales Revenue & Profit by Country  for October 2025
SELECT 
    "Country",
    SUM("Total Amount") AS "Total Revenue",
    SUM("Profit") AS "Total Profit"     
FROM public."Sales Data"
WHERE "Date" BETWEEN  '2025-10-01' AND '2025-10-31'
GROUP BY "Country"
ORDER BY "Total Revenue" DESC;

-- Step 10. Top 5 Best Selling Products for October 2025
SELECT 
    "Product Name",
    SUM("Quantity Purchased") AS "Total Units Sold",
    FROM public."Sales Data"
WHERE "Date" BETWEEN '2025-10-01' AND '2025-10-31'
GROUP BY "Product Name"         
ORDER BY "Total Units Sold" DESC
LIMIT 5;

-- Step 11. Top 5 Sales Representative for October 2025
SELECT "Sales Representative",
    SUM("Total Amount") AS "Total Sales"
    FROM public."Sales Data"    
    WHERE "Date" BETWEEN '2025-10-01' AND '2025-10-31'
    GROUP BY "Sales Representative "
    ORDER BY "Total Sales" DESC
    LIMIT 5;

-- Step 12. Top 5 Highest Sales Store Locations for October 2025
SELECT "Store Location",
    SUM("Total Amount") AS "Total Sales",
    SUM("Profit") AS "Total Profit"
    FROM public."Sales Data"    
    WHERE "Date" BETWEEN '2025-10-01' AND '2025-10-31'
    GROUP BY "Store Location"
    ORDER BY "Total Sales" DESC
    LIMIT 5;

-- Step 13. Key sales and Profit Insight for October 2025
SELECT 
    MIN("Total Amount") AS "Min Sales Value",
    MAX("Total Amount") AS "Max Sales Value",
    AVG("Total Amount") AS "Avg Sales Value",
    SUM("Total Amount") AS "Total Sales Value",
    MIN("Profit") AS "Min Profit",
    MAX("Profit") AS "Max Profit",
    AVG("Profit") AS "Avg Profit",
    SUM("Profit") AS "Total Profit"
FROM public."Sales Data"
 WHERE "Date" BETWEEN '2025-10-01' AND '2025-10-31'

