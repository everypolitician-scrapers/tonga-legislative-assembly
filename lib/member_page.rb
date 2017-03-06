# frozen_string_literal: true
require 'scraped'
require 'date'
require_relative './member_email_decorator'

class MemberPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls
  decorator MemberEmailDecorator

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

  field :email do
    noko.xpath("//span[starts-with(@id, 'cloak')]").map(&:text).join(';')
  end

  field :cell do
    noko.xpath("//tr/td[contains(., 'Mobile Phone')]").text
        .match(/Mobile Phone[[:space:]]*?\:[[:space:]]*?([^\nH]+)/)
        .to_a[1].to_s.tidy.gsub(' or', ';')
  end

  field :phone do
    noko.xpath("//tr/td[contains(., 'Home Phone')]").text
        .match(/Home Phone[[:space:]]*?:[[:space:]]*?([\+\d[[:space:]]]+)/)
        .to_a[1].to_s.tidy
  end

  field :source do
    url
  end

  private

  def table_field(text)
    noko.xpath("//tr/td[contains(., '#{text}')]/following-sibling::td").text.tidy
  end
end
