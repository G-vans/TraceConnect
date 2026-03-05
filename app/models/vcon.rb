# Represents a VCON (Virtual Conversation) record from the Supabase database.
# Maps to the vcons table created by the VCON MCP server migrations.
class Vcon < ApplicationRecord
  self.table_name = "vcons"
  self.primary_key = "id"

  has_many :parties, foreign_key: :vcon_id, dependent: :destroy
  has_many :dialogs, class_name: "Dialog", foreign_key: :vcon_id, dependent: :destroy
  has_many :analyses, class_name: "Analysis", foreign_key: :vcon_id, dependent: :destroy
  has_many :vcon_attachments, class_name: "VconAttachment", foreign_key: :vcon_id, dependent: :destroy

  scope :recent, -> { order(created_at: :desc) }

  # Uses detect on preloaded collections instead of find_by to avoid N+1 queries.
  # All accessor methods are memoized so each JSON parse happens at most once per instance.

  def tags
    @tags ||= begin
      tag_attachment = vcon_attachments.detect { |a| a.type == "tags" }
      return {} unless tag_attachment&.body.present?

      parsed = JSON.parse(tag_attachment.body)
      tags_hash = {}
      Array(parsed).each do |tag_str|
        key, value = tag_str.to_s.split(":", 2)
        tags_hash[key] = value if key.present?
      end
      tags_hash
    rescue JSON::ParserError
      {}
    end
  end

  def branch
    tags["branch"]
  end

  def status
    tags["status"]
  end

  def priority
    tags["priority"]
  end

  def channel
    tags["channel"]
  end

  def issue_category
    tags["issue_category"]
  end

  def sentiment
    @sentiment ||= begin
      sentiment_analysis = analyses.detect { |a| a.type == "sentiment" }
      return nil unless sentiment_analysis&.body.present?
      JSON.parse(sentiment_analysis.body)
    rescue JSON::ParserError
      nil
    end
  end

  def summary
    @summary ||= begin
      summary_analysis = analyses.detect { |a| a.type == "summary" }
      summary_analysis&.body
    end
  end

  def consent_data
    @consent_data ||= begin
      consent_attachment = vcon_attachments.detect { |a| a.type == "consent" }
      return {} unless consent_attachment&.body.present?
      JSON.parse(consent_attachment.body)
    rescue JSON::ParserError
      {}
    end
  end

  def agent
    @agent ||= parties.detect { |p| p.metadata&.dig("role") == "agent" }
  end

  def customer
    @customer ||= parties.detect { |p| p.metadata&.dig("role") == "customer" }
  end
end
