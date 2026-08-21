SELECT *
FROM ProiectPortofoliu..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM ProiectPortofoliu..CovidVaccinations
--ORDER BY 3,4

--Selectam partea din date pe care urmeaza sa o folosim
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProiectPortofoliu..CovidDeaths
ORDER BY 1,2

--Comparam Total Cases cu Total Deaths
--Pune in evidenta probabilitatea de a muri pentru situatia in care o persoana era infectata in Romania
SELECT location, date, total_cases, total_deaths, (total_deaths * 1.0/total_cases)*100 AS death_percentage
FROM ProiectPortofoliu..CovidDeaths
WHERE location = 'Romania'
ORDER BY 1,2

--Comparam Total Cases cu Populatia
--Pune in evidenta ce procent din populatie s-a infectat cu COVID in Romania
SELECT location, date, total_cases, population, (total_cases * 1.0/population) * 100 AS infection_rate
FROM ProiectPortofoliu..CovidDeaths
--WHERE location = 'Romania'
ORDER BY 1,2

--Vizualizam tarile cu cel mai mare infection_rate in comparatie cu populatia
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX ((total_cases * 1.0/population)) * 100  AS MAX_infection_rate
FROM ProiectPortofoliu..CovidDeaths
GROUP BY location, population
ORDER BY MAX_infection_rate DESC

--Vizualizam tarile cu cele mai multe decese 
SELECT location, MAX(total_deaths) AS highest_deaths_count
FROM ProiectPortofoliu..CovidDeaths
WHERE continent IS NOT NULL --deoarece in setul de date initial sunt date in care de exemplu continentul este NULL iar tara este Asia
GROUP BY location
ORDER BY highest_deaths_count DESC

--Vizualizam continentele cu cele mai multe decese 
SELECT continent, MAX(total_deaths) AS highest_deaths_count
FROM ProiectPortofoliu..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY highest_deaths_count DESC

-- Numere la nivel global
SELECT date, SUM (new_cases) AS total_new_cases, SUM (new_deaths) AS total_new_deaths, (SUM (new_deaths)*1.0/SUM (new_cases)) * 100 AS death_percentage 
FROM ProiectPortofoliu..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date

-- Vizualizam comparativ populatia totala vs. nivelul total de vaccinare
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinated_people_per_region
FROM ProiectPortofoliu..CovidDeaths AS dea
INNER JOIN ProiectPortofoliu..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Utilizare CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, vaccinated_people_per_region) 
AS 
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinated_people_per_region
FROM ProiectPortofoliu..CovidDeaths AS dea
INNER JOIN ProiectPortofoliu..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (vaccinated_people_per_region*1.0/population)*100 AS vaccination_rate
FROM pop_vs_vac

--Utilizate TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location varchar(255),
date datetime,
population bigint,
new_vaccinations int,
vaccinated_people_per_region int)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinated_people_per_region
FROM ProiectPortofoliu..CovidDeaths AS dea
INNER JOIN ProiectPortofoliu..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT *, (vaccinated_people_per_region*1.0/population)*100 AS vaccination_rate
FROM #PercentPopulationVaccinated

--Crearea view pentru o vizualizarea ulterioara a datelor
DROP VIEW IF EXISTS PercentPopulationVaccinated
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinated_people_per_region
FROM ProiectPortofoliu..CovidDeaths AS dea
INNER JOIN ProiectPortofoliu..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated