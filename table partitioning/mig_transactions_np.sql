drop table if exists mig_transactions_np;
create table mig_transactions_np
(
    row_id                   bigint unsigned auto_increment                                         not null,
    id                       varchar(40)                                                            not null,
    invoice_id               varchar(40)                                                            not null,
    reference_id             varchar(40)                                                            not null,
    reference_row_id         bigint unsigned                                                        null comment 'reference to parent transaction fatt.transaction.row_id',
    recurring_transaction_id varchar(40)                                                            not null,
    auth_id                  varchar(50)                                                            null,
    type                     enum ('charge', 'void', 'refund', 'capture', 'pre_auth', 'credit', '') not null,
    source                   varchar(50)                                                            null comment 'The system where the payment was processed (e.g. terminalservice.dejavoo, haywire.apps). A value of null means that the transaction was processed within the Stax system via the core api.',
    source_ip                varchar(50)                                                            null,
    is_merchant_present      tinyint                                                                null,
    merchant_id              varchar(40)                                                            not null,
    user_id                  varchar(40)                                                            not null,
    customer_id              varchar(40)                                                            not null,
    payment_method_id        varchar(40)                                                            null,
    is_manual                tinyint                                                                null,
    spreedly_token           varchar(50)                                                            not null,
    spreedly_response        text                                                                   not null,
    success                  tinyint                                                                not null,
    message                  varchar(255)                                                           null,
    meta                     text                                                                   not null,
    total                    double                                                                 not null,
    method                   varchar(20)                                                            not null,
    pre_auth                 tinyint                                                                not null,
    is_captured              tinyint     default 0                                                  not null,
    last_four                varchar(4)  default ''                                                 null,
    interchange_code         varchar(45) default ''                                                 null,
    interchange_fee          double                                                                 null,
    batch_id                 varchar(80) default ''                                                 null,
    batched_at               timestamp   default CURRENT_TIMESTAMP                                  null on update CURRENT_TIMESTAMP,
    emv_response             varchar(80) default ''                                                 null,
    avs_response             varchar(80) default ''                                                 null,
    cvv_response             varchar(80) default ''                                                 null,
    pos_entry                varchar(92) default ''                                                 null,
    pos_salesperson          varchar(80) default ''                                                 null,
    receipt_email_at         timestamp                                                              null,
    receipt_sms_at           timestamp                                                              null,
    settled_at               timestamp                                                              null,
    created_at               timestamp   default CURRENT_TIMESTAMP                                  not null,
#     updated_at               timestamp   default '0000-00-00 00:00:00'                              not null,
    updated_at               TIMESTAMP                                                              NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    gateway_id               varchar(50)                                                            null,
    issuer_auth_code         varchar(50) as ((case
                                                  when json_valid(`spreedly_response`) then coalesce(
                                                          json_unquote(json_extract(`spreedly_response`,
                                                                                    _utf8mb4'$.gateway_specific_response_fields.nmi.authcode')),
                                                          json_unquote(json_extract(`spreedly_response`,
                                                                                    _utf8mb4'$.gateway_specific_response_fields.forte.authorization_code')),
                                                          json_unquote(json_extract(`spreedly_response`,
                                                                                    _utf8mb4'$.gateway_specific_response_fields.authorize_net.authorization_code')),
                                                          json_unquote(json_extract(`spreedly_response`, _utf8mb4'$.AuthCode')))
                                                  else _utf8mb4'' end)) stored,
    channel                  varchar(50)                                                            null,
    currency                 enum ('USD', 'CAD', 'MXN', 'EUR', 'GBP')                               null,
    primary key (created_at, row_id),
    constraint id_unique
        unique (row_id),
    index transactions_merchant_id_customer_id (merchant_id, customer_Id)
) engine=InnoDB,collate = utf8mb4_unicode_ci
    row_format = DYNAMIC;

drop table if exists mig_transactions_np_log;
-- log table
create table mig_transactions_np_log
(
    id int auto_increment primary key,
    v_start_id bigint,
    v_next_id bigint,
    rows_migrated int,
    started_at timestamp default CURRENT_TIMESTAMP,
    ended_at timestamp
);

call mig_transactions_np();

drop procedure if exists mig_transactions_np;
create procedure mig_transactions_np()
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
        insert into mig_transactions_np_log(v_start_id, v_next_id)
        values (v_start_id, v_next_id);
        set v_log_Id = last_insert_id();

        insert into mig_transactions_np (
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
        where row_id between v_start_id and v_next_id
                and row_id not in (12325247);
        set insert_row_cnt = row_count();

        update mig_transactions_np_log set rows_migrated = insert_row_cnt, ended_at = NOW() where id = v_log_id;

        set v_start_id = v_next_id + 1;
        set v_next_id = v_start_id + v_batch_size;
        end while;
end;