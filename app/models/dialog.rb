# Represents a dialog entry (message, call segment) within a VCON conversation.
# Maps to the dialog table in the Supabase database.
class Dialog < ApplicationRecord
  self.table_name = "dialog"

  belongs_to :vcon, foreign_key: :vcon_id

  scope :chronological, -> { order(start_time: :asc) }

  def speaker(vcon_record = nil)
    return nil unless parties.present? && vcon_record.present?
    party_index = parties.first
    vcon_record.parties.find_by(party_index: party_index)
  end
end
