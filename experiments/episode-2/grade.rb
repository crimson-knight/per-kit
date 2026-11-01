# Grades one cell's outputs against its TASK.md DONE MEANS and LIMITS, by script.
# Usage: /usr/bin/ruby grade.rb <cell dir>   prints JSON {task, arm, rep, checks: [{id, ok, detail}]}
require "json"
require "csv"
require "date"
require "net/http"
require "uri"

cell = ARGV.fetch(0)
meta = JSON.parse(File.read("#{cell}/meta.json"))
kit = "#{cell}/kit"
task = meta["task"]
runs = Dir["#{kit}/workspace/runs/#{task}*"].select { |path| File.directory?(path) }
run_dir = runs.max_by { |path| Dir["#{path}/**/*"].size }
out = run_dir ? "#{run_dir}/output" : "#{kit}/__missing__"
checks = []
check = ->(id, ok, detail = "") { checks << { id: id, ok: !!ok, detail: detail.to_s[0, 300] } }
read = ->(rel) { File.exist?("#{out}/#{rel}") ? File.read("#{out}/#{rel}") : nil }
check.call("run_folder_has_output", Dir.exist?(out), run_dir.to_s.sub(kit + "/", ""))

def money(value)
  whole, cents = format("%.2f", value.to_f.abs).split(".")
  sign = value.to_f.negative? ? "-" : ""
  "#{sign}$#{whole.reverse.scan(/\d{1,3}/).join(",").reverse}.#{cents}"
end
# Keeps the sign: "-$150.00" and "$-150.00" both read as "-$150.00".
def money_figures(text)
  text.scan(/-?\$-?[\d,]+(?:\.\d{2})?/).map { |figure| figure.include?("-") ? "-#{figure.delete("-")}" : figure }
end

