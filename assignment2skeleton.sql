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
 

--Invalid account #
Check if account # exists 

--Negative values given for transaction 
Check if any values are negative

--Invalid transcation type
Compare to make sure it D or C

--missin transaction number
if Transaction number is null

--Get defaut transaction type from row
--Match account_no.new_transactions to account_no.accunt
--get account_no.accunt account_type_code
--Match account_type_code.account to account_type_code.accoun_type
--get default_trans_type 
--Compare default_trans_type.account_type to transaction_type.new_transactions
if they are the same add amount to account 
if they are diffrent subtract amount from account 


--Add to transaction_detail and transaction_hisotory

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
