SELECT * 
FROM Project.dbo.Data1;

SELECT * 
FROM Project.dbo.[data 2];
--number of rows into dataset

SELECT count(*) from Project..Data1;
SELECT count(*) from Project..[data 2];
--dataset for jharkhand and bihar

SELECT * from project.. Data1
WHERE state in ('Jharkhand' , ' Bihar')
--total population of india

select sum(population) as population
from Project..[data 2]

--avg growth

select state,avg(growth)*100 avg_growth
from project..Data1 group by State;
--avg sex ratio

select state,round(avg(Sex_Ratio),0) avg_sex_ratio 
from project..Data1 group by State order by avg_sex_ratio desc;
--avg literacy rate

 select state,round(avg(Literacy),0) avg_literacy_ratio 
from project..Data1 group by State having round(avg(Literacy),0)>90 order by avg_literacy_ratio desc;

--top 3 states with highest growth ratio
select top 3 state,avg(growth)*100 avg_growth
from project..Data1 group by State order by avg_growth desc;

--bottom 3 states with lowest sex ratio
select top 3 state,round(avg(Sex_Ratio),0) avg_sex_ratio 
from project..Data1 group by State order by avg_sex_ratio asc;
--top and botoom 3 states in literacy rate

drop table if exists #topstates;
create table #topstates
(state nvarchar(255),
 topstates float

 )

insert into #topstates
select state,round(avg(Literacy),0) avg_literacy_ratio 
from project..Data1
group by State order by avg_literacy_ratio desc;

select top 3 * from #topstates order  by #topstates.topstates desc;

-- bottom 3
drop table if exists #bottomstates;
create table #bottomstates
(state nvarchar(255),
 bottomstates float

 )

insert into #bottomstates
select state,round(avg(Literacy),0) avg_literacy_ratio 
from project..Data1
group by State order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order  by #bottomstates.bottomstates asc;

--union operator
Select * from (
select top 3 * from #topstates order  by #topstates.topstates desc)a

union

select * from(
select top 3 * from #bottomstates order  by #bottomstates.bottomstates asc)b;

--states starting with a

select Distinct state from project..Data1 
where lower(state) like 'a%' or lower(state) like 'b%';

select Distinct state from project..Data1 
where lower(state) like 'a%' and lower(state) like '%m';

--joining two tables
--total males and females
select d.state,sum(d.males) total_males,sum(d.females) total_females from 
(select c.district,c.state state,round(c.population/(c.Sex_Ratio+1),0) males,round((c.population *c.Sex_Ratio)/(c.Sex_Ratio+1),0) females from
(select a.district, a.state,a.sex_ratio/1000 sex_ratio,b.Population
from project..Data1 a inner join project..[data 2] b on a.district = b.district) c) d
group by d.state;

--total literacy rate

select c.state,sum(literate_people) total_literate_pop, sum(illeterate_people) total_illiterate_pop from
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,round((1-d.literacy_ratio)*d.population,0) illeterate_people from
(select a.district, a.state,a.literacy/100 literacy_ratio,b.Population
from project..Data1 a inner join project..[data 2] b on a.district = b.district)d) c
group by c.state;

--population in previous census

select sum(m.previous_census_population), sum(m.current_census_population) from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district, a.state,a.growth growth,b.Population
from project..Data1 a inner join project..[data 2] b on a.district = b.district)d )e
group by e.state)m

--window functions

output top 3 districts from each state with highest literacy rate

select a.*from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from project..Data1) a

where a.rnk in (1,2,3) order by state