alter table processor.transactions_fees_amounts
    drop primary key,
    add column row_id int unsigned not null auto_increment,
        add primary key (row_id),
        add unique key transaction_id_unique (transaction_id);