select *
from CovidDeaths
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


--looking at total cases vs total deaths


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'India'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population

select location, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc


--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- showing continents with the highest death count per population


select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100
as DeathPercentage
from CovidDeaths
--where location = 'India'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac(Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- TEMP TABLE

drop table if exists #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPeopleVaccinated


-- creating view to store data for later visualizations

create view PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *
from PercentPeopleVaccinated