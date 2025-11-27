# Warehouse Data Cleaning Project

## Overview
This project demonstrates data cleaning on a warehouse dataset using SQL. 
The goal was to fix common data quality issues and create a clean dataset ready for analysis.

## Dataset
- `warehouse_raw.csv` — original dataset  
- `warehouse_clean.csv` — cleaned dataset  
- Key columns: Product_ID, Product_Name, Category, Warehouse, Location, Quantity, Price, Supplier, Status, Last_Restocked

## Steps Taken
1. Standardized quantity and price, handled missing values  
2. Cleaned and standardized product names and categories  
3. Checked for duplicate Product_IDs and inconsistencies  
4. Converted dates to proper format  
5. Detected inventory errors and created a `Stock_Level` column  
6. Exported final cleaned dataset

## Files
- `data/` — CSV files  
- `sql/` — SQL queries for cleaning  
- `reports/` — explanation of cleaning steps

## Tools
SQL Server, Git & GitHub
