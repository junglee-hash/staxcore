/*
select created_at, date(created_at) from fatt.invoices limit 10;
 SELECT
  TABLE_SCHEMA,
  TABLE_NAME,
  PARTITION_NAME,
  PARTITION_ORDINAL_POSITION AS part_no,
  PARTITION_METHOD,
  PARTITION_EXPRESSION,
  PARTITION_DESCRIPTION,
  TABLE_ROWS,           -- approximate
  DATA_LENGTH,          -- bytes
  INDEX_LENGTH,         -- bytes
  (DATA_LENGTH + INDEX_LENGTH) AS total_bytes
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_SCHEMA = 'fatt'
  AND TABLE_NAME   = 'mig_invoices'
  AND PARTITION_NAME IS NOT NULL
ORDER BY part_no;
 */

SELECT
      i.total - SUM(
      CASE
      WHEN t.type IN ('refund','void','credit') AND t.success = 1 THEN t.total * -1
      WHEN t.type IN ('charge','capture') AND t.success = 1 THEN t.total
      ELSE 0 END) as sum,
      i.id as invoice_id,
      i.status,
      DATE_FORMAT(CONVERT_TZ(i.created_at, 'UTC', '-5:00'), '%Y-%m-%d %T') as datetime,
      i.customer_id,
      c.firstname as customer_firstname,
      c.lastname as customer_lastname,
      c.email as customer_email
      FROM fatt.invoices i
      LEFT JOIN fatt.customers c ON i.customer_id = c.id
      LEFT JOIN fatt.transactions t ON i.id = t.invoice_id
      WHERE i.merchant_id = '90dfced0-bd2f-4cd7-8ab2-7a8add79f9db'
      AND i.created_at BETWEEN '2026-03-01 05:00:00' AND '2026-03-04 04:59:59'
      AND i.status NOT IN ('paid')
      AND i.deleted_at IS NULL
      GROUP BY i.id
      UNION ALL # duplicate query as a union to get portal merchant data also
      SELECT
      i.total - SUM(
      CASE
      WHEN t.type IN ('refund','void','credit') AND t.success = 1 THEN t.total * -1
      WHEN t.type IN ('charge','capture') AND t.success = 1 THEN t.total
      ELSE 0 END) as sum,
      i.id as invoice_id,
      i.status,
      DATE_FORMAT(CONVERT_TZ(i.created_at, 'UTC', '-5:00'), '%Y-%m-%d %T') as datetime,
      i.customer_id,
      c.firstname as customer_firstname,
      c.lastname as customer_lastname,
      c.email as customer_email
      FROM processor.invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      LEFT JOIN processor.transactions t ON i.id = t.invoice_id
      LEFT JOIN fatt.transactions_settlements as ts ON ts.settlement_id = t.id
      JOIN processor.merchants m ON m.id = i.merchant_id
      AND m.id = '90dfced0-bd2f-4cd7-8ab2-7a8add79f9db'
      AND i.created_at BETWEEN '2026-03-01 05:00:00' AND '2026-03-04 04:59:59'
      AND i.status NOT IN ('paid')
      AND i.deleted_at IS NULL
      AND ts.transaction_id IS NULL
      GROUP BY i.id;