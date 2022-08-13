use [Portfolio Project ]

select * from CovidVaccinations$

select * from [dbo].[CovidDeaths$] where continent is null
---Data Exploration -----------------
select location ,date, total_cases,new_cases,total_deaths,population from [Portfolio Project ]..CovidDeaths$
ORDER BY 1,2


--looking at total cases vs deaths 

select location ,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from [Portfolio Project ]..CovidDeaths$
where location='United states'
ORDER BY 1,2

----LOOKING AT Total Caes vs Population 

select location ,date, total_cases,population,(total_cases/population)*100 as death_percentage
from [Portfolio Project ]..CovidDeaths$
--where location='United states'
ORDER BY 1,2


---Looking at countries with highest infection with population 
select location, max(total_cases) as Highest_Infections,population,max((total_cases/population))*100 as perecent_population_infected
from [Portfolio Project ]..CovidDeaths$
group by population,location
--where location='United states'
ORDER BY perecent_population_infected desc


---countries with highest death rate per pop
select location, max(cast(total_deaths as int))as total_deathcount
from [Portfolio Project ]..CovidDeaths$
where continent is not null
group by location
--where location='United states'
ORDER BY total_deathcount desc


----break it  b continent
select continent, max(cast(total_deaths as int))as total_deathcount
from [Portfolio Project ]..CovidDeaths$
where continent is not null
group by continent
ORDER BY total_deathcount desc


----Global Numbers 
select SUM(new_cases),sum(cast(new_deaths as int)),SUM(cast(new_deaths as int))/SUM(new_cases)*100
from [Portfolio Project ]..CovidDeaths$
--where location='United states'
where continent is not null
--group by date
ORDER BY 1,2

----Joins
---total pop vs vaccinated
select d.continent,d.location,d.date,population,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int))over (partition by d.location order by d.date) as rolling_peopleVaccinated,
from [CovidDeaths$] d
join [CovidVaccinations$] v
on d.location=v.location and d.date =v.date 
where d.continent is not null
order by d.location,d.date

--with cte 
With Popvsvacs (continent,location,date,population,new_vaccinations,rolling_peopleVaccinated)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations))over (partition by d.location order by d.date,d.location) as rolling_peopleVaccinated
from [CovidDeaths$] d
join [CovidVaccinations$] v
on d.location=v.location 
and 
d.date =v.date 
where d.continent is not null)
--order by 2,3
select *,(rolling_peopleVaccinated / population)*100 as rolling_pop
from Popvsvacs

--temp table 
drop table if exists #tempPopvsvac
create table #tempPopvsvac
(continent varchar(255),location varchar(255),date datetime,population numeric,new_vaccinations numeric,rolling_peopleVaccinated numeric)

insert into #tempPopvsvac
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations))over (partition by d.location order by d.date,d.location) as rolling_peopleVaccinated
from [CovidDeaths$] d
join [CovidVaccinations$] v
on d.location=v.location 
and 
d.date =v.date 
where d.continent is not null
--order by 2,3
select *,(rolling_peopleVaccinated / population)*100 as rolling_pop
from  #tempPopvsvac

--creating view
create view percentage_pop_vacinnated as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations))over (partition by d.location order by d.date,d.location) as rolling_peopleVaccinated
from [CovidDeaths$] d
join [CovidVaccinations$] v
on d.location=v.location 
and 
d.date =v.date 
where d.continent is not null

select * from percentage_pop_vacinnated
