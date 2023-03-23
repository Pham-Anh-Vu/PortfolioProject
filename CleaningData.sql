use `portfolioproject`;
select * from nashvillehousing where ParcelID = "025 07 0 031.00" limit 100;

delete from nashvillehousing;

alter table nashvillehousing add column SaleDate_col date;
update nashvillehousing set SaleDate_col = str_to_date(SaleDate, "%m/%d/%Y");
alter table nashvillehousing modify SaleDate_col date after SaleDate;
alter table nashvillehousing drop column SaleDate;

-- Populate Property Address data

select *
from nashvillehousing
where PropertyAddress = '';

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from nashvillehousing a
join nashvillehousing b
	on a.ParcelID = b.ParcelID 
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress = '' ;

update nashvillehousing a
join nashvillehousing b
	on a.ParcelID = b.ParcelID 
	and a.UniqueID <> b.UniqueID
    and a.PropertyAddress = ''
set a.PropertyAddress = b.PropertyAddress
where a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID and a.PropertyAddress = '';

select instr(PropertyAddress, ","), length(PropertyAddress)
from nashvillehousing;

select PropertyAddress, substring(PropertyAddress, 1, instr(PropertyAddress, ",")-1) as address, substring(PropertyAddress, instr(PropertyAddress, ",")+1, length(PropertyAddress))
from nashvillehousing; 


alter table nashvillehousing add column PropertySplitAddress nvarchar(255);
update nashvillehousing set PropertySplitAddress = substring(PropertyAddress, 1, instr(PropertyAddress, ",")-1);
alter table nashvillehousing modify PropertySplitAddress nvarchar(255) after PropertyAddress;

alter table nashvillehousing add column PropertySplitCity nvarchar(255);
update nashvillehousing set PropertySplitCity = substring(PropertyAddress, instr(PropertyAddress, ",")+1, length(PropertyAddress));
alter table nashvillehousing modify PropertySplitCity nvarchar(255) after PropertySplitAddress;


select substring_index(OwnerAddress, ",", -1) from nashvillehousing;
select substring_index(substring_index(OwnerAddress, ",", 2), ",", -1) from nashvillehousing;
select substring_index(OwnerAddress, ",", 1) from nashvillehousing;


alter table nashvillehousing add column OwnerSplitAddress nvarchar(255);
update nashvillehousing set OwnerSplitAddress = substring_index(OwnerAddress, ",", 1);
alter table nashvillehousing modify OwnerSplitAddress nvarchar(255) after OwnerAddress;

alter table nashvillehousing add column OwnerSplitCity nvarchar(255);
update nashvillehousing set OwnerSplitCity = substring_index(substring_index(OwnerAddress, ",", 2), ",", -1);
alter table nashvillehousing modify OwnerSplitCity nvarchar(255) after OwnerSplitAddress;

alter table nashvillehousing add column OwnerSplitState nvarchar(255);
update nashvillehousing set OwnerSplitState = substring_index(OwnerAddress, ",", -1);
alter table nashvillehousing modify OwnerSplitState nvarchar(255) after OwnerSplitCity;


select SoldAsVacant ,
case when SoldAsVacant = "Y" then "Yes"
	when SoldAsVacant = "N" then 'No'
    else SoldAsVacant
    End
from nashvillehousing;

update nashvillehousing set SoldAsVacant = case when SoldAsVacant = "Y" then "Yes"
												when SoldAsVacant = "N" then 'No'
												else SoldAsVacant
												End;

select distinct(SoldAsVacant) from nashvillehousing;

with table1 as(
	select *, row_number() over( partition by ParcelID,
											LandUse,
											PropertyAddress,
											SaleDate_col,
											SalePrice,
											LegalReference,
											OwnerName
								) as row_num
	from nashvillehousing
)
-- select count(row_num) from table1 group by row_num;
delete from nashvillehousing a where a.UniqueID In (select UniqueID from table1 where row_num > 1);

select * from nashvillehousing;


alter table nashvillehousing drop column OwnerAddress; 
alter table nashvillehousing drop column PropertyAddress; 


