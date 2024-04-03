-- View the imported data for reference
Select *
From coviddeaths
order by 3, 4

--Select the data that is being used
Select location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
Where continent is not null
Order by 1,2

--Finding Total Cases vs Total Deaths as Death Percentage
-- Shows the likelihood of dying if infected with Covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From coviddeaths
Where continent is not null
Order by 1,2

--Finding the Total Cases vs Population
--Shows the percentage of population with Covid
Select location, date, total_cases, (total_cases/population)*100 AS cases_percentage
From coviddeaths
Where continent is not null
Order by 1,2

-- Finding the countries with the highest infection rate compared to population
Select location, population, MAX(total_cases) AS population_infected, MAX((total_cases/population))*100 AS percentpopulationinfected
From coviddeaths
Where continent is not null
Group By location, population
Order by percentpopulationinfected desc

-- Finding the countries with the highest death rate from Covid
Select location, population, MAX(total_deaths) AS total_death_count
From coviddeaths
Where continent is not null
Group By location, population
Order by total_death_count desc

-- Finding the continent with the highest death rate from Covid
Select continent, MAX(total_deaths) AS total_death_count
From coviddeaths
Where continent is not null
Group By continent
Order by total_death_count desc

--Finding the total number of new cases by continent
Select continent, MAX(new_cases) AS new_cases_count
From coviddeaths
Where continent is not null
Group By continent
Order by new_cases_count desc

--Finding percentage of new deaths by contintent
Select continent, sum(new_cases) as new_cases, sum(new_deaths) as new_deaths,
sum(new_deaths)/sum(new_cases)*100 AS new_deaths_percentage
From coviddeaths
Where continent is not null AND new_deaths >0 and new_cases >0
Group By continent
Order by new_deaths_percentage DESC

--Joining the two tables to test
Select*
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date

--Finding Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3

--Calculating a rolling count of people vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) AS rolling_count
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Use of CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_count)
As (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) AS rolling_count
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (rolling_count/population)*100 as rolling_percentage
From PopvsVac

--Creating Temp table

Create Table PercentPeopleVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPeopleVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) AS rolling_count
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as Rolling_percentage
From PercentPeopleVaccinated

--Creating View to Store Data for Visualizations

Create View PercentPeopleVaccinated1 AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) AS rolling_count
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
