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
    table_field('Constituency')[/People's Representative for (.*)/, 1]
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

  # This handles the following variations of the "Mobile Phone" field:
  #
  #   Mobile Phone : 676 7714548
  #   Mobile Phone : 676 7755555 or 676 88855555
  #   Mobile Phone : +676 66858
  #   Email: fvakata11@gmail.comMobile Phone : 676 7716294Home Phone :23851
  field :cell do
    noko.xpath("//tr/td[contains(., 'Mobile Phone')]").text
        .match(/Mobile Phone[[:space:]]*?\:[[:space:]]*?([^\nH]+)/)
        .to_a[1].to_s.tidy.gsub(' or', ';')
  end

  # This handles the following variations of the "Home Phone" field:
  #
  #   Home Phone : 676 25773
  #   Home Phone : +676 31194
  #   Email: fvakata11@gmail.comMobile Phone : 676 7716294Home Phone :23851
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
