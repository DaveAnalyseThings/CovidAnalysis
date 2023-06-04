-- CREATE TABLE coviddeath (
-- iso_code varchar(20),	
-- continent varchar(20),	
-- location varchar(50),
-- date date,
-- population bigint,	
-- total_cases int,
-- new_cases int,
-- new_cases_smoothed decimal,	
-- total_deaths int,	
-- new_deaths int,	
-- new_deaths_smoothed decimal,
-- total_cases_per_million decimal,	
-- new_cases_per_million decimal,	
-- new_cases_smoothed_per_million decimal,	
-- total_deaths_per_million decimal,	
-- new_deaths_per_million decimal,	
-- new_deaths_smoothed_per_million	decimal,
-- reproduction_rate decimal,	
-- icu_patients int,
-- icu_patients_per_million decimal,
-- hosp_patients int,	
-- hosp_patients_per_million decimal,
-- weekly_icu_admissions decimal,
-- weekly_icu_admissions_per_million decimal,
-- weekly_hosp_admissions	decimal,
-- weekly_hosp_admissions_per_million decimal
-- );

-- DROP TABLE coviddeath;

-- COPY PUBLIC.coviddeath FROM 'C:\Users\Administrator\Desktop\CovidDeath.csv' WITH CSV HEADER;

-- SELECT * FROM coviddeath

-- CREATE TABLE covidvacc (
-- iso_code varchar(20),	
-- continent varchar(20),	
-- location varchar(50),	
-- date date,
-- new_tests int,	
-- total_tests int,	
-- total_tests_per_thousand decimal,
-- new_tests_per_thousand decimal,	
-- new_tests_smoothed int,
-- new_tests_smoothed_per_thousand decimal,
-- positive_rate decimal,
-- tests_per_case decimal,	
-- tests_units	varchar(20), 
-- total_vaccinations	int,
-- people_vaccinated int,	
-- people_fully_vaccinated int,	
-- new_vaccinations int,
-- new_vaccinations_smoothed int,	
-- total_vaccinations_per_hundred decimal,
-- people_vaccinated_per_hundred decimal,
-- people_fully_vaccinated_per_hundred	decimal,
-- new_vaccinations_smoothed_per_million int,
-- stringency_index decimal,
-- population_density decimal,
-- median_age decimal,
-- aged_65_older decimal,
-- aged_70_older decimal,
-- gdp_per_capita decimal,
-- extreme_poverty decimal,
-- cardiovasc_death_rate decimal,
-- diabetes_prevalence decimal,
-- female_smokers decimal,
-- male_smokers decimal,
-- handwashing_facilities decimal,
-- hospital_beds_per_thousand decimal,
-- life_expectancy decimal,
-- human_development_index decimal
-- );

-- COPY PUBLIC.covidvacc FROM 'C:\Users\Administrator\Desktop\Data Analytics\Data Analytics Bootcamp\CovidVacc.csv' WITH CSV HEADER;

-- SELECT * FROM covidvacc

-- DATA TO USE
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeath
ORDER BY 1,2

-- Total Case vs Total Death
SELECT location, date, total_cases, total_deaths,
ROUND(CAST(total_deaths AS decimal)/CAST(total_cases AS decimal)*100,2) as DeathPercentage
FROM coviddeath
-- WHERE location = 'Romania'
ORDER BY 1,2

-- Total Case vs Population percent of infected
SELECT location, date, total_cases, population,
ROUND(CAST(total_cases AS decimal)/CAST(population AS decimal),2)
FROM coviddeath

ORDER BY 1,2

-- Country with Highest infection rate
SELECT location, population, MAX(total_cases) AS highestinfectioncount,
ROUND(MAX(CAST(total_cases AS numeric)/CAST(population AS numeric))*100,2) AS percentpopulationinfection
FROM coviddeath
WHERE total_cases IS NOT NULL
GROUP BY location, population
ORDER BY 1,2 DESC;

-- countries with highest death count per population
SELECT location, MAX(total_deaths) AS highestdeathcount
FROM coviddeath
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY highestdeathcount DESC;

-- BY CONTINENT : HIGHEST DEATH COUNT
SELECT continent, MAX(total_deaths) AS highestdeathcount
FROM coviddeath
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY continent
ORDER BY highestdeathcount DESC;


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS totalcases, sum(new_deaths) AS totaldeaths, --total_cases, total_deaths,
ROUND(CAST(sum(new_deaths) AS decimal)/CAST(SUM(new_cases) AS decimal)*100,2) as DeathPercentage
FROM coviddeath
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1

-- Total Population vs. Total Vaccionation
WITH popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevacc)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevacc
FROM coviddeath dea
JOIN covidvacc vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
)
SELECT *, (rollingpeoplevacc/population)*100 AS vaccpercent FROM popvsvac

-- TEMP TABLE
DROP TABLE IF EXISTS percentpeoplevacc;
CREATE TEMPORARY TABLE percentpeoplevacc (
continent varchar (255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
rollingpeoplevacc numeric);

INSERT INTO percentpeoplevacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevacc
FROM coviddeath dea
JOIN covidvacc vac
ON dea.location = vac.location AND dea.date = vac.date;
--WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3;
SELECT * FROM percentpeoplevacc;

-- CREATE VIEW FOR PROCEDURE

SELECT continent, MAX(total_deaths) AS highestdeathcount
FROM coviddeath
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY continent
ORDER BY highestdeathcount DESC;

CREATE VIEW percentpeoplevacc AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevacc
FROM coviddeath dea
JOIN covidvacc vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
)

SELECT * FROM percentpeoplevacc