SET LINESIZE 60
SET PAGESIZE 66
SET SERVEROUTPUT ON

--==MainCode==--
DECLARE

--Constants
    k_tDebit CHAR(1) := 'D';
    k_tCredit CHAR(1) := 'C';

--Cursor
    CURSOR cur_ntData IS
    SELECT *
    FROM NEW_TRANSACTIONS;

    Cursor cur_accData IS
    SELECT *
    FROM ACCOUNT;

--Account Type Variables (For Ease)
    v_atDefTransType ACCOUNT_TYPE.Default_trans_type%TYPE;
    v_accAccNo ACCOUNT.Account_no%TYPE;

--For Calculations
    v_accBal ACCOUNT.Account_balance%TYPE;
    v_ntTransAmount NEW_TRANSACTIONS.Transaction_Amount%TYPE;
    v_ntTransNoTemp NEW_TRANSACTIONS.Transaction_no%TYPE;
    v_ntTransType NEW_TRANSACTIONS.Transaction_type%TYPE;
    v_ntAccNo NEW_TRANSACTIONS.Account_no%TYPE;

--Exceptions
    ex_invalidAccNum_update EXCEPTION;
    ex_nVal_update EXCEPTION;
    ex_invalidTransType_update EXCEPTION;
    ex_missingTransNum_update EXCEPTION;

BEGIN
    v_ntTransNoTemp := 0;

    FOR rec_ntData IN cur_ntData LOOP
        v_ntAccNo := rec_ntData.Account_no;
        v_ntTransAmount := rec_ntData.Transaction_amount;
        v_ntTransType := rec_ntData.Transaction_type;
        v_accBal := 0;

        IF (v_ntTransNoTemp !=  rec_ntData.Transaction_no) THEN
            v_ntTransNoTemp := rec_ntData.Transaction_no;
            DBMS_OUTPUT.PUT_LINE('-----------');--Test**
            DBMS_OUTPUT.PUT_LINE(v_ntTransNoTemp);--Test*

        ELSIF (v_ntTransNoTemp = rec_ntData.Transaction_no) THEN 
            FOR rec_accData IN cur_accData LOOP
                v_accAccNo := rec_accData.Account_no;

                SELECT Default_trans_type
                INTO v_atDefTransType
                FROM ACCOUNT_TYPE
                WHERE Account_type_code = rec_accData.Account_type_code;

                /*
                --==Error Check 
                IF SQL%NOTFOUND THEN --Invalid Account #
                    RAISE ex_invalidAccNum_update;
                ELSIF (rec_ntData.Transaction_amount < 0) THEN --Negative Values
                    RAISE ex_nVal_update;
                ELSIF (rec_ntData.Transaction_type = 'D' OR rec_transData.Transaction_type = 'C') THEN --Invalid Transaction Type
                    RAISE ex_invalidTransType_update;
                ELSIF (rec_ntData.Transaction_no IS NULL) THEN --Missing Transaction Number
                    RAISE ex_missingTransNum_update;
                ELSE NULL;
                END IF;
                */
                
                --==Calculations 
                IF (v_ntAccNo = v_accAccNo) THEN
                    CASE
                        WHEN (v_atDefTransType = rec_ntData.Transaction_type) THEN
                            v_accBal := v_accBal + v_ntTransAmount;
                        WHEN (v_atDefTransType != rec_ntData.Transaction_type) THEN
                            v_accBal := v_accBal - v_ntTransAmount;
                        ELSE NULL;
                    END CASE;

                END IF;
                        
            END LOOP;
        
        ELSE NULL;
        END IF;

        --==Check if Equal

        /*
        --==Update Transaction Detail
        INSERT INTO TRANSACTION_DETAIL
        VALUES(Account_no, Transaction_no, Transaction_type, Transaction_amount);

        --==Update Transaction History
        INSERT INTO TRANSACTION_HISTORY
        VALUES(Transaction_no, Transaction_date, Description);

        --==Delete Transaction History
        DELETE FROM NEW_TRANSACTIONS
        WHERE Transaction_no = v_ntTransNoTemp;
        */

    END LOOP;

/*
EXCEPTION
    WHEN ex_invalidAccNum_update THEN
        RAISE_APPLICATION_ERROR(-20031, 'Account # does not exist');
    WHEN ex_nVal_update THEN
        RAISE_APPLICATION_ERROR(-20032, 'Negative values are invalid');
    WHEN ex_invalidTransType_update THEN
        RAISE_APPLICATION_ERROR(-20033, 'Invalid trasaction type');
    WHEN ex_missingTransNum_update THEN
        RAISE_APPLICATION_ERROR(-20034, 'Missing transaction number');
*/

END;
/