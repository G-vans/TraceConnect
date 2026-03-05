# Radar Dashboard controller — the HQ command center view.
# Shows branch cards, pattern alerts, and quick stats at a glance.
class RadarController < ApplicationController
  def index
    @vcons = Vcon.includes(:parties, :vcon_attachments, :analyses).recent

    @branches = build_branch_stats
    @pattern_alerts = detect_patterns
    @quick_stats = build_quick_stats
  end

  private

  def build_branch_stats
    branch_names = ["Nairobi", "Lagos", "New York"]
    branch_names.map do |branch|
      vcons_for_branch = @vcons.select { |v| v.branch == branch }
      {
        name: branch,
        country: country_for(branch),
        law: law_for(branch),
        open_issues: vcons_for_branch.count { |v| v.status == "open" },
        in_progress: vcons_for_branch.count { |v| v.status == "in_progress" },
        resolved_today: vcons_for_branch.count { |v| v.status == "resolved" && v.updated_at&.today? },
        resolved_total: vcons_for_branch.count { |v| v.status == "resolved" },
        total: vcons_for_branch.size,
        avg_resolution_hours: avg_resolution_hours(vcons_for_branch),
        consent_status: consent_status_for(vcons_for_branch)
      }
    end
  end

  def detect_patterns
    category_branches = {}
    @vcons.each do |v|
      cat = v.issue_category
      branch = v.branch
      next unless cat.present? && branch.present?
      category_branches[cat] ||= {}
      category_branches[cat][branch] ||= 0
      category_branches[cat][branch] += 1
    end

    category_branches.select { |_cat, branches| branches.keys.size >= 2 }.map do |cat, branches|
      {
        category: cat,
        branches: branches,
        total: branches.values.sum
      }
    end
  end

  def build_quick_stats
    week_ago = 1.week.ago
    recent_vcons = @vcons.select { |v| v.created_at >= week_ago }
    resolved = recent_vcons.select { |v| v.status == "resolved" }

    top_agent = find_top_agent(resolved)

    {
      total_conversations: recent_vcons.size,
      resolution_rate: recent_vcons.any? ? (resolved.size.to_f / recent_vcons.size * 100).round(0) : 0,
      top_performer: top_agent
    }
  end

  def find_top_agent(resolved_vcons)
    agent_counts = {}
    resolved_vcons.each do |v|
      agent = v.agent
      next unless agent
      agent_counts[agent.display_name] ||= 0
      agent_counts[agent.display_name] += 1
    end
    return nil if agent_counts.empty?
    top = agent_counts.max_by { |_name, count| count }
    { name: top[0], resolved_count: top[1] }
  end

  def avg_resolution_hours(vcons)
    resolved = vcons.select { |v| v.status == "resolved" }
    return 0 if resolved.empty?
    total_hours = resolved.sum do |v|
      ((v.updated_at - v.created_at) / 1.hour).round(1)
    end
    (total_hours / resolved.size).round(1)
  end

  def consent_status_for(vcons)
    return "green" if vcons.empty?
    expired_count = vcons.count do |v|
      consent = v.consent_data
      consent["consent_expiry_date"].present? && Date.parse(consent["consent_expiry_date"]) < Date.today
    rescue
      false
    end
    expiring_soon = vcons.count do |v|
      consent = v.consent_data
      if consent["consent_expiry_date"].present?
        expiry = Date.parse(consent["consent_expiry_date"])
        expiry >= Date.today && expiry <= 7.days.from_now.to_date
      end
    rescue
      false
    end
    return "red" if expired_count > 0
    return "yellow" if expiring_soon > 0
    "green"
  end

  def country_for(branch)
    { "Nairobi" => "Kenya", "Lagos" => "Nigeria", "New York" => "USA" }[branch]
  end

  def law_for(branch)
    { "Nairobi" => "Kenya DPA", "Lagos" => "Nigeria NDPR", "New York" => "US TCPA" }[branch]
  end
end
