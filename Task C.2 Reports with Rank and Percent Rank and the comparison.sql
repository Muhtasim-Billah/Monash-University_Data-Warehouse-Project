--Report 1
select td.yearnumber,nd.nationality, sum(Total_number__transactions) as CountPassengers
from transaction_fact tf,time_dim td, nationality_dim nd, TRAVEL_CLASS_DIM tc
where tf.time_id = td.time_id
and tf.natid = nd.natid
and tf.TRAVEL_CLASS_ID = tc.travel_class_id
and nd.nationality = 'Australian'
and td.yearnumber = '2008'
and tc.TRAVEL_CLASS_TYPE = 'First Class'
Group By td.yearnumber,nd.nationality;

--Report 2
select ad.name as AirlineName, sum(total_total_paid)-sum(tf.TOTAL_FARE) as TotalProfit  
from airline_dim ad, transaction_fact tf, time_dim td
where ad.AIRLINEID = tf.AIRLINEID
and tf.TIME_ID = td.TIME_ID
and td.yearnumber = '2007'
Group By ad.name;


--Report 3
select sa.country as SourceCountry, da.Country as DestinationCountry, sum(total_routes) as RouteCount
from SOURCE_AIRPORT_DIM sa, DEST_AIRPORT_DIM da, route_fact rf
where rf.SOURCEAIRPORTID = sa.AIRPORTID
and rf.DESTAIRPORTID = da.AIRPORTID
and sa.country = 'Germany'
and da.country = 'United States'
and rf.SERVICE_LIST Like '%' || (select serviceid from service_dim where name = 'In-flight internet') || '%'
Group By sa.country, da.country;

--Report 4
select 
decode(grouping(sa.city),1,'Any City',sa.city) as "Departure City",
decode(grouping(sa.country),1,'Any Country',sa.country) as "Departure Country",
decode(grouping(da.city),1,'Any City',da.city) as "Arrival City",
decode(grouping(da.country),1,'Any Country',da.country) as "Arrival Country",
sum(rf.TOTAL_ROUTES) as "Number of Routes",
round(sum(rf.TOTAL_ROUTE_DISTANCE)/sum(rf.TOTAL_ROUTES),2) as "Average Distance"
from route_fact rf, source_airport_dim sa, dest_airport_dim da
where rf.sourceairportid = sa.airportid
and rf.destairportid = da.airportid
group by cube (sa.CITY, sa.COUNTRY, da.CITY, da.COUNTRY)
order by sa.COUNTRY,sa.CITY;

--Report 5
select decode(grouping(td.YEARNUMBER),1,'Any Year',td.YEARNUMBER) as "Flight Year",
decode(grouping(ad.NAME),1,'Any Airline',ad.NAME) as "Airline Name",
decode(grouping(ft.FLIGHT_TYPE),1,'All Flight Type',ft.FLIGHT_TYPE) as "Flight Type",
decode(grouping(sa.COUNTRY),1,'Any Country',sa.COUNTRY) as "Source Country",
decode(grouping(da.COUNTRY),1,'Any Country',da.COUNTRY) as "Destination Country",
sum(tf.TOTAL_NUMBER__TRANSACTIONS) as "Number of Transactions",
round((sum(tf.TOTAL_TOTAL_PAID) - sum(tf.TOTAL_FARE))/sum(tf.TOTAL_NUMBER__TRANSACTIONS),2) as "Average Agent Profit(USD)"
from transaction_fact tf, airline_dim ad, flight_type_dim ft,
time_dim td, source_airport_dim sa, dest_airport_dim da
where tf.AIRLINEID = ad.AIRLINEID
and tf.FLIGHT_TYPE_ID = ft.FLIGHT_TYPE_ID
and tf.time_ID = td.time_ID
and tf.SOURCE_AIRPORT_ID = sa.AIRPORTID
and tf.DEST_AIRPORT_ID = da.AIRPORTID
and (sa.COUNTRY = da.COUNTRY
or sa.COUNTRY != da.COUNTRY)
group by td.YEARNUMBER,ad.NAME, rollup (ft.FLIGHT_TYPE,sa.COUNTRY,da.COUNTRY);


