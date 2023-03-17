--All of these are good data 
-- Inserts into NEW_TRANSACTIONS
--transaction 1
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Payment for services rendered', 1250, 'D', 30000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Payment for services rendered', 3058, 'C', 30000);

--transaction 2
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Investment purchased', 1850, 'D', 30000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Investment purchased', 1250, 'C', 30000);

--transaction 3
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Royalty revenue', 1250, 'D', 10000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Royalty revenue', 3073, 'C', 10000);








--Null transaction Number
--transaction 12
INSERT INTO new_transactions
VALUES
(NULL, SYSDATE, 'Payroll processed', 4045, 'D', 5000);

INSERT INTO new_transactions
VALUES
(NULL, SYSDATE, 'Payroll processed', 2050, 'C', 5000);







--Bad transaction_type
--transaction 17
INSERT INTO new_transactions
VALUES
(50, TRUNC(SYSDATE), 'Payment for services rendered', 1250, 'D', 30000);

INSERT INTO new_transactions
VALUES
(50, TRUNC(SYSDATE), 'Payment for services rendered', 3058, 'Q', 30000);


COMMIT;










--nagative transaction_amount 
--transaction 16
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, SYSDATE, 'Royalty revenue', 1250, 'D', 4000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, SYSDATE, 'Royalty revenue', 1150, 'D', -1000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, SYSDATE, 'Royalty revenue', 3073, 'C', 3000);







--Non existent account number 
--transaction 1
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, SYSDATE, 'Payment for services rendered', 8780, 'D', 30000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, SYSDATE, 'Payment for services rendered', 3058, 'C', 30000);