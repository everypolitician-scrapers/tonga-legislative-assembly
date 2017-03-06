# frozen_string_literal: true
require_relative 'member_page'

class NoblePage < MemberPage
  field :constituency do
    table_field('Constituency').match(' for (.*)').to_a[1]
  end

  field :cell do
    noko.xpath("//ul/li[contains(., 'Mob number')]").text.split(':').last.to_s.tidy
  end
end