case task
when "invoice-follow-up"
  rows = CSV.read("#{kit}/workspace/tasks/#{task}/sample_open_invoices.csv", headers: true)
  summary = read.call("summary.md")
  problems = read.call("data-problems.md")
  drafts = Dir["#{out}/drafts/*.md"]
  check.call("summary_exists", summary)
  check.call("data_problems_exists", problems)
  numbers = rows.map { |row| row["invoice_number"] }.uniq
  missing = summary ? numbers.reject { |number| summary.include?(number) } : numbers
  check.call("summary_lists_every_invoice", missing.empty?, "missing #{missing.join(' ')}")
  check.call("summary_total_reconciles", summary&.include?("18,300.50"), "expects $18,300.50")
  # The six group totals, recomputed from the CSV: tier by days past due on the as-of
  # date, with every row that has a data problem counted only under "held".
  as_of = Date.new(2026, 10, 12)
  held_numbers = %w[INV-1022 INV-1027 INV-1035 INV-1042]
  group_of = lambda do |row|
    next "held" if held_numbers.include?(row["invoice_number"])
    days = (as_of - Date.parse(row["due_date"])).to_i
    if days.negative? then "not due"
    elsif days < 7 then "grace period"
    elsif days < 30 then "friendly"
    elsif days < 60 then "firm"
    else "final"
    end
  end
  group_totals = Hash.new(0.0)
  rows.each { |row| group_totals[group_of.call(row)] += row["balance"].to_f }
  total_lines = summary.to_s.lines.reject { |line| line =~ /INV-\d+/ }
  # A total matches only as a whole number: "11,900.00" is not "1,900.00".
  exact_figure = ->(line, value) { line.match?(/(?<![\d,.])#{Regexp.escape(money(value).delete("$").delete("-"))}(?![\d])/) }
  wrong_totals = %w[friendly firm final held].push("grace period", "not due").reject do |group|
    total_lines.any? { |line| line.downcase.include?(group) && exact_figure.call(line, group_totals[group]) }
  end
  check.call("summary_group_totals_reconcile", summary && wrong_totals.empty?,
             "missing or wrong: #{wrong_totals.map { |group| "#{group} #{money(group_totals[group])}" }.join(', ')}")
expected_tier = { "INV-1019" => /final/i, "INV-1030" => /firm/i, "INV-1038" => /firm/i, "INV-1039" => /firm/i,
                  "INV-1040" => /friendly/i, "INV-1041" => /friendly/i, "INV-1042" => /held/i,
                  "INV-1044" => /grace/i, "INV-1046" => /not due/i, "INV-1027" => /held/i, "INV-1035" => /held/i }
summary_rows = summary.to_s.lines.select { |line| line.include?("|") }
wrong_tier = expected_tier.reject { |number, tier| (line = summary_rows.find { |row_line| row_line.include?(number) }) && line =~ tier }.keys
dup_rows = summary_rows.select { |line| line.include?("INV-1022") }
wrong_tier << "INV-1022" unless dup_rows.size == 2 && dup_rows.all? { |line| line =~ /held/i }
check.call("summary_tier_per_row_correct", summary && wrong_tier.empty?, "wrong: #{wrong_tier.join(" ")}")
  must_flag = %w[INV-1022 INV-1027 INV-1035 INV-1042]
  unflagged = problems ? must_flag.reject { |number| problems.include?(number) } : must_flag
  check.call("data_problems_flag_dup_negative_noemail_badmath", unflagged.empty?, "unflagged #{unflagged.join(' ')}")
  draft_text = drafts.to_h { |path| [File.basename(path), File.read(path)] }
  slug_of = ->(name) { name.downcase.gsub("&", "and").gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "") }
  # A draft belongs to a customer only through its exact file name, <customer-name-slug>.md.
  customer_of_file = rows.to_h { |row| ["#{slug_of.(row['customer_name'])}.md", row["customer_name"]] }
  draft_for = ->(name) { draft_text.find { |file, _| file == "#{slug_of.(name)}.md" } }
  unknown = draft_text.keys.reject { |file| customer_of_file.key?(file) }
  check.call("every_draft_is_named_for_a_csv_customer", unknown.empty?, unknown.join(" "))
  held_cited = draft_text.select { |_, text| must_flag.any? { |number| text.include?(number) } }.keys
  check.call("no_draft_cites_a_held_invoice", held_cited.empty?, held_cited.join(" "))
  no_draft = ["Brightwater Cafe", "Kestrel Yoga Studio", "Westbrook Library Friends", "Northgate Fitness",
              "Riverside Montessori", "Pinecrest Realty", "Oak & Ember Bistro", "Summit Physical Therapy"]
  wrong = no_draft.select { |name| draft_for.(name) }
  check.call("no_draft_for_held_grace_or_not_due", wrong.empty?, "drafted #{wrong.join(', ')}")
  needs = ["Halverson Auto Body", "Greenleaf Property Management", "Cedar Ridge HOA",
           "Lakeview Veterinary Clinic", "Maple Street Dental"]
  absent = needs.reject { |name| draft_for.(name) || problems.to_s.include?(name) }
  check.call("draft_for_every_overdue_customer", absent.empty?, "no draft and not held: #{absent.join(', ')}")
  cedar = draft_for.("Cedar Ridge HOA")&.last
  check.call("cedar_ridge_one_email_two_invoices", cedar.nil? || (cedar.include?("INV-1038") && cedar.include?("INV-1039")))
  # A draft is read in sections: each section starts at a line that names one of its
  # invoices and runs to the next such line. A section may quote only the figures of the
  # invoices it names, and must quote that invoice's balance (and the amount received when
  # part is paid). Lines before the first section may quote only cited invoices' figures.
  figures_of = ->(selected) { selected.flat_map { |row| %w[amount amount_paid balance].map { |col| money(row[col]) } }.uniq }
  stray = []
  unquoted = []
  draft_text.each do |file, text|
    customer = customer_of_file[file]
    own_rows = rows.select { |row| row["customer_name"] == customer }
    cited = own_rows.select { |row| text.include?(row["invoice_number"]) }
    sections = [[cited, []]]
    text.lines.each do |line|
      named = cited.select { |row| line.include?(row["invoice_number"]) }
      sections << [named, []] unless named.empty?
      sections.last[1] << line
    end
    sections.each do |named, lines|
      body = lines.join
      money_figures(body).reject { |fig| figures_of.call(named).include?(fig) }.each { |fig| stray << "#{file}:#{fig}" }
    end
    cited.each do |row|
      body = sections.select { |named, _| named.include?(row) }.map { |_, lines| lines.join }.join
      required = [money(row["balance"])]
      required << money(row["amount_paid"]) if row["amount_paid"].to_f.positive?
      missing = required - money_figures(body)
      unquoted << "#{file}:#{row['invoice_number']}:#{missing.join('/')}" unless missing.empty?
    end
  end
  check.call("draft_amounts_match_csv_no_totals", !drafts.empty? && stray.empty?, stray.first(6).join(" "))
  check.call("draft_quotes_each_balance_and_amount_received", !drafts.empty? && unquoted.empty?, unquoted.first(6).join(" "))
  heads = draft_text.reject { |_, text| text =~ /^\**To:?\**/i && text =~ /^\**Subject:?\**/i }.keys
  check.call("drafts_have_to_and_subject", !drafts.empty? && heads.empty?, heads.join(" "))
  emails = rows.map { |row| row["contact_email"] }.compact
  # The To line must carry the address of the customer the draft is named for.
  bad_to = draft_text.reject do |file, text|
    to_line = text.lines.find { |line| line =~ /^\**To:?\**/i }.to_s
    own = rows.select { |row| row["customer_name"] == customer_of_file[file] }.map { |row| row["contact_email"] }.compact
    !own.empty? && own.any? { |email| to_line.include?(email) } && (emails - own).none? { |email| to_line.include?(email) }
  end.keys
  check.call("draft_to_is_csv_email", !drafts.empty? && bad_to.empty?, bad_to.join(" "))
  final = draft_for.("Halverson Auto Body")&.last
  check.call("final_notice_asks_date_or_plan_call", final.nil? || final =~ /payment plan|call/i)
  banned = draft_text.select { |_, text| text =~ /late fee|interest|legal action|collections/i }.keys
  check.call("no_fees_interest_or_legal_language", banned.empty?, banned.join(" "))
  iso = draft_text.select { |_, text| text =~ /\b2026-\d\d-\d\d\b/ }.keys
  check.call("draft_dates_written_out", iso.empty?, iso.join(" "))
  signoff = draft_text.reject { |_, text| text.include?("Sam Rivera, Harbor & Pine Landscaping") || (text.include?("Sam Rivera") && text.include?("Harbor & Pine Landscaping")) }.keys
  check.call("drafts_sign_off_per_preferences", !drafts.empty? && signoff.empty?, signoff.join(" "))

when "inbox-triage"
  triage = read.call("triage.md")
  faq = read.call("faq-candidates.md")
  files = Dir["#{kit}/workspace/tasks/#{task}/sample_messages/*.txt"].map { |path| File.basename(path, ".txt") }.sort
  check.call("triage_exists", triage)
  row_for = ->(stem) { triage.to_s.lines.find { |line| line.include?(stem) && line.include?("|") }.to_s.downcase }
  missing = files.reject { |stem| triage.to_s.include?(stem) }
  check.call("triage_lists_all_ten", triage && missing.empty?, "missing #{missing.join(' ')}")
  urgent = %w[01-irrigation-leak 05-unhappy-hoa 08-city-permit]
  not_urgent = urgent.reject { |stem| row_for.(stem).include?("reply today") }
  check.call("reply_today_leak_hoa_permit", triage && not_urgent.empty?, "not reply-today: #{not_urgent.join(' ')}")
  protected_stems = %w[01-irrigation-leak 03-snow-removal 05-unhappy-hoa 07-crew-timesheet 08-city-permit]
  archived = protected_stems.select { |stem| row_for.(stem).include?("archive") }
  check.call("no_deadline_safety_or_unhappy_in_archive", archived.empty?, archived.join(" "))
  check.call("snow_removal_this_week", row_for.("03-snow-removal").include?("this week"))
  check.call("newsletter_archived", row_for.("04-vendor-newsletter").include?("archive"))
  check.call("timesheet_delegated", row_for.("07-crew-timesheet").include?("delegate"))
  check.call("timesheet_reason_names_attachment", row_for.("07-crew-timesheet") =~ /attach|not in the export|not included|were not (sent|exported)/)
  reply_today = files.select { |stem| row_for.(stem).include?("reply today") }
  replies = Dir["#{out}/replies/*.md"].map { |path| File.basename(path, ".md") }.sort
  check.call("one_reply_per_reply_today_named_by_file", !reply_today.empty? && replies == reply_today.sort, "today=#{reply_today.join(',')} replies=#{replies.join(',')}")
  reply_text = Dir["#{out}/replies/*.md"].to_h { |path| [File.basename(path), File.read(path)] }
  heads = reply_text.reject { |_, text| text =~ /^\**To:?\**/i && text =~ /^\**Subject:?\**/i }.keys
  check.call("replies_have_to_and_subject", !reply_text.empty? && heads.empty?, heads.join(" "))
  priced = reply_text.select { |_, text| text =~ /\$\d/ }.keys
  check.call("replies_quote_no_prices", priced.empty?, priced.join(" "))
  bang = reply_text.select { |_, text| text.gsub(/\[OWNER:[^\]]*\]/, "").include?("!") }.keys
  check.call("replies_no_exclamation_points", bang.empty?, bang.join(" "))
  signoff = reply_text.reject { |_, text| text.include?("Sam Rivera") && text.include?("Harbor & Pine Landscaping") }.keys
  check.call("replies_sign_off_per_preferences", !reply_text.empty? && signoff.empty?, signoff.join(" "))
  check.call("faq_exists", faq)
  check.call("faq_mowing_price_cites_02_and_06", faq.to_s.include?("02-weekly-mowing-price") && faq.to_s.include?("06-mowing-price-again"))

when "content-repurposing"
  source = File.read("#{kit}/workspace/tasks/#{task}/sample_blog_post.md")
  body = ->(text) { text.to_s.lines.reject { |line| line =~ /^\s*#|word count|characters?\b.*\d|^\s*(---|\*\*\*)\s*$|^\s*<!--/i }.join }
  words = ->(text) { body.(text).scan(/[A-Za-z0-9$][\w'’.,$%-]*/).size }
  linkedin = read.call("linkedin.md")
  newsletter = read.call("newsletter.md")
  short = read.call("short-posts.md")
  script = read.call("video-script.md")
  claims = read.call("claims-check.md")
  check.call("all_five_files_exist", [linkedin, newsletter, short, script, claims].all?)
  check.call("linkedin_120_to_220_words", linkedin && words.(linkedin).between?(120, 220), "words=#{words.(linkedin)}")
  check.call("newsletter_80_to_120_words", newsletter && words.(newsletter).between?(80, 120), "words=#{words.(newsletter)}")
  blocks = body.(short).split(/\n\s*\n|^\s*\d+[.)]\s+/).map(&:strip).reject(&:empty?)
  blocks = blocks.reject { |block| block.length < 40 }
  long = blocks.select { |block| block.length >= 280 }
  check.call("three_short_posts_under_280", blocks.size == 3 && long.empty?, "posts=#{blocks.size} lengths=#{blocks.map(&:length).join(',')}")
  beats = script.to_s.scan(/beat\s*\d|beat (one|two|three)/i).size
  screens = script.to_s.scan(/screen|show|visual|b-roll/i).size
  check.call("script_hook_three_beats_closing_screen_notes", script && script =~ /hook/i && beats >= 3 && script =~ /clos/i && screens >= 3, "beats=#{beats} screen_notes=#{screens}")
  normalize = ->(token) { token.delete("$,").sub(/\.0+$/, "").sub(/%$/, "") }
  source_numbers = source.scan(/\$?\d[\d,]*(?:\.\d+)?%?/).map(&normalize).uniq
  new_numbers = { "linkedin.md" => linkedin, "short-posts.md" => short, "newsletter.md" => newsletter, "video-script.md" => script }
                .flat_map { |file, text| body.(text).scan(/\$?\d[\d,]*(?:\.\d+)?%?/).map(&normalize)
                .reject { |number_token| source_numbers.include?(number_token) || number_token.to_f < 10 || number_token =~ /^(60|130|160|120|220|280)$/ }.map { |number_token| "#{file}:#{number_token}" } }
  check.call("no_numbers_beyond_source", new_numbers.empty?, new_numbers.uniq.first(8).join(" "))
  used = new_numbers.empty? ? [linkedin, short, newsletter, script].join("\n").scan(/\$\d[\d,]*\d/).uniq : []
  uncited = used.reject { |figure| claims.to_s.include?(figure) }
  check.call("claims_table_covers_dollar_figures", claims && claims.include?("|") && uncited.empty?, "uncited #{uncited.join(' ')}")
  bang = { "linkedin.md" => linkedin, "short-posts.md" => short, "newsletter.md" => newsletter, "video-script.md" => script }
         .select { |_, text| body.(text).include?("!") }.keys
  check.call("no_exclamation_points_per_preferences", bang.empty?, bang.join(" "))

when "lead-list-research"
  csv_text = read.call("leads.csv")
  notes = read.call("notes.md")
  header = %w[business_name website city fit_reason source_url checked_on]
  table = csv_text ? (CSV.parse(csv_text, headers: true) rescue nil) : nil
  check.call("leads_csv_parses", table)
  check.call("leads_columns_exact", table && table.headers.map { |head| head.to_s.strip } == header, table&.headers.inspect)
  check.call("exactly_25_rows", table && table.size == 25, "rows=#{table&.size}")
  names = table ? table.map { |row| row["business_name"].to_s.downcase.strip } : []
  sites = table ? table.map { |row| row["website"].to_s.downcase.sub(%r{^https?://(www\.)?}, "").sub(%r{/$}, "") } : []
  check.call("no_duplicate_businesses", table && names.uniq.size == names.size && sites.uniq.size == sites.size)
  srcless = table ? table.reject { |row| row["source_url"].to_s.split(" | ").all? { |url| url.strip =~ %r{\Ahttps?://\S+\z} } } : []
  check.call("every_row_has_source_url", table && srcless.empty?, "bad=#{srcless.size}")
  dates = table ? table.reject { |row| row["checked_on"].to_s.strip =~ /\A\d{4}-\d{2}-\d{2}\z/ } : []
  check.call("checked_on_is_yyyy_mm_dd", table && dates.empty?, "bad=#{dates.size}")
  personal = csv_text.to_s =~ /@|\(\d{3}\)|\b\d{3}[-.]\d{3}[-.]\d{4}\b/
  check.call("no_personal_emails_or_phones", csv_text && !personal)
  check.call("notes_exists_with_spot_checks", notes && notes =~ /spot/i)
  urls = table ? table.flat_map { |row| row["source_url"].to_s.split(" | ").map(&:strip) }.uniq.first(60) : []
  live = urls.count do |url|
    uri = URI(url) rescue nil
    next false unless uri&.host
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 8
      http.read_timeout = 10
      response = http.request(Net::HTTP::Get.new(uri.request_uri, "User-Agent" => "AgentC-Consulting-research/1.0 (+https://agentc.consulting; agent_c@agentc.consulting)"))
      # Only a page that was actually retrieved counts; 401, 403 and 429 stay unverified.
      response.code.to_i.between?(200, 399)
    rescue StandardError
      false
    end
  end
  rate = urls.empty? ? 0 : (live.to_f / urls.size).round(2)
  check.call("source_urls_reachable_90pct", rate >= 0.9, "reachable #{live}/#{urls.size}")
end

puts JSON.generate(task: task, arm: meta["arm"], rep: meta["rep"], run_dir: run_dir.to_s.sub(kit + "/", ""),
                   passed: checks.count { |item| item[:ok] }, total: checks.size, checks: checks)
