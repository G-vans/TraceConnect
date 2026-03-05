# Represents an attachment on a VCON conversation (tags, consent, files).
# Maps to the attachments table in the Supabase database.
class VconAttachment < ApplicationRecord
  self.table_name = "attachments"

  belongs_to :vcon, foreign_key: :vcon_id

  # Override STI since we use 'type' column for attachment type, not inheritance
  self.inheritance_column = :_type_disabled

  scope :tags, -> { where(type: "tags") }
  scope :consent, -> { where(type: "consent") }

  def parsed_body
    return nil unless body.present?
    JSON.parse(body)
  rescue JSON::ParserError
    nil
  end
end
