SELECT *
FROM PortfolioProject..CovidDeaths
order by 3, 4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3, 4


--select data we are goung to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%states'
where continent is not NULL
order by 1,2

--looking at total cases vs population
--show what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
where location like 'Nigeria'
where continent is not NULL
order by 1,2


--looking at Countries with Highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like 'Nigeria'
where continent is not NULL
GROUP BY Location, Population
order by PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like 'Nigeria'
where continent is not NULL
GROUP BY Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the continent with the highest Death Count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like 'Nigeria'
where continent is NULL
GROUP BY Location
order by TotalDeathCount desc


--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like 'Nigeria'
where continent is not NULL
--GROUP BY date
order by 1,2


--Looking at Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

WITH PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3