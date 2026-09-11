#CURATAREA DATELOR
RENAME TABLE world_layoffs.`data cleaning project data mysql`
TO world_layoffs.layoffs;

SELECT *
FROM world_layoffs.layoffs;

#1 Eliminam duplicatele 
#2 Standardizam datele 
#3 Valori nule 
#4 Eliminarea coloanelor nefolositoare din cadrul copiei

#Realizam o copie a data setului initial
CREATE TABLE layoffs_copy
LIKE world_layoffs.layoffs;

SELECT *
FROM layoffs_copy;

#Adaugam randurile in cadrul copiei
INSERT INTO world_layoffs.layoffs_copy
SELECT *
FROM layoffs;

 #1 
 SELECT *,
 ROW_NUMBER () OVER (PARTITION BY company, location, industry, total_laid_off, 
 percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
 FROM layoffs_copy
 ;
 
 
WITH duplicate_cte AS 
 (
  SELECT *,
 ROW_NUMBER () OVER (PARTITION BY company, location, industry, total_laid_off, 
 percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
 FROM layoffs_copy
 )
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

#Verificam daca randurile obtinute sunt cu adevarat duplicate 
SELECT *
FROM layoffs_copy
WHERE company IN ('Casper', 'Cazoo', 'Hibob', 'Wildfire Studios', 'Yahoo')
ORDER BY company;

#Realizam o copie a tabelei si adaugam coloana row_num
CREATE TABLE `layoffs_copy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_copy2;

INSERT INTO layoffs_copy2
SELECT *,
 ROW_NUMBER () OVER (PARTITION BY company, location, industry, total_laid_off, 
 percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
 FROM layoffs_copy;
 
SELECT *
FROM layoffs_copy2
ORDER BY row_num DESC;
 
#Stergem randurile duplicate
DELETE 
FROM layoffs_copy2
WHERE row_num > 1;
 
#2
#Eliminam spatiile din stanga si din dreapta in cadrul coloanei company utilizand TRIM si modificam tabela
SELECT company, TRIM(`company`)
FROM layoffs_copy2;

UPDATE layoffs_copy2
SET company=TRIM(company);
 
SELECT DISTINCT industry
FROM layoffs_copy2
ORDER BY 1;

#Verificam toate randurile care contin Crypto in cadrul coloanei industry
SELECT *
FROM layoffs_copy2
WHERE industry LIKE 'Crypto%';

#Transformam Crypto Currency si CryptoCurrency in Crypto
UPDATE layoffs_copy2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency','CryptoCurrency');

SELECT DISTINCT country 
FROM layoffs_copy2
ORDER BY 1; #Observam ca apare Unitated States de doua ori 

SELECT *
FROM layoffs_copy2
WHERE country LIKE 'United States%';

#Modificam tabela astfel incat sa apara United States in locul United States. in cadrul coloanei Country
UPDATE layoffs_copy2
SET country = 'United States'
WHERE country LIKE 'United States.';

#Modificam tipul coloanei date (din text in date)
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') AS date_format
FROM layoffs_copy2;

UPDATE layoffs_copy2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_copy2
MODIFY COLUMN `date` DATE;

#3
SELECT DISTINCT *
FROM layoffs_copy2
WHERE industry IS NULL OR industry ='';

#Verificam spatiile libere din cadrul coloanei industry 
SELECT lc2.industry, lc.industry
FROM layoffs_copy2 lc2
JOIN layoffs_copy2 lc
ON lc2.company = lc.company
WHERE (lc2.industry IS NULL OR lc2.industry = '') AND lc.industry IS NOT NULL;

UPDATE layoffs_copy2
SET industry = null
WHERE industry = '';

#Populam spatiile NULL din cadrul coloanei industry
UPDATE layoffs_copy2 lc2
JOIN layoffs_copy2 lc
ON lc2.company = lc.company
SET lc2.industry = lc.industry 
WHERE lc2.industry IS NULL AND lc.industry IS NOT NULL;

#Verificam daca a functionat
SELECT *
FROM layoffs_copy2
WHERE industry IS NULL;

SELECT DISTINCT industry 
FROM layoffs_copy2;

#Verificam din nou duplicatele 
SELECT *, ROW_NUMBER () OVER (PARTITION BY company, 
location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS numar
FROM layoffs_copy2;


WITH CTE_duplicate AS 
(
SELECT *, ROW_NUMBER () OVER (PARTITION BY company, 
location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS numar
FROM layoffs_copy2
)
SELECT *
FROM CTE_duplicate
WHERE numar>1;

#Realizam o noua tabela pentru a elimina duplicatele 
CREATE TABLE `layoffs_copy3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` date DEFAULT NULL,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int DEFAULT NULL,
  `row_num2` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_copy3
SELECT *, ROW_NUMBER () OVER (PARTITION BY company, 
location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS numar
FROM layoffs_copy2;

DELETE
FROM layoffs_copy3
WHERE row_num2 > 1;

SELECT *
FROM layoffs_copy3 AS tb1
JOIN layoffs_copy3 AS tb2 
ON tb1.company=tb2.company
WHERE tb1.industry IS NULL AND tb2.industry IS NULL; 
#Nu mai putem popula industry deoarece pentru compania Bally's Interactive nu avem cu ce sa populam 

#4
SELECT *
FROM layoffs_copy3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_copy3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_copy3
DROP COLUMN row_num;

ALTER TABLE layoffs_copy3
DROP COLUMN row_num2;

SELECT *, ROW_NUMBER () OVER () AS ID
FROM layoffs_copy3 
