/*

Cleaning Data in SQL Queries

*/


select *
from NashvilleHousing
-----------------------------------------------------------------------------------------
--Standardize date formate

select saledateconverted, convert(date, saledate)
from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date, saledate)

Alter table NashvilleHousing
add saledateconverted date;

update NashvilleHousing
set saledateconverted = convert(date, saledate)

--------------------------------------------------------------------------------------------------

--Populate property address data
select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress , b.PropertyAddress)   --isnull(checking column, result will show in this column)
from NashvilleHousing as a                                                                                           --Basically, it means if it(a.propertyaddress is null then populate the values in b.propertyaddress) 
join NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress , b.PropertyAddress)
from NashvilleHousing as a                                                                                           --Basically, it means if it(a.propertyaddress is null then populate the values in b.propertyaddress) 
join NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------
--Breaking out address into individual columns (address, state, city)
--Deliminar(,) is separate column or diff values(a,b)

select PropertyAddress
from NashvilleHousing                                                            
--where PropertyAddress is null
--order by ParcelID


select 
substring(propertyaddress,1, charindex(',', propertyaddress) -1) as address,                     --charindex('what you are looking', 'where you are looking')  -1 indicates the last value(,) in text
substring(propertyaddress,charindex(',', propertyaddress) +1, len(propertyaddress)) as city      --+1 indicates the first value according to the code.
--charindex(',', propertyaddress)  --to get the position of ,
from NashvilleHousing

Alter table NashvilleHousing
add propertysplitaddress nvarchar(255);

update NashvilleHousing
set propertysplitaddress = substring(propertyaddress,1, charindex(',', propertyaddress) -1) 

Alter table NashvilleHousing
add propertysplitcity nvarchar(255);

update NashvilleHousing
set propertysplitcity = substring(propertyaddress,charindex(',', propertyaddress) +1, len(propertyaddress))      --length indicates the remaining whole text


select *
from NashvilleHousing


--Now, let's split the owneraddress using Parsename not substring
select OwnerAddress
from NashvilleHousing


select 
parsename (replace(owneraddress, ',',  '.'),3),             --parsename(replace(column name, thing that we are going to change(,),  going to change , with .(period)), index count 1 that indicates first string before ,) 
parsename (replace(owneraddress, ',',  '.'),2),
parsename (replace(owneraddress, ',',  '.'),1) 
from NashvilleHousing





Alter table NashvilleHousing
add ownersplitaddress nvarchar(255);

update NashvilleHousing
set ownersplitaddress = parsename (replace(owneraddress, ',',  '.'),3)

Alter table NashvilleHousing
add ownersplitcity nvarchar(255);

update NashvilleHousing
set ownersplitcity = parsename (replace(owneraddress, ',',  '.'),2)


Alter table NashvilleHousing
add ownersplitstate nvarchar(255);

update NashvilleHousing
set ownersplitstate = parsename (replace(owneraddress, ',',  '.'),1) 



select *
from NashvilleHousing



-----------------------------------------------------------------------------------------------------

--Changing Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates using CTEs

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

From NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



--If we want to delete duplicate using CTEs
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

From NashvilleHousing
--order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress
------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------------------
--Delete Un-used column

Select *
From NashvilleHousing

alter table NashvilleHousing
drop column owneraddress, Taxdistrict, Propertyaddress


alter table NashvilleHousing
drop column saledate