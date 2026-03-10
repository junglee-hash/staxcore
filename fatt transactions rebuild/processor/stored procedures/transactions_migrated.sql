drop procedure if exists transactions_migrated;
create procedure transactions_migrated()
begin
    declare done int default 0;
    declare v_start_id bigint default 0;
    declare v_last_id bigint default 0;
    declare v_next_id bigint default 0;
    declare v_batch_size int default 50000;
    declare v_log_id int default 0;
    declare insert_row_cnt int default 0;

    set v_start_id = (select min(row_id) from transactions);
    -- set v_start_id = 15400309;
    set v_last_id = (select max(row_id) from transactions);
    set v_next_id = v_start_id + v_batch_size;

    while v_next_id <= v_last_id do
        insert into mig_transactions_log(v_start_id, v_next_id)
        values (v_start_id, v_next_id);
        set v_log_Id = last_insert_id();

        insert into mig_transactions (
                row_id, id, invoice_id, reference_id, reference_row_id, recurring_transaction_id, auth_id, type, source
                , source_ip, is_merchant_present, merchant_id, user_id, customer_id, payment_method_id, is_manual
                , spreedly_token, spreedly_response, success, message, meta, total, method, pre_auth, is_captured
                , last_four, interchange_code, interchange_fee, batch_id, batched_at, emv_response, avs_response
                , cvv_response, pos_entry, pos_salesperson, receipt_email_at, receipt_sms_at, settled_at, created_at
                , updated_at, gateway_id,  channel, currency)
        select  row_id, id, invoice_id, reference_Id, reference_row_id, recurring_transaction_id, auth_id, type, source
                , source_ip, is_merchant_present, merchant_id, user_id, customer_id, payment_method_id, is_manual
                , spreedly_token, spreedly_response, success, message, meta, total, method, pre_auth, is_captured
                , last_four, interchange_code, interchange_fee, batch_id, batched_at, emv_response, avs_response
                , cvv_response, pos_entry, pos_salesperson, receipt_email_at, receipt_sms_at, settled_at, created_at
                , updated_at, gateway_id, channel, currency
        from transactions
        where row_id between v_start_id and v_next_id;
        set insert_row_cnt = row_count();

        update mig_transactions_log set rows_migrated = insert_row_cnt, ended_at = NOW() where id = v_log_id;

        set v_start_id = v_next_id + 1;
        set v_next_id = v_start_id + v_batch_size;
        end while;
end;