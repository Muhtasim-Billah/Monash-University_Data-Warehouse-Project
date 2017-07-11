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