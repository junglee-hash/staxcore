explain format = json
SELECT t.is_card_present
     , t.card_brand
     , t.bin_type
     , MAX(t.rate)                                                                         AS rate
     , ROUND(SUM(
                     CASE
                         WHEN t.transaction_type IN ('refund', 'void', 'credit') THEN -1 * t.base_amount
                         WHEN t.transaction_type = 'pre_auth' THEN 0
                         ELSE COALESCE(t.base_amount, 0) END
             ), 4)                                                                         AS total_charges
     , SUM(CASE WHEN t.transaction_type IN ('refund', 'void', 'credit') THEN 0 ELSE 1 end) AS use_count
     , ROUND(SUM(rate_fees_amount), 4)                                                     AS rate_fees
     , ROUND(SUM(transaction_fees_amount), 4)                                              AS per_transaction_fees
     , ROUND(SUM(interchange_fees_amount), 4)                                              AS interchange_fees_amount
     , ROUND(SUM(rate_fees_amount + interchange_fees_amount + transaction_fees_amount), 4) AS total_fees
FROM (SELECT pt.id           AS transaction_id
           , CASE
                 WHEN icp.is_card_present = 1 THEN 1
                 ELSE 0
        END                  AS is_card_present
           , CASE
                 WHEN pt.method = 'bank' THEN 'ACH'
                 WHEN ft.method IS NOT NULL AND ft.method = 'VENMO' THEN 'VENMO'
                 WHEN ft.method IS NOT NULL AND ft.method = 'PAYPAL' THEN 'PAYPAL'
                 WHEN pm.card_type IS NOT NULL THEN pm.card_type
                 WHEN pm.method IS NULL AND pt.reference_id != '' THEN COALESCE(orp.card_type, orfpm.card_type)
                 ELSE COALESCE(fpm.card_type, pt.method)
        END                  AS card_brand
           , CASE
                 WHEN pm.method = 'bank' OR fpm.method = 'bank' THEN 'ACH'
                 WHEN pm.method IS NULL AND pt.method = 'bank' THEN 'ACH'
                 WHEN pm.method IS NULL AND pt.reference_id != '' THEN COALESCE(orp.bin_type, orfpm.bin_type)
                 ELSE COALESCE(pm.bin_type, fpm.bin_type)
        END                  AS bin_type
           , CASE
                 WHEN JSON_VALID(pt.meta) AND JSON_EXTRACT(pt.meta, '$.billing') IS NOT NULL
                     THEN ROUND(JSON_EXTRACT(pt.meta, '$.billing.fee_percent') * 100, 2)
                 WHEN JSON_VALID(ort.meta) AND JSON_EXTRACT(ort.meta, '$.billing') IS NOT NULL
                     THEN ROUND(JSON_EXTRACT(ort.meta, '$.billing.fee_percent') * 100, 2)
                 WHEN rtppr.rate THEN ROUND(rtppr.rate, 2)
                 ELSE COALESCE(ROUND(tppr.rate, 2), 0.00)
        END                  AS rate
           , tfa.base_amount AS base_amount
           , SUM(
            CASE
                WHEN psf.type IN ('CARD_FIXED', 'ACH_FIXED') THEN psf.total
                ELSE 0
                END
             )               AS transaction_fees_amount
           , SUM(
            CASE
                WHEN psf.type IN ('CARD_BASIS_POINTS', 'ACH_BASIS_POINTS') THEN psf.total
                ELSE 0
                END
             )               AS rate_fees_amount
           , SUM(
            CASE
                WHEN psf.type IN ('CARD_INTERCHANGE') THEN psf.total
                ELSE 0
                END
             )               AS interchange_fees_amount
           , tfa.type        AS transaction_type
      FROM `processor`.transactions pt
               LEFT JOIN `processor`.transactions_fees_amounts AS tfa
                         ON pt.id = tfa.transaction_id
                             AND tfa.merchant_id = pt.merchant_id
          --  Join pt to itself in order to find the original refund transaction (ort) by pt.reference_id
               LEFT JOIN `processor`.transactions ort
                         ON pt.reference_id = ort.id
                             AND pt.merchant_id = ort.merchant_id
               LEFT JOIN `processor`.payment_methods AS pm
                         ON pt.payment_method_id = pm.id
                             AND pm.merchant_id = pt.merchant_id
          --  Join payment methods using original refund transaction (ort).id to get original refund payment method (orp)
               LEFT JOIN `processor`.payment_methods orp
                         ON ort.payment_method_id = orp.id
                             AND ort.merchant_id = orp.merchant_id
               LEFT JOIN `fatt`.transactions_settlements AS fts
                         ON fts.settlement_id = pt.id
               LEFT JOIN `fatt`.transactions AS ft
                         ON ft.id = fts.transaction_id
                             AND ft.merchant_id = pt.merchant_id
               LEFT JOIN `fatt`.payment_methods AS fpm
                         ON ft.payment_method_id = fpm.id
                             AND ft.merchant_id = fpm.merchant_id
          --  Join transactions_settlements using original refund transaction (ort).id to get original refund settlements rows
               LEFT JOIN `fatt`.transactions_settlements AS orfts
                         ON orfts.settlement_id = ort.id
                             AND ft.merchant_id = fpm.merchant_id
          --  Join fatt.transactions using original refund transactions settlments id (orfts.transaction_id) to get original refund fatt transactions (orft)
               LEFT JOIN `fatt`.transactions AS orft
                         ON orft.id = orfts.transaction_id
                             AND orft.merchant_id = ort.merchant_id
          --  Join fatt.transactions_pricing_plan_rates (rtppr) on refund fatt transaction (orft) id and refund processer transaction (ort) to get rate fallback for refund transactions
               LEFT JOIN `fatt`.transactions_pricing_plan_rates AS rtppr
                         ON rtppr.transaction_id = orft.id
                             AND rtppr.merchant_id = ort.merchant_id
          --  Join fatt.payment_methods using original refund fatt transaction's payment method (orft.payment_method_id) to get original refund fatt transaction payment method (orfpm)
               LEFT JOIN `fatt`.payment_methods AS orfpm
                         ON orft.payment_method_id = orfpm.id
               LEFT JOIN `fatt`.transactions_is_card_present AS icp
                         ON ft.id = icp.transaction_id
               LEFT JOIN `fatt`.transactions_pricing_plan_rates AS tppr
                         ON tppr.transaction_id = ft.id
                             AND tppr.merchant_id = pt.merchant_id
               LEFT JOIN `fatt`.registrations AS r
                         ON r.merchant_id = pt.merchant_id
               LEFT JOIN `processor`.settlement_fees AS psf
                         ON psf.transaction_id = pt.id
                             AND psf.merchant_id = pt.merchant_id
      WHERE pt.merchant_id = '6624f2c2-4cab-42d7-b8a1-d2210be9b3ff'
        AND (
          (psf.batch_id IN (SELECT batch_id
                            FROM `processor`.settlement_fees sf
                            WHERE sf.merchant_id = '6624f2c2-4cab-42d7-b8a1-d2210be9b3ff'
                              AND sf.settled_at BETWEEN '2026-03-05 00:00:00.000' AND '2026-03-05 23:59:59.999'
                            GROUP BY batch_id)
              AND psf.type NOT IN
                  ("APPLICATION_FEE", "DISPUTE_FIXED_FEE", "DISPUTE_INQUIRY_FIXED_FEE", "ACH_DEBIT_RETURN_FIXED_FEE")
              )
              OR (
              tfa.created_at BETWEEN '2026-02-01 00:00:00' AND '2026-02-28 23:59:59'
                  AND tfa.surcharge_amount > 0
                  AND tfa.fee_amount = 0
                  AND psf.type IN ("APPLICATION_FEE", "DISPUTE_FIXED_FEE", "DISPUTE_INQUIRY_FIXED_FEE",
                                   "ACH_DEBIT_RETURN_FIXED_FEE")
              )
          )
        AND (
          pt.meta IS NULL
              -- Exclude dispute holds and achreturn clawbacks
              OR
          (
              JSON_VALID(pt.meta)
                  AND COALESCE(pt.meta -> "$.isChargeback", false) != 'true'
                  AND COALESCE(pt.meta ->> "$.externalType", "") != 'ACHRETURN'
              )
          )

      GROUP BY pt.id, icp.is_card_present, fpm.bin_type, tppr.rate, fpm.card_type, ft.method, orfpm.card_type,
               orfpm.bin_type, fpm.method, rtppr.rate) t
GROUP BY t.card_brand, t.bin_type, t.is_card_present, t.rate;