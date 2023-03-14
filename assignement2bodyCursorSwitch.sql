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
/*
--New Transaction Variablaes (For Ease)
    v_ntTransNo NEW_TRANSACTIONS.Transaction_no%TYPE;
    v_ntTransDate NEW_TRANSACTIONS.Transaction_date%TYPE;
    v_ntDesc NEW_TRANSACTIONS.Description%TYPE;
    v_ntAccNo NEW_TRANSACTIONS.Account_no%TYPE;
    v_ntTransType NEW_TRANSACTIONS.Transaction_type%TYPE;
    v_ntTransAmount NEW_TRANSACTIONS.Transaction_amount%TYPE;
*/

/*
--Account Variables (For Ease)
    v_accBal ACCOUNT.Account_balance%TYPE;
*/

--Account Type Variables (For Ease)
    --v_atCode ACCOUNT_TYPE.Account_type_code%TYPE;
    v_atDefTransType ACCOUNT_TYPE.Default_trans_type%TYPE;

--For Calculations
    v_accBal ACCOUNT.Account_balance%TYPE;
    v_ntTransNoTemp NEW_TRANSACTIONS.Transaction_no%TYPE;

--Test Values
    v_accCount NUMBER(3) := 0;
    v_ntCount NUMBER(3) := 0;

--Exceptions
    ex_invalidAccNum_update EXCEPTION;
    ex_nVal_update EXCEPTION;
    ex_invalidTransType_update EXCEPTION;
    ex_missingTransNum_update EXCEPTION;

BEGIN
    v_ntTransNoTemp := 0;

    FOR rec_ntData IN cur_ntData LOOP
        v_accBal := 0;
        v_ntCount := 0;--Test**

        --**TEST**
        IF (v_ntTransNoTemp !=  rec_ntData.Transaction_no) THEN
            v_ntTransNoTemp := rec_ntData.Transaction_no;
            DBMS_OUTPUT.PUT_LINE('-----------');
            DBMS_OUTPUT.PUT_LINE(v_ntTransNoTemp);
            DBMS_OUTPUT.PUT_LINE(v_ntCount);

        ELSIF (v_ntTransNoTemp = rec_ntData.Transaction_no) THEN
            v_ntCount := v_ntCount + 1;

        ELSE NULL;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE(v_ntCount);

        FOR rec_accData IN cur_accData LOOP
            v_accCount := 0;--Test**

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

            /*
            --==Calculations 
            IF (rec_ntData.Account_no = rec_accData.Account_no) THEN
                CASE
                    WHEN (v_atDefTransType = rec_ntData.Transaction_type) THEN
                        v_accBal := v_accBal + rec_ntData.Transaction_amount;
                    WHEN (v_atDefTransType != rec_ntData.Transaction_type) THEN
                        v_accBal := v_accBal - rec_ntData.Transaction_amount;
                    ELSE NULL;
                END CASE;

            END IF;
            */

            /*
            --**TEST** For Account Num Count
            IF (rec_ntData.Account_no = rec_accData.Account_no) THEN
                v_accCount := v_accCount + 1;
            END IF;
            */

        END LOOP;

        --==Check if Equal

        /*
        --==Update Transaction Detail
        INSERT INTO TRANSACTION_DETAIL
        VALUES(Account_no, Transaction_no, Transaction_type, Transaction_amount);

        --==Update Transaction History
        INSERT INTO TRANSACTION_HISTORY
        VALUES(Transaction_no, Transaction_date, Description);
        */

        /*
        --**TEST** For Balance Calculations
        DBMS_OUTPUT.PUT_LINE('-----------');
        DBMS_OUTPUT.PUT_LINE(v_ntTransNoTemp);
        DBMS_OUTPUT.PUT_LINE(rec_accData.Account_no);
        DBMS_OUTPUT.PUT_LINE(v_accCount);
        DBMS_OUTPUT.PUT_LINE(v_atDefTransType);
        DBMS_OUTPUT.PUT_LINE(v_accBal);
        */

        /*
        --**TEST** For Transaction Order
        DBMS_OUTPUT.PUT_LINE('-----------');
        DBMS_OUTPUT.PUT_LINE(v_ntTransNoTemp);
        DBMS_OUTPUT.PUT_LINE(v_ntCount);
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