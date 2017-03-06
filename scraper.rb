# frozen_string_literal: true

require 'pry'
require 'scraperwiki'
require_relative 'lib/members_page'
require_relative 'lib/member_page'
require_relative 'lib/noble_page'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'
# require 'scraped_page_archive/open-uri'

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil

{
  'peoples' => MemberPage,
  'nobles'  => NoblePage,
}.each do |section, klass|
  url = "http://parliament.gov.to/members-of-parliament/#{section}/"

  data = scrape(url => MembersPage).member_urls.map do |mem_url|
    scrape(mem_url => klass).to_h
  end

  ScraperWiki.save_sqlite(%i(id), data)
  puts "Added #{data.count} from #{url}"
end
