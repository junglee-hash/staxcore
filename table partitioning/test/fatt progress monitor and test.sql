/*
 truncate table mig_transactions;
 truncate table mig_transactions_log;
 */

call mig_migrate_transactions();

# select sum(rows_migrated), sum(timestampdiff(second, started_at, ended_at))
select *, timestampdiff(second, started_at, ended_at)
from mig_transactions_log
order by id desc;

 SELECT
  TABLE_SCHEMA,
  TABLE_NAME,
  PARTITION_NAME,
  PARTITION_ORDINAL_POSITION AS part_no,
  PARTITION_METHOD,
  PARTITION_EXPRESSION,
  PARTITION_DESCRIPTION,
  TABLE_ROWS,           -- approximate
  DATA_LENGTH,          -- bytes
  INDEX_LENGTH,         -- bytes
  (DATA_LENGTH + INDEX_LENGTH) AS total_bytes
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_SCHEMA = 'fatt'
  AND TABLE_NAME   = 'transactions_partitioned2'
  AND PARTITION_NAME IS NOT NULL
ORDER BY part_no;

-- test partitioning
-- pls check indexes on the tables before running the below queries
show indexes from transactions;

select p.merchant_id,  count(p.id)
from fatt.transactions p use index(idx_transactions__merchant_id_created_at_id)
join fatt.merchants m use index for join (idx_merchants_status_is_sandbox_id) on m.id = p.merchant_id
where
        (m.status = 'INACTIVE' or m.is_sandbox = 1)
        AND p.created_at between '2026-02-01' and '2026-03-01'
group by p.merchant_id;

select p.merchant_id,  count(p.id)
from mig_transactions p use index(idx_transactions_partitioned2_merchant_id_created_at_id) -- idx_transactions_partitioned2_merchant_id
join merchants m use index for join (idx_merchants_status_is_sandbox_id) on m.id = p.merchant_id
where
        (m.status = 'INACTIVE' or m.is_sandbox = 1)
        AND p.created_at between '2026-02-01' and '2026-03-01'
group by p.merchant_id;

show indexes from fatt.transactions_partitioned;
select p.merchant_id,  count(p.id)
from fatt.transactions_partitioned p use index(idx_transactions_partitioned_merchant_id_created_at_id)
join fatt.merchants m use index for join (idx_merchants_status_is_sandbox_id) on m.id = p.merchant_id
where   p.year = 2026
        and p.month = 2
        and (m.status = 'INACTIVE' or m.is_sandbox = 1)
group by p.merchant_id;

-- test partitioning