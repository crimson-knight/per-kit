# Task: weekly invoice follow-up

GOAL: Turn this week's open-invoice export into ready-to-review follow-up email drafts,
a summary of who owes what, and a list of anything in the data that looks wrong.

INPUTS:
- `sample_open_invoices.csv` (in this folder): an export of open invoices from an
  accounting system. Columns: invoice_number, customer_name, contact_name, contact_email,
  invoice_date, due_date, amount, amount_paid, balance, status.
- AS-OF DATE: 2026-10-12. Count days overdue from this date, so the sample gives the same
  answer whenever you run it. When you use your own export, set this to its export date.
- The business sending the reminders is Harbor & Pine Landscaping (see preferences.md).

TIERS (by days past the due date on the as-of date):
- Not yet due: no email; summary tier "not due", days column "due in N days".
- 0 to 6 days past due: no email; summary tier "grace period".
- 7 to 29 days: friendly reminder.
- 30 to 59 days: firm reminder that names the original due date and asks for a payment
  date.
- 60 days or more: final notice that asks for one thing: a payment date, or a time for a
  call to set up a payment plan. The CSV has no contact history, so the draft mentions
  only the invoice facts, never earlier reminders or calls.

DONE MEANS:
- `output/drafts/`: one Markdown file per customer who needs an email, named
  `<customer-name-slug>.md`, with To, Subject, and Body. A customer with several overdue
  invoices gets one email that lists each invoice, at the tier of the oldest one.
- `output/summary.md`: a table with every row of the CSV: invoice, customer, balance, due
  date, days overdue, and tier (friendly, firm, final, grace period, not due, or "held:
  data problem"), then the total of the balances for each of those six groups, with held
  rows counted only under "held". The six totals add up to the CSV's total balance.
- `output/data-problems.md`: every row that looks wrong, the reason, and what the owner
  should check. Rows with a data problem get no draft until the owner confirms them. When
  an invoice number appears on more than one row, every row with that number is held.
- Every draft quotes each invoice's balance (and, when part is paid, the amount
  received), and every amount, invoice number, and due date has the same value as the
  CSV. Drafts contain only per-invoice figures from the CSV: no computed totals.

LIMITS:
- Drafts only. Nothing is sent, and no system outside this folder is touched.
- Use only the facts in the CSV, this file, and preferences.md. Charge no late fees or
  interest and use no legal language unless preferences.md asks for them.
- To use your own export: replace the CSV, set the AS-OF DATE above, change the sender
  business name above, and update the sign-off in preferences.md.

TIME: a person doing this by hand takes about 45 minutes a week.
