--==TestCode
DECLARE
    --Constants
    k_tDebit CHAR(1) := 'D';
    k_tCredit CHAR(1) := 'C';

    --Cursor
    CURSOR cur_ntData IS
    SELECT *
    FROM NEW_TRANSACTIONS;
	
	Cursor c_account IS
		SELECT *
	FROM ACCOUNT;

    --Variables
    v_accAccNo ACCOUNT.Account_no%TYPE; --The Account_no in the ACCOUNT TABLE 
    v_accAccTypeCode ACCOUNT.Account_type_code%TYPE; --The Account_type_code in the ACCOUNT TABLE
    v_accAccBal ACCOUNT.Account_balance%TYPE; --The Account_balance in the ACCOUNT TABLE
    v_atDefTransType ACCOUNT_TYPE.Default_trans_type%TYPE; --The Default_trans_type in the ACCOUNT_ TABLE
    v_ntTransNoTemp NEW_TRANSACTIONS.Transaction_no%TYPE; --A placeholder for tranaction number
    v_ntTransDate NEW_TRANSACTIONS.Transaction_date%TYPE; --A placeholder for tranaction date
    v_errorStatus NUMBER(1) := 0; --Status for transaction group
    v_transaction_balanced NUMBER; --current transaction stuff
	v_transDesc NEW_TRANSACTIONS.Description%TYPE; --The Description of the transaction
    v_transType NEW_TRANSACTIONS.Transaction_type%TYPE; --The transaction type of the new transaction
    v_transAmount NEW_TRANSACTIONS.Transaction_amount%TYPE; --The size of the transaction
	v_count INTEGER; --For making sure the transaction number is UNIQUE
	v_exists NUMBER := 0; --Used to check if the account number in a transaction exists

BEGIN

    v_errorStatus := 0;
    v_ntTransNoTemp := 0;
    
	BEGIN
	
        FOR rec_ntData IN cur_ntData LOOP

            DECLARE
            --Exceptions
            e_invalidAccNum EXCEPTION;
            e_negative_amount EXCEPTION;
            e_invalidTransType EXCEPTION;
            e_missingTransNum EXCEPTION;
            e_uneven_transaction_balance EXCEPTION;

            BEGIN
        
                IF(rec_ntData.transaction_no IS NULL) THEN 
                    v_errorStatus := 1;
                    raise e_missingTransNum;
                END IF;
                
                for rec_account IN c_account LOOP
                    IF(rec_ntData.account_no = rec_account.account_no) THEN
                        v_exists := 1;

                    END IF;

                END loop;

                IF(v_exists = 0) THEN
                    raise e_invalidAccNum;
                END IF;

                SELECT Account_no, Account_type_code, Account_balance
                INTO v_accAccNo, v_accAccTypeCode, v_accAccBal
                FROM ACCOUNT
                WHERE Account_no = rec_ntData.Account_no;
                
                SELECT Default_trans_type
                INTO v_atDefTransType
                FROM ACCOUNT_TYPE
                WHERE Account_type_code = v_accAccTypeCode;

                v_ntTransDate := rec_ntData.Transaction_date;
                v_ntTransNoTemp := rec_ntData.Transaction_no;
                v_transType := rec_ntData.Transaction_type;
                v_transAmount := rec_ntData.Transaction_amount;
                V_transDesc := rec_ntData.description;

                --Point Beginning
                IF (v_ntTransNoTemp = rec_ntData.Transaction_no) THEN
                    
                    --Error Checking
                    IF (v_errorStatus = 0) THEN

                        IF(rec_ntData.Transaction_no is null) THEN 
                            v_errorStatus := 1;
                            raise e_negative_amount;
                        END IF;
                        
                        IF(rec_ntData.Transaction_amount <0) THEN 
                            v_errorStatus := 1;
                            raise e_negative_amount;
                        END IF;

                        IF(rec_ntData.Transaction_type <> 'D' AND rec_ntData.Transaction_type <> 'C')THEN
                            v_errorStatus := 1;
                            raise e_invalidTransType;
                        END IF;
                        
                        IF(rec_ntData.Transaction_type = 'D') THEN 
                            v_transaction_balanced := v_transaction_balanced + rec_ntData.transaction_amount;
                        ELSE 
                            v_transaction_balanced := v_transaction_balanced - rec_ntData.transaction_amount;
                        END IF;
                        
                        
                        --Updating
                        IF (rec_ntData.Account_no = v_accAccNo) THEN
                            CASE
                                WHEN (v_atDefTransType = rec_ntData.Transaction_type) THEN
                                    UPDATE ACCOUNT
                                    SET Account_balance = Account_balance + rec_ntData.Transaction_amount
                                    WHERE Account_no = rec_ntData.Account_no;

                                WHEN (v_atDefTransType != rec_ntData.Transaction_type) THEN
                                    UPDATE ACCOUNT
                                    SET Account_balance = Account_balance - rec_ntData.Transaction_amount
                                    WHERE Account_no = rec_ntData.Account_no;
                                    
                                ELSE NULL;
                            END CASE;

                        END IF;
                          
                        --When a transaction isn't even, but im not sure where this would go 
                        --DBMS_OUTPUT.PUT_LINE(v_transaction_balanced || 'hello how are you today');
                        IF(v_transaction_balanced <> 0) THEN
                            raise e_uneven_transaction_balance;
                        END IF;

                        DBMS_OUTPUT.PUT_LINE(v_ntTransNoTemp);
                        
                    ELSE NULL;

                    END IF;
                
                ELSIF (v_ntTransNoTemp != rec_ntData.Transaction_no) THEN
                    IF (v_errorStatus = 1) THEN
                        v_errorStatus := 0;

                    ELSE  
                        NULL;
                        --COMMIT;

                    END IF;

                ELSE NULL;
                END IF;
                --Point End 
                
                SELECT COUNT(*) INTO v_count
                FROM transaction_history
                WHERE transaction_no = V_ntTransNoTemp;
                
                IF v_count = 0 THEN
                    INSERT INTO transaction_history (transaction_no, transaction_date, DESCRIPTION)
                    VALUES (V_ntTransNoTemp, V_ntTransDate, V_transDesc);

                ELSE NULL;
                END IF;

                INSERT INTO transaction_detail (Account_no, transaction_no, transaction_type, transaction_amount)
                VALUES (v_accAccNo, v_ntTransNoTemp, v_transType, v_transAmount);
                
                --delete from new_transactions where transaction_no = v_ntTransNoTemp; --deletes all transactions of the same number
            
            EXCEPTION
                WHEN e_invalidAccNum THEN
                    INSERT INTO wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
                    VALUES(v_ntTransNoTemp, v_ntTransDate, 'Account # does not exist', 'invalidAccNum');
                WHEN e_negative_amount THEN
                    INSERT INTO wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
                    VALUES(v_ntTransNoTemp, v_ntTransDate, 'Negative values are invalid', 'negativeAmount');
                WHEN e_invalidTransType THEN
                    INSERT INTO wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
                    VALUES(v_ntTransNoTemp, v_ntTransDate, 'Invalid trasaction type', 'invalidTransType');
                WHEN e_missingTransNum THEN
                    INSERT INTO wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
                    VALUES(null, v_ntTransDate, 'Missing transaction number', 'missingTransNum');
                WHEN e_uneven_transaction_balance THEN 
                    INSERT INTO wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
                    VALUES(v_ntTransNoTemp, v_ntTransDate, 'The Transaction Doesnt balance', 'unevenTransBal');
                WHEN others THEN 
                    DBMS_OUTPUT.PUT_LINE('Some other error occured');

            END;
        END LOOP;	
	END;
END;
/