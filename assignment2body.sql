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
    v_aBal ACCOUNT.Account_balance%TYPE;
*/

    v_accCount NUMBER(3) := 0;

--Exceptions
    ex_invalidAccNum_update EXCEPTION;
    ex_nVal_update EXCEPTION;
    ex_invalidTransType_update EXCEPTION;
    ex_missingTransNum_update EXCEPTION;

BEGIN

    FOR rec_accData IN cur_accData LOOP
        v_accCount := 0;

        FOR rec_ntData IN cur_ntData LOOP

            IF (rec_ntData.Account_no = rec_accData.Account_no) THEN
                v_accCount := v_accCount + 1;
            END IF;

        END LOOP;

        DBMS_OUTPUT.PUT_LINE(rec_accData.Account_no);
        DBMS_OUTPUT.PUT_LINE(v_accCount);
        
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