SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
order by 3,4

/* SELECT *
FROM PortfolioProject..CovidVaccinations
order by 3,4 */

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

-- Looking at total cases vs population
SELECT location, date, total_cases, population, (total_cases / population) * 100 AS CasePercentage  
FROM PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

-- Looking at countries with highest infection rate compared to population
SELECT location, MAX(total_cases) AS HighestInfection, population, MAX((total_cases / population)) * 100 AS PercecentPpulationInfected  
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
GROUP BY Population, Location
order by PercecentPpulationInfected desc

-- Showing countries with highest death count per Population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathcount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
--where location like '%states%'
GROUP BY Location
order by TotalDeathcount desc

--	LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing the continents with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathcount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
--where location like '%states%'
GROUP BY continent
order by TotalDeathcount desc

-- Global numbers
SELECT  SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths as int)) AS TotalNewDeaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as GlobalDeathPerc
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent IS NOT null
--GROUP BY date
order by  2 desc

-- Total Population vs vaccination

SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date ) AS RollingPeopleVaccinated,

FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
where dea.continent IS NOT NULL
ORDER BY 1,3

-- USE CTE
 WITH PopvsVac (Location, Continent, Date, Population, NewVac, RollingPeopleVaccinated) 
 AS 
 (
 SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
where dea.continent IS NOT NULL
--ORDER BY 1,3
)

Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac

-- Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
where dea.continent IS NOT NULL
--ORDER BY 1,3

Select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated


-- Create a view to store dat for later visualisations

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
where dea.continent IS NOT NULL
--ORDER BY 1,3


