/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select * 
from project1..covid_deaths
where continent is not null
order by 3,4

--Select * 
--from project1..covid_vaccination
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from project1..covid_deaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from project1..covid_deaths
where location like '%states%'
where continent is not null
order by 1,2

--looking at total cases vs population
-- shows what % of population has gotten covid

Select location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from project1..covid_deaths
where continent is not null
--where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to population

Select location, MAX(total_cases) as HighestInfectionCount,population, 
(CONVERT(float, Max(total_cases))/ NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from project1..covid_deaths
--where location like '%states%'
where continent is not null
group by location,population
order by PercentPopulationInfected desc

-- showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from project1..covid_deaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- breaking down by continent
-- showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from project1..covid_deaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from project1..covid_deaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project1..covid_deaths dea
Join project1..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project1..covid_deaths dea
Join project1..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project1..covid_deaths dea
Join project1..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project1..covid_deaths dea
Join project1..covid_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

DROP VIEW IF EXISTS PercentPopulationVaccinated;
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
       --, (RollingPeopleVaccinated/population)*100
FROM project1..covid_deaths dea
JOIN project1..covid_vaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT name 
FROM sys.views 
WHERE name = 'PercentPopulationVaccinated';

select * from PercentPopulationVaccinated
