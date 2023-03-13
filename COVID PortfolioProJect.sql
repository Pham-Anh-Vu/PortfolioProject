create database if not exists PortfolioProject;
use PortfolioProject;


select * from coviddeaths where new_cases = 13;
select * from covidvaccinations;


alter table coviddeaths add column date_col date;
update coviddeaths set date_col = STR_TO_DATE(date, '%m/%d/%Y');
alter table coviddeaths modify date_col date after date;
alter table coviddeaths drop column date;


select * from coviddeaths
where continent = null;

select location, date_col, total_cases, new_cases, total_deaths, population
from coviddeaths;


-- so sánh giữa total_cases với total_deaths
select location, date_col, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like "%Viet%";

-- so sánh giữa total_cases với population
select location, date_col, total_cases, population, (total_cases/population)*100 as PercentageInfection
from coviddeaths
where location like "%Viet%";


-- tỉ lệ phần trăm nhiễm cao nhất
with table1 as(
select location, date_col, total_cases, population, (total_cases/population)*100 as PercentageInfection
from coviddeaths
where location like "%Viet%")
select location, max(PercentageInfection) as maxPercentageInfection
from table1;


-- Tìm ngày có tỷ lệ nhiễm cao nhất
with table1 as(
SELECT location, date_col, total_cases, population, (total_cases/population)*100 as PercentageInfection
FROM coviddeaths
where location like "%Viet%"
) 
select * from table1
where PercentageInfection = (select max(PercentageInfection) from table1);


-- tìm nước có tỷ lệ nhiễm cao nhất
with table1 as(
SELECT location, date_col, total_cases, population, (total_cases/population)*100 as PercentageInfection
from coviddeaths)
select * from table1
where PercentageInfection = (select max(PercentageInfection) from table1);


-- tìm nước có tỷ lệ người tử vong cao nhất nhất tính đến năm 2023
with table1 as(
SELECT location, date_col, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where date_col like "%2023-03-05%"
)
select * from table1 
where DeathPercentage = (select max(DeathPercentage) from table1);
  
 
 -- số ca nhiễm 1 ngày
select date_col, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths
from coviddeaths
where continent is not null
group by date_col;


-- kết hợp 2 bảng và tính số lượng vacination
select dea.continent, dea.location, dea.date_col, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by location order by dea.location, dea.date_col) as vaccination
from coviddeaths dea
join covidvaccinations as vac
on dea.location = vac.location and dea.date_col = vac.date_col
where dea.continent not like ""
order by 1,2,3; 


-- use cte
with PopvsVac as(
select dea.continent, dea.location, dea.date_col, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by location order by dea.location, dea.date_col) as vaccination
from coviddeaths dea
join covidvaccinations as vac
on dea.location = vac.location and dea.date_col = vac.date_col
where dea.continent not like ""
order by 1,2,3
)
select *, (vaccination/population)*100 as VaccinatedPercentage from PopvsVac;


-- temp table
drop table PercentPopulationVaccinated;
create table PercentPopulationVaccinated(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population varchar(255),
New_vaccinations varchar(255),
RollingPeopleVaccinated varchar(255),
VaccinatedPercentage varchar(255)
);

Insert into PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date_col, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by location order by dea.location, dea.date_col) as vaccination, (sum(vac.new_vaccinations) over (partition by location order by dea.location, dea.date_col)/population)*100
from coviddeaths dea
join covidvaccinations as vac
on dea.location = vac.location and dea.date_col = vac.date_col
where dea.continent not like ""
order by 1,2,3;

select * from PercentPopulationVaccinated;


-- create view to store date
drop view PercentPopulationVaccinated1;
create view PercentPopulationVaccinated1 as 
select dea.continent, dea.location, dea.date_col, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by location order by dea.location, dea.date_col) as vaccination, (sum(vac.new_vaccinations) over (partition by location order by dea.location, dea.date_col)/population)*100 as VaccinatedPercentage
from coviddeaths dea
join covidvaccinations as vac
on dea.location = vac.location and dea.date_col = vac.date_col
where dea.continent not like ""
order by 1,2,3;


