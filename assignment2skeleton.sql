--==preCode==--
SET LINESIZE 155;
SET PAGESIZE 66;
SET SERVEROUTPUT ON;

--Hard Code
    k_tDebit CHAR(1) := 'D';
    k_tCredit CHAR(1) := 'C';

--Cursor
    CURSOR cur_transData IS
    SELECT *
    FROM NEW_TRANSACTIONS;

--Finding Acc Type

--Getting Account Type's Debit or Credit (Case decision)
    v_accTypeDC ACCOUNT.ACCOUNT_TYPE_CODE%TYPE;

    CASE
        WHEN () THEN
            v_accTypeDC := D;

        WHEN () THEN
            v_accTypeDC := c;

        ELSE NULL;

    END CASE;

--Compare Debit and Credit if Equal


--Compare NewTrans and Account type (Case decision)
    IF (rec_transData.transaction_type = ) THEN --ADD

    ELSE () --SUBTRACT

    END IF;

--==EXCEPTIONS==--
