drop table if exists mig_transactions_cdc;
create table mig_transactions_cdc
(
    `id`                 bigint unsigned                                                                                                                                              NOT NULL,
    `settlement_id`      varchar(40) COLLATE utf8mb3_unicode_ci                                                                                                                            DEFAULT NULL COMMENT 'processor.transaction.id',
    `transaction_id`     varchar(40) COLLATE utf8mb3_unicode_ci                                                                                                                            DEFAULT NULL COMMENT 'fatt.transaction.id',
    `batch_id`           varchar(50) COLLATE utf8mb3_unicode_ci                                                                                                                            DEFAULT NULL COMMENT 'Populated with processor.transactions.batch_id',
    `source`             enum ('emaf','engine','finix','skynetsimulator','terminalservice.deja','test','unknown','haywire-test','terminalservice.dejavoo') COLLATE utf8mb3_unicode_ci NOT NULL,
    `processor`          enum ('processor','test') COLLATE utf8mb3_unicode_ci                                                                                                         NOT NULL,
    `funded_at`          timestamp                                                                                                                                                    NULL DEFAULT NULL,
    `deleted_at`         timestamp                                                                                                                                                    NULL DEFAULT NULL,
    `created_at`         datetime                                                                                                                                                     NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`         timestamp                                                                                                                                                    NULL DEFAULT NULL,
    `settlement_row_id`  bigint unsigned                                                                                                                                                   DEFAULT NULL COMMENT 'row id for processor.transaction',
    `transaction_row_id` bigint unsigned                                                                                                                                                   DEFAULT NULL COMMENT 'row id for fatt.transaction',
    cdc_type             enum ('INSERT', 'UPDATE', 'DELETE')                                                                                                                               default 'INSERT' not null comment 'The type of change that occurred in the row.',
    cdc_created_at       timestamp                                                                                                                                                         default CURRENT_TIMESTAMP not null comment 'The timestamp of the change.'
);