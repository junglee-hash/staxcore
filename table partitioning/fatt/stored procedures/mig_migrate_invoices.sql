show indexes from fatt.transactions_partitioned2;
drop procedure if exists mig_invoices;
create procedure mig_invoices()
begin
    declare done int default 0;
    declare v_start_id datetime default 0;
    declare v_last_id datetime default 0;
    declare v_next_id datetime default 0;
    declare v_batch_size int default 10;
    declare v_log_id int default 0;
    declare insert_row_cnt int default 0;

    set v_start_id = (select date(min(created_at)) from invoices);
    set v_last_id = (select date(max(created_at)) from invoices);
    set v_next_id = date_add(v_start_id, interval v_batch_size day);

    while v_next_id <= v_last_id do
        insert into mig_invoices_log(v_start_id, v_next_id)
        values (v_start_id, v_next_id);
        set v_log_Id = last_insert_id();

        insert into mig_invoices (id, merchant_id, user_id, customer_id, total, meta, status, is_merchant_present
                                    , sent_at, viewed_at, paid_at, schedule_id, reminder_id, payment_method_id
                                    , url, is_webpayment, deleted_at, created_at, updated_at, due_at, is_partial_payment_enabled, invoice_date_at)
        select  id, merchant_id, user_id, customer_id, total, meta, status, is_merchant_present
                , sent_at, viewed_at, paid_at, schedule_id, reminder_id, payment_method_id
                , url, is_webpayment, deleted_at, created_at, updated_at, due_at, is_partial_payment_enabled, invoice_date_at
        from invoices
        where created_at between v_start_id and v_next_id;
        set insert_row_cnt = row_count();

        update mig_invoices_log set rows_migrated = insert_row_cnt, ended_at = NOW() where id = v_log_id;

        set v_start_id = date_add(v_next_id, interval 1 day);;
        set v_next_id = date_add(v_start_id, interval v_batch_size day);
        end while;
end;
