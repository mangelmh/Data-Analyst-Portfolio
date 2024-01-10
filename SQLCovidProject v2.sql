-- Select all data from extracted tables
Select * 
From CovidProject..CovidDeaths
Where continent is not null
order by 3, 4

Select * 
From CovidProject..CovidVaccinations
Where continent is not null
order by 3, 4

-- Select Data that we are going to use from the CovidDeaths table
Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Where continent is not null
order by 1, 2

-- Looking at Total_cases vs Total_deaths at a specific location
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%mex%'
And continent is not null
order by 1, 2

-- Looking at Total Cases vs Population and
-- shows what percentage of the population contracted Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentageContractCovid
From CovidProject..CovidDeaths
Where location like '%mex%'
And continent is not null
order by 1, 2

-- Looking at the South American countries with the highest infection rate compared to the population
Select location, population, MAX(total_cases) as HighestInfectionCountry, MAX((total_cases/population))*100 as PercentageContractCovid
From CovidProject..CovidDeaths
Where continent like '%south america%'
Group by location, population
order by PercentageContractCovid desc

-- Showing the South American countries with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathsCountry
From CovidProject..CovidDeaths
Where continent like '%south america%'
Group by location, population
order by TotalDeathsCountry desc

-- Let's Break things down by continent
-- Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCountry
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathsCountry desc

-- Global numbers of total cases and death 
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
order by 1, 2

-- Analyzing the total_population against vaccines by implementing a CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Inner Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccPopulation
From PopvsVac

-- TEMP TEABLE
-- Shows the total number of vaccines, vaccinated population and their percentage
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Inner Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccPopulation
From #PercentPopulationVaccinated