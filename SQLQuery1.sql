SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjetoCovid1..CovidDeaths
ORDER BY 1, 2

-- Casos totais vs Mortes totais

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ProjetoCovid1..CovidDeaths
ORDER BY 1, 2