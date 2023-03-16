SET LINESIZE 60
SET PAGESIZE 66
SET SERVEROUTPUT ON

--==Constants
    k_tDebit CHAR(1) := 'D';
    k_tCredit CHAR(1) := 'C';

--==Exceptions
	e_invalidAccNum EXCEPTION;
	e_negative_amount EXCEPTION;
	e_invalidTransType EXCEPTION;
	e_missingTransNum EXCEPTION;
	e_uneven_transaction_balance EXCEPTION;
	
--==NEW_TRANSACTIONS
CURSOR cur_ntData IS
SELECT *
FROM NEW_TRANSACTIONS;

--==Account
Cursor c_account IS
SELECT *
FROM ACCOUNT;

--==Get Account_no for Account_Bal (Where statement for update)
--Dec
v_accAccNo ACCOUNT.Account_no%TYPE; --The Account_no in the ACCOUNT TABLE 
v_accAccTypeCode ACCOUNT.Account_type_code%TYPE; --The Account_type_code in the ACCOUNT TABLE
v_accAccBal ACCOUNT.Account_balance%TYPE; --The Account_balance in the ACCOUNT TABLE

--Beg
SELECT Account_no, Account_type_code, Account_balance
INTO v_accAccNo, v_accAccTypeCode, v_accAccBal
FROM ACCOUNT
WHERE Account_no = rec_ntData.Account_no;

--End

--==Get Default_trans_type for comparison (D or C)
--Dec
v_atDefTransType ACCOUNT_TYPE.Default_trans_type%TYPE; --The Default_trans_type in the ACCOUNT_ TABLE

--Beg
SELECT Default_trans_type
INTO v_atDefTransType
FROM ACCOUNT_TYPE
WHERE Account_type_code = v_accAccTypeCode;

--End

--==TestCode
DECLARE
    --Constants
    k_tDebit CHAR(1) := 'D';
    k_tCredit CHAR(1) := 'C';

    --Cursor
    CURSOR cur_ntData IS
    SELECT *
    FROM NEW_TRANSACTIONS;

    --Variables
    v_accAccNo ACCOUNT.Account_no%TYPE; --The Account_no in the ACCOUNT TABLE 
    v_accAccTypeCode ACCOUNT.Account_type_code%TYPE; --The Account_type_code in the ACCOUNT TABLE
    v_accAccBal ACCOUNT.Account_balance%TYPE; --The Account_balance in the ACCOUNT TABLE
    v_atDefTransType ACCOUNT_TYPE.Default_trans_type%TYPE; --The Default_trans_type in the ACCOUNT_ TABLE
    v_ntTransNoTemp NEW_TRANSACTIONS.Transaction_no%TYPE; --A placeholder for tranaction number
    v_ntTransDate NEW_TRANSACTIONS.Transaction_date%TYPE; --A placeholder for tranaction date
    v_errorStatus NUMBER(1) := 0; --Status for transaction group
    v_transaction_balanced number; --current transaction stuff

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

				SELECT Account_no, Account_type_code, Account_balance
				INTO v_accAccNo, v_accAccTypeCode, v_accAccBal
				FROM ACCOUNT
				WHERE Account_no = rec_ntData.Account_no;
				
				SELECT Default_trans_type
				INTO v_atDefTransType
				FROM ACCOUNT_TYPE
				WHERE Account_type_code = v_accAccTypeCode;

                v_ntTransDate := rec_ntData.Transaction_date;

				--Point beginign
                IF (v_ntTransNoTemp != rec_ntData.Transaction_no) THEN
                    v_ntTransNoTemp := rec_ntData.Transaction_no;
                    v_errorStatus := 0;

                ELSIF (v_ntTransNoTemp = rec_ntData.Transaction_no) THEN
                    IF (v_errorStatus = 1) THEN
                        NULL;
                    ELSIF (v_errorStatus = 0) THEN

                        --Error checking
                        
                        if(rec_ntData.transaction_no is null) then 
                            raise e_negative_amount;
                        end if;
                        
                        if(rec_ntData.transaction_amount <0) then 
                            raise e_negative_amount;
                        end if;

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
                        
                        --WHen a transaction isnt even, but im not sure where this would go 
                        if(v_transaction_balanced <> 0)then 
                            raise e_uneven_transaction_balance;
                        end if;
                        
                    ELSE NULL;
                    END IF;

                ELSE NULL;
                END IF;
				--Point end 
				
			END LOOP;
	EXCEPTION
		--I dont think doing these as application errors is the best call 
		--as it will terminat the program 
		--Stuff can also be added to the error table 
			
			WHEN e_invalidAccNum THEN
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(v_ntTransNoTemp, v_ntTransDate, 'Account # does not exist', 'invalidAccNum');
				--RAISE_APPLICATION_ERROR(-20031, 'Account # does not exist');
			WHEN e_negative_amount THEN
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(v_ntTransNoTemp, v_ntTransDate, 'Negative values are invalid', 'negativeAmount');
				--RAISE_APPLICATION_ERROR(-20032, 'Negative values are invalid');
			WHEN e_invalidTransType THEN
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(v_ntTransNoTemp, v_ntTransDate, 'Invalid trasaction type', 'invalidTransType');
				--RAISE_APPLICATION_ERROR(-20033, 'Invalid trasaction type');
			WHEN e_missingTransNum THEN
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(null, v_ntTransDate, 'Missing transaction number', 'missingTransNum');
				--RAISE_APPLICATION_ERROR(-20034, 'Missing transaction number');
			WHEN e_uneven_transaction_balance then 
				insert into wkis_error_log (TRANSACTION_NO, TRANSACTION_DATE, DESCRIPTION, ERROR_MSG) 
				values(v_ntTransNoTemp, v_ntTransDate, 'The Transaction Doesnt balance', 'unevenTransBal');
				--RAISE_APPLICATION_ERROR(-20035, 'The Transaction Doesnt balance');
			WHEN others then 
				DBMS_OUTPUT.PUT_LINE('Some other error occured');
			
	END;
END;
/