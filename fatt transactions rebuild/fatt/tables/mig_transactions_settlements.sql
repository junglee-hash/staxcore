drop table if exists mig_transactions_settlements;
create table `mig_transactions_settlements` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `settlement_id` varchar(40) COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'processor.transaction.id',
  `transaction_id` varchar(40) COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'fatt.transaction.id',
  `batch_id` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Populated with processor.transactions.batch_id',
  `source` enum('emaf','engine','finix','skynetsimulator','terminalservice.deja','test','unknown','haywire-test','terminalservice.dejavoo') COLLATE utf8mb3_unicode_ci NOT NULL,
  `processor` enum('processor','test') COLLATE utf8mb3_unicode_ci NOT NULL,
  `funded_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  `settlement_row_id` bigint unsigned DEFAULT NULL COMMENT 'row id for processor.transaction',
  `transaction_row_id` bigint unsigned DEFAULT NULL COMMENT 'row id for fatt.transaction',
  PRIMARY KEY (`created_at`,`id`),
  UNIQUE KEY `uc_id` (`id`),
  UNIQUE KEY `uc_transaction_id` (`transaction_id`),
  KEY `transactions_settlements_settlement_id_index` (`settlement_id`),
  KEY `transactions_settlements_batch_id_transaction_row_id` (`batch_id`,`transaction_row_id`),
  KEY `transactions_settlements_covering_index` (`settlement_id`(13),`transaction_id`(13),`source`),
  KEY `transactions_settlements_id_source_index` (`transaction_id`(13),`source`),
  KEY `transactions_settlements_batch_id_index` (`batch_id`(16),`transaction_id`(13))
) ENGINE=InnoDB AUTO_INCREMENT=426866375 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=COMPACT;