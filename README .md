# Personal Expense Tracker (Oracle APEX + PL/SQL)

A small database application that records everyday expenses and shows them month by month.
Built for the **PL/SQL** course (Subject Code 26CAP-602), MCA, University Institute of Computing, Chandigarh University.

**Author:** Ujjal Roy (UID 26MCA20159, 26MCA-3, Section A)
**Submitted to:** Tanisha Rani, Professor

**Live application:** https://oracleapex.com/ords/r/ujjals_space/personal-expense-tracker/home

## What it does

- **Add Expense page:** save an expense with amount, category, date and a short description.
- **Expense History page:** pick a month to see its expenses and the month's total.
- Every new expense is checked by a PL/SQL procedure before it is saved.

## Technologies

- Oracle Database (SQL and PL/SQL)
- Oracle APEX 26.2 (SQL Workshop, App Builder, Page Designer)

## Database design

- `CATEGORIES` (category_id, category_name): one row per category.
- `EXPENSES` (expense_id, amount, category_id, expense_date, description): one row per expense. `category_id` is a foreign key to `CATEGORIES`, and `amount` must be greater than 0.
- Procedure `ADD_EXPENSE`: checks the amount, date, category and description length, raises a custom error (-20001 to -20005) if a rule fails, otherwise inserts the row and commits.
- Function `GET_MONTH_TOTAL(p_month_date)`: returns the total spent in the month that contains the given date.

## Files

| File | What it is |
|------|------------|
| `expense_tracker.sql` | Database script: tables, sample data (7 categories, 13 expenses), procedure and function |
| `f185095.sql` | Oracle APEX application export (the two pages) |
| `screenshots/` | Screenshots of the running application |

## How to run it yourself

1. Get a free Oracle APEX workspace (apex.oracle.com) or use one from your college.
2. In APEX, open **SQL Workshop > SQL Scripts**, upload `expense_tracker.sql` and run it. Check that all statements finish with no errors.
3. Open **App Builder > Import**, choose `f185095.sql`, and follow the import steps.
4. Run the imported application.

## Testing summary

- Database script: 25 statements processed, 0 errors.
- Adding a valid expense saves it and the month total goes up.
- A negative amount is rejected with the message "Amount must be greater than zero."
- Expense History for October 2026 lists the expenses and shows the matching total.

## Limitations

- No login: the pages are public, so data is shared by everyone who opens the link. Do not enter real personal finances.
- No edit or delete, fixed categories, no charts or budgets.

## Screenshots

Add your images to the `screenshots/` folder with these names:

![Add Expense page](screenshots/add-expense.png)
![Validation error](screenshots/validation-error.png)
![Expense History](screenshots/expense-history.png)
