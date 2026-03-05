# Consent Dashboard controller — per-branch consent tracking and compliance.
# Shows consent status per country/law, expiration alerts, and timeline.
class ConsentController < ApplicationController
  def index
    @vcons = Vcon.includes(:vcon_attachments, :parties).recent

    @branches = build_consent_overview
    @expiring_soon = find_expiring_soon
    @expired = find_expired
  end

  private

  def build_consent_overview
    branch_names = ["Nairobi", "Lagos", "New York"]
    branch_names.map do |branch|
      vcons_for_branch = @vcons.select { |v| v.branch == branch }
      consent_data_list = vcons_for_branch.map { |v| [v, v.consent_data] }

      valid = consent_data_list.count { |_v, c| consent_valid?(c) }
      expiring = consent_data_list.count { |_v, c| consent_expiring_soon?(c) }
      expired = consent_data_list.count { |_v, c| consent_expired?(c) }
      no_consent = consent_data_list.count { |_v, c| c.empty? || c["consent_given"] == false }

      {
        name: branch,
        country: country_for(branch),
        law: law_for(branch),
        total: vcons_for_branch.size,
        valid_consent: valid,
        expiring_soon: expiring,
        expired: expired,
        no_consent: no_consent
      }
    end
  end

  def find_expiring_soon
    @vcons.select do |v|
      consent = v.consent_data
      consent_expiring_soon?(consent)
    end
  end

  def find_expired
    @vcons.select do |v|
      consent = v.consent_data
      consent_expired?(consent)
    end
  end

  def consent_valid?(consent)
    return false if consent.empty? || consent["consent_given"] != true
    return true unless consent["consent_expiry_date"].present?
    Date.parse(consent["consent_expiry_date"]) >= Date.today
  rescue
    false
  end

  def consent_expiring_soon?(consent)
    return false unless consent["consent_expiry_date"].present? && consent["consent_given"] == true
    expiry = Date.parse(consent["consent_expiry_date"])
    expiry >= Date.today && expiry <= 7.days.from_now.to_date
  rescue
    false
  end

  def consent_expired?(consent)
    return false unless consent["consent_expiry_date"].present?
    Date.parse(consent["consent_expiry_date"]) < Date.today
  rescue
    false
  end

  def country_for(branch)
    { "Nairobi" => "Kenya", "Lagos" => "Nigeria", "New York" => "USA" }[branch]
  end

  def law_for(branch)
    { "Nairobi" => "Kenya DPA", "Lagos" => "Nigeria NDPR", "New York" => "US TCPA" }[branch]
  end
end
