
select * 
from p..CovidDeaths
order by 3,4;

--select * 
--from p..CovidVaccinations
--order by 3,4;

select location,date,total_cases,new_cases,total_deaths,population
from p..CovidDeaths
order by 1,2;

-- Total death Vs Total cases

select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from p..CovidDeaths
where location='Sri Lanka'
order by 1,2;

-- Total cases Vs population

select location, date,total_cases,population,(total_cases/population)*100 as GetingCovidPercentage
from p..CovidDeaths
where location='Sri Lanka'
order by 1,2;

-- Countries of highest Infection Rate

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as HighestInfectionrate
from p..CovidDeaths
group by location,population
order by HighestInfectionrate desc;

--- countries of highest death rate

select location,population,max(cast(total_deaths as int)) as HighestDeathCount, max((total_deaths/population)*100) as HighestDeathRate
from p..CovidDeaths
group by location,population
order by HighestDeathRate desc;


-- Death Count by continent

select continent,max(cast(total_deaths as int)) as HighestDeathCount
from p..CovidDeaths
where continent is not null
group by continent 
order by HighestDeathCount desc;

-- New cases and Deaths Vs date

select date, sum(new_cases),sum(cast(new_deaths as int))
from p..CovidDeaths
group by date 
order by 2,3; 

-- Death percentage per day

select date, SUM(new_cases), sum(cast(new_deaths as int)), (SUM(cast(new_deaths as int))/nullif(sum(new_cases),0)*100)
from p..CovidDeaths
group by date
order by 4;

select SUM(new_cases), sum(cast(new_deaths as int)), (SUM(cast(new_deaths as int))/nullif(sum(new_cases),0)*100)
from p..CovidDeaths

-- population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as PeopleVaccinated
from p..CovidDeaths dea
join p..CovidVaccinations vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null
order by 2,3;


-- Total vaccinated population

with PopVsVac (continent,location,date,population,new_vaccinations,PeopleVaccinated)as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as PeopleVaccinated
from p..CovidDeaths dea
join p..CovidVaccinations vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null)

select *, (PeopleVaccinated/population)*100 as vaccinationRate
from PopVsVac;

--TEMP table

create table #PercentVaccination
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

insert into #PercentVaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as PeopleVaccinated
from p..CovidDeaths dea
join p..CovidVaccinations vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null

select *, (PeopleVaccinated/population)*100 as vaccinationRate
from #PercentVaccination;


create view PercentVaccination as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(convert(int, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as PeopleVaccinated
from p..CovidDeaths dea
join p..CovidVaccinations vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null


select * from PercentVaccination;
