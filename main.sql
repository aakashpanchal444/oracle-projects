
---Write a PL/SQL blocks to develop following modules for bank application.
/*
1.  Open a new account.
2.  Deposite amount.
3.  Withdraw amount.
4.  Ammount transaction by using account numbers.
5.  Check balance by using account number and mobile number.
6.  Mini statement.
7.  Account statement.
8.  View account details by using account number and mobile number.
9.  Update account details.
10. Delete account details by using account number and mobile number.
*/

--Table creations:
CREATE TABLE bank_mast(
    accno VARCHAR2(10),
    cust_name VARCHAR2(50),
    mobile_no NUMBER(12),
    open_date DATE,
    acc_type VARCHAR(2),
    balance NUMBER(10,2)
);

CREATE TABLE bank_trans(
    t_no NUMBER(20),
    s_accno VARCHAR2(10),
    d_accno varchar2(10),
    t_date DATE,
    t_type VARCHAR2(2),
    t_amount NUMBER(8,2)
);

---Sequence for to generate account numbers.
CREATE SEQUENCE accno_seq
START WITH 1
INCREMENT BY 1;

---Sequence for to generate transaction numbers.
CREATE SEQUENCE trans_seq
START WITH 1
INCREMENT BY 1;

---Procedure podl
CREATE OR REPLACE PROCEDURE podl(
    text VARCHAR2
)IS
BEGIN
    DBMS_OUTPUT.PUT_LINE( text );
END;
/

/*
---------------------:Validation:---------------------
1. Open a new account:
- account_no should be generated automatically ex : sbi1, sbi2
- customer name is capital latter
- mobile no should be accept 10 digits only ant it shoud be unique
- opening date is system date
- account type should be accepts 's', 'c'
- if account type is 'S' then mini opening balance rs.500
- if account type is 'C' then mini opening balance 

2. Deposite ammount:
- deposite amount should be updated in bank master table

3. Withdraw amount:
- withdraw amount should be updated in bank master table

4. Amount transaction using accnos:
- transaction amount should be updated in source account number and destination account number

5. Check balance by using account number and mobile number:
- to check your account balance by using account number and mobile number

6. Mini statement:
- to display last five latest transaction details

7. Account statement:
- to generate account statement from to given dates

8. View account details:
- To view account details by using account_no and mobile_no

9. Update account details:
- to update given account master data

10. Delete account details:
- to delete account details by using account_no and mobile_no
*/

---Package Specification
CREATE OR REPLACE PACKAGE bank_pack
IS
---Procedure spec. for to open a new account
PROCEDURE new_acc(
    p_cname bank_mast.cust_name%type,
    p_mobileno bank_mast.mobile_no%type,
    p_acc_type bank_mast.acc_type%type,
    p_balance bank_mast.balance%type
);

---Procedure spec. for to deposite amount
PROCEDURE credit(
    p_accno bank_mast.accno%type,
    p_tamount bank_trans.t_amount%type
);

---Procedure spec. for withdraw amount
PROCEDURE debit(
    p_accno bank_mast.accno%type,
    p_tamount bank_trans.t_amount%type
);

---Procedure spec. for transfer amount
PROCEDURE trans_amt(
    p_saccno bank_trans.s_accno%type,
    p_daccno bank_trans.d_accno%type,
    p_tamount bank_trans.t_amount%type
);

---Function to check account balance by using accno
FUNCTION chk_bal(
    p_accno bank_mast.accno%type   
)RETURN NUMBER;

---Function to check amount balance by using mobile_no
FUNCTION chk_bal(
    p_mobileno bank_mast.mobile_no%type
)RETURN NUMBER;

---Procedure spec. to generate mini statement
PROCEDURE mini_stat(
    p_saccno bank_trans.s_accno%type
);

---Procedure spec. to generate account statement 
PROCEDURE acc_stat(
    p_saccno bank_trans.s_accno%type,
    sdate DATE,
    edate DATE
);

---Procedure spec. for to view account details usign accno
PROCEDURE view_acc(
    p_accno bank_mast.accno%type   
);

---Procedure spec. for to view account details usign mobile_no
PROCEDURE view_acc(
    p_mobileno bank_mast.mobile_no%type
);

