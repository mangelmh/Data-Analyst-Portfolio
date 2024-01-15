-- Show DB data
Select *
From PortfolioProject.dbo.NashvilleHousing

-- Standardize Data Format
-- The SaldeDate column was changed to SaleDateConverted to homogenize the date type
Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address data
-- We find that there are null fields
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null

-- The solution found is to assign the null address with the ParcelID column
Select *
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
INNER JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- We fill the nulls of the PropertyAddress column
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
INNER JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
-- We can see that the commas separate the owner from the address
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

-- We separate the data into two columns starting from ','
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Property,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

-- We add a column
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

-- We update the information
Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

-- We add a column
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

-- We update the information
Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing

-- We perform the same task in the OwnerAddress column separating by ','
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject.dbo.NashvilleHousing

-- Column 1
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

-- Column 2
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

-- Column 3
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select *
From PortfolioProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "SoldAsVacant" field
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END

-- Remove duplicates
WITH RowNumCTE as(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
From PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
ORDER BY PropertyAddress

--Delete
--From RowNumCTE
--Where row_num > 1

-- Delete unused columns
Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
