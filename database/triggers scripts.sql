-- Create sequence for LOAN_ID if not exists
CREATE SEQUENCE loan_id_seq START WITH 1001 INCREMENT BY 1;

-- Trigger to auto-generate LOAN_ID before insert
CREATE OR REPLACE TRIGGER trg_auto_loan_id
BEFORE INSERT ON LOANS
FOR EACH ROW
BEGIN
    IF :NEW.LOAN_ID IS NULL THEN
        :NEW.LOAN_ID := loan_id_seq.NEXTVAL;
    END IF;
END;
/
-- Trigger to update loan status when repayments are made
CREATE OR REPLACE TRIGGER trg_update_loan_status
AFTER INSERT OR UPDATE ON REPAYMENTS
FOR EACH ROW
DECLARE
    v_total_paid NUMBER(10,2);
    v_loan_amount NUMBER(10,2);
    v_loan_status VARCHAR2(20);
BEGIN
    -- Calculate total paid for this loan
    SELECT SUM(AMOUNT_PAID) 
    INTO v_total_paid
    FROM REPAYMENTS 
    WHERE LOAN_ID = :NEW.LOAN_ID;
    
    -- Get loan amount
    SELECT LOAN_AMOUNT, STATUS
    INTO v_loan_amount, v_loan_status
    FROM LOANS 
    WHERE LOAN_ID = :NEW.LOAN_ID;
    
    -- Update loan status based on repayment progress
    IF v_total_paid >= v_loan_amount AND v_loan_status != 'Paid Off' THEN
        UPDATE LOANS 
        SET STATUS = 'Paid Off'
        WHERE LOAN_ID = :NEW.LOAN_ID;
        
        -- Log the payoff
        INSERT INTO LOAN_AUDIT (LOAN_ID, ACTION, ACTION_DATE, DESCRIPTION)
        VALUES (:NEW.LOAN_ID, 'PAID_OFF', SYSDATE, 'Loan fully paid via repayments');
        
    ELSIF v_total_paid > 0 AND v_loan_status = 'Active' THEN
        -- Optional: Track partial payments
        UPDATE LOANS 
        SET STATUS = 'Repaying'
        WHERE LOAN_ID = :NEW.LOAN_ID;
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL; -- Handle gracefully
END;
/
-- Trigger to validate and calculate monthly payment on loan insertion
CREATE OR REPLACE TRIGGER trg_loan_validation
BEFORE INSERT OR UPDATE ON LOANS
FOR EACH ROW
DECLARE
    v_monthly_payment NUMBER(10,2);
    v_min_interest_rate NUMBER(5,2) := 5.0; -- Minimum interest rate
    v_max_interest_rate NUMBER(5,2) := 20.0; -- Maximum interest rate
    v_max_term_months NUMBER(3) := 84; -- Maximum 7 years
BEGIN
    -- Validate interest rate range
    IF :NEW.INTEREST_RATE < v_min_interest_rate THEN
        RAISE_APPLICATION_ERROR(-20001, 'Interest rate cannot be less than ' || v_min_interest_rate || '%');
    ELSIF :NEW.INTEREST_RATE > v_max_interest_rate THEN
        RAISE_APPLICATION_ERROR(-20002, 'Interest rate cannot exceed ' || v_max_interest_rate || '%');
    END IF;
    
    -- Validate loan term
    IF :NEW.TERM_MONTHS > v_max_term_months THEN
        RAISE_APPLICATION_ERROR(-20003, 'Loan term cannot exceed ' || v_max_term_months || ' months');
    END IF;
    
    -- Validate loan amount (assuming minimum loan amount)
    IF :NEW.LOAN_AMOUNT < 10000 THEN -- Minimum 10,000
        RAISE_APPLICATION_ERROR(-20004, 'Minimum loan amount is 10,000');
    END IF;
    
    -- Calculate and store monthly payment (for reference, though not in table)
    -- Formula: P * r * (1+r)^n / ((1+r)^n - 1)
    -- You could store this in a separate table or calculate on the fly
    DBMS_OUTPUT.PUT_LINE('Loan validated: Monthly payment would be approximately ' || 
        ROUND(:NEW.LOAN_AMOUNT * (:NEW.INTEREST_RATE/100/12) * 
        POWER(1 + (:NEW.INTEREST_RATE/100/12), :NEW.TERM_MONTHS) / 
        (POWER(1 + (:NEW.INTEREST_RATE/100/12), :NEW.TERM_MONTHS) - 1), 2));
        
END;
/
-- Trigger to ensure repayment dates are valid
CREATE OR REPLACE TRIGGER trg_repayment_date_validation
BEFORE INSERT OR UPDATE ON REPAYMENTS
FOR EACH ROW
DECLARE
    v_disbursement_date DATE;
    v_loan_status VARCHAR2(20);
BEGIN
    -- Get loan disbursement date and status
    SELECT DISBURSEMENT_DATE, STATUS
    INTO v_disbursement_date, v_loan_status
    FROM LOANS 
    WHERE LOAN_ID = :NEW.LOAN_ID;
    
    -- Ensure repayment date is after disbursement
    IF :NEW.REPAYMENT_DATE < v_disbursement_date THEN
        RAISE_APPLICATION_ERROR(-20005, 'Repayment date cannot be before loan disbursement date: ' || v_disbursement_date);
    END IF;
    
    -- Ensure loan is active before accepting repayments
    IF v_loan_status = 'Cancelled' OR v_loan_status = 'Rejected' THEN
        RAISE_APPLICATION_ERROR(-20006, 'Cannot accept repayments for ' || v_loan_status || ' loans');
    END IF;
    
    -- Ensure repayment date is not in the future (unless it's scheduled)
    IF :NEW.REPAYMENT_DATE > SYSDATE AND :NEW.STATUS = 'Paid' THEN
        RAISE_APPLICATION_ERROR(-20007, 'Cannot mark future date repayments as "Paid"');
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20008, 'Invalid LOAN_ID: ' || :NEW.LOAN_ID);
END;
/