-- =====================================================================
-- PERSONAL EXPENSE TRACKER   (Oracle SQL / PL/SQL only - no MySQL syntax)
-- Run in: Oracle APEX > SQL Workshop > SQL Scripts > Run
-- =====================================================================

-- To START OVER, remove the leading "--" from these 4 lines, then run again:
-- DROP FUNCTION get_month_total;
-- DROP PROCEDURE add_expense;
-- DROP TABLE expenses;
-- DROP TABLE categories;


-- ---------------------------------------------------------------------
-- 1. TABLES
-- ---------------------------------------------------------------------

-- One row per category (Food, Rent, ...)
CREATE TABLE categories (
    category_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name  VARCHAR2(50) NOT NULL UNIQUE
);

-- One row per expense; category_id points to the categories table
CREATE TABLE expenses (
    expense_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    amount         NUMBER(10,2)  NOT NULL,
    category_id    NUMBER        NOT NULL,
    expense_date   DATE          NOT NULL,
    description    VARCHAR2(200),
    CONSTRAINT chk_expense_amount CHECK (amount > 0),
    CONSTRAINT fk_expense_category FOREIGN KEY (category_id)
        REFERENCES categories (category_id)
);


-- ---------------------------------------------------------------------
-- 2. SAMPLE DATA
-- ---------------------------------------------------------------------

INSERT INTO categories (category_name) VALUES ('Food');
INSERT INTO categories (category_name) VALUES ('Transport');
INSERT INTO categories (category_name) VALUES ('Rent');
INSERT INTO categories (category_name) VALUES ('Shopping');
INSERT INTO categories (category_name) VALUES ('Entertainment');
INSERT INTO categories (category_name) VALUES ('Bills');
INSERT INTO categories (category_name) VALUES ('Education');

-- September 2026
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (5000.00, (SELECT category_id FROM categories WHERE category_name = 'Rent'),
        DATE '2026-09-02', 'September room rent');
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (120.50, (SELECT category_id FROM categories WHERE category_name = 'Food'),
        DATE '2026-09-04', 'Lunch at canteen');
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (45.00, (SELECT category_id FROM categories WHERE category_name = 'Transport'),
        DATE '2026-09-09', 'Bus pass top-up');
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (350.00, (SELECT category_id FROM categories WHERE category_name = 'Education'),
        DATE '2026-09-15', 'Notebook and printouts');
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (250.00, (SELECT category_id FROM categories WHERE category_name = 'Entertainment'),
        DATE '2026-09-20', 'Movie with friends');
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (399.00, (SELECT category_id FROM categories WHERE category_name = 'Bills'),
        DATE '2026-09-27', 'Mobile recharge');

-- October 2026
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (5000.00, (SELECT category_id FROM categories WHERE category_name = 'Rent'),
        DATE '2026-10-01', 'October room rent');
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (95.00, (SELECT category_id FROM categories WHERE category_name = 'Food'),
        DATE '2026-10-02', 'Breakfast and tea');
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (60.00, (SELECT category_id FROM categories WHERE category_name = 'Transport'),
        DATE '2026-10-03', 'Auto to college');
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (450.00, (SELECT category_id FROM categories WHERE category_name = 'Education'),
        DATE '2026-10-05', 'DBMS reference book');
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (180.75, (SELECT category_id FROM categories WHERE category_name = 'Food'),
        DATE '2026-10-06', 'Dinner with friends');
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (399.00, (SELECT category_id FROM categories WHERE category_name = 'Bills'),
        DATE '2026-10-08', 'Mobile recharge');
INSERT INTO expenses (amount, category_id, expense_date, description)
VALUES (799.00, (SELECT category_id FROM categories WHERE category_name = 'Shopping'),
        DATE '2026-10-10', 'T-shirt');

COMMIT;


-- ---------------------------------------------------------------------
-- 3. PROCEDURE: add one expense after basic validation
-- ---------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE add_expense (
    p_amount        IN NUMBER,
    p_category_id   IN NUMBER,
    p_expense_date  IN DATE,
    p_description   IN VARCHAR2
) IS
    v_count NUMBER;
BEGIN
    -- Rule 1: amount must be a positive number
    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Amount must be greater than zero.');
    END IF;

    -- Rule 2: date is required
    IF p_expense_date IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'Please enter the expense date.');
    END IF;

    -- Rule 3: date cannot be in the future
    IF p_expense_date > TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20003, 'Date cannot be in the future.');
    END IF;

    -- Rule 4: category must exist
    SELECT COUNT(*)
      INTO v_count
      FROM categories
     WHERE category_id = p_category_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Please choose a valid category.');
    END IF;

    -- Rule 5: description must fit the column (200 characters)
    IF LENGTH(p_description) > 200 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Description is too long (maximum 200 characters).');
    END IF;

    -- All checks passed: save the expense
    INSERT INTO expenses (amount, category_id, expense_date, description)
    VALUES (p_amount, p_category_id, TRUNC(p_expense_date), p_description);

    COMMIT;
END add_expense;
/


-- ---------------------------------------------------------------------
-- 4. FUNCTION: total spent in one month
--    Pass any date inside the month you want, e.g. DATE '2026-10-15'
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_month_total (
    p_month_date IN DATE
) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(amount), 0)
      INTO v_total
      FROM expenses
     WHERE expense_date >= TRUNC(p_month_date, 'MM')
       AND expense_date <  ADD_MONTHS(TRUNC(p_month_date, 'MM'), 1);

    RETURN v_total;
END get_month_total;
/


-- ---------------------------------------------------------------------
-- 5. OPTIONAL CHECKS - copy these into SQL Workshop > SQL Commands
--    and run them ONE AT A TIME after the script has finished.
-- ---------------------------------------------------------------------
-- SELECT get_month_total(DATE '2026-10-01') FROM dual;     -- 6983.75
-- SELECT get_month_total(DATE '2026-09-01') FROM dual;     -- 6164.5
--
-- BEGIN add_expense(100, 1, DATE '2026-10-09', 'Test'); END;   -- works
-- BEGIN add_expense(-5, 1, DATE '2026-10-09', 'Bad');   END;   -- error -20001
