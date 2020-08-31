#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'json'
require 'pry'
require 'scraped'

require_relative 'lib/quickstatement_candidate'

json_file = ARGV.first
json = JSON.parse(File.read(json_file), symbolize_names: true)
csv = CSV.table(json[:combofile])

rows = csv.sort_by { |row| row[:name] }
commands = rows.each_with_index.map do |row, index|
  data = row.to_h
  data[:id] ||= data.delete(:foundid)
  data[:id] ||= 'LAST' if rows[index][:name] == rows[index-1][:name]

  year = data[:electionlabel][/(\d{4})/, 1]
  data[:constituency] = json[:wikidata].find { |item| (year >= item[:start]) && (year < item[:end]) }[:id] rescue binding.pry

  QuickStatement::Candidate.new(
    data.merge(url: json[:wikipedia], description: json[:new_person_description])
  ).to_s
end

puts commands.join("\n")
