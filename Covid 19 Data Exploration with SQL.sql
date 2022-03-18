SELECT * 
FROM PortfolioProject..CovidDeaths

ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Data that I am using 

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract Covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)* 100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at the total cases vs population
-- Shows what percentage got Covid

SELECT location,date,population,total_cases,(total_cases/population)* 100 AS Percent_Population_Infected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Countries with Highest Infection Rate Compared to Population

SELECT location,population, MAX(total_cases) AS Highest_Infection_Count, MAX(total_cases/population)* 100 AS Percent_Population_Infected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY  location,population
ORDER BY Percent_Population_Infected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location,MAX (cast(total_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY  location
ORDER BY Total_Death_Count DESC


--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX (cast(total_deaths as int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY  continent
ORDER BY Total_Death_Count DESC

-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS Highest_Death_Count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY Highest_Death_Count DESC


--GLOBAL NUMBERS
-- Total New Cases Each Day

SELECT date, SUM(new_cases) AS Sum_New_Cases, SUM(cast(new_deaths as int)) AS Sum_New_Deaths,SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as Death_Percentage    
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS Sum_New_Cases, SUM(cast(new_deaths as int)) AS Sum_New_Deaths,SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as Death_Percentage    
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



