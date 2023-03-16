SET LINESIZE 60
SET PAGESIZE 66
SET SERVEROUTPUT ON

--==Constants
    k_tDebit CHAR(1) := 'D';
    k_tCredit CHAR(1) := 'C';

--==NEW_TRANSACTIONS
CURSOR cur_ntData IS
SELECT *
FROM NEW_TRANSACTIONS;

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

BEGIN
    FOR rec_ntData IN cur_ntData LOOP

        SELECT Account_no, Account_type_code, Account_balance
        INTO v_accAccNo, v_accAccTypeCode, v_accAccBal
        FROM ACCOUNT
        WHERE Account_no = rec_ntData.Account_no;
        
        SELECT Default_trans_type
        INTO v_atDefTransType
        FROM ACCOUNT_TYPE
        WHERE Account_type_code = v_accAccTypeCode;

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

        DBMS_OUTPUT.PUT_LINE('--------------');
        DBMS_OUTPUT.PUT_LINE(rec_ntData.Account_no);
        DBMS_OUTPUT.PUT_LINE(v_atDefTransType);
        DBMS_OUTPUT.PUT_LINE(v_accAccBal);

    END LOOP;

END;
/