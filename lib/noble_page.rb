# frozen_string_literal: true

require_relative 'member_page'

class NoblePage < MemberPage
  # We need to override this field because the Nobles use "Mob number" rather
  # than "Mobile Phone" to specify the cell number. This field has a simpler
  # implementation from the parent because the field is always in the following
  # format:
  #
  #   Mob number : 8403558
  field :cell do
    noko.xpath("//ul/li[contains(., 'Mob number :')]").text.split(':', 2).last.to_s.tidy
  end
end
