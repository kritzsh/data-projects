
/*

Queries used for Tableau Project

*/

[Tableau Visualisation](https://public.tableau.com/app/profile/kritika.sharma1054/viz/Project-CovidDashboard_17400355570690/Dashboard1?publish=yes)

-- 1. 

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From project1..covid_deaths
--Where location like '%states%'
--where continent is not null 
--Group By date
--order by 1,2

SELECT 
    SUM(TRY_CAST(new_cases AS INT)) AS total_cases, 
    SUM(TRY_CAST(new_deaths AS INT)) AS total_deaths, 
    SUM(TRY_CAST(new_deaths AS FLOAT)) / NULLIF(SUM(TRY_CAST(new_cases AS FLOAT)), 0) * 100 AS death_percentage
FROM project1..covid_deaths
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths;

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT 
    continent, 
    SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM project1..covid_deaths
WHERE continent IS NOT NULL  -- Exclude NULL values
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- 3.

SELECT 
    Location, 
    Population, 
    MAX(TRY_CAST(total_cases AS INT)) AS HighestInfectionCount, 
    MAX(TRY_CAST(total_cases AS FLOAT) / NULLIF(TRY_CAST(population AS FLOAT), 0)) * 100 AS PercentPopulationInfected
FROM project1..covid_deaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- 4.

SELECT 
    Location, 
    Population, 
    date,
    MAX(CAST(total_cases AS INT)) AS HighestInfectionCount,
    MAX((CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100) AS PercentPopulationInfected
FROM project1..covid_deaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC;














