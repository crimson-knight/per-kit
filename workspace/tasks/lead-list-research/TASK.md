# Task: lead list research

GOAL: Build a list of 25 businesses that match the ideal customer in
`sample_ideal_customer.md`, with a public source for every fact, ready for the owner to
start outreach.

INPUTS:
- `sample_ideal_customer.md` (in this folder): who fits, the region, and the signals.
- Web search and web pages. If your tool has no web access, write the plan, then the
  blocker report described in run-task, and stop.
- Reading the ideal customer: the buyer is the management firm, not the HOA or office
  park it manages. A firm needs an office in Sacramento County or a neighboring county;
  the other signals rank candidates rather than rule them out. Expect to screen about
  three candidates for each one that makes the list.

DONE MEANS:
- `output/leads.csv` with exactly 25 rows and these columns: business_name, website,
  city, fit_reason (one sentence tied to the ideal-customer signals), source_url (the
  public page that supports fit_reason and city; when they come from two pages, both
  URLs separated by " | "), checked_on (the date you opened the page, as YYYY-MM-DD).
- `output/notes.md`: how you searched, which candidates you dropped and why, and the
  five rows you spot-checked by reopening their sources, with the result of each check.
- No duplicates: one row per business.

LIMITS:
- Public business information only: business names, business websites, and what those
  sites or a public directory or news page say about the business. A business name that
  includes a person's name (such as "The John Stewart Company") is a business name. Leave out individual people's names, personal emails,
  and personal phone numbers.
- Every row cites a source that you opened. A row with no source stays out of the file.
- Nothing is sent and no one is contacted.

TIME: a person doing this by hand takes about 2 hours.
