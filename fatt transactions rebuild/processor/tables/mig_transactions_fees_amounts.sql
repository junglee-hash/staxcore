drop table if exists `mig_transactions_fees_amounts`;
create table `mig_transactions_fees_amounts` (
  `row_id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(40) COLLATE utf8mb3_unicode_ci NOT NULL,
  `merchant_id` varchar(40) COLLATE utf8mb3_unicode_ci NOT NULL,
  `type` varchar(32) COLLATE utf8mb3_unicode_ci NOT NULL,
  `fee_count` int NOT NULL,
  `fee_amount` decimal(20,5) NOT NULL,
  `surcharge_amount` decimal(20,5) DEFAULT NULL,
  `base_amount` decimal(20,5) DEFAULT NULL,
  `total` decimal(20,5) DEFAULT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`created_at`, `row_id`),
  UNIQUE KEY `id_unique` (row_id),
  UNIQUE KEY `transaction_id_unique` (`transaction_id`),
  KEY `merchant_id_index` (`merchant_id`),
  KEY `updated_at_index` (`updated_at`),
  KEY `type_mid_created_at_index` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci COMMENT='"materialized view" aggregation table';