--Select *
--From PortfolioProject..CovidVaccinations
--Where continent is not null
--order by 3,4

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select Location, date, total_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, Population, (Cast(total_deaths AS FLOAT)/Cast(total_cases AS FLOAT))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, Population, total_cases,  
	(Cast(total_cases AS FLOAT)/Cast(population AS FLOAT))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, 
Max((Cast(total_cases AS FLOAT)/Cast(population AS FLOAT)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET's BREAK THINGS DOWN BY CONTINENT


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Gobal Numbers
Select  date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null
Group By date
Having SUM(new_cases) > 0
order by 1,2


-- Looking at Toral Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinated,
	--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated

create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
	--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
	dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated