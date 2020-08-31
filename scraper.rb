#!/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require_relative 'lib/remove_notes'

require_relative 'lib/scraped_wikipedia_positionholders'
require_relative 'lib/wikipedia_candidates_page'
require_relative 'lib/wikipedia_candidate_row'


# The Wikipedia page with a list of election results
class Candidates < WikipediaCandidatesPage
  decorator RemoveNotes
  decorator WikidataIdsDecorator::Links

  def wanted_tables
    noko.xpath('//table[caption[a]]')
  end
end

# Each candidate in each election
class Candidate < WikipediaCandidateRow
  def columns
    %w[_color party name votes _percentage _diff]
  end

  field :election do
    noko.xpath('ancestor::table//caption//a/@wikidata').map(&:text).first
  end

  field :electionLabel do
    noko.xpath('ancestor::table//caption//a').map(&:text).map(&:tidy).first
  end

  # https://stackoverflow.com/a/6630486
  field :ranking do
    (tds[0].xpath('count(ancestor::tr) + count(ancestor::tr[1]/preceding-sibling::tr)') - 1).to_i
  end
end

jsonfile = ARGV.first or abort "Usage: #$0 <configfile>"
config = JSON.parse(File.read(jsonfile), symbolize_names: true)
url = config[:wikipedia] or abort "No <wikipedia> URL in config"
puts Scraped::Wikipedia::PositionHolders.new(url => Candidates).to_csv(config[:mapping])
