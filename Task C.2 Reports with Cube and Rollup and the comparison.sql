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