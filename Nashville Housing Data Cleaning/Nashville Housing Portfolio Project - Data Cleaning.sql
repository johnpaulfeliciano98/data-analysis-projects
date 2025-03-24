-- Cleaning Data in SQL Queries
SELECT *
FROM PortfolioProject..NashvilleHousing	 


-- Standardized Date Format
SELECT saleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashVilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Property Address Data
SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Updates Property Address where PropertyAddress is NULL
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID

-- SUBSTRING SPLIT
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashVilleHousing

-- State SUBSTRING
ALTER TABLE NashVilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

-- City SUBSTRING
ALTER TABLE NashVilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- UPDATED SUBSTRING
SELECT PropertySplitAddress, PropertySplitCity
FROM PortfolioProject..NashvilleHousing

-- PARSENAME for OwnerAddress (SUBSTRING ALTERNATIVE)
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject..NashVilleHousing

-- Address PARSENAME
ALTER TABLE NashVilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

-- City PARSENAME
ALTER TABLE NashVilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

-- State PARSENAME
ALTER TABLE NashVilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- UPDATED PARSENAME
SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" Field
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing

-- Update Y to Yes and N to No
UPDATE NashvilleHousing
SET	SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END
FROM PortfolioProject..NashvilleHousing


-- Remove Duplicates
-- CTE
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
)

-- DELETE Duplicates
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1

-- UPDATED Removed Duplicates
SELECT *
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate