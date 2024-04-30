Select *
From PortfolioProject..NashvilleHousing


-- Standardize date format

ALTER Table PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date


Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate) 


Select SaleDateConverted, CONVERT(Date, SaleDate) 
From PortfolioProject..NashvilleHousing



-- Populate Property Address data

Select table1.ParcelID, table1.PropertyAddress, table2.ParcelID, table2.PropertyAddress
From PortfolioProject..NashvilleHousing as table1
Join PortfolioProject..NashvilleHousing as table2
	On table1.ParcelID = table2.ParcelID
	and table1.[UniqueID ] <> table2.[UniqueID ]
Where table1.PropertyAddress is null

Update table1
SET PropertyAddress = ISNULL(table2.PropertyAddress, table1.PropertyAddress)
From PortfolioProject..NashvilleHousing as table1
Join PortfolioProject..NashvilleHousing as table2
	On table1.ParcelID = table2.ParcelID
	and table1.[UniqueID ] <> table2.[UniqueID ]
Where table1.PropertyAddress is null




-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select OwnerAddress
From PortfolioProject..NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)




-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by COUNT(SoldAsVacant)

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




-- Remove Duplicates

WITH ROWNUMCTE 
as (
Select *, 
ROW_NUMBER() over (PARTITION BY ParcelID,
								PropertyAddress,
								SalePrice,
								 SaleDate,
								 LegalReference
								 ORDER BY
									UniqueID
									) row_num
From PortfolioProject..NashvilleHousing
)

Select *
From ROWNUMCTE
Where row_num > 1
order by PropertyAddress




-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN TaxDistrict

