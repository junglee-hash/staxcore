select count(id) from transactions;
-- 403441069
call transactions_migrated();

select *, timestampdiff(second, started_at, ended_at) as seconds_elapsed
from mig_transactions_log
order by id desc
limit 10;
select sum(rows_migrated) as running_row_count, (sum(timestampdiff(second, started_at, ended_at))/60.0)/60.0 as running_time_hr from mig_transactions_log
