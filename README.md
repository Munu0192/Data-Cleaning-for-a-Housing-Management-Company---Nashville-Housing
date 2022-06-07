# Data-Cleaning-for-a-Housing-Management-Company---Nashville-Housing
In this assignment, I have cleaned data of a housing company known as Nashville Housing using different functions in SQL.

•	Task 1 – Standardized the date format by removing the time from it. For this we have used ALTER TABLE.

•	Task 2 – Is to populate the property address data that are showing NULL value. For this we have used ISNULL(), JOIN and UPDATE.

•	Task 3 – Segregating the Address column into sub-columns. For this we have used SUBSTRING(), CHARINDEX(), LEN() and then added new columns using ALTER TABLE & ADD. Using UPDATE we will provide the desired outcome.
•	Alternatively, it can be done with PARSENAME & REPLACE.

•	Task 4 – Using CASE Statement to change the ‘Y’ and ‘N’ to ‘Yes’ and ‘No’.

•	Task 5 – Remove duplicates, using CTE, ROW_NUMBER()

•	Task 6 – Delete unused columns, using ALTER TABLE and DROP.
