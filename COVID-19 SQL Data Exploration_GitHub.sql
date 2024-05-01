

			/*
				Covid 19 Data Exploration 

				Skills used: Operators, Aggregate Functions, Converting Data Types, Joins, CTE, Temp Table, Creating Views

			*/

	
	-- Checking if data is imported properly

		select * 
		from PortfolioProject..Covid_Deaths;

		select * 
		from PortfolioProject..Covid_Vaccinations;

	-- Just to start with
		
		select location, date, total_cases, new_cases, total_deaths, population
		from PortfolioProject..Covid_Deaths
		ORDER BY 1, 2;   
			

	-- 1. Total Cases vs. Total Deaths By the Country & Continent (what are the percentage of people who died for their the total cases)
	-- Shows likelihood of dying if you contract covid in your country 

		select location, continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
		from PortfolioProject..Covid_Deaths
		where location LIKE '%India%'
		ORDER BY 1, 3;
			

	-- 2. Total Cases vs. Population By the Country & Continent (what percentage of population got COVID)
	-- Shows what percentage of population infected with Covid

		select location, continent, date, total_cases, population, (total_cases/population)*100 AS Percenage_Of_Population_Infected
		from PortfolioProject..Covid_Deaths
		where location LIKE '%India' AND date = '2020-12-31'
		ORDER BY 1, 3;
		

	-- 3. Countries With Highest Infection Rate Compared to Population (what percentage of your population got COVID, that's been reported and 

		select location, continent, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/Population))*100 AS Percenage_Of_Population_Infected
		from PortfolioProject..Covid_Deaths
		GROUP BY location, continent, population 
		ORDER BY Percenage_Of_Population_Infected DESC;
			

	--4.  Countries with Highest Death Count per Population

		select location, continent, MAX(cast(total_deaths as int)) AS Total_Death_Count 
		from PortfolioProject..Covid_Deaths 
		where continent IS NOT NULL
		GROUP BY location, continent 
		ORDER BY Total_Death_count DESC;
			

	 -- BREAKING DOWN BY CONTINENT
	 
	 -- 5. Continents with Highest Death Count per Population

		select continent, MAX(cast(total_deaths as int)) AS Total_Death_Count
		from PortfolioProject..Covid_Deaths
		where continent IS NOT NULL
		GROUP BY continent
		ORDER BY Total_Death_Count ASC;
			

	-- RETRIVING GLOBAL NUMBERS
	
	-- 6. Total of Daily New_Cases and New_Deaths around the world (i.e. not filtering out by countries or continents)

		select date, SUM(new_cases) AS Daily_New_Cases_Around_The_World, SUM(cast (new_deaths as int)) AS Daily_New_Death_Around_The_World	
		from PortfolioProject..Covid_Deaths
		GROUP BY date
		ORDER BY date, Daily_New_Cases_Around_The_World, Daily_New_Death_Around_The_World;


	-- 7. Just Joining 2 tables on 2 different columns.
		select *
		from PortfolioProject..Covid_Deaths Dea
		JOIN PortfolioProject..Covid_Vaccinations Vac
			ON Dea.location = Vac.location
			AND Dea.date = Vac.date;

	-- 8. Total Population vs. New Vaccinantion Per Day (what is the total amount of people in the world that have been vaccinated)
	-- Shows Percentage of Population that has recieved at least one Covid Vaccine	
		
		select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
		,SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS Rolling_Count_People_Vaccinated_Daily
		from PortfolioProject..Covid_Deaths Dea
		JOIN PortfolioProject..Covid_Vaccinations Vac
			ON Dea.location = Vac.location
			AND Dea.date = Vac.date
		where Dea.continent IS NOT NULL
		ORDER BY 2, 3;

			
	-- 9. Total How Many People In That Country Is Vaccinated
	-- Using a CTE to perform Calculation on PARTITION BY in previous query

		WITH TotalPopulation_vs_Vaccination (continent, location, date, population, new_vaccinations, Rolling_Count_People_Vaccinated_Daily)
		AS 
		(
		select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
		,SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS Rolling_Count_People_Vaccinated_Daily
		from PortfolioProject..Covid_Deaths Dea
		JOIN PortfolioProject..Covid_Vaccinations Vac
			ON Dea.location = Vac.location
			AND Dea.date = Vac.date
		where Dea.continent IS NOT NULL
		)
		select *, (Rolling_Count_People_Vaccinated_Daily/population)*100 AS Percentage_Of_Rolling_Count_People_Vaccinated_Daily
		from TotalPopulation_vs_Vaccination
		where location LIKE '%Albania%';


	-- 10. TEMP TABLE
	-- Using TEMP TABLE to perform Calculation on PARTITION BY in previous query

		DROP TABLE IF EXISTS #TotalPopulation_vs_Vaccination;

		CREATE TABLE #TotalPopulation_vs_Vaccination (
		continent varchar(50),
		location varchar(50),
		date datetime,
		population int,
		new_vaccinations int,
		Rolling_Count_People_Vaccinated_Daily int
		);

		INSERT INTO #TotalPopulation_vs_Vaccination
		select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
		,SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS Rolling_Count_People_Vaccinated_Daily
		from PortfolioProject..Covid_Deaths Dea
		JOIN PortfolioProject..Covid_Vaccinations Vac
			ON Dea.location = Vac.location
			AND Dea.date = Vac.date
		where Dea.continent IS NOT NULL

		select *, (Rolling_Count_People_Vaccinated_Daily/population)*100 AS Percentage_Of_Rolling_Count_People_Vaccinated_Daily
		from #TotalPopulation_vs_Vaccination
		where location LIKE '%Albania%' AND date = '2021-01-13';
			
			
	-- 11. CREATING VIEW
	-- Creating View to store data for later visualizations
	
	-- A VIEW for Continents with Highest Death Count per Population

		CREATE VIEW  TotalPopulation_vs_Vaccination AS
		select continent, MAX(cast(total_deaths as int)) AS Total_Death_Count
		from PortfolioProject..Covid_Deaths
		where continent IS NOT NULL
		GROUP BY continent;
		
		select * from TotalPopulation_vs_Vaccination;
