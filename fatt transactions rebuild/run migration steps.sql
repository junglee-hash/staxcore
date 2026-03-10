/* this script contains migration steps. The steps are executed in this order.
   1. create tables needed for the table rebuild.
        a. mig_transactions_cdc.sql for CDC of the transactions table during data migration.
        b. mig_transactions_log.sql for logging of the transactions data loaded during data migration.
        c. transactions_migrated.sql for the newly created table that will contain the migrated data.
   2. create a stored procedure for batch data migration processing.
        a. transactions_migrated.sql
   3. create triggers to capture the CDC events.
        a.  mig_transactions_triggers.sql
   4. run the migration stored procedure. This will load the data into the newly created table.
      This ran almost 10 hours in the database engineering environment.
      You can monitor the progress of the migration by querying the mig_transactions_log table using the below queries.
         a. select sum(rows_migrated) as running_row_count, (sum(timestampdiff(second, started_at, ended_at))/60.0)/60.0 as running_time_hr from mig_transactions_log;
         b. select *, timestampdiff(second, started_at, ended_at) as seconds_elapsed from mig_transactions_log order by id desc limit 10;
 */
call transactions_migrated();
/*  5. This step is to apply the CDC events to the newly populated table.
       During this time, ensure no data is written to transactions table. Otherwise, there will be data discrepancies.
 */
-- Enable global read-only mode
SET GLOBAL read_only = ON;
SET GLOBAL super_read_only = ON;

-- Kill all application sessions, kill <id> is the process id of the application session
select ID from information_schema.PROCESSLIST where USER not in ('admin', 'rdsadmin');

-- INSERT CDC event
insert into fatt.transactions_migrated (row_id, id, invoice_id, reference_id, reference_row_id, recurring_transaction_id
                , auth_id, type, source, source_ip, is_merchant_present, merchant_id, user_id, customer_id
                , payment_method_id, is_manual, spreedly_token, spreedly_response, success, message, meta, total, method
                , pre_auth, is_captured, last_four, interchange_code, interchange_fee, batch_id, batched_at, emv_response
                , avs_response, cvv_response, pos_entry, pos_salesperson, receipt_email_at, receipt_sms_at, settled_at
                , created_at, updated_at, gateway_id,  channel, currency)
select row_id, id, invoice_id, reference_id, reference_row_id, recurring_transaction_id
                , auth_id, type, source, source_ip, is_merchant_present, merchant_id, user_id, customer_id
                , payment_method_id, is_manual, spreedly_token, spreedly_response, success, message, meta, total, method
                , pre_auth, is_captured, last_four, interchange_code, interchange_fee, batch_id, batched_at, emv_response
                , avs_response, cvv_response, pos_entry, pos_salesperson, receipt_email_at, receipt_sms_at, settled_at
                , created_at, updated_at, gateway_id,  channel, currency from mig_transactions_cdc where cdc_type = 'INSERT';

-- UPDATE CDC event
delete m from fatt.transactions_migrated m join mig_transactions_cdc c ON c.row_id = m.row_id where c.cdc_type = 'UPDATE';
insert into fatt.transactions_migrated (row_id, id, invoice_id, reference_id, reference_row_id, recurring_transaction_id
                , auth_id, type, source, source_ip, is_merchant_present, merchant_id, user_id, customer_id
                , payment_method_id, is_manual, spreedly_token, spreedly_response, success, message, meta, total, method
                , pre_auth, is_captured, last_four, interchange_code, interchange_fee, batch_id, batched_at, emv_response
                , avs_response, cvv_response, pos_entry, pos_salesperson, receipt_email_at, receipt_sms_at, settled_at
                , created_at, updated_at, gateway_id,  channel, currency)
select row_id, id, invoice_id, reference_id, reference_row_id, recurring_transaction_id
                , auth_id, type, source, source_ip, is_merchant_present, merchant_id, user_id, customer_id
                , payment_method_id, is_manual, spreedly_token, spreedly_response, success, message, meta, total, method
                , pre_auth, is_captured, last_four, interchange_code, interchange_fee, batch_id, batched_at, emv_response
                , avs_response, cvv_response, pos_entry, pos_salesperson, receipt_email_at, receipt_sms_at, settled_at
                , created_at, updated_at, gateway_id,  channel, currency from mig_transactions_cdc where cdc_type = 'UPDATE';

-- DELETE CDC event
delete m from fatt.transactions_migrated m join mig_transactions_cdc c ON c.row_id = m.row_id where c.cdc_type = 'DELETE';

/*  6. Double-check row counts from the two tables and spot check the data for accuracy. If everything looks good, proceed to step 7.*/

/*  7. Swap the transaction table with the newly populated table. */
rename table fatt.transactions to transactions_old, fatt.transactions_migrated to transactions;

--  8. Disable global read-only mode after the migration is complete.
SET GLOBAL super_read_only = OFF;
SET GLOBAL read_only = OFF;
