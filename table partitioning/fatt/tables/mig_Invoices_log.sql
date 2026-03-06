drop table if exists mig_invoices_log;
-- log table
create table mig_invoices_log
(
    id int auto_increment primary key,
    v_start_id datetime,
    v_next_id datetime,
    rows_migrated int,
    started_at timestamp default CURRENT_TIMESTAMP,
    ended_at timestamp
);