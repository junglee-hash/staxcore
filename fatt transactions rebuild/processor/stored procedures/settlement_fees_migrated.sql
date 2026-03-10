drop procedure if exists mig_settlement_fees;
create procedure mig_settlement_fees()
begin
    declare done int default 0;
    declare v_start_id bigint default 0;
    declare v_last_id bigint default 0;
    declare v_next_id bigint default 0;
    declare v_batch_size int default 50000;
    declare v_log_id int default 0;
    declare insert_row_cnt int default 0;

    set v_start_id = (select min(id) from processor.settlement_fees);
    -- set v_start_id = 15400309;
    set v_last_id = (select max(id) from processor.settlement_fees);
    set v_next_id = v_start_id + v_batch_size;

    while v_next_id <= v_last_id do
        insert into processor.mig_settlement_fees_log(v_start_id, v_next_id)
        values (v_start_id, v_next_id);
        set v_log_Id = last_insert_id();

        insert into processor.mig_settlement_fees (`row_id`,`id`,`merchant_id`,`transaction_id`,`transaction_row_id`,`batch_id`,`external_id`
            ,`external_linked_id`,`source`,`total`,`type`,`subtype`,`name`,`created_at`,`updated_at`,`settled_at`,`billing_invoice_id`)
        select `row_id`,`id`,`merchant_id`,`transaction_id`,`transaction_row_id`,`batch_id`,`external_id`
            ,`external_linked_id`,`source`,`total`,`type`,`subtype`,`name`,`created_at`,`updated_at`,`settled_at`,`billing_invoice_id`
        from processor.settlement_fees
        where row_id between v_start_id and v_next_id;
        set insert_row_cnt = row_count();

        update processor.mig_settlement_fees_log set rows_migrated = insert_row_cnt, ended_at = NOW() where id = v_log_id;

        set v_start_id = v_next_id + 1;
        set v_next_id = v_start_id + v_batch_size;
        end while;
end;