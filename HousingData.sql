--Cleaning data in SQL Queries

select *
from NashvilleHousing


--Standardize Date Format

select SaleDateConverted, convert(date, SaleDate)
from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date, saledate)


--Populate Property Address Data


select *
from NashvilleHousing
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null         

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null         



--Breaking Out Address Into Individual Columns (Address, City, State)


select PropertyAddress
from NashvilleHousing


select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
, substring(PropertyAddress,  charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Address

from NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress nvarchar(225);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)


alter table NashvilleHousing
add PropertySplitCity nvarchar(225);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,  charindex(',', PropertyAddress)+1, len(PropertyAddress))


select *
from NashvilleHousing




select OwnerAddress
from NashvilleHousing


select
parsename(replace(OwnerAddress, ',','.') ,3)
,parsename(replace(OwnerAddress, ',','.') ,2)
,parsename(replace(OwnerAddress, ',','.') ,1)
from NashvilleHousing



alter table NashvilleHousing
add OwnerSplitAddress nvarchar(225);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',','.') ,3)


alter table NashvilleHousing
add OwnerSplitCity nvarchar(225);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',','.') ,2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(225);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',','.') ,1)


select *
from NashvilleHousing



--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2




select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end


--Remove Duplicates

with RowNumCTE as (
select *,
     ROW_NUMBER() over (
	 partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  order by
				     UniqueID
					 ) row_num

from NashvilleHousing
)

select*
from RowNumCTE
where row_num > 1



--Delete Unused Columns


select *
from NashvilleHousing


alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate