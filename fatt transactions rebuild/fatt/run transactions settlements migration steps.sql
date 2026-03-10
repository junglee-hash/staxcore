select count(id) from fatt.transactions_settlements;
-- 401290102
select count(id) from fatt.transactions_settlements where created_at is null;

call mig_transactions_settlements();

select sum(rows_migrated) as running_row_count,
       (sum(timestampdiff(second, started_at, ended_at))/60.0)/60.0 as running_time_hr
from fatt.mig_transactions_settlements_log;

select count(id) from fatt.mig_transactions_settlements;
select *, timestampdiff(second, started_at, ended_at) as seconds_elapsed
from fatt.mig_transactions_settlements_log
order by id desc
limit 10;
