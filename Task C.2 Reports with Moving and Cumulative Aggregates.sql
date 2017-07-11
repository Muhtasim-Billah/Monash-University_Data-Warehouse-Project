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