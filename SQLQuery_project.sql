Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



--Total deaths Vs Vaccinations 

Select death.continent, death.location, death.population , vaccin.new_vaccinations
from PortfolioProject..CovidDeaths death
JOIN PortfolioProject.[dbo].COVIDVACCINATIONS_corrected vaccin
on death.location = vaccin.location 
and death.date = vaccin.date
where vaccin.continent is not null
order by 1,2,3

--Looking at Total Populations Vs Vaccinations

Select death.continent, death.location, death.population , vaccin.new_vaccinations,
SUM(cast(vaccin.new_vaccinations as bigint)) Over  (partition by death.location order by death.location, death.date) as people_vaccinated
from PortfolioProject..CovidDeaths death
JOIN PortfolioProject.[dbo].COVIDVACCINATIONS_corrected vaccin
on death.location = vaccin.location 
and death.date = vaccin.date
where vaccin.continent is not null
order by 1,2,3


--select new_vaccinations from
--PortfolioProject..COVIDVACCINATIONS_corrected

--select new_deaths from
--PortfolioProject..CovidDeaths
--where new_deaths is null


--select continent, location, population,  sum(cast(new_vaccinations as bigint)) as sumofvaccin
--from PortfolioProject..COVIDVACCINATIONS_corrected
--where continent is not null
--group by continent , location, population


With PopvsVac (Continent, Location, Population,new_vaccinations, people_vaccinated)
as
(
Select death.continent, death.location, death.population , vaccin.new_vaccinations,
SUM(cast(vaccin.new_vaccinations as bigint)) Over  (partition by death.location order by death.location, death.date) as people_vaccinated
from PortfolioProject..CovidDeaths death
JOIN PortfolioProject.[dbo].COVIDVACCINATIONS_corrected vaccin
on death.location = vaccin.location 
and death.date = vaccin.date
where vaccin.continent is not null
--order by 2,3
)
Select * , (people_vaccinated/Population)*100 as percent_vaccinated_percent
from
PopvsVac



--Creating table for the peoplevaccinated vs population


Drop table if exists #PeopleVaccinated_Percentage
create table #PeopleVaccinated_Percentage
(
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
New_vaccinations numeric,
People_vaccinated numeric
)

Insert into #PeopleVaccinated_Percentage
Select death.continent, death.location,death.date, death.population , vaccin.new_vaccinations,
SUM(cast(vaccin.new_vaccinations as bigint)) Over  (partition by death.location order by death.location, death.date) as people_vaccinated
from PortfolioProject..CovidDeaths death
JOIN PortfolioProject.[dbo].COVIDVACCINATIONS_corrected vaccin
on death.location = vaccin.location 
and death.date = vaccin.date
--where vaccin.continent is not null

Select * , (people_vaccinated/Population)*100 
from
#PeopleVaccinated_Percentage


Create View PeopleVaccinatedPercentageView as
Select death.continent, death.location,death.date, death.population , vaccin.new_vaccinations,
SUM(cast(vaccin.new_vaccinations as bigint)) Over  (partition by death.location order by death.location, death.date) as people_vaccinated
from PortfolioProject..CovidDeaths death
JOIN PortfolioProject.[dbo].COVIDVACCINATIONS_corrected vaccin
on death.location = vaccin.location 
and death.date = vaccin.date
where vaccin.continent is not null
