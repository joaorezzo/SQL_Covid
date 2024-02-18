-- This dataset contains covid-19 data from february of 2020 until april of 2021.

SELECT *
from SQLCovid..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4


SELECT location, date, total_cases, new_cases, total_deaths, population
from SQLCovid..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths (DeathPercentage)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from SQLCovid..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Looking at DeathPercentage in Brazil
-- Shows likelihood, probability of dying if you contract covid in your coutry

-- Looking at Total Cases vs Population
-- Shows the percentage of population that got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
from SQLCovid..CovidDeaths
WHERE location like 'Brazil' 
and continent is not null
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
from SQLCovid..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with Highest Death Count per population
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
from SQLCovid..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- As we can see, Brazil holds the second place when it comes to the total death count.

-- Now we are going to group by continent

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
from SQLCovid..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Showing continents with the highest death count per population


-- GLobal numbers

--Total of cases per day, total deaths per day and death percentage per day
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
from SQLCovid..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 

-- Total cases, total deaths and death percentage
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
from SQLCovid..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 

-- As we see, until this date we have 150 million cases, 3.2 million deaths and a death percentage of 2.11% based on the previous data



-- Now, let's join the tables 
-- looking at Total  population vs Vaccinations

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLCovid..CovidDeaths dea
Join SQLCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3  // Learned that ordey by clauses cant be used on CTEs
)

-- Executing the query with the CTE, we have a table with a updated percentage of the vaccinated
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinatedPerDay
From PopvsVac


-- Temp table

DROP TABLE IF exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLCovid..CovidDeaths dea
Join SQLCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

GO 

CREATE VIEW PercentPopulationVaccinated 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLCovid..CovidDeaths dea
Join SQLCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 