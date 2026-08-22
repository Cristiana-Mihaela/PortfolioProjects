--Curatarea datelor in SQL 
SELECT *
FROM ProiectPortofoliu.dbo.Nashville_Housing

------------------------------------------------------------------------------------------------------------
--Standardizarea datelor calendaristice
SELECT SaleDate, CONVERT (Date, SaleDate) AS SaleDateStand
FROM ProiectPortofoliu.dbo.Nashville_Housing

UPDATE ProiectPortofoliu.dbo.Nashville_Housing
SET SaleDate = CONVERT (Date, SaleDate)

-------------------------------------------------------------------------------------------------------------
--Popularea coloanei PropertyAdress
SELECT *
FROM ProiectPortofoliu.dbo.Nashville_Housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID --se observa faptul ca atunci cand avem acelasi ParcellID PropertyAdress trebuie sa 
--fie aceeasi in ambele cazuri

--Verificam care adrese au acealsi ParcelID, insa nu sunt populate corespunzator 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM ProiectPortofoliu.dbo.Nashville_Housing AS a
INNER JOIN ProiectPortofoliu.dbo.Nashville_Housing AS b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL 

--Populam spatiile goale 
UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM ProiectPortofoliu.dbo.Nashville_Housing AS a
INNER JOIN ProiectPortofoliu.dbo.Nashville_Housing AS b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------
--Impartirea coloanei PropertyAddress in coloane individuale (Adress, City, State)
SELECT PropertyAddress
FROM ProiectPortofoliu.dbo.Nashville_Housing

--Realizam impartirea coloanei PropertyAddress
SELECT PropertyAddress,
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) AS Address, 
SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN (PropertyAddress)) AS Address
FROM ProiectPortofoliu.dbo.Nashville_Housing

--Populam tabela initiala cu datele impartite prin adaugarea a doua noi coloane 
ALTER TABLE ProiectPortofoliu.dbo.Nashville_Housing
ADD PropertySplitAddress Nvarchar(255)

UPDATE ProiectPortofoliu.dbo.Nashville_Housing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1)

ALTER TABLE ProiectPortofoliu.dbo.Nashville_Housing
ADD PropertySplitCity Nvarchar(255)

UPDATE ProiectPortofoliu.dbo.Nashville_Housing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN (PropertyAddress))

SELECT *
FROM ProiectPortofoliu.dbo.Nashville_Housing

-----------------------------------------------------------------------------------------------------------------------
--Impartirea coloanei OwnerAddress utilizand PARSENAME
SELECT OwnerAddress
FROM ProiectPortofoliu.dbo.Nashville_Housing

SELECT 
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3),
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2),
PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1)
FROM ProiectPortofoliu.dbo.Nashville_Housing

--Populam tabela initiala cu inca 3 coloane care contin informatiile impartite din coloana OwnerAddress
ALTER TABLE ProiectPortofoliu.dbo.Nashville_Housing
ADD OwnerAddressSplit Nvarchar(255)

UPDATE ProiectPortofoliu.dbo.Nashville_Housing
SET OwnerAddressSplit = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3)

ALTER TABLE ProiectPortofoliu.dbo.Nashville_Housing
ADD OwnerCitySplit Nvarchar(255)

UPDATE ProiectPortofoliu.dbo.Nashville_Housing
SET OwnerCitySplit = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2)

ALTER TABLE ProiectPortofoliu.dbo.Nashville_Housing
ADD OwnerStateSplit Nvarchar(255)

UPDATE ProiectPortofoliu.dbo.Nashville_Housing
SET OwnerStateSplit = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1)

SELECT *
FROM ProiectPortofoliu.dbo.Nashville_Housing

--------------------------------------------------------------------------------------------------------
--Schimbarea 0 si 1 cu Yes si No in coloana SoldAsVacant
SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
FROM ProiectPortofoliu.dbo.Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = '1' THEN 'YES'
ELSE 'NO'
END 
FROM ProiectPortofoliu.dbo.Nashville_Housing

--Realizam schimbarea in cadrul setului de date initial
ALTER TABLE ProiectPortofoliu.dbo.Nashville_Housing
ADD NewSoldAsVacant varchar(50)

UPDATE ProiectPortofoliu.dbo.Nashville_Housing
SET NewSoldAsVacant = CASE WHEN SoldAsVacant = '1' THEN 'YES'
ELSE 'NO'
END 
FROM ProiectPortofoliu.dbo.Nashville_Housing

SELECT *
FROM ProiectPortofoliu.dbo.Nashville_Housing

-------------------------------------------------------------------------------------------------------------
--Eliminarea duplicatelor
WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER () OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY  UniqueID) Row_Num
FROM ProiectPortofoliu.dbo.Nashville_Housing
)

DELETE 
FROM RowNumCTE
WHERE Row_Num > 1

SELECT *
FROM ProiectPortofoliu.dbo.Nashville_Housing

--------------------------------------------------------------------------------------------------------------
--Stergerea coloanelor nefolosite
ALTER TABLE ProiectPortofoliu.dbo.Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SoldAsVacant