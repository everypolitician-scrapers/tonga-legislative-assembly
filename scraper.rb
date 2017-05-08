# frozen_string_literal: true

require 'pry'
require 'scraperwiki'
require 'require_all'
require_rel 'lib'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil

{
  'peoples' => MemberPage,
  'nobles'  => NoblePage,
}.each do |section, klass|
  url = "http://parliament.gov.to/members-of-parliament/#{section}/"

  data = scrape(url => MembersPage).member_urls.map do |mem_url|
    scrape(mem_url => klass).to_h
  end

  data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']
  ScraperWiki.save_sqlite(%i(id), data)
end
