SELECT *
FROM [Portfolio Project]..covid_deaths
WHERE continent is NOT NULL
ORDER BY 3, 4

SELECT *
FROM [Portfolio Project]..covid_vaccinations
WHERE continent is NOT NULL
ORDER BY 3, 4

--Selcet Data that i will be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..covid_deaths
WHERE continent is NOT NULL
ORDER BY 1,2 

--Looking at total cases vs total deaths
--Showing chances of dying when you have covid diagnosed based on Poland 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..covid_deaths
WHERE location like '%Poland%' AND continent is NOT NULL
ORDER BY 1,2 

--Looking at total cases vs population
--Shows percentage of how many people got covid

Select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
FROM [Portfolio Project]..covid_deaths
WHERE location = 'Poland' AND continent is NOT NULL
ORDER BY 1,2 

--Countries with highest infection rate compared to population

Select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as CovidPercentage
FROM [Portfolio Project]..covid_deaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY CovidPercentage desc


--I need to change the datatype of total_deaths column in order to make calculations 

ALTER TABLE [Portfolio Project]..covid_deaths
ALTER COLUMN total_deaths int

--Countries with highest death rate compared to population


Select location, max(total_deaths) as HighestDeathCount, population, max((total_deaths/population))*100 as DeathPercentage
FROM [Portfolio Project]..covid_deaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY DeathPercentage desc

--Countries where the most people have died
Select location, max(total_deaths) as DeathCount
FROM [Portfolio Project]..covid_deaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY DeathCount desc

--LET'S BREAK IT DOWN TO CONTINENTS

Select continent, max(total_deaths) as DeathCount
FROM [Portfolio Project]..covid_deaths
WHERE continent is NOT NULL 
GROUP BY continent
ORDER BY DeathCount desc

--Global numbers

Select date, SUM(new_cases) as new_cases, SUM(CAST(new_deaths as FLOAT)) as new_deaths, SUM(CAST(new_deaths as FLOAT))/ SUM(new_cases)*100 as death_percentage
FROM [Portfolio Project]..covid_deaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1


Select SUM(new_cases) as new_cases, SUM(CAST(new_deaths as FLOAT)) as new_deaths, SUM(CAST(new_deaths as FLOAT))/ SUM(new_cases)*100 as death_percentage
FROM [Portfolio Project]..covid_deaths
WHERE continent is NOT NULL

--Total population vs total vaccination
--Time for some joins
--Use CTE
--Option 1

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
	as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths dea
JOIN [Portfolio Project]..covid_vaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is NOT NULL)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Temp Table
--Option 2

DROP TABLE IF EXISTS #PercentPPLVaccinated
CREATE TABLE #PercentPPLVaccinated
(Continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPPLVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths dea
JOIN [Portfolio Project]..covid_vaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPPLVaccinated

--Creating view to store data for future visualisations

CREATE VIEW PercentPPLVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths dea
JOIN [Portfolio Project]..covid_vaccinations vac
	ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is NOT NULL
