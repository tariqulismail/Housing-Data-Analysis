
--- Importing Data using ODBC importer 

/*

Cleaning Data in PL_SQL Queries

*/


Select *
From WESTVILLE_HOUSING

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select to_date(SaleDate) saleDateConverted
From WESTVILLE_HOUSING;

Update WESTVILLE_HOUSING
SET SaleDate = to_date(SaleDate);

-- If it doesn't Update properly

ALTER TABLE WESTVILLE_HOUSING
Add SaleDateConverted Date;

Update WESTVILLE_HOUSING
SET SaleDateConverted = to_date(SaleDate);


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From WESTVILLE_HOUSING
--Where PropertyAddress is null
order by ParcelID


--35 rows
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, nvl(a.PropertyAddress,b.PropertyAddress)
From WESTVILLE_HOUSING a
JOIN WESTVILLE_HOUSING b
  on a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID 
Where a.PropertyAddress is null;

select * from WESTVILLE_HOUSING a Where a.PropertyAddress is null;
select * from WESTVILLE_HOUSING a where a.ParcelID  = '025 07 0 031.00';

update WESTVILLE_HOUSING t set t.PropertyAddress = (select nvl(t.PropertyAddress,u.PropertyAddress) from WESTVILLE_HOUSING u 
where t.ParcelID=u.ParcelID
and t.UniqueID <> u.UniqueID
and rownum=1)
where t.PropertyAddress is null;



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From WESTVILLE_HOUSING;
--Where PropertyAddress is null
--order by ParcelID


SELECT
SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1 ) as Address
, SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 1 , LENGTH(PropertyAddress)) as Address
From WESTVILLE_HOUSING;


ALTER TABLE WESTVILLE_HOUSING
Add PropertySplitAddress Nvarchar2(255);

Update WESTVILLE_HOUSING
SET PropertySplitAddress = SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1 )


ALTER TABLE WESTVILLE_HOUSING
Add PropertySplitCity Nvarchar2(255);

Update WESTVILLE_HOUSING
SET PropertySplitCity = SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 1 , LENGTH(PropertyAddress))




Select *
From WESTVILLE_HOUSING

Select OwnerAddress
From WESTVILLE_HOUSING


SELECT SUBSTR(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1) as OwnerSplitAddress,
       SUBSTR(SUBSTR(OwnerAddress,
                     INSTR(OwnerAddress, ',') + 1,
                     LENGTH(OwnerAddress)),
              1,
              INSTR((SUBSTR(OwnerAddress,
                            INSTR(OwnerAddress, ',') + 1,
                            LENGTH(OwnerAddress))),
                    ',',
                    1,
                    1) - 1) as OwnerSplitCity,
       SUBSTR(OwnerAddress,
              INSTR(OwnerAddress, ',', 1, 2) + 1,
              LENGTH(OwnerAddress)) as OwnerSplitState
  From WESTVILLE_HOUSING;



ALTER TABLE WESTVILLE_HOUSING
Add OwnerSplitAddress Nvarchar2(255);

Update WESTVILLE_HOUSING
SET OwnerSplitAddress = SUBSTR(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1);


ALTER TABLE WESTVILLE_HOUSING
Add OwnerSplitCity Nvarchar2(255);

Update WESTVILLE_HOUSING
SET OwnerSplitCity = SUBSTR(SUBSTR(OwnerAddress,
                     INSTR(OwnerAddress, ',') + 1,
                     LENGTH(OwnerAddress)),
              1,
              INSTR((SUBSTR(OwnerAddress,
                            INSTR(OwnerAddress, ',') + 1,
                            LENGTH(OwnerAddress))),
                    ',',
                    1,
                    1) - 1);



ALTER TABLE WESTVILLE_HOUSING
Add OwnerSplitState Nvarchar2(255);

Update WESTVILLE_HOUSING
SET OwnerSplitState = SUBSTR(OwnerAddress,
              INSTR(OwnerAddress, ',', 1, 2) + 1,
              LENGTH(OwnerAddress));



Select *
From WESTVILLE_HOUSING;




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From WESTVILLE_HOUSING
Group by SoldAsVacant
order by 2;




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
From WESTVILLE_HOUSING;


Update WESTVILLE_HOUSING
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END;






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
         PropertyAddress,
         SalePrice,
         SaleDate,
         LegalReference
         ORDER BY
          UniqueID
          ) row_num

From WESTVILLE_HOUSING
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;





Select count(1)
From WESTVILLE_HOUSING;--56477

select b.Max_uniqueid from 
(select * from 
(Select ParcelID,
         PropertyAddress,
         SalePrice,
         SaleDate,
         LegalReference, count(1) c, max(t.uniqueid) Max_uniqueid
From WESTVILLE_HOUSING t
group by ParcelID,
         PropertyAddress,
         SalePrice,
         SaleDate,
         LegalReference)a
         where a.c > 1)b;


delete  from WESTVILLE_HOUSING t
where t.uniqueid in (select b.Max_uniqueid from 
(select * from 
(Select ParcelID,
         PropertyAddress,
         SalePrice,
         SaleDate,
         LegalReference, count(1) c, max(t.uniqueid) Max_uniqueid
From WESTVILLE_HOUSING t
group by ParcelID,
         PropertyAddress,
         SalePrice,
         SaleDate,
         LegalReference)a
         where a.c > 1)b);


Select count(1)
From WESTVILLE_HOUSING;--56373

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From WESTVILLE_HOUSING;


ALTER TABLE WESTVILLE_HOUSING
DROP COLUMN OwnerAddress;

ALTER TABLE WESTVILLE_HOUSING
DROP COLUMN TaxDistrict;

ALTER TABLE WESTVILLE_HOUSING
DROP COLUMN PropertyAddress;

ALTER TABLE WESTVILLE_HOUSING
DROP COLUMN SaleDate; 







