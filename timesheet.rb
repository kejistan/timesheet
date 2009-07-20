#!/usr/bin/env ruby
# Timesheet class for use in CU Timesheet related scripts

require 'Time'
require 'rubygems'
require 'elif'

class Timesheet

  TIMESHEET_PATH = File.expand_path("~/.timesheet")

  def initialize
    @reverse_time_file = Elif.new(TIMESHEET_PATH)
    @pay_period = load_period(@reverse_time_file)
  end

  def start_time(defined_time)
    time_file = File.open(TIMESHEET_PATH, 'a+')
    started = Time.parse defined_time
    if @pay_period[-1].ended? then
      @pay_period.push WorkDay.new(started)
      time_file << "\n" + @pay_period[-1].log_start + ' to '
    else
      puts "You haven't punched out from last time yet."
    end
  end

  def end_time(defined_time)
    time_file = File.open(TIMESHEET_PATH, 'a+')
    ended = Time.parse defined_time
    unless @pay_period[-1].ended? then
      @pay_period[-1].set_end ended
      time_file << @pay_period[-1].log_end
    else
      puts "You haven't punched in yet."
    end
  end

  def paid!
    time_file = File.open(TIMESHEET_PATH, 'a+')
    time_file << "\nPAID: " + period_total(@pay_period).to_s + ' hours'
  end

  def period_total(period)
    total_hours = 0.0
    period.each do |day|
      total_hours = total_hours + day.hours_worked if day.ended?
    end
    return total_hours
  end

  def stats
    puts 'Today:'
    @pay_period[-1].report
    puts 'Total hours this period: ' + period_total(@pay_period).to_s
  end

  def period_summary(period = @pay_period)
    period.each do |day|
      puts day.to_s if day.ended?
    end
    puts "\n" + 'Total hours: ' + period_total(@pay_period).to_s + ' hours'
  end

  def load_period(timesheet_file)
    period = Array.new
    timesheet_file.each do |line|
      break if line.empty?
      tokenized_line = parse_line(line)
      period.push(WorkDay.new(tokenized_line[:start],tokenized_line[:end]))
    end
    return period.reverse
  end

  def parse_line(line)
    start_and_end = line.split(' to ', 2)
    tokenized_line = Hash.new
    tokenized_line[:start] = Time.parse(start_and_end[0])
    unless start_and_end[1].nil? || start_and_end[1].empty? then
      tokenized_line[:end] = Time.parse(tokenized_line[:start].strftime("%Y-%m-%d") + ' ' + start_and_end[1])
    end
    return tokenized_line
  end

end

class WorkDay

  def initialize(start_time, end_time = nil)
    @start_time = start_time
    @end_time = end_time
  end

  def hours_worked
    return 0 if end_time.nil?
    hours = @end_time.hour - @start_time.hour
    min_difference = @end_time.min - @start_time.min
    hours = hours - 1 if min_difference < 0
    hours = hours + (min_difference / 15).abs * 0.25
    hours = hours + 0.25 if min_difference % 15 > 7
    return hours
  end

  def report
    puts 'Punched in at: ' + pretty_time(@start_time)
    puts 'Punched out at: ' + pretty_time(@end_time) unless @end_time.nil?
    puts 'Total time worked: ' + hours_worked.to_s + ' hours' unless @end_time.nil?
  end

  def to_s
    pretty_date(@start_time) + ' | ' + pretty_time(@start_time) + ' to ' + pretty_time(@end_time) + ' | ' + hours_worked.to_s + ' hours'
  end

  def pretty_time(time)
    time.strftime("%X")
  end

  def pretty_date(time)
    time.strftime("%x")
  end

  def set_end(end_time)
    @end_time = end_time
  end

  def set_start(start_time)
    @start_time
  end

  def start_time
    return @start_time
  end

  def end_time
    return @end_time
  end

  def ended?
    return !@end_time.nil?
  end

  def log_day
    log_line = log_start + ' to '
    log_line = log_line + log_end unless @end_time.nil?
    return log_line
  end

  def log_end
    @end_time.strftime("%X")
  end

  def log_start
    @start_time.strftime("%Y-%m-%d %X")
  end

end
