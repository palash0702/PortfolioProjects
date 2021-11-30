-----------------------------------------------Data cleaning in SQL---------------------------------------------------------------------
use [Portfolio Project]

select * from Nashville_housing


----------------------------------------------Standardizing date format----------------------------------------------------------

select SaleDate, sales_date_converted
from Nashville_housing

alter table Nashville_housing	------Altering the table by Adding a new column
add sales_date_converted date

update Nashville_housing	------Updating the table by changing the data in the new column
set sales_date_converted = CONVERT(date, SaleDate)







-------------------------------------------Populate Property Address Data-----------------------------------------------------------

select * from Nashville_housing	-----Originally, 29 NULL values are present in Property address column
where PropertyAddress is null


select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) ---ISNULL ensures if 1st Col is NULL, it takes the value from 2nd Col and generates anew tables with values.
from Nashville_housing a   
join Nashville_housing b
on a.ParcelID = b.ParcelID	-------Taking ParcelID as a reference, basically doing Vlookup on parcelID to find Property Address from the same table
and a.[UniqueID ] != b.[UniqueID ] 
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville_housing a   
join Nashville_housing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null



---------------------------------Breaking the PropertyAddress and the OwnerAddress(Delimiter)--------------------------------------
select PropertyAddress,OwnerAddress from Nashville_housing

---SUBSTRING(Column, Start Point, End point)

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as PropertyAddress1	---------- Separating the PropertyAddress column before ','
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as PropertyAddress2	--------- Separating the PropertyAddress column after ','
from Nashville_housing

-----Adding columns to the table------
ALTER TABLE Nashville_housing
add PropertyAddress1 nvarchar(255)

ALTER TABLE Nashville_housing
add PropertyAddress2 nvarchar(255)

----Updating the data into the table----
UPDATE Nashville_housing
SET PropertyAddress1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

UPDATE Nashville_housing
SET PropertyAddress2 = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--------------------------------------------------Splitting Owner's Address-----------------------------------------------------
select OwnerAddress from Nashville_housing

select 
PARSENAME(replace(OwnerAddress,',','.'), 3) as OwnerAddress1,	-------Parsename works in Reverse, So, 3 gives us the 1st separated data.
PARSENAME(replace(OwnerAddress, ',','.'), 2) as OwnerAddress2,
PARSENAME(replace(OwnerAddress, ',','.'), 1) as OwnerAddress3
from Nashville_housing
	
ALTER TABLE Nashville_housing
add OwnerAddress1 nvarchar(255)

ALTER TABLE Nashville_housing
add OwnerAddress2 nvarchar(255)

ALTER TABLE Nashville_housing
add OwnerAddress3 nvarchar(255)

UPDATE Nashville_housing
SET OwnerAddress1 = PARSENAME(replace(OwnerAddress,',','.'), 3)

UPDATE Nashville_housing
SET OwnerAddress2 = PARSENAME(replace(OwnerAddress,',','.'), 2)

UPDATE Nashville_housing
SET OwnerAddress3 = PARSENAME(replace(OwnerAddress,',','.'), 1)


-----------------------------Change Y, N to Yes and No in "Sold as Vacant" field------------------------------------------------------

select distinct(SoldAsVacant), count(SoldAsVacant) as count_soldasvacant ------There are 399 N, 52 Y
from Nashville_housing
GROUP BY SoldAsVacant

select SoldAsVacant
,CASE	when SoldAsVacant = 'Y' then 'Yes'  -------Forming a case statement for Y and N
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
 END
from Nashville_housing

UPDATE Nashville_housing	---------Updating the data in the table
SET SoldAsVacant = CASE	when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
					END

---------------------------------------------------Removing Duplicates-----------------------------------------------------------
WITH Row_numCTE AS		----------Creating a CTE	
(
select *, ROW_NUMBER() OVER( PARTITION BY ParcelID, PropertyAddress,	-----------This will count duplicates based on defined parameters
SalePrice,SaleDate,LegalReference ORDER BY ParcelID) AS Row_num
from Nashville_housing
)
DELETE FROM Row_numCTE
where Row_num > 1


-----------------------------------------------------Delete Unused Columns--------------------------------------------------------
select * from Nashville_housing

ALTER TABLE Nashville_Housing
DROP COLUMN SaleDate, TaxDistrict

