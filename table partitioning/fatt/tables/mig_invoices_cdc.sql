drop table if exists mig_invoices_cdc;
create table mig_invoices_cdc
(
    `id`                         varchar(50) COLLATE utf8mb3_unicode_ci                                                                            NOT NULL,
    `merchant_id`                varchar(50) COLLATE utf8mb3_unicode_ci                                                                            NOT NULL,
    `user_id`                    varchar(50) COLLATE utf8mb3_unicode_ci                                                                            NOT NULL,
    `customer_id`                varchar(50) COLLATE utf8mb3_unicode_ci                                                                                     DEFAULT '',
    `total`                      double                                                                                                            NOT NULL,
    `meta`                       text COLLATE utf8mb3_unicode_ci                                                                                   NOT NULL,
    `status`                     enum ('VOID','DELETED','DRAFT','SENT','VIEWED','PAID','PARTIALLY APPLIED','ATTEMPTED') COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'DRAFT',
    `is_merchant_present`        tinyint(1)                                                                                                                 DEFAULT NULL,
    `sent_at`                    timestamp                                                                                                         NULL     DEFAULT NULL,
    `viewed_at`                  timestamp                                                                                                         NULL     DEFAULT NULL,
    `paid_at`                    timestamp                                                                                                         NULL     DEFAULT NULL,
    `schedule_id`                varchar(50) COLLATE utf8mb3_unicode_ci                                                                                     DEFAULT NULL,
    `reminder_id`                varchar(50) COLLATE utf8mb3_unicode_ci                                                                                     DEFAULT NULL,
    `payment_method_id`          varchar(50) COLLATE utf8mb3_unicode_ci                                                                                     DEFAULT NULL,
    `url`                        varchar(100) COLLATE utf8mb3_unicode_ci                                                                           NOT NULL,
    `is_webpayment`              tinyint(1)                                                                                                        NOT NULL,
    `deleted_at`                 timestamp                                                                                                         NULL     DEFAULT NULL,
    `created_at`                 datetime                                                                                                          NOT NULL DEFAULT '0000-00-00 00:00:00',
    `updated_at`                 timestamp                                                                                                         NOT NULL DEFAULT '0000-00-00 00:00:00',
    `due_at`                     varchar(20) COLLATE utf8mb3_unicode_ci                                                                                     DEFAULT NULL,
    `is_partial_payment_enabled` tinyint(1)                                                                                                        NOT NULL DEFAULT '1',
    `invoice_date_at`            timestamp                                                                                                         NULL     DEFAULT NULL,
    cdc_type                     enum ('INSERT', 'UPDATE', 'DELETE')                                                                                        default 'INSERT' not null comment 'The type of change that occurred in the row.',
    cdc_created_at               timestamp
)