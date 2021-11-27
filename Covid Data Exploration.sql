use [Portfolio Project]
select * from [covid deaths]
order by location, date

select * from [covid vaccinations]
order by location, date


select location, date, total_cases, new_cases, total_deaths, population  from [covid deaths]
order by location, date

--Total Cases vs Total Deaths
-- Shows likelihood of dying after contracting Covid-19
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [covid deaths] 
--where location = 'India'
order by location, date

--Total cases vs Population
--Shows what Percentage of the popuation got covid
select location, date, total_cases, population, (total_cases/population)*100 as affected_percentage
from [covid deaths] 
where continent is not null
--where location = 'India'
order by location, date

--Looking at countries with highest infection rate per population
select location, max(total_cases) as Highest_infection_count, population, 
max((total_cases/population)) * 100 as percentage_population_affected
from [covid deaths]
where continent is not null
group by location, population
order by percentage_population_affected desc

--Looking at countries with most deaths
select location, max(cast(total_deaths as int)) as total_death_count from [covid deaths]
where continent is not null
group by location
order by total_death_count desc

--Looking at continents with most deaths
select continent, max(cast(total_deaths as int)) as total_death_count from [covid deaths]
where continent is not null
group by continent
order by total_death_count desc

--Global death Percentage
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage from [covid deaths]
where continent is not null




--Looking at Total Population vs People Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
--,(Rolling_people_vaccinated)/population *100 - We can't do this without creating Temp Table
from [covid deaths] dea
join [covid vaccinations] vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3



--------Creating Temp Table--------
drop table if exists PercentPopulationVaccinated

create table PercentPopulationVaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations bigint,
rolling_people_vaccinated bigint)

insert into PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
from [covid deaths] dea
join [covid vaccinations] vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (rolling_people_vaccinated/population) *100 as percent_pop_vaccinated from PercentPopulationVaccinated


-----------Creating Views for future Visualization---------
create view percent_population_vaccinated as
select *, (rolling_people_vaccinated/population) *100 as percent_pop_vaccinated from PercentPopulationVaccinated




