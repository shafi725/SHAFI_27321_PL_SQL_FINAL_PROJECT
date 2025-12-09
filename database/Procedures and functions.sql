CREATE OR REPLACE PACKAGE BODY MMS_LOAN_PKG
AS

    -- *** PROCEDURE IMPLEMENTATIONS ***

    -- Disburse Loan (implementation moved inside package body)
    PROCEDURE PRC_DISBURSE_LOAN (
        p_client_id     IN NUMBER,
        p_amount        IN NUMBER,
        p_interest_rate IN NUMBER,
        p_due_date      IN DATE
    )
    IS
        v_new_loan_id NUMBER := loans_seq.NEXTVAL;
    BEGIN
        INSERT INTO LOANS (
            LOAN_ID, CLIENT_ID, AMOUNT, INTEREST_RATE, START_DATE, DUE_DATE, OUTSTANDING_BALANCE
        ) VALUES (
            v_new_loan_id, p_client_id, p_amount, p_interest_rate, SYSDATE, p_due_date, p_amount
        );
    END PRC_DISBURSE_LOAN;


    -- Records a payment, which is the transaction that fires the TRG_PAYMENT_PENALTY
    PROCEDURE PRC_RECORD_PAYMENT (
        p_loan_id      IN NUMBER,
        p_amount_paid  IN NUMBER,
        p_payment_date IN DATE
    )
    IS
    BEGIN
        -- Inserting the payment fires the trigger (TRG_PAYMENT_PENALTY)
        -- The trigger handles the balance update and penalty logic.
        INSERT INTO PAYMENTS (
            PAYMENT_ID, LOAN_ID, AMOUNT_PAID, PAYMENT_DATE
        ) VALUES (
            payments_seq.NEXTVAL, p_loan_id, p_amount_paid, p_payment_date
        );
        
        DBMS_OUTPUT.PUT_LINE('Payment recorded for Loan ' || p_loan_id || '. Amount: ' || p_amount_paid);

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error recording payment: ' || SQLERRM);
            RAISE;
    END PRC_RECORD_PAYMENT;


    -- *** FUNCTION IMPLEMENTATIONS ***

    -- Calculate Outstanding Balance (implementation moved inside package body)
    FUNCTION FNC_CALC_OUTSTANDING_BALANCE (
        p_loan_id IN NUMBER
    )
    RETURN NUMBER
    IS
        v_principal_amount NUMBER(12, 2);
        v_total_paid       NUMBER(12, 2);
        v_total_penalties  NUMBER(12, 2);
    BEGIN
        SELECT AMOUNT INTO v_principal_amount FROM LOANS WHERE LOAN_ID = p_loan_id;
        SELECT NVL(SUM(AMOUNT_PAID), 0) INTO v_total_paid FROM PAYMENTS WHERE LOAN_ID = p_loan_id;
        SELECT NVL(SUM(PENALTY_AMOUNT), 0) INTO v_total_penalties FROM PENALTIES WHERE LOAN_ID = p_loan_id;

        RETURN v_principal_amount + v_total_penalties - v_total_paid;
    END FNC_CALC_OUTSTANDING_BALANCE;

END MMS_LOAN_PKG;
