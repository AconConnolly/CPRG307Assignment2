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

--Read Transaction number untell diffrent number 

loop tell %norowfound
--stuff = 1
--Select * from new_transactions where transaction_no = stuff + 2

make varible 0 
add amount if type = d
subtract ammount if type = c 

if varible == 0 Contine

--**Miguel Stuff**
    v_accTransNoTemp NEW_TRANSACTIONS.Transaction_no%TYPE;
    v_accBalTemp ACCOUNT.Account_balance%TYPE;

    v_accTransNoTemp := 0;
    v_accBalTemp := 0;

    IF (v_accTransNoTemp != rec_transData.Transaction_no) THEN
        v_accTransNoTemp := rec_transData.Transaction_no;
        v_accBalTemp := 0;

    ELSE
        IF (rec_transData.Transaction_type = k_tDebit) THEN
            v_accBalTemp := v_accBalTemp + rec_transData.Transaction_amount;

        ELSIF (rec_transData.Transaction_type = k_tDebit) THEN
            v_accBalTemp := v_accBalTemp - rec_transData.Transaction_amount;

        ELSE NULL;

        END IF;

    END IF;

--==EXCEPTIONS==--
ex_invalidAccNum_update EXCEPTION;
ex_nVal_update EXCEPTION;
ex_invalidTransType_update EXCEPTION;
ex_missingTransNum_update EXCEPTION;

--Invalid account #
Check if account # exists 

--**Miguel Stuff**
IF SQL%NOTFOUND THEN
    RAISE ex_invalidAccNum_update;
END IF;

EXCEPTION

WHEN ex_invalidAccNum_update THEN
    RAISE_APPLICATION_ERROR(-20031, 'Account # does not exist');

END;

--Negative values given for transaction 
Check if any values are negative

--**Miguel Stuff**
IF (rec_transData.Transaction_amount < 0) THEN
    RAISE ex_nVal_update;
END IF;

EXCEPTION

WHEN ex_nVal_update THEN
    RAISE_APPLICATION_ERROR(-20032, 'Negative values are invalid');

END;

--Invalid transcation type
Compare to make sure it D or C

--**Miguel Stuff**
IF (rec_transData.Transaction_type = 'D' OR rec_transData.Transaction_type = 'C') THEN
    RAISE ex_invalidTransType_update;
END IF;

EXCEPTION

WHEN ex_invalidTransType_update THEN
    RAISE_APPLICATION_ERROR(-20033, 'Invalid trasaction type');

END;

--missin transaction number
if Transaction number is null

--**Miguel Stuff**
IF (rec_transData.Transaction_no IS NULL) THEN
    RAISE ex_missingTransNum_update;
END IF;

EXCEPTION

WHEN ex_missingTransNum_update THEN
    RAISE_APPLICATION_ERROR(-20034, 'Missing transaction number');

END;

--Get defaut transaction type from row
--Match account_no.new_transactions to account_no.accunt
--get account_no.accunt account_type_code
--Match account_type_code.account to account_type_code.accoun_type
--get default_trans_type 
--Compare default_trans_type.account_type to transaction_type.new_transactions
if they are the same add amount to account 
if they are diffrent subtract amount from account 


--Add to transaction_detail and transaction_history

--Delete transaction from new_transactions table 




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
