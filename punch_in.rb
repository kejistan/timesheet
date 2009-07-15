#!/usr/bin/env ruby
# Start the day off right....

require 'timesheet.rb'

timesheet = Timesheet.new
timesheet.start_time(ARGV.join(' '))
