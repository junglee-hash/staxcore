drop table if exists mig_transactions_log;
-- log table
create table mig_transactions_log
(
    id int auto_increment primary key,
    v_start_id bigint,
    v_next_id bigint,
    rows_migrated int,
    started_at timestamp default CURRENT_TIMESTAMP,
    ended_at timestamp
);