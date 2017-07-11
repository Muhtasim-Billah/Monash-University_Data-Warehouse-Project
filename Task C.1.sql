--Create airport_dim
create table airline_dim as
(select al.Airlineid, al.name, al.Country, al.active, 
  round(1/ count(av.serviceid),2) as WeightFactor, 
  listagg(av.serviceid,'_') within group (order by av.serviceid) as servicegrouplist
from airlines1 al, Airline_Services1 av, Provides1 p
where al.airlineid = p.airlineid
And p.serviceid = av.serviceid
group by al.Airlineid, al.name, al.Country, al.active);

--Create provides_bridge
create table Provides_Bridge as 
select distinct * from provides1;

--Create service_dim
create table Service_dim as 
select distinct * from airline_services1;

--Create source_airport_dim
create table Source_airport_dim as
select * from airports1; 

--Create dest_airport_dim
create table Dest_airport_dim as
select * from airports1; 

--Create Routes Temporary Fact Table
create table temp_route_fact as
select distinct sourceairportid, destairportid, r.AIRLINEID, r.routeid, distance, servicecost 
from routes1 r, airlines1 al 
where r.airlineid = al.airlineid;

--Alter Temporary Routes Fact to add a column for List_Agg
alter table temp_route_fact add (service_list varchar2(50));

--Update temporary_fact with List Agg
update temp_route_fact t1 
set t1.service_list = (select t2.SERVICEGROUPLIST from (select al.Airlineid, 
  listagg(av.serviceid,'_') within group (order by av.serviceid) as servicegrouplist
from airlines1 al, Airline_Services1 av, Provides1 p
where al.airlineid = p.airlineid
And p.serviceid = av.serviceid
group by al.Airlineid) t2 where t1.AIRLINEID=t2.AIRLINEID)
where t1.AIRLINEID IN ( select t2.AIRLINEID from (select al.Airlineid, 
  listagg(av.serviceid,'_') within group (order by av.serviceid) as servicegrouplist
from airlines1 al, Airline_Services1 av, Provides1 p
where al.airlineid = p.airlineid
And p.serviceid = av.serviceid
group by al.Airlineid) t2 where t1.AIRLINEID=t2.AIRLINEID);

--Creates route_fact table
create table route_fact
as (select sourceairportid, destairportid, service_list, count(routeid) total_routes, sum(distance) as total_route_distance,  sum(servicecost) as total_service_cost 
from temp_route_fact 
group by sourceairportid, destairportid, service_list);

--Create travel class dim
create table travel_class_dim (
travel_class_id  number not null,
travel_class_type varchar2(50)
);

insert into travel_class_dim values (1, 'First Class');
insert into travel_class_dim values (2, 'Business Class');
insert into travel_class_dim values (3, 'Economy Class');

--Create passenger_type_dim
create table passenger_type_dim (
passenger_type_id number not null,
passenger_type varchar2(50));

insert into passenger_type_dim values (1,'Children');
insert into passenger_type_dim values (2,'Teenager');
insert into passenger_type_dim values (3,'Young Adult');
insert into passenger_type_dim values (4,'Middle Adult');
insert into passenger_type_dim values (5,'Senior Adult');

--Create Sequence for Nationality_Dim
CREATE SEQUENCE nat_seq
  START WITH 1
  MINVALUE 1
  INCREMENT BY 1
  nocycle;
  
--Create nationality_dim
create table nationality_dim as
select distinct nationality from passengers1;

alter table nationality_dim add (natid number(3));

update nationality_dim
set natid = nat_seq.nextval;

--Create flight_type_dim
create table flight_type_dim (
flight_type_id  number not null,
flight_type varchar2(50));

insert into flight_type_dim values (1, 'Domestic');
insert into flight_type_dim values (2, 'International');

--Create  flight_distance_dim
create table flight_distance_dim (
flight_ditance_id number not null,
flight_description varchar2(50));

insert into flight_distance_dim values (1,'Small');
insert into flight_distance_dim values (2,'Medium');
insert into flight_distance_dim values (3,'Large');
insert into flight_distance_dim values (4,'Very Large');