---Procedure spec. for to update account details using accno
PROCEDURE upd_acc(
    p_accno bank_mast.accno%type,
    p_new_mobile_no bank_mast.mobile_no%type
);

---Procedure spec. for to delete account by using accno
PROCEDURE del_acc(
    p_accno bank_mast.accno%type
);

---Procedure spec. for to delete account by using mobile_no
PROCEDURE del_acc(
    p_mobileno bank_mast.mobile_no%type
);

END bank_pack;
/

---Package Body
CREATE OR REPLACE PACKAGE BODY bank_pack
IS
--1. Open a new account:
---Procedure body for to open a new account
PROCEDURE new_acc(
    p_cname bank_mast.cust_name%type,
    p_mobileno bank_mast.mobile_no%type,
    p_acc_type bank_mast.acc_type%type,
    p_balance bank_mast.balance%type
)IS
    v_accno bank_mast.accno%type;
    cnt NUMBER;
BEGIN
---mobile no should be accept 10 digits only ant it shoud be unique
    IF LENGTH(p_mobileno) != 10 THEN
        RAISE_APPLICATION_ERROR(-20101, 'Invalid mobile number !!!');
    END IF;
    
    SELECT COUNT(*) INTO cnt FROM bank_mast
    WHERE mobile_no = p_mobileno;
    
    IF cnt = 1 THEN
        RAISE_APPLICATION_ERROR(-20102, 'Mobile number already registered.');
    END IF;
---if account type is 'S' then mini opening balance Rs.500/-
    IF UPPER(p_acc_type) = UPPER('s') THEN
        IF p_balance < 500 THEN
            RAISE_APPLICATION_ERROR(-20103,'Min. saving A/C balance Rs.500/-.');
        END IF;
---if account type is 'C' then mini opening balance Rs.1000/-
    ELSIF UPPER(p_acc_type) = UPPER('c') THEN
        IF p_balance < 1000 THEN
            RAISE_APPLICATION_ERROR(-20104,'Min. current opening balance Rs.1000/-.');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20105, 'Invalid account type !!!');
    END IF;
---account_no should be generated automatically ex : sbi1, sbi2
    v_accno := 'SBI0000'||(accno_seq.nextval);
    INSERT INTO bank_mast VALUES(v_accno, UPPER(p_cname),p_mobileno,SYSDATE,UPPER(p_acc_type),p_balance);
    
podl('Account Created.');
END new_acc;

---2. Deposite ammount:
---Procedure body for to deposite amount
PROCEDURE credit(
    p_accno bank_mast.accno%type,
    p_tamount bank_trans.t_amount%type
)IS
BEGIN
    UPDATE bank_mast
    SET balance = balance + p_tamount
    WHERE accno = p_accno;

podl('Amount credited.');
END credit;

---3. Withdraw amount:
---Procedure amount for to withdraw amount
PROCEDURE debit(
    p_accno bank_mast.accno%type,
    p_tamount bank_trans.t_amount%type
)IS
BEGIN
    UPDATE bank_mast
    SET balance = balance - p_tamount
    WHERE accno = p_accno;

podl('Amount debited.');
END debit;

---4. Amount transaction using accnos:
---Procedure body for to transfer amount
PROCEDURE trans_amt(
    p_saccno bank_trans.s_accno%type,
    p_daccno bank_trans.d_accno%type,
    p_tamount bank_trans.t_amount%type
)IS
BEGIN
    debit(p_saccno, p_tamount);
    credit(p_daccno, p_tamount);
    podl('Amount transfer.');
END trans_amt;

---5. Check balance by using account number and mobile number:
---Function for to check account balance by using account_no.
FUNCTION chk_bal(
    p_accno bank_mast.accno%type
)RETURN NUMBER
IS
    v_bal bank_mast.accno%type;
BEGIN
    SELECT balance INTO v_bal FROM bank_mast
    WHERE accno = p_accno;
    RETURN(v_bal);
END chk_bal;

---Function for to check account banlance by using mobile_no.
FUNCTION chk_bal(
    p_mobileno bank_mast.mobile_no%type
)RETURN NUMBER
IS
    v_bal bank_mast.accno%type;
BEGIN
    SELECT balance INTO v_bal FROM bank_mast
    WHERE mobile_no = p_mobileno;
    RETURN(v_bal);
