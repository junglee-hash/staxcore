drop procedure if exists mig_transactions_settlements;
create procedure mig_transactions_settlements()
begin
    declare done int default 0;
    declare v_start_id bigint default 0;
    declare v_last_id bigint default 0;
    declare v_next_id bigint default 0;
    declare v_batch_size int default 50000;
    declare v_log_id int default 0;
    declare insert_row_cnt int default 0;

    set v_start_id = (select min(id) from transactions_settlements);
    -- set v_start_id = 15400309;
    set v_last_id = (select max(id) from transactions_settlements);
    set v_next_id = v_start_id + v_batch_size;

    while v_next_id <= v_last_id do
        insert into mig_transactions_settlements_log(v_start_id, v_next_id)
        values (v_start_id, v_next_id);
        set v_log_Id = last_insert_id();

        insert into mig_transactions_settlements (
                `id`,`settlement_id`,`transaction_id`,`batch_id`,`source`,`processor`,`funded_at`,`deleted_at`,`created_at`,`updated_at`,`settlement_row_id`,`transaction_row_id`)
        select  `id`,`settlement_id`,`transaction_id`,`batch_id`,`source`,`processor`,`funded_at`,`deleted_at`,`created_at`,`updated_at`,`settlement_row_id`,`transaction_row_id`
        from transactions_settlements
        where id between v_start_id and v_next_id;
        set insert_row_cnt = row_count();

        update mig_transactions_settlements_log set rows_migrated = insert_row_cnt, ended_at = NOW() where id = v_log_id;

        set v_start_id = v_next_id + 1;
        set v_next_id = v_start_id + v_batch_size;
        end while;
end;