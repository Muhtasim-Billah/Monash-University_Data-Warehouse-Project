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