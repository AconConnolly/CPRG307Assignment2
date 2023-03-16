--==Get Account_no for Account_Bal (Where statement for update)
--Dec
v_accAccNo ACCOUNT.Account_no%TYPE;
v_accAccTypeCode ACCOUNT.Account_type_code%TYPE;
v_accAccBal ACCOUNT.Account_balance%TYPE;

--Beg
SELECT Account_no, Account_type_code, Account_balance
INTO v_accAccNo, v_accAccTypeCode, v_accAccBal
FROM ACCOUNT
WHERE Account_no = rec_ntData.Account_no;

--End

--==Get Default_trans_type for comparison (D or C)
--Dec
v_atDefTransType ACCOUNT_TYPE.Default_trans_type%TYPE;

--Beg
SELECT Default_trans_type
INTO v_atDefTransType
FROM ACCOUNT_TYPE
WHERE Account_type_code = v_accAccTypeCode;

--End

