# Task: inbox triage

GOAL: Sort a pile of incoming messages so the owner knows what to answer today, with
reply drafts ready for the urgent ones and a list of questions customers keep asking.

INPUTS:
- `sample_messages/` (in this folder): ten exported messages, one per `.txt` file, each
  with From, Date, and Subject lines. Swap in your own exported or pasted messages.
- AS-OF DATE: Monday, October 12, 2026, 8:00 a.m.

DONE MEANS:
- `output/triage.md`: a table with every message: file name, sender, subject, bucket, and
  a one-line reason. Buckets: reply today, this week, delegate (name the role, such as
  "crew lead" or "bookkeeper"), archive.
- `output/replies/`: one draft reply per "reply today" message, named after the message
  file, with To, Subject, and Body.
- `output/faq-candidates.md`: questions that appear in two or more messages, each with
  the message files it came from and a draft answer, or "owner to answer" when the
  messages do not contain the facts.
- No message with a deadline, a safety issue, a property-damage report, or an unhappy
  paying customer is in archive.

LIMITS:
- Drafts only; nothing is sent.
- Replies promise nothing the owner has not already offered in the messages or in
  preferences.md: no prices, dates, or discounts that are not in the source.

TIME: a person doing this by hand takes about 40 minutes.
