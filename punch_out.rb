#!/usr/bin/env ruby
# bbl omw hoem

require 'timesheet.rb'

timesheet = Timesheet.new
timesheet.end_time(ARGV.join(' '))
timesheet.stats
