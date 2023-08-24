select *
from CovidDeaths
where continent is not null
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'Taiwan'
where continent is not null
order by 1,2


-- Looking at Total Cases vs Population
select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from CovidDeaths
where continent is not null
--where location like 'Taiwan'
order by 1,2


-- Looking at Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as CovidPercentage
from CovidDeaths
where continent is not null
group by location, population
order by 4 desc


-- Showing the Countries with highest death count per population
select location, max(total_deaths) as TotaltDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotaltDeathCount desc

select location, max(cast(total_deaths as int)) as TotaltDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotaltDeathCount desc

-- Showing continents with the highest death per population
select continent, max(cast(total_deaths as int)) as TotaltDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotaltDeathCount desc


-- Global numbers
select date, sum(new_cases) as DailyCases, sum(cast(new_deaths as int)) as DailyDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as DailyCases, sum(cast(new_deaths as int)) as DailyDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/ population)*100
from [SQL Porfolio Project].dbo.CovidDeaths as dea
join [SQL Porfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = dea.date
where dea.continent is not null
order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [SQL Porfolio Project].dbo.CovidDeaths as dea
join [SQL Porfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = dea.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [SQL Porfolio Project].dbo.CovidDeaths as dea
join [SQL Porfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = dea.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from [SQL Porfolio Project].dbo.CovidDeaths as dea
join [SQL Porfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = dea.date
where dea.continent is not null


select *
from PercentPopulationVaccinated

