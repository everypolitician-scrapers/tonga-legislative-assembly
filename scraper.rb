# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'
require 'date'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'
# require 'scraped_page_archive/open-uri'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :member_urls do
    noko.css('.item .readmore-link/@href').map(&:text)
  end
end

class MemberPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :id do
    url.split('/').last
  end

  field :name do
    noko.css('.page-header h2').text.tidy
  end

  field :image do
    noko.at_css('.item-page img/@src').text
  end

  field :constituency do
    table_field('Constituency').match("People's Representative for (.*)")[1]
  end

  field :birth_date do
    Date.parse(table_field('Date of Birth')) rescue nil
  end

  field :gender do
    table_field('Sex').downcase
  end

  field :source do
    url
  end

  private

  def table_field(text)
    noko.xpath("//tr/td[contains(., '#{text}')]/following-sibling::td").text.tidy
  end
end

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

peoples_url = 'http://parliament.gov.to/members-of-parliament/peoples/'

data = scrape(peoples_url => MembersPage).member_urls.map do |mem_url|
  scrape(mem_url => MemberPage).to_h
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
ScraperWiki.save_sqlite(%i(id), data)
puts "Added #{data.count}"