END chk_bal;

---6. Mini statement:
---Procedure body to generate mini statement.
PROCEDURE mini_stat(
    p_saccno bank_trans.s_accno%type
)IS
    CURSOR mini_cur IS
        SELECT * FROM bank_trans
        WHERE rownum <= (SELECT COUNT(*) FROM bank_trans WHERE s_accno = p_saccno) and s_accno = p_saccno
        MINUS
        SELECT * FROM bank_trans
        WHERE rownum <= (SELECT COUNT(*)-5 FROM bank_trans WHERE s_accno = p_saccno) and s_accno = p_saccno;
    i mini_cur%rowtype;
BEGIN
    OPEN mini_cur;
    LOOP
        FETCH mini_cur INTO i;
        EXIT WHEN mini_cur%notfound;
        podl(mini_cur%rowcount||' '||i.s_accno||' '||i.t_date||' '||i.t_type||' '||i.t_amount);
    END LOOP;
    CLOSE mini_cur;
END mini_stat;

---7. Account statement:
---Procedure to generate account statement
PROCEDURE acc_stat(
    p_saccno bank_trans.s_accno%type,
    sdate DATE,
    edate DATE
)IS
    CURSOR acc_cur IS
        SELECT bm.accno, bm.cust_name, bm.mobile_no, bt.t_date, bt.t_type,bt.t_amount
        FROM bank_mast bm, bank_trans bt
        WHERE bm.accno = bt.s_accno and bt.s_accno = p_saccno and
        TRUNC(t_date) BETWEEN TRUNC(sdate) and TRUNC(edate);
    i acc_cur%rowtype;
BEGIN
    OPEN acc_cur;
    FETCH acc_cur INTO i;
    podl('*****************************************');
    podl(i.accno||' '||i.cust_name||' '||i.mobile_no);
    podl('*****************************************');
    while(acc_cur%found)
    LOOP
        podl(i.t_date||' '||i.t_type||' '||i.t_amount);
        FETCH acc_cur INTO i;
    END LOOP;
    CLOSE acc_cur;
END acc_stat;

--8. View account details:
---Procedure body for to view account details using account_no.
PROCEDURE view_acc(
    p_accno bank_mast.accno%type
)IS
    bm bank_mast%rowtype;
BEGIN
    SELECT * INTO bm FROM bank_mast
    WHERE accno = p_accno;

    podl('*****************************************');
    podl(bm.accno);
    podl(bm.cust_name);
    podl(bm.mobile_no);
    podl(bm.open_date);
    podl(bm.acc_type);
    podl(bm.balance);
    podl('*****************************************');
END view_acc;

---Procedure body for to view account details using mobile_no.
PROCEDURE view_acc(
    p_mobileno bank_mast.mobile_no%type
)IS
    bm bank_mast%rowtype;
BEGIN
    SELECT * INTO bm FROM bank_mast
    WHERE mobile_no = p_mobileno;

    podl('*****************************************');
    podl(bm.accno);
    podl(bm.cust_name);
    podl(bm.mobile_no);
    podl(bm.open_date);
    podl(bm.acc_type);
    podl(bm.balance);
    podl('*****************************************');
END view_acc;

---9. Update account details:
---Procedure body to update account details by using account_no.
PROCEDURE upd_acc(
    p_accno bank_mast.accno%type,
    p_new_mobile_no bank_mast.mobile_no%type
)IS
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt FROM bank_mast
    WHERE mobile_no = p_new_mobile_no;

    IF cnt = 1 THEN
        RAISE_APPLICATION_ERROR(-20102,'Mobile number already register.');
    END IF;

    UPDATE bank_mast
    SET mobile_no = p_new_mobile_no
    WHERE accno = p_accno;

    IF sql%found THEN
        podl('Record updated.');
    ELSIF sql%notfound THEN
        podl('Invalid account number.');
    END IF;
END upd_acc;

---10. Delete account details:
---Procedure body for to delete account by using account_no.
PROCEDURE del_acc(
    p_accno bank_mast.accno%type
)IS
BEGIN
    DELETE FROM bank_mast
    WHERE accno = p_accno;
    
    IF sql%rowcount != 0 THEN
        podl('Record deleted.');
    ELSIF sql%rowcount = 0 THEN
        podl('Record not found.');
    END IF;
