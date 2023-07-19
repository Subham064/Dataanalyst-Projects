SELECT * FROM dataexploreproject..covidDeaths 
order by 3,4
SELECT Location,date,total_cases,new_cases,total_deaths, population_density
FROM dataexploreproject..covidDeaths
order by 1,2

--Total Cases vs Total Deaths
-- Shows the probabilty of deaths if covid contracts in country

SELECT Location,date,total_cases,new_cases,total_deaths, (CAST (total_deaths AS float)/ CAST (total_cases AS float))*100 as DeathPercentage
FROM dataexploreproject..covidDeaths
WHERE location like '%states%'
order by 1,2 

-- Total Cases vs Population
-- % of Population got covid
SELECT Location,date,total_cases, population_density, (CAST (total_cases AS float)/population_density )*100 as InfectedPercentage
FROM dataexploreproject..covidDeaths
WHERE location like '%states%'
order by 1,2

-- Countries with Highest Infection Rates as compared to population

SELECT Location,population_density,MAX(CAST (total_cases AS float))  as HighestInfected , Max(CAST (total_cases AS float)/population_density )*100 as HighestInfectedPercentage
FROM dataexploreproject..covidDeaths
--WHERE location like '%states%'
group by Location, population_density
order by HighestInfectedPercentage desc

--ccountries with highest death  count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From dataexploreproject..covidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From dataexploreproject..covidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From dataexploreproject..covidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Populations vs vaccination

select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
SUM (cast (vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date)  as RollingPeopleVaccinated
From dataexploreproject..covidDeaths dea
Join dataexploreproject..CovidVaccinations vac
    on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null 
order by 1,2,3

-- using CTE 

With PopualionvsVacc (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
SUM (cast (vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date)  as RollingPeopleVaccinated
From dataexploreproject..covidDeaths dea
Join dataexploreproject..CovidVaccinations vac
    on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null 
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as rolling_percentage
From  PopualionvsVacc

-- using temp table

DROP Table if exists Percent_PopulationVaccinated
Create Table Percent_PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into Percent_PopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
SUM (cast (vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date)  as RollingPeopleVaccinated
From dataexploreproject..covidDeaths dea
Join dataexploreproject..CovidVaccinations vac
    on dea.location = vac.location and dea.date=vac.date
--where dea.continent is not null 
--order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From Percent_PopulationVaccinated

-- create view for later visualization
Create View Percent__PopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
SUM (cast (vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date)  as RollingPeopleVaccinated
From dataexploreproject..covidDeaths dea
Join dataexploreproject..CovidVaccinations vac
    on dea.location = vac.location and dea.date=vac.date
--where dea.continent is not null 
select * from Percent__PopulationVaccinated