--Report 6
select 
decode(grouping(td.DAYNAME),1,'Any Day',td.DAYNAME) as "Flight Day",
decode(grouping(ft.FLIGHT_TYPE),1,'All Flight Type',ft.FLIGHT_TYPE) as "Flight Type",
decode(grouping(tc.TRAVEL_CLASS_TYPE),1,'Any Class',tc.TRAVEL_CLASS_TYPE) as "Flight Class",
decode(grouping(sa.COUNTRY),1,'Any Country',sa.COUNTRY) as "Source Country",
decode(grouping(da.COUNTRY),1,'Any Country',da.COUNTRY) as "Destination Country",
sum(tf.TOTAL_NUMBER__TRANSACTIONS) as "Number of Transactions",
round(sum(tf.TOTAL_TOTAL_PAID)/ sum(tf.TOTAL_NUMBER__TRANSACTIONS),2) as "Average Paid Ticket(USD)"
from 
transaction_fact tf, time_dim td, flight_type_dim ft, 
travel_class_dim tc, source_airport_dim sa, dest_airport_dim da
where 
tf.time_id = td.time_id
and tf.FLIGHT_TYPE_ID = ft.FLIGHT_TYPE_ID
and tf.TRAVEL_CLASS_ID = tc.TRAVEL_CLASS_ID
and tf.SOURCE_AIRPORT_ID = sa.AIRPORTID
and tf.DEST_AIRPORT_ID = da.AIRPORTID
group by td.DAYNAME, cube
(ft.FLIGHT_TYPE,tc.TRAVEL_CLASS_TYPE,sa.COUNTRY,da.COUNTRY);

--Report 7
select 
decode(grouping(sa.city),1,'Any City',sa.city) as "Departure City",
decode(grouping(sa.country),1,'Any Country',sa.country) as "Departure Country",
decode(grouping(da.city),1,'Any City',da.city) as "Arrival City",
decode(grouping(da.country),1,'Any Country',da.country) as "Arrival Country",
sum(rf.TOTAL_SERVICE_COST) as "Total Service Cost"
from route_fact rf, source_airport_dim sa, dest_airport_dim da
where rf.sourceairportid = sa.airportid
and rf.destairportid = da.airportid
group by cube (sa.CITY, sa.COUNTRY, da.CITY, da.COUNTRY)
order by sa.COUNTRY,sa.CITY;

--Report 8
select decode(grouping(td.YEARNUMBER),1,'Any Year',td.YEARNUMBER) as "Flight Year",
decode(grouping(ad.NAME),1,'Any Airline',ad.NAME) as "Airline Name",
decode(grouping(tc.TRAVEL_CLASS_TYPE),1,'All Class Type',tc.TRAVEL_CLASS_TYPE) as "Travel Class Type",
decode(grouping(fd.FLIGHT_DESCRIPTION),1,'All Flight Description',fd.FLIGHT_DESCRIPTION) as "Flight Description",
decode(grouping(sa.COUNTRY),1,'Any Country',sa.COUNTRY) as "Source Country",
decode(grouping(da.COUNTRY),1,'Any Country',da.COUNTRY) as "Destination Country",
sum(tf.TOTAL_NUMBER__TRANSACTIONS) as "Number of Transactions",
sum(tf.TOTAL_TOTAL_PAID) - sum(tf.TOTAL_FARE) as "Total Agent Profit(USD)"
from transaction_fact tf, airline_dim ad, travel_class_dim tc, FLIGHT_DISTANCE_DIM fd,
time_dim td, source_airport_dim sa, dest_airport_dim da
where tf.AIRLINEID = ad.AIRLINEID
and tf.TRAVEL_CLASS_ID = tc.TRAVEL_CLASS_ID
and tf.FLIGHT_DISTANCE_ID = fd.FLIGHT_DITANCE_ID
and tf.time_ID = td.time_ID
and tf.SOURCE_AIRPORT_ID = sa.AIRPORTID
and tf.DEST_AIRPORT_ID = da.AIRPORTID
and (sa.COUNTRY = da.COUNTRY
or sa.COUNTRY != da.COUNTRY)
group by td.YEARNUMBER,ad.NAME, rollup (tc.TRAVEL_CLASS_TYPE,fd.FLIGHT_DESCRIPTION,sa.COUNTRY,da.COUNTRY);

--Report 9
select td.MONTH, sa.CITY, sa.country, fd.FLIGHT_DESCRIPTION,
(sum(tf.total_total_paid) - sum(tf.total_fare)) as "Total profit",
to_char(sum(sum(tf.total_total_paid) - sum(tf.total_fare)) over
(order by substr(td.time_id,5,2) rows unbounded preceding),
'9,999,999,999.99') as "Cumulative Monthly Profit"
from
transaction_fact tf, flight_distance_dim fd, time_dim td, 
source_airport_dim sa
where tf.SOURCE_AIRPORT_ID = sa.AIRPORTID
and tf.FLIGHT_DISTANCE_ID = fd.FLIGHT_DITANCE_ID
and tf.time_ID = td.time_ID
and td.YEARNUMBER = '2007'
and fd.FLIGHT_DESCRIPTION = 'Small'
and sa.city = 'Sydney'
group by
td.MONTH, sa.CITY, sa.country,fd.FLIGHT_DESCRIPTION,substr(td.time_id,5,2);


