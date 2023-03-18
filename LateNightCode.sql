
COLUMN 'description' FORMAT A30
COLUMN error_msg FORMAT A30
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
	v_currentNo NEW_TRANSACTIONS.Transaction_no%TYPE; --A placeholder for tranaction number
	v_usedForUpdate NEW_TRANSACTIONS.Transaction_no%TYPE; --A placeholder for tranaction number
    v_ntTransDate NEW_TRANSACTIONS.Transaction_date%TYPE; --A placeholder for tranaction date
    v_errorStatus NUMBER(1) := 0; --Status for transaction group
    v_transaction_balanced NUMBER; --current transaction stuff
	v_transDesc NEW_TRANSACTIONS.Description%TYPE; --The Description of the transaction
    v_transType NEW_TRANSACTIONS.Transaction_type%TYPE; --The transaction type of the new transaction
    v_transAmount NEW_TRANSACTIONS.Transaction_amount%TYPE; --The size of the transaction
	v_count INTEGER; --For making sure the transaction number is UNIQUE
	v_exists number := 0; --Used to check if the account number in a transaction exists

    --Exceptions
    e_invalidAccNum EXCEPTION;
	e_negative_amount EXCEPTION;
	e_invalidTransType EXCEPTION;
	e_missingTransNum EXCEPTION;
	e_uneven_transaction_balance EXCEPTION;

BEGIN

    v_ntTransNoTemp := 0;
    FOR rec_ntData IN cur_ntData LOOP
    v_errorStatus := 0;
	BEGIN
	
			DBMS_OUTPUT.PUT_LINE(' '|| rec_ntData.transaction_no ||' '|| rec_ntData.account_no ||' '||rec_ntData.Transaction_amount||' '|| rec_ntData.Transaction_type);
			
				if(rec_ntData.transaction_no is null) then 
					--rollback;
					DBMS_OUTPUT.PUT_LINE('null trans number');
					v_errorStatus := 1;
                    raise e_missingTransNum;
                end if;
				
				for rec_account in c_account LOOP
					if(rec_ntData.account_no = rec_account.account_no) then
						v_exists := 1;
					end if;
				end loop;
				if(v_exists = 0) then
					DBMS_OUTPUT.PUT_LINE('bad account number');
					raise e_invalidAccNum;
				end if;

				--DBMS_OUTPUT.PUT_LINE(rec_ntData.Account_no);
				SELECT Account_no, Account_type_code, Account_balance
				INTO v_accAccNo, v_accAccTypeCode, v_accAccBal
				FROM ACCOUNT
				WHERE Account_no = rec_ntData.Account_no;
				
				SELECT Default_trans_type
				INTO v_atDefTransType
				FROM ACCOUNT_TYPE
				WHERE Account_type_code = v_accAccTypeCode;

                v_ntTransDate := rec_ntData.Transaction_date;
				v_transType := rec_ntData.Transaction_type;
				v_transAmount := rec_ntData.Transaction_amount;
				V_transDesc := rec_ntData.description;
				v_usedForUpdate := rec_ntData.Transaction_no;
				
				if(v_ntTransNoTemp = 0) then
					v_ntTransNoTemp := rec_ntData.Transaction_no;
				ELSE
					v_ntTransNoTemp := v_currentNo;
				end if;

				IF (v_ntTransNoTemp != rec_ntData.Transaction_no) THEN
		
						DBMS_OUTPUT.PUT_LINE('hello how are you today');
                IF(v_transaction_balanced <> 0) THEN
					--rollback;
                    raise e_uneven_transaction_balance;
                END IF;
				
				
				
				
				
				--Point Beginning
                IF (v_ntTransNoTemp = rec_ntData.Transaction_no) THEN
                    v_currentNo := rec_ntData.Transaction_no;
					
                    --Error Checking
                    --IF (v_errorStatus = 0) THEN
                        
                        IF(rec_ntData.Transaction_amount <0) THEN 
                            --rollback;
							DBMS_OUTPUT.PUT_LINE('Transaction Ammount');
							v_errorStatus := 1;
							raise e_negative_amount;
                        END IF;

						--DBMS_OUTPUT.PUT_LINE(rec_ntData.Transaction_type);
                        IF(rec_ntData.Transaction_type <> 'D' and rec_ntData.Transaction_type <> 'C')THEN
                            --rollback;
							DBMS_OUTPUT.PUT_LINE('Bad data type');
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
                        
                    

                    --END IF;
				end if;					--DBMS_OUTPUT.PUT_LINE('Why this no work');
						
				--COMMIT;
                    IF (v_errorStatus = 1) THEN
                        v_errorStatus := 0;

                    ELSE  
                        NULL;
                        

                    END IF;

                ELSE NULL;
                END IF;
				--Point End 
			
			--Everything below this is for adding to the table and stuff		
			--COMMIT;
			v_errorStatus := 0;
			v_exists := 0;			
			SELECT COUNT(*) INTO v_count
			FROM transaction_history
			WHERE transaction_no = v_usedForUpdate;
			
			--DBMS_OUTPUT.PUT_LINE(v_count);
			IF v_count = 0 THEN
				
				--DBMS_OUTPUT.PUT_LINE(' '|| v_usedForUpdate ||' '|| V_ntTransDate ||' '||V_transDesc);
				INSERT INTO transaction_history (transaction_no, transaction_date, description)
				VALUES (v_usedForUpdate, V_ntTransDate, V_transDesc);
				
				insert into transaction_detail (Account_no, transaction_no, transaction_type, transaction_amount)
				values (v_accAccNo, v_usedForUpdate, v_transType, v_transAmount);
			ELSE
				null;
			END IF;

			
			
			--if(v_errorStatus = 0)then
			delete from new_transactions where transaction_no = v_usedForUpdate; --deletes all transactions of the same number
			--end if;	
			--v_errorStatus := 0;
			
            
	EXCEPTION
		--I don't think doing these as application errors is the best call 
		--as it will terminate the program 
		--Stuff can also be added to the error table 
			WHEN e_invalidAccNum THEN
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(v_ntTransNoTemp, v_ntTransDate, 'Account # does not exist', 'invalidAccNum');
				v_errorStatus := 0;
			WHEN e_negative_amount THEN
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(v_ntTransNoTemp, v_ntTransDate, 'Negative values are invalid', 'negativeAmount');
				v_errorStatus := 0;
			WHEN e_invalidTransType THEN
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(v_ntTransNoTemp, v_ntTransDate, 'Invalid trasaction type', 'invalidTransType');
				v_errorStatus := 0;
			WHEN e_missingTransNum THEN
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(null, v_ntTransDate, 'Missing transaction number', 'missingTransNum');
				v_errorStatus := 0;
			WHEN e_uneven_transaction_balance THEN 
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(v_ntTransNoTemp, v_ntTransDate, 'The Transaction Doesnt balance', 'unevenTransBal');
				v_errorStatus := 0;
			--WHEN others THEN 
			--	DBMS_OUTPUT.PUT_LINE('Some other error occured');
			
	END;
	END LOOP;
END;
/
