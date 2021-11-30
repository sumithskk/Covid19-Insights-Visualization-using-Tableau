--Add new column of month and year 
ALTER TABLE dbo.coviddata$ DROP COLUMN IF EXISTS yearmonth
ALTER TABLE dbo.coviddata$ ADD yearmonth varchar(255);
UPDATE dbo.coviddata$ SET yearmonth  =  (cast(year(CONVERT(date,DATE)) as varchar)+ '-' +cast(FORMAT(date,'MM') as varchar))
--UPDATE dbo.coviddata$ SET yearmonth = FORMAT(date,'Y') 

--create table with selected columns
DROP Table if exists covidcasesforlastfewmonths
Create Table covidcasesforlastfewmonths
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
yearmonth varchar(255),
Total_cases numeric,
New_cases numeric,
Total_deaths numeric,
New_deaths numeric,
Population numeric,
)
Insert into covidcasesforlastfewmonths
Select cov.continent, cov.location, CONVERT(date,DATE),cov.yearmonth,cov.total_cases,cov.new_cases,cov.total_deaths,cov.new_deaths,cov.population
From dbo.coviddata$ as cov
where yearmonth>='2021-08'


-- Total cases by continent from august 2021
select location,MAX(cast(Total_cases as int)) as TotalCasesCount,SUM(New_cases) as TotalCasesFromAugust2021,
(SUM(New_cases)/MAX(cast(Total_cases as int)))*100 as PercentageChangeinCasesFromAugust
from dbo.covidcasesforlastfewmonths
where continent is null
and location  in ('Europe','Asia','South America','North America','Africa','Oceania')
group by location
order by  PercentageChangeinCasesFromAugust desc


-- Total Deaths by continent from august 2021
select location,MAX(cast(Total_deaths as int)) as TotalDeathsCount,SUM(New_deaths) as TotalDeathsFromAugust2021,
(SUM(New_deaths)/MAX(cast(Total_deaths as int)))*100 as PercentageChangeinDeathsFromAugust
from dbo.covidcasesforlastfewmonths
where continent is null
and location  in ('Europe','Asia','South America','North America','Africa','Oceania')
group by location
order by  PercentageChangeinDeathsFromAugust desc


--Monthly cases and deaths BY Continents
select continent,yearmonth,SUM(New_cases) as MonthlyCases,SUM(CAST(New_deaths as int)) as MonthlyDeaths
from dbo.coviddata$
where continent is not null
group by continent,yearmonth
order by continent,yearmonth

-- Cases and deaths by location 
select location,MAX(cast(Total_cases as int)) as TotalCasesCount,SUM(New_cases) as TotalCasesFromAugust2021,
(SUM(New_cases)/MAX(cast(Total_cases as int)))*100 as PercentageChangeinCasesFromAugust,
convert(DOUBLE PRECISION,round((MAX(cast(Total_cases as int))/MAX(Population))*100,2)) as HighestInfectionRate,
MAX(cast(Total_deaths as int)) as TotalDeathsCount,SUM(New_deaths) as TotalDeathsFromAugust2021,
(SUM(New_deaths)/MAX(cast(Total_deaths as int)))*100 as PercentageChangeinDeathsFromAugust,
convert(DOUBLE PRECISION,round((MAX(cast(Total_deaths as int))*100/MAX((Total_cases))),2)) as HighestDeathRate,
MAX(Population) as Population
from dbo.covidcasesforlastfewmonths
where continent is not null  
group by location
--having (SUM(New_cases)/MAX(cast(Total_cases as int)))*100 > 20 and 
--MAX(Population) > 40000000
order by  TotalCasesFromAugust2021 desc

-- Percent of population Infected by location and date
select continent,SUM(total_cases) as total_cases
from dbo.coviddata$
where continent is not NULL 
group by continent
order by continent

-- Total cases and deaths by continent as a time series
select continent,CONVERT(date,DATE) as Date,SUM(total_cases) as total_cases, SUM(CAST(total_deaths as int)) as total_deaths
from dbo.coviddata$
where continent is not null
group by continent,date
order by continent,date