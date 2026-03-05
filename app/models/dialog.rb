# Represents a dialog entry (message, call segment) within a VCON conversation.
# Maps to the dialog table in the Supabase database.
class Dialog < ApplicationRecord
  self.table_name = "dialog"

  belongs_to :vcon, foreign_key: :vcon_id

  scope :chronological, -> { order(start_time: :asc) }

  # Uses detect on preloaded parties instead of find_by to avoid N+1 queries.
  def speaker(vcon_record = nil)
    return nil unless parties.present? && vcon_record.present?
    idx = parties.first
    vcon_record.parties.detect { |p| p.party_index == idx }
  end
end
