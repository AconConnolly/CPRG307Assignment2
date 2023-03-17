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
	
	rec_account c_account%ROWTYPE;

    --Variables
    v_accAccNo ACCOUNT.Account_no%TYPE; --The Account_no in the ACCOUNT TABLE 
    v_accAccTypeCode ACCOUNT.Account_type_code%TYPE; --The Account_type_code in the ACCOUNT TABLE
    v_accAccBal ACCOUNT.Account_balance%TYPE; --The Account_balance in the ACCOUNT TABLE
    v_atDefTransType ACCOUNT_TYPE.Default_trans_type%TYPE; --The Default_trans_type in the ACCOUNT_ TABLE
    v_ntTransNoTemp NEW_TRANSACTIONS.Transaction_no%TYPE; --A placeholder for tranaction number
    v_ntTransDate NEW_TRANSACTIONS.Transaction_date%TYPE; --A placeholder for tranaction date
    v_errorStatus NUMBER(1) := 0; --Status for transaction group
    v_transaction_balanced number; --current transaction stuff
	v_exists number := 0; --Used to check if the account number in a transaction existst

    --Exceptions
    e_invalidAccNum EXCEPTION;
	e_negative_amount EXCEPTION;
	e_invalidTransType EXCEPTION;
	e_missingTransNum EXCEPTION;
	e_uneven_transaction_balance EXCEPTION;

BEGIN

    v_ntTransNoTemp := 0;

	begin

	
			FOR rec_ntData IN cur_ntData LOOP

				--This is functional (check if transaction number is null)
				if(rec_ntData.transaction_no is null) then 
                            raise e_missingTransNum;
                        end if;
						
				
				--This is functional (cheack for missing account number)
				for rec_account in c_account LOOP
					if(rec_ntData.account_no = rec_account.account_no) then
						v_exists := 1;
					end if;
				end loop;
				if(v_exists = 0) then
					raise e_invalidAccNum;
				end if;
					


					
				SELECT Account_no, Account_type_code, Account_balance
				INTO v_accAccNo, v_accAccTypeCode, v_accAccBal
				FROM ACCOUNT
				WHERE Account_no = rec_ntData.Account_no;
				
				SELECT Default_trans_type
				INTO v_atDefTransType
				FROM ACCOUNT_TYPE
				WHERE Account_type_code = v_accAccTypeCode;

                v_ntTransDate := rec_ntData.Transaction_date;

				v_ntTransNoTemp := rec_ntData.transaction_no;
				--Point beginign
                --IF (v_ntTransNoTemp != rec_ntData.Transaction_no) THEN
                --    v_ntTransNoTemp := rec_ntData.Transaction_no;
                --    v_errorStatus := 0;

                --ELSIF (v_ntTransNoTemp = rec_ntData.Transaction_no) THEN
                --    IF (v_errorStatus = 1) THEN
                --        NULL;
                --    ELSIF (v_errorStatus = 0) THEN

                        --Error checking
                        
                        
                        --This is functional  (Checks if the ammont in the transaction is negative)
                        if(rec_ntData.transaction_amount <0) then 
                            raise e_negative_amount;
                        end if;

						--This is functional (will throw an error if the transacion type is not C or D)
                        if(rec_ntData.Transaction_type <> 'D' and rec_ntData.Transaction_type <> 'C')THEN
                            raise e_invalidTransType;
                        end if;
                        
                        if(rec_ntData.transaction_type = 'D') then 
                            v_transaction_balanced := v_transaction_balanced + rec_ntData.transaction_amount;
                        else 
                            v_transaction_balanced := v_transaction_balanced - rec_ntData.transaction_amount;
                        end if;
                        
                        --Updateing 
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
                        
                        --Cant check
                        if(v_transaction_balanced <> 0)then 
                            raise e_uneven_transaction_balance;
                        end if;
                        
                    --ELSE NULL;
                    --END IF;

                --ELSE NULL;
                --END IF;
				--Point end 
				
			END LOOP;
			--There will have to be a commit here
	EXCEPTION
		
			--There will have to be a roleback somewere here
			WHEN e_invalidAccNum THEN
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(v_ntTransNoTemp, v_ntTransDate, 'Account # does not exist', 'invalidAccNum');
			WHEN e_negative_amount THEN
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(v_ntTransNoTemp, v_ntTransDate, 'Negative values are invalid', 'negativeAmount');
			WHEN e_invalidTransType THEN
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(v_ntTransNoTemp, v_ntTransDate, 'Invalid trasaction type', 'invalidTransType');
			WHEN e_missingTransNum THEN
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(null, v_ntTransDate, 'Missing transaction number', 'missingTransNum');
			WHEN e_uneven_transaction_balance then 
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(v_ntTransNoTemp, v_ntTransDate, 'The Transaction Doesnt balance', 'unevenTransBal');
			--I comments this out to make sure I can see other error 
			--It will have to be added back after 
			--WHEN others then 
			--	DBMS_OUTPUT.PUT_LINE('Some other error occured');
			
	END;
END;
/