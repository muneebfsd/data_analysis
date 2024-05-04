-- Layoffs Data Cleaning

-- 1. Remove Duplicates

SELECT *
FROM layoffs;

-- Create & Insert a staging table of raw dataset to follow the best practice

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Add a column row_num for indexing the each row

SELECT *,ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,
percentage_laid_off, `date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Do the CTE to check the duplicate rows

WITH duplicates_CTE AS
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,
percentage_laid_off, `date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicates_CTE
WHERE row_num>1;

-- We have to create & Insert a new table from SCHEMAS to easily remove the duplicates

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,
percentage_laid_off, `date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Delete duplicates rows

SELECT *
FROM layoffs_staging2
WHERE row_num>1;

DELETE
FROM layoffs_staging2
WHERE row_num>1;

-- 2. Standardizing the data

-- Update company column with TRIM to remove extra spaces
SELECT company,TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company=TRIM(company);

-- Update industry column with One Crypto industry

SELECT DISTINCT industry
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry='Crypto'
WHERE industry LIKE 'Crypto%';

-- Update date column format

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date`= STR_TO_DATE(`date`,'%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

-- Change the date format from text to date 

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` date;

-- 3. NULL / Blank values

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR 
industry='';

SELECT *
FROM layoffs_staging2
WHERE company='Airbnb';

-- We will see this query later

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Updating industry column from '' to NULL

UPDATE layoffs_staging2
SET industry=NULL
WHERE industry='';

-- Merging and populating the industry from non-blank to blank columns

SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
WHERE t1.industry IS NULL or t1.industry=''
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
SET t1.industry=t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2;

-- 4. Remove Unnecessary Columns

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Removing total_laid_off and percentage_laid_off having NULL values.

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

-- Removing row_num column which is a redundant column

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2
ORDER BY 1;

-- Layoff data cleaning project completed.






