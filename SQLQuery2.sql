SELECT * 
FROM PortfolioProject..COVIDDEATHS
where continent is not null
order by 3,4

SELECT * 
FROM PortfolioProject..COVIDVACCINATIONS
where continent is not null
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..COVIDDEATHS
where continent is not null
order by 1,2

--Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDEATHS
where continent is not null
order by 1,2
--Looking at Total Cases Vs Population
--Shows what percentage of population got covid
SELECT location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..COVIDDEATHS
where continent is not null
order by 1,2

-- Looking at Countries With Highest Infection Rate compared to Population 
SELECT location, Population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..COVIDDEATHS
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as int)) TotalDeathCount
FROM PortfolioProject..COVIDDEATHS
where continent is null
Group by Location
order by TotalDeathCount desc

--Let's break things down by Continent 

SELECT continent, MAX(cast(Total_deaths as int)) TotalDeathCount
FROM PortfolioProject..COVIDDEATHS
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing continents with thw highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) TotalDeathCount
FROM PortfolioProject..COVIDDEATHS
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS 
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/
SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDEATHS
where continent is not null
Group By date
order by 1,2

---Total_cases, Total_deaths, DeathPercentage
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/
SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDEATHS
where continent is not null
order by 1,2

--Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
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
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

