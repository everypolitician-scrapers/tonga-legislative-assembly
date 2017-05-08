# frozen_string_literal: true

require 'scraped'
require 'cgi'
require 'execjs'
require 'nokogiri'

# Deobfuscates email address fields that are masked with JavaScript.
class MemberEmailDecorator < Scraped::Response::Decorator
  def body
    noko = Nokogiri::HTML(super)
    noko.xpath("//span[starts-with(@id, 'cloak')]").each do |email_field|
      email_field.inner_html = email_from_javascript(email_field[:id])
      email_field[:class] = 'email'
    end
    noko.to_s
  end

  private

  def email_from_javascript(cloak_id)
    return if cloak_id.empty?
    addy_id = cloak_id.sub('cloak', 'addy')
    lines = response.body.lines.select { |l| l.include?(addy_id) }.take(2)
    lines << ";return #{addy_id};"
    fn = "function() { #{lines.map(&:strip).join("\n")} }()"
    CGI.unescape_html(ExecJS.eval(fn))
  end
end