--Report 10
select sub.MONTH as "Month", 
sum(sub.TOTAL_NUMBER__TRANSACTIONS) as "Total Transactions",
to_char(avg(sum(sub.TOTAL_NUMBER__TRANSACTIONS)) over
(order by sub.RepPeriod rows 2 preceding),
'9,999,999,999.99') as moving_avg_transactions
from (Select substr(td.time_id,5,2) || td.YEARNUMBER as RepPeriod, td.MONTH, tf.TOTAL_NUMBER__TRANSACTIONS from transaction_fact tf, time_dim td, nationality_dim nd
where
tf.time_id = td.time_id
and tf.natid = nd.natid
and nd.NATIONALITY = 'Australian'
and td.yearnumber = '2009') sub
group by
sub.MONTH,sub.RepPeriod ;

--Report 11
select substr(td.time_id,5,2) || substr(td.time_id,3,2) as RepPeriod, td.month, td.YEARNUMBER,
(sum(tf.total_total_paid) - sum(tf.total_fare)) as "Total profit",
to_char(sum(sum(tf.total_total_paid) - sum(tf.total_fare)) over
( partition by td.YEARNUMBER order by td.YEARNUMBER desc rows unbounded preceding),
'9,999,999,999.99') as "Cumulative Monthly Profit"
from
transaction_fact tf, flight_distance_dim fd, 
source_airport_dim sa, TIME_DIM td
where tf.SOURCE_AIRPORT_ID = sa.AIRPORTID
and tf.FLIGHT_DISTANCE_ID = fd.FLIGHT_DITANCE_ID
and td.time_id = tf.time_id
group by
substr(td.time_id,5,2) || substr(td.time_id,3,2),td.month,td.YEARNUMBER
order by td.YEARNUMBER, substr(td.time_id,5,2) || substr(td.time_id,3,2);

--Report 12
select sub.aln as airlines_name, sub.sn as source_name, sub.month as month_name,sub.YEARNUMBER,
(sum(sub.total_total_paid)-sum(sub.TOTAL_FARE)) as "Total Profit",
to_char(avg(sum(sub.total_total_paid)-sum(sub.TOTAL_FARE)) over
(partition by sub.aln, sub.sn order by sub.aln, sub.sn, sub.YEARNUMBER rows 2 preceding),
'9,999,999,999.99') as moving_avg_profit
from (Select td.YEARNUMBER || td.month as RepDate, ad.NAME as aln, sa.NAME sn, td.month, tf.total_total_paid, tf.TOTAL_FARE, ad.airlineid, td.yearnumber
from transaction_fact tf, time_dim td, airline_dim ad, SOURCE_AIRPORT_DIM sa
where
tf.time_ID = td.time_ID
and tf.airlineid = ad.airlineid
and sa.airportid = tf.SOURCE_AIRPORT_ID) sub
group by
sub.Month,sub.YEARNUMBER,sub.airlineid,sub.aln, sub.sn ;

--Report 13
Select sa.country, sa.city as CityName, sa.name as SourceAirport,
To_char(sum(rf.total_service_cost)) as Service$,
Rank() Over (Partition By sa.Country
ORDER BY sum(rf.total_service_cost) desc) as RankScore
from source_airport_dim sa, ROUTE_FACT rf
where rf.SOURCEAIRPORTID = sa.airportid
group by
sa.country, sa.city, sa.name;

--Report 14
Select *
from (Select td.YEARNUMBER, nd.NATIONALITY, pt.PASSENGER_TYPE,
To_char(sum(tf.TOTAL_TOTAL_PAID)-sum(tf.total_fare)) as Revenue$,
Percent_Rank() Over (Partition By nd.NATIONALITY
ORDER BY sum(tf.TOTAL_TOTAL_PAID)-sum(tf.total_fare) desc) as PercentRankScoreNationality,
Percent_Rank() Over (Partition By PASSENGER_TYPE
ORDER BY sum(tf.TOTAL_TOTAL_PAID)-sum(tf.total_fare) desc) as PercentankScorePassenger
from nationality_Dim nd, transaction_fact tf, PASSENGER_TYPE_DIM pt, TIME_DIM td
where tf.NATID = nd.NATID
And tf.PASSENGER_TYPE_ID = pt.PASSENGER_TYPE_ID
and td.TIME_ID = tf.TIME_ID
group by
td.YEARNUMBER, nd.NATIONALITY, pt.PASSENGER_TYPE
order by
td.yearnumber) q1
where PercentRankScoreNationality < 0.1
Or PercentankScorePassenger < 0.1;