END del_acc;

---Procedure body for to delete account by using mobile_no.
PROCEDURE del_acc(
    p_mobileno bank_mast.mobile_no%type
)IS
BEGIN
    DELETE FROM bank_mast
    WHERE mobile_no = p_mobileno;
    
    IF sql%rowcount != 0 THEN
        podl('Record deleted.');
    ELSIF sql%rowcount = 0 THEN
        podl('Record not found.');
    END IF;
END del_acc;
END bank_pack;
/

---Insert customre details into bank_mast table
EXEC bank_pack.new_acc('Aakash',9769671761,'s',700);
EXEC bank_pack.new_acc('king',9000994005, 'c',7000);

---Trigger on bank transaction table :
/*
Validations:
-   tno generate automatically
-   saccno is mandatory
-   if transaction type is 'at' then daccno is mandatory
-   if transaction type is 'w','d','at' then saccno should be available in bank_mast table
-   if transaction type is 'at' then daccno should be available in bank_mast table
-   minimum transaction amount Rs. 100/-
-   transaction date is system date
-   if transaction type is 'd' no validations and balance should be update
-   if transaction type is 'w' or 'at' then first check available balance
-   if customer contains sufficient balance then to allow the transaction and balance should be updated
-   transaction type accepts anly 'd','w','at' only
*/
---Trigger
CREATE OR REPLACE TRIGGER bank_trans_trig
BEFORE INSERT ON bank_trans
FOR EACH ROW
DECLARE
    cnt NUMBER;
BEGIN
    :new.t_no := trans_seq.nextval;
    IF :new.s_accno IS NULL THEN
        RAISE_APPLICATION_ERROR(-20601,'Saccno is mandatory!!!');
    END IF;

    IF :new.t_type = 'at' THEN
        IF :new.d_accno IS NULL THEN
            RAISE_APPLICATION_ERROR(-20602,'Daccno is mandatory!!!');
        END IF;
    END IF;

    IF :new.t_type IN ('d','w','at') THEN
        SELECT COUNT(*) INTO cnt FROM bank_mast
        WHERE accno = :new.s_accno;
        IF cnt = 0 THEN
            RAISE_APPLICATION_ERROR(-20603,'Invalid saccno!!!');
        END IF;
    END IF;

    IF :new.t_type = 'at' THEN
        SELECT COUNT(*) INTO cnt FROM bank_mast
        WHERE accno = :new.d_accno;
        IF cnt = 0 THEN
            RAISE_APPLICATION_ERROR(-20604,'Invalid daccno!!!');
        END IF;
    END IF;

    IF :new.t_amount < 100 THEN
        RAISE_APPLICATION_ERROR(-20605,'Min. Trans.Amount Rs.100/-');
    END IF;

    :new.t_date := SYSDATE;
    IF :new.t_type = 'd' THEN
        bank_pack.credit(:new.s_accno, :new.t_amount);
    ELSIF :new.t_type = 'w' THEN
        IF (bank_pack.chk_bal(:new.s_accno) - :new.t_amount) > 0 THEN
            bank_pack.debit(:new.s_accno, :new.t_amount);
        ELSE
            RAISE_APPLICATION_ERROR(-20606,'Insufficient balance!!!');
        END IF;
    ELSIF :new.t_type = 'at' THEN
        IF (bank_pack.chk_bal(:new.s_accno) - :new.t_amount) > 0 THEN
            bank_pack.trans_amt(:new.s_accno, :new.d_accno, :new.t_amount);
        ELSE
            RAISE_APPLICATION_ERROR(-20607,'Insufficient balance!!!');
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20608,'Invalid transaction type!!!');
    END IF;
END;
/

---Testing
---Deposite amount
SELECT * FROM bank_mast;
select * FROM bank_trans;

INSERT INTO bank_trans(s_accno,t_type,t_amount)
VALUES('SBI00001','d','1000');

INSERT INTO bank_trans(s_accno, t_type, t_amount)
VALUES('SBI00001','w',200);

INSERT INTO bank_trans(s_accno, d_accno, t_type, t_amount)
VALUES('SBI00001','SBI00002','at',500);
