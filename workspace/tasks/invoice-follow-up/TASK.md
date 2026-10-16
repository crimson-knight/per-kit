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
- 0 to 6 days past due, or not yet due: no email; list it in the summary as "not yet".
- 7 to 29 days: friendly reminder.
- 30 to 59 days: firm reminder that names the original due date and asks for a payment
  date.
- 60 days or more: final notice that says the account is paused for new work until it is
  settled, and offers a call to set up a payment plan.

DONE MEANS:
- `output/drafts/`: one Markdown file per customer who needs an email, named
  `<customer-name-slug>.md`, with To, Subject, and Body. A customer with several overdue
  invoices gets one email that lists each invoice, at the tier of the oldest one.
- `output/summary.md`: a table with every row of the CSV: invoice, customer, balance, due
  date, days overdue, tier (or "not yet" or "held: data problem"), and a total of the
  balances in each tier.
- `output/data-problems.md`: every row that looks wrong, the reason, and what the owner
  should check. Rows with a data problem get no draft until the owner confirms them.
- Every amount, invoice number, and due date in every draft matches the CSV exactly.

LIMITS:
- Drafts only. Nothing is sent, and no system outside this folder is touched.
- Use only the facts in the CSV and preferences.md. No late fees, interest, or legal
  language unless preferences.md asks for them.

TIME: a person doing this by hand takes about 45 minutes a week.