--Create Time_Dim
create table time_dim as
select 
  to_char(flightdate,'yyyy') ||  to_char(flightdate,'mm') || to_char(flightdate,'dd') as time_id,
  to_char(flightdate, 'Day') as dayname, 
  to_char(flightdate, 'Mon') as month, 
  to_char(flightdate, 'yyyy') as yearnumber 
from (select distinct flightdate from flights1);

--Create Temporary Fact
create table Transactions_Temp_Fact as
select a.AIRPORTID as source_airport_id, a.country as source_country, b.airportid as dest_airport_id, b.COUNTRY As dest_country, al.airlineid, r.distance, f.flightdate, f.fare, t.flightid, t.totalpaid, p.nationality, p.age,a.COUNTRY as sourceCountry,b.country as destCountry
from routes1 r, airports1 a, airports1 b, flights1 f, transactions1 t, passengers1 p, AIRLINES1 al
where r.sourceairportid = a.airportid
and r.destairportid = b.airportid
and f.routeid = r.routeid
and t.passid = p.passid
and f.flightid = t.flightid
and al.airlineid = r.airlineid
and f.fare > 0
and p.age > 0;

--Add nationality id
alter table Transactions_Temp_Fact add natid number(3);
update Transactions_Temp_Fact tf
set natid = (select natid from nationality_dim nd where nd.nationality = tf.nationality);

--Add passenger_type_id
alter table Transactions_Temp_Fact add passenger_type_id number;

update Transactions_Temp_Fact
set passenger_type_id = 1
where age < 11;

update Transactions_Temp_Fact
set passenger_type_id = 2
where age between 11 and 17;

update Transactions_Temp_Fact
set passenger_type_id = 3
where age between 18 and 35;

update Transactions_Temp_Fact
set passenger_type_id = 4
where age between 36 and 60;

update Transactions_Temp_Fact
set passenger_type_id = 5
where age > 60;

--Add flight_distance_id
alter table Transactions_Temp_Fact add flight_distance_id number;

update Transactions_Temp_Fact
set flight_distance_id = 1
where distance < 1200;

update Transactions_Temp_Fact
set flight_distance_id = 2
where distance between 1200 and 4000;

update Transactions_Temp_Fact
set flight_distance_id = 3
where distance between 4001 and 10000;

update Transactions_Temp_Fact
set flight_distance_id = 4
where distance > 10000;

--Add Time ID
alter table transactions_temp_fact add (time_id varchar2(8));
update transactions_temp_fact
set time_id = to_char(flightdate,'yyyy') ||  to_char(flightdate,'mm') || to_char(flightdate,'dd');

--Add travel_class_id
alter table Transactions_Temp_Fact add travel_class_id number;

update Transactions_Temp_Fact
set travel_class_id = 1
where TotalPaid >= (1.8*Fare);

update Transactions_Temp_Fact
set travel_class_id = 2
where (1.3*Fare) <= TotalPaid
And TotalPaid < (1.8*Fare);

update Transactions_Temp_Fact
set travel_class_id = 3
where TotalPaid < (1.3*Fare);

--Add Flight_Type_ID
alter table Transactions_Temp_Fact add flight_type_id number;
update Transactions_Temp_Fact
set flight_type_id = 1
where SOURCE_country = DEST_country;

update Transactions_Temp_Fact
set flight_type_id = 2
where SOURCE_country != DEST_country;

--Create Transaction_Fact
create table Transaction_Fact as 
select SOURCE_AIRPORT_ID,DEST_AIRPORT_ID,airlineid,natid, passenger_type_id, flight_type_id, flight_distance_id, time_id, travel_class_id, count(flightid) as total_number__Transactions, sum(totalpaid) as total_total_paid, sum(fare) as total_fare, sum(age) as total_age, sum(distance) as total_travel_distance
from Transactions_Temp_Fact
Group By SOURCE_AIRPORT_ID,DEST_AIRPORT_ID,airlineid,natid, passenger_type_id, flight_type_id, flight_distance_id, time_id, travel_class_id;

