#!/usr/bin/env ruby
# put the latest pay period in ~/timesheet_report and mark the current period as 'paid'

require 'timesheet.rb'

REPORT_FILE = File.expand_path("~/timesheet_report")

timesheet = Timesheet.new
report = File.open(REPORT_FILE, 'w')
$stdout = report
timesheet.period_summary
$stdout = STDOUT
timesheet.paid!
