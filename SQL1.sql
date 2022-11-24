select * from Portfolio..HousingData

/*
Cleaning Dataset
*/

-- Standardize Date Format
select SaleDate from Portfolio..HousingData

--select SaleDate, CONVERT(Date, SaleDate) from Portfolio..HousingData

update Portfolio..HousingData set SaleDate = CONVERT(Date, SaleDate)

-- If not updated alter table

alter table Portfolio..HousingData
add SaleDateUpdated Date 

update Portfolio..HousingData set SaleDateUpdated  = CONVERT(Date, SaleDate)

select SaleDateUpdated, CONVERT(Date, SaleDate) from Portfolio..HousingData

alter table Portfolio..HousingData drop column SaleDate

/*
select * from Portfolio..HousingData
exec sp_rename 'HousingData.SaleDateUpdated', 'SaleDate'
*/

select * from Portfolio..HousingData




-- Populate Property Address Data

select * from Portfolio..HousingData
where PropertyAddress is null


select * from Portfolio..HousingData
order by ParcelID

/*
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio..HousingData a
Join Portfolio..HousingData b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <>b.[UniqueID ]

	where a.PropertyAddress is null
*/

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio..HousingData a
Join Portfolio..HousingData b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <>b.[UniqueID ]

	where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)
 
select PropertyAddress from Portfolio..HousingData

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from Portfolio..HousingData


-- Creating two different columns 
alter table Portfolio..HousingData
add PropertyHomeAddress Nvarchar(255)

update PortFolio..HousingData
set PropertyHomeAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table PortFolio..HousingData
add PropertyCity Nvarchar(255)

update Portfolio..HousingData
set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select PropertyHomeAddress, PropertyCity from Portfolio..HousingData



select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from Portfolio..HousingData


alter table Portfolio..HousingData
add OwnerHomeAddress Nvarchar(255)

update PortFolio..HousingData
set OwnerHomeAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table PortFolio..HousingData
add OwnerCity Nvarchar(255)

update Portfolio..HousingData
set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table Portfolio..HousingData
add OwnerState Nvarchar(255)

update PortFolio..HousingData
set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select * from Portfolio..HousingData






-- Changing 'Y' & 'N' to 'Yes' & 'No' in 'Sold as Vacant' field

select SoldAsVacant from Portfolio..HousingData

select Distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio..HousingData
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
from Portfolio..HousingData

update Portfolio..HousingData
Set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
from Portfolio..HousingData





-- Remove Duplicates 

With RowNum as(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference

	Order by UniqueID
	) Row_Num
from Portfolio..HousingData )
--order by ParcelID
/*
DELETE from RowNum
where Row_Num  > 1
*/
select * from RowNum
where Row_Num  > 1
--order by SaleDate



--Delete Unused Columns

select * from Portfolio..HousingData

Alter table Portfolio..HousingData
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table Portfolio..HousingData
drop column SaleDate


--END
