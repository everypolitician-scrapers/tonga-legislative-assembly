# frozen_string_literal: true

require 'scraped'
require 'date'
require_relative './member_email_decorator'

class MemberPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls
  decorator MemberEmailDecorator

  field :id do
    URI.split(source)[5].split('/').last
  end

  field :name do
    noko.css('.page-header h2').text.sub('Hon. ', '').tidy
  end

  field :image do
    noko.at_css('.item-page img/@src').text
  end

  field :constituency do
    table_field('Constituency')[/ for (.*)/, 1]
  end

  field :birth_date do
    Date.parse(table_field('Date of Birth')) rescue nil
  end

  field :gender do
    table_field('Sex').downcase
  end

  field :email do
    noko.css('.email').map(&:text).join(';')
  end

  field :source do
    url
  end

  private

  def table_field(text)
    noko.xpath("//tr/td[contains(., '#{text}')]/following-sibling::td").text.tidy
  end
end
