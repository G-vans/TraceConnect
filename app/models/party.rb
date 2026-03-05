# Represents a participant (agent, customer, supervisor) in a VCON conversation.
# Maps to the parties table in the Supabase database.
class Party < ApplicationRecord
  self.table_name = "parties"

  belongs_to :vcon, foreign_key: :vcon_id

  def role
    metadata&.dig("role")
  end

  def display_name
    name || mailto || tel || "Unknown"
  end
end
