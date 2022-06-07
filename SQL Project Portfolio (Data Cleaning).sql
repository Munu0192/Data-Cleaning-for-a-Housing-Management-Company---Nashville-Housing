-- 1) Cleaning Data in SQL Queries
Select *
From [dbo].[Nashville Housing]




-- 2) Standardize Date Format (Here we can see that SaleDate is having time as well and we dont want that)

Select [SaleDate], Convert(Date, [SaleDate])    --Here we will use CONVERT where we will convert SaleDate into Date format from datetime format
From [dbo].[Nashville Housing]

ALTER TABLE [dbo].[Nashville Housing] --Here we actually changed the data type of SaleDate from datetime to date only
Alter column [SaleDate] date

--Alternative Way (But it doesnt work most of the time)
Update [dbo].[Nashville Housing]     --So, we need to update the SaleDate in date format only in our main table, but by this coding process its not happening
SET SaleDate = Convert(Date, [SaleDate])





-- 3) Populate Property Address Data (Its saying that there are some PropertyAddress showing NULL value and we need to populate that)
Select *
From [dbo].[Nashville Housing]
--Where PropertyAddress is NULL
Order By [ParcelID]         
--By doing so we observed that for same ParcelID, the PropertyAddress is same. So, we can join the same table so that we can say if a.ParcelID = b.ParcelID
--Then we will populate the PropertyAddress a with PropertyAddress b where PropertyAddress a is having NULL

-- ANS) Using JOIN       (ISNULL is used to populate the value which we will provide, when a given value is NULL)
Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) --Its saying, if A.PropertyAddress is NULL then we will populate it with B.PropertyAddress
From [dbo].[Nashville Housing] A
JOIN [Nashville Housing] B
ON A.ParcelID = B.ParcelID         --This means if ParcelIDs are same but UniqueIDs are different, then it will populate the result of PropertyAddress
AND A.[UniqueID ] <> B.[UniqueID ]  --We have to give this command orelse both the tables would show NULL values
Where A.PropertyAddress is NULL

UPDATE A   --Whenever we use UPDATE with JOIN, we have to use the aliasing name 
SET [PropertyAddress] = ISNULL(A.PropertyAddress, B.PropertyAddress)
From [dbo].[Nashville Housing] A
JOIN [Nashville Housing] B
ON A.ParcelID = B.ParcelID         --This means if ParcelIDs are same but UniqueIDs are different, then it will populate the result of PropertyAddress
AND A.[UniqueID ] <> B.[UniqueID ]
--So, after updating the table, all the NULL values got filled and we have populated the PropertyAddress rows





-- 4) Breaking out Address into Individual Columns (Address, City, State)
--Here SUBSTRING is used to split any given string and CHARINDEX is used to look for a particular value and it gives the position where that value is present in number
Select
SUBSTRING([PropertyAddress], 1, CHARINDEX(',', PropertyAddress)-1) AS Address, --Here we use -1 because, the CHARINDEX gave value upto the ',' and we dont want ',' in our output
SUBSTRING([PropertyAddress], CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))  AS City    --Here we want to display the 2nd word, therefore our starting position should be one place ahead of ','
From [dbo].[Nashville Housing]

--We cant separate the values in a column, without creating 2 separate columns. So, we need to add two column
ALTER Table [dbo].[Nashville Housing]
ADD Address nvarchar(255)             --Address column is added

UPDATE [dbo].[Nashville Housing]
SET Address = SUBSTRING([PropertyAddress], 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER Table [dbo].[Nashville Housing]
ADD City nvarchar(255)                   --City column is added

UPDATE [dbo].[Nashville Housing]
SET City = SUBSTRING([PropertyAddress], CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From [dbo].[Nashville Housing]  --So, the newly added columns will be present at the last


---Alternative Way  (PARSENAME, is used as delimiter by '.' and if we simply use it nothing will change as it is a ',' and we need to replace ',' with '.')
Select [OwnerAddress],
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS [Owner Address],  --The REPLACE function requires the Column name, the value to be changed, the new value and PARSENAME does things backward
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS [Owner City],
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS [Owner State]
From [dbo].[Nashville Housing] 

ALTER Table [dbo].[Nashville Housing]
ADD [Owner Address] nvarchar(255)             --Address column is added

UPDATE [dbo].[Nashville Housing]
SET [Owner Address] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER Table [dbo].[Nashville Housing]
ADD [Owner City] nvarchar(255)                   --City column is added

UPDATE [dbo].[Nashville Housing]
SET [Owner City] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER Table [dbo].[Nashville Housing]
ADD [Owner State] nvarchar(255)                   --State column is added

UPDATE [dbo].[Nashville Housing]
SET [Owner State] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From [dbo].[Nashville Housing] 






-- 5) Change Y and N to Yes and No in 'SoldAsVacant' field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)  --Here we can see that we have Yes, Y, No, N in the column and to change Y and N to Yes and No
From [dbo].[Nashville Housing]                      -- we will use CASE statement
Group By [SoldAsVacant]
Order By 2

--ANSWER
Select SoldAsVacant,
CASE
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
END
From [dbo].[Nashville Housing]  

--So, now we need to update that into our table
UPDATE [dbo].[Nashville Housing]  
SET [SoldAsVacant] = CASE
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
END                               --So, by doing so we have changed all the Y and N to Yes and No in our main table






-- 6) Remove Duplicates  (We will use CTE, and we will use a function to find duplicate values)
--We want to partition our data by identifying duplicate rows using Row_Number(), we can also use Rank and Dense Rank

WITH RowNumCTE AS (
Select *,                                  --After typing the command we can use CTE, so that we can execute the created column 'Row_Num'
ROW_NUMBER() OVER (                         --ROW_NUMBER() actually gives the value, that how many times the row is repeated depending on our choice of input
PARTITION BY ParcelID,              --We should use those fields in partition by that are unique and if they are same then the row is repeated
PropertyAddress, SalePrice, SaleDate, LegalReference
Order By [UniqueID ] ) AS Row_Num               --We need to Order By with the field that is unique for each row
From [dbo].[Nashville Housing] 
--Order By ParcelID
)

Select *                      --Inorder to DELETE duplicate rows, we will type DELETE in place of Select * and to check we can again type Select *
From RowNumCTE
Where  Row_Num > 1

SELECT * From [dbo].[Nashville Housing] --Use this after deleting the duplicate rows




-- 7) Delete Unused Columns

Select *
From [dbo].[Nashville Housing] 

ALTER Table [dbo].[Nashville Housing]
DROP COLUMN [OwnerAddress], [TaxDistrict], [PropertyAddress]   ---DROP is used to remove the unnecessary columns from the table
