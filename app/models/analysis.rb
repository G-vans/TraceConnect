# Represents an AI/ML analysis result attached to a VCON conversation.
# Maps to the analysis table in the Supabase database.
class Analysis < ApplicationRecord
  self.table_name = "analysis"

  belongs_to :vcon, foreign_key: :vcon_id

  scope :summaries, -> { where(type: "summary") }
  scope :sentiments, -> { where(type: "sentiment") }
  scope :transcripts, -> { where(type: "transcript") }

  # Override STI since we use 'type' column for analysis type, not inheritance
  self.inheritance_column = :_type_disabled
end
