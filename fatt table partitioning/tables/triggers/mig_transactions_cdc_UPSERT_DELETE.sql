DELIMITER $$

drop trigger if exists trg_transactions_ai;
-- AFTER INSERT: capture the inserted row
CREATE TRIGGER trg_transactions_ai
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
  INSERT INTO mig_transactions_cdc (row_id, id, invoice_id, reference_id, reference_row_id, recurring_transaction_id
                , auth_id, type, source, source_ip, is_merchant_present, merchant_id, user_id, customer_id
                , payment_method_id, is_manual, spreedly_token, spreedly_response, success, message, meta, total, method
                , pre_auth, is_captured, last_four, interchange_code, interchange_fee, batch_id, batched_at, emv_response
                , avs_response, cvv_response, pos_entry, pos_salesperson, receipt_email_at, receipt_sms_at, settled_at
                , created_at, updated_at, gateway_id,  channel, currency, cdc_type)
  VALUES (NEW.row_id, NEW.id, NEW.invoice_id, NEW.reference_id, NEW.reference_row_id, NEW.recurring_transaction_id
                , NEW.auth_id, NEW.type, NEW.source, NEW.source_ip, NEW.is_merchant_present, NEW.merchant_id, NEW.user_id, NEW.customer_id
                , NEW.payment_method_id, NEW.is_manual, NEW.spreedly_token, NEW.spreedly_response, NEW.success, NEW.message, NEW.meta, NEW.total, NEW.method
                , NEW.pre_auth, NEW.is_captured, NEW.last_four, NEW.interchange_code, NEW.interchange_fee, NEW.batch_id, NEW.batched_at, NEW.emv_response
                , NEW.avs_response, NEW.cvv_response, NEW.pos_entry, NEW.pos_salesperson, NEW.receipt_email_at, NEW.receipt_sms_at, NEW.settled_at
                , NEW.created_at, NEW.updated_at, NEW.gateway_id,  NEW.channel, NEW.currency, 'INSERT');
END$$

DELIMITER $$
drop trigger if exists trg_transactions_bu;
-- BEFORE UPDATE: capture diffs + before/after snapshots
CREATE TRIGGER trg_transactions_bu
BEFORE UPDATE ON transactions
FOR EACH ROW
BEGIN
  INSERT INTO mig_transactions_cdc (row_id, id, invoice_id, reference_id, reference_row_id, recurring_transaction_id
                , auth_id, type, source, source_ip, is_merchant_present, merchant_id, user_id, customer_id
                , payment_method_id, is_manual, spreedly_token, spreedly_response, success, message, meta, total, method
                , pre_auth, is_captured, last_four, interchange_code, interchange_fee, batch_id, batched_at, emv_response
                , avs_response, cvv_response, pos_entry, pos_salesperson, receipt_email_at, receipt_sms_at, settled_at
                , created_at, updated_at, gateway_id,  channel, currency, cdc_type)
  VALUES (NEW.row_id, NEW.id, NEW.invoice_id, NEW.reference_id, NEW.reference_row_id, NEW.recurring_transaction_id
                , NEW.auth_id, NEW.type, NEW.source, NEW.source_ip, NEW.is_merchant_present, NEW.merchant_id, NEW.user_id, NEW.customer_id
                , NEW.payment_method_id, NEW.is_manual, NEW.spreedly_token, NEW.spreedly_response, NEW.success, NEW.message, NEW.meta, NEW.total, NEW.method
                , NEW.pre_auth, NEW.is_captured, NEW.last_four, NEW.interchange_code, NEW.interchange_fee, NEW.batch_id, NEW.batched_at, NEW.emv_response
                , NEW.avs_response, NEW.cvv_response, NEW.pos_entry, NEW.pos_salesperson, NEW.receipt_email_at, NEW.receipt_sms_at, NEW.settled_at
                , NEW.created_at, NEW.updated_at, NEW.gateway_id,  NEW.channel, NEW.currency, 'UPDATE');
END$$

DELIMITER $$
drop trigger if exists trg_transactions_bd;
-- BEFORE DELETE: capture the row that is being deleted
CREATE TRIGGER trg_transactions_bd
BEFORE DELETE ON transactions
FOR EACH ROW
BEGIN
  INSERT INTO mig_transactions_cdc (row_id, id, invoice_id, reference_id, reference_row_id, recurring_transaction_id
                , auth_id, type, source, source_ip, is_merchant_present, merchant_id, user_id, customer_id
                , payment_method_id, is_manual, spreedly_token, spreedly_response, success, message, meta, total, method
                , pre_auth, is_captured, last_four, interchange_code, interchange_fee, batch_id, batched_at, emv_response
                , avs_response, cvv_response, pos_entry, pos_salesperson, receipt_email_at, receipt_sms_at, settled_at
                , created_at, updated_at, gateway_id,  channel, currency, cdc_type)
  VALUES (OLD.row_id, OLD.id, OLD.invoice_id, OLD.reference_id, OLD.reference_row_id, OLD.recurring_transaction_id
                , OLD.auth_id, OLD.type, OLD.source, OLD.source_ip, OLD.is_merchant_present, OLD.merchant_id, OLD.user_id, OLD.customer_id
                , OLD.payment_method_id, OLD.is_manual, OLD.spreedly_token, OLD.spreedly_response, OLD.success, OLD.message, OLD.meta, OLD.total, OLD.method
                , OLD.pre_auth, OLD.is_captured, OLD.last_four, OLD.interchange_code, OLD.interchange_fee, OLD.batch_id, OLD.batched_at, OLD.emv_response
                , OLD.avs_response, OLD.cvv_response, OLD.pos_entry, OLD.pos_salesperson, OLD.receipt_email_at, OLD.receipt_sms_at, OLD.settled_at
                , OLD.created_at, OLD.updated_at, OLD.gateway_id,  OLD.channel, OLD.currency, 'DELETE');
END$$