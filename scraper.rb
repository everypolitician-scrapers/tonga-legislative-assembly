# frozen_string_literal: true

require 'pry'
require 'scraperwiki'
require 'require_all'
require_rel 'lib'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

alldata = %w[peoples nobles ministers].flat_map do |section|
  url = "http://parliament.gov.to/members-of-parliament/#{section}/"
  scrape(url => MembersPage).member_urls.map { |mem_url| scrape(mem_url => MemberPage).to_h }
end

# Some of the members appear on more than one page, so only take the
# first entry for each
data = alldata.group_by { |mem| mem[:name] }.map { |_m, ms| ms.first }
data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite(%i[id], data)
