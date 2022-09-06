
/*Useful queries to explore the data in the database */

-- All covid vaccinations data, ordered by location and date

select*from CovidVaccinations
Order by 3,4

-- All covid deaths data, ordered by location and date

Select Location, date, total_cases, new_cases, total_deaths,population
From CovidDeaths
Where continent is not null
Order by 1,2

-- Showing total cases vs total deaths from United States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
Order by 1,2

-- Showing total cases vs population from United States

Select Location, date, population, total_cases,  (total_cases/population)*100 as CasesPercentage
From dbo.CovidDeaths
Where location like '%states%'
Order by 1,2

-- Showing countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectCount,  MAX((total_cases/population))*100 as PercentagePopulationInfected
From dbo.CovidDeaths
Where continent is not null
Group by Location, population
Order by PercentagePopulationInfected desc

-- Showing countries with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc



-- Breaking down the data by continent

-- Showing continents with the hightest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers 

-- Global death percentage by date (total cases vs total deaths)

Select date,  SUM(new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_deaths, SUM (cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Global death percentage (total cases vs total deaths)

Select  SUM(new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_deaths, SUM (cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From CovidDeaths
Where continent is not null
Order by 1,2


-- Showing Total population vs Vaccinations by location and date

With PopvsVac (continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as 
(
Select D.Continent, D.Location, D.date, D.population, V.new_vaccinations, 
	SUM(CONVERT(int, V.new_vaccinations)) OVER (Partition by D.Location Order by D.Location, D.Date) as 'RollingPeopleVaccinated'
From CovidDeaths D
JOIN CovidVaccinations V
	ON D.Location = V.Location
	and D.date = V.date
Where D.continent is not null
--Order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Table showing vaccinated population 

DROP Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric, 
	RollingPeopleVaccinated numeric,
	)

Insert into #PercentPopulationVaccinated

Select D.Continent, D.Location, D.date, D.population, V.new_vaccinations, 
	SUM(CONVERT(int, V.new_vaccinations)) OVER (Partition by D.Location Order by D.Location, D.Date) as 'RollingPeopleVaccinated'---, (RollingPeopleVaccinated/population)*100 as 'PercRollingPeopleVacc'
From CovidDeaths D
JOIN CovidVaccinations V
	ON D.Location = V.Location
	and D.date = V.date
--Where D.continent is not null
--Order by 2,3


Select*, (RollingPeopleVaccinated/population)*100 as 'PercRollingPeopleVacc'
From #PercentPopulationVaccinated



/* Creating useful views based on exploratory analysis  */


-- View: Population Vaccinated

DROP VIEW PercentPopulationVaccinated
Create View PercentPopulationVaccinated as

Select D.Continent, D.Location, D.date, D.population, V.new_vaccinations, 
	SUM(CONVERT(int, V.new_vaccinations)) OVER (Partition by D.Location Order by D.Location, D.Date) as 'RollingPeopleVaccinated'--, (RollingPeopleVaccinated/population)*100
From CovidDeaths D
JOIN CovidVaccinations V
	ON D.Location = V.Location
	and D.date = V.date
Where D.continent is not null
--Order by 2,3

Select*
from PercentPopulationVaccinated