Select *
From portfolio..COVIDDEATHS
Where continent is not null AND continent <> ''
order by 3,4

Select *
From portfolio..COVIDVACCINATIONS
order by 3,4

-- Select data that we are going to use
Select Location, date, total_cases, new_cases, total_deaths, population
From portfolio..COVIDDEATHS
ORDER BY 1,2

-- Looking at total cases vs total deaths = death rate
Select [location], [date], [total_cases], [total_deaths],
CAST([total_deaths] AS FLOAT) / NULLIF(CAST([total_cases] AS FLOAT), 0) AS death_rate
From portfolio..COVIDDEATHS
ORDER BY 1,2

-- Death rate to show as precentage.
Select [location], [date], [total_cases], [total_deaths],
CAST([total_deaths] AS FLOAT) / NULLIF(CAST([total_cases] AS FLOAT), 0) * 100 AS death_percentage
From portfolio..COVIDDEATHS
ORDER BY 1,2

-- Shows likelihood of dying if you contract covid in Lithuania

Select [location], [date], [total_cases], [total_deaths],
CAST([total_deaths] AS FLOAT) / NULLIF(CAST([total_cases] AS FLOAT), 0) * 100 AS death_percentage
From portfolio..COVIDDEATHS
Where location like '%Lithuania%'
ORDER BY 1,2

-- Looking at total cases vs population (shows what precentage of population got covid)

Select [location], [date], [population], [total_cases],
CAST([total_cases] AS FLOAT) / NULLIF(CAST([population] AS FLOAT), 0) * 100 AS death_percentage
From portfolio..COVIDDEATHS
Where location like '%Lithuania%'
ORDER BY 1,2

-- Looking at countries with highiest infection rate compared to Population

Select [location], [population], MAX(TRY_CAST([total_cases] AS BIGINT)) as HighestInfectionCount,  MAX(TRY_CAST([total_cases] AS DECIMAL(20,2))  / NULLIF(TRY_CAST([population] AS DECIMAL(20,2)), 0)* 100) AS PercentPopulationInfected
from portfolio..COVIDDEATHS
--Where location like '%states%'
Group by [location] , [population]
ORDER BY PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population 

Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From portfolio..COVIDDEATHS
Where continent is not null AND continent <> ''
Group by Location 
Order By TotalDeathCount desc

-- Breaking things down by continent
-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolio..COVIDDEATHS
Where continent is not null AND continent <>''
Group by continent
Order By TotalDeathCount desc


-- Global numbers

SELECT  
    SUM(CAST(new_cases AS INT)) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    CASE 
        WHEN SUM(CAST(new_cases AS INT)) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS INT)) * 100.0 / SUM(CAST(new_cases AS INT)))
    END AS death_percentage
FROM 
    portfolio..COVIDDEATHS

	-- Joining both tables

	Select *
	From Portfolio..COVIDDEATHS dea
	JOIN portfolio..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 

	-- Looking at total population vs Vaccinations

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location)
	From Portfolio..COVIDDEATHS dea
	JOIN portfolio..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
	Where dea.continent is not null AND dea.continent <> ''
	Order by 1,2,3

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date)
	From Portfolio..COVIDDEATHS dea
	JOIN portfolio..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
	Where dea.continent is not null AND dea.continent <> ''
	Order by 2,3

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From Portfolio..COVIDDEATHS dea
	JOIN portfolio..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
	Where dea.continent is not null AND dea.continent <> ''
	Order by 2,3

	-- USE CTE

	With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
	as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From Portfolio..COVIDDEATHS dea
	JOIN portfolio..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
	Where dea.continent is not null AND dea.continent <> ''
	-- Order by 2,3
	)
	Select*,  (CAST(RollingPeopleVaccinated AS FLOAT) / NULLIF(population, 0)) * 100 AS PercentVaccinated
	From PopvsVac

	-- Creating View to store data for later visualizations

	Create View PercentofPopulationVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From Portfolio..COVIDDEATHS dea
	JOIN portfolio..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
	Where dea.continent is not null AND dea.continent <> ''
	-- Order by 2,3

	SELECT * FROM sys.views WHERE name = 'PercentPopulationVaccinated'

	USE Portfolio;
	GO

	
	Create View PercentofPopulationVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From Portfolio..COVIDDEATHS dea
	JOIN portfolio..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
	Where dea.continent is not null AND dea.continent <> ''
	-- Order by 2,3


	-- Checking if view was created correctly 

	Select *
	From PercentofPopulationVaccinated