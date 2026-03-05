# Represents a VCON (Virtual Conversation) record from the Supabase database.
# Maps to the vcons table created by the VCON MCP server migrations.
class Vcon < ApplicationRecord
  self.table_name = "vcons"
  self.primary_key = "id"

  has_many :parties, foreign_key: :vcon_id, dependent: :destroy
  has_many :dialogs, class_name: "Dialog", foreign_key: :vcon_id, dependent: :destroy
  has_many :analyses, class_name: "Analysis", foreign_key: :vcon_id, dependent: :destroy
  has_many :vcon_attachments, class_name: "VconAttachment", foreign_key: :vcon_id, dependent: :destroy

  # Tags are stored as attachments with type='tags'
  has_many :tag_attachments, -> { where(type: "tags") }, class_name: "VconAttachment", foreign_key: :vcon_id

  scope :recent, -> { order(created_at: :desc) }
  scope :by_branch, ->(branch) { joins(:tag_attachments).where("attachments.body LIKE ?", "%branch:#{branch}%") }
  scope :by_status, ->(status) { joins(:tag_attachments).where("attachments.body LIKE ?", "%status:#{status}%") }

  def tags
    tag_attachment = vcon_attachments.find_by(type: "tags")
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
    sentiment_analysis = analyses.find_by(type: "sentiment")
    return nil unless sentiment_analysis&.body.present?
    JSON.parse(sentiment_analysis.body)
  rescue JSON::ParserError
    nil
  end

  def summary
    summary_analysis = analyses.find_by(type: "summary")
    summary_analysis&.body
  end

  def consent_data
    consent_attachment = vcon_attachments.find_by(type: "consent")
    return {} unless consent_attachment&.body.present?
    JSON.parse(consent_attachment.body)
  rescue JSON::ParserError
    {}
  end

  def agent
    parties.find_by("metadata->>'role' = ?", "agent")
  end

  def customer
    parties.find_by("metadata->>'role' = ?", "customer")
  end
end
