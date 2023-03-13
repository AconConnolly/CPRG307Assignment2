--==MainCode==--
DECLARE

--Constants
    k_tDebit CHAR(1) := 'D';
    k_tCredit CHAR(1) := 'C';

--Cursor
    CURSOR cur_transData IS
    SELECT *
    FROM NEW_TRANSACTIONS;



--Exceptions
    ex_invalidAccNum_update EXCEPTION;
    ex_nVal_update EXCEPTION;
    ex_invalidTransType_update EXCEPTION;
    ex_missingTransNum_update EXCEPTION;uyhhgggbvvvvvvvvvvvvvvvvf

BEGIN

    FOR rec_transData IN cur_transData LOOP

        --DBMS_OUTPUT.PUT_LINE(rec_transData.Account_no);

        DECLARE
        --New Transaction Variablaes (For Ease)
            v_ntTransNo NEW_TRANSACTIONS.Transaction_no%TYPE;
            v_ntTransDate NEW_TRANSACTIONS.Transaction_date%TYPE;
            v_ntDesc NEW_TRANSACTIONS.Description%TYPE;
            v_ntAccNo NEW_TRANSACTIONS.Account_no%TYPE;
            v_ntTransType NEW_TRANSACTIONS.Transaction_type%TYPE;
            v_ntTransAmount NEW_TRANSACTIONS.Transaction_amount%TYPE;

        BEGIN

        END;

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