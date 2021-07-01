/* 
Cleaning Data
*/

SELECT TOP(100) * FROM
NashvilleHousing

-- Standardaize Date Format -----------------------------------------------

Select SaleDate, CONVERT(date, SaleDate)
From NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

-- Populate Property Address data ------------------------------------------

Select *
From NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.propertyaddress) 
From NashvilleHousing as a
JOIN NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL

UPDATE a
SET Propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
From NashvilleHousing as a
JOIN NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL

-- Breaking Address into Individual columns (Address, city, state) using SUBSTRING -----------------------------------

Select PropertyAddress
From NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress)) AS City
FROM nashvillehousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress))

SELECT * From 
NashvilleHousing

-- Breaking OwnerAddress into Individual columns (Address, city, state) using PARSENAME -----------------------------------

SELECT OwnerAddress From 
NashvilleHousing

SELECT 
PARSENAME(owneraddress, 1) --doesn't do anything because PARSENAME recognises "." not ","
From 
NashvilleHousing

SELECT 
PARSENAME(REPLACE(owneraddress, ',', '.') , 3) 
, PARSENAME(REPLACE(owneraddress, ',', '.') , 2)
, PARSENAME(REPLACE(owneraddress, ',', '.') , 1)
From 
NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)
update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.') , 3) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)
update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)
update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.') , 2)

SELECT * From 
NashvilleHousing


-- Change Y and N to Yes and No in "SoldAsVacant" ----------------------
Select Distinct (SoldAsVacant), COUNT(soldasvacant)
From NashvilleHousing
Group By SoldAsVacant
order by 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'NO'
	ELSE soldasvacant
	END
From NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'NO'
	ELSE soldasvacant
	END

-- REMOVE DUPLICATES --
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY parcelId,
				propertyaddress,
				Saleprice,
				Saledate,
				legalreference
				order by 
				uniqueid
				) row_num

From NashvilleHousing
--order by ParcelID
)
SELECT * FROM RowNumCTE
where row_num > 1
--order by PropertyAddress


-- Select Unused Columns ---

SELECT * From 
NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN owneraddress, Taxdistrict, propertyaddresS

ALTER TABLE NashvilleHousing
DROP COLUMN Saledate
