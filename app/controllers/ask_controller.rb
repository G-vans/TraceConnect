# Handles natural language queries about vCon conversation data.
# Parses user input via QueryParser, queries the database,
# and returns formatted results as Turbo Stream responses.
class AskController < ApplicationController
  def query
    raw_query = params[:query].to_s.strip
    return render_error("Please enter a question.") if raw_query.blank?

    parsed = QueryParser.parse(raw_query)
    result = route_intent(parsed)

    render turbo_stream: turbo_stream.append(
      "ask-messages",
      partial: result[:partial],
      locals: result[:locals]
    )
  end

  private

  def route_intent(parsed)
    case parsed[:intent]
    when :help then help_results
    when :compare then compare_results(parsed)
    when :consent then consent_results(parsed)
    else
      vcons = load_vcons(parsed)
      execute_intent(parsed, vcons)
    end
  end

  def load_vcons(parsed)
    vcons = Vcon.includes(:parties, :vcon_attachments, :analyses).recent.to_a

    vcons = vcons.select { |v| v.branch&.downcase == parsed[:branch].downcase } if parsed[:branch]
    vcons = vcons.select { |v| v.status == parsed[:status] } if parsed[:status]
    vcons = vcons.select { |v| v.priority == parsed[:priority] } if parsed[:priority]
    vcons = vcons.select { |v| v.channel == parsed[:channel] } if parsed[:channel]
    vcons = vcons.select { |v| v.issue_category == parsed[:issue_category] } if parsed[:issue_category]

    if parsed[:time_range] == "today"
      vcons = vcons.select { |v| v.created_at&.today? }
    elsif parsed[:time_range] == "this_week"
      vcons = vcons.select { |v| v.created_at && v.created_at >= 1.week.ago }
    elsif parsed[:time_range] == "this_month"
      vcons = vcons.select { |v| v.created_at && v.created_at >= 1.month.ago }
    end

    vcons
  end

  def execute_intent(parsed, vcons)
    case parsed[:intent]
    when :count then count_results(parsed, vcons)
    when :stats then stats_results(parsed, vcons)
    when :top_agents then top_agents_results(vcons)
    when :resolution_rate then resolution_rate_results(parsed, vcons)
    when :sentiment then sentiment_results(parsed, vcons)
    else list_results(parsed, vcons)
    end
  end

  # --- Intent handlers ---

  def help_results
    { partial: "ask/help_response", locals: {} }
  end

  def count_results(parsed, vcons)
    { partial: "ask/count_response", locals: { count: vcons.size, description: describe(parsed) } }
  end

  def list_results(parsed, vcons)
    { partial: "ask/list_response", locals: { vcons: vcons.first(10), total: vcons.size, description: describe(parsed) } }
  end

  def stats_results(parsed, vcons)
    {
      partial: "ask/stats_response",
      locals: {
        total: vcons.size,
        open_count: vcons.count { |v| v.status == "open" },
        in_progress: vcons.count { |v| v.status == "in_progress" },
        resolved: vcons.count { |v| v.status == "resolved" },
        high_priority: vcons.count { |v| v.priority == "high" },
        description: describe(parsed)
      }
    }
  end

  def top_agents_results(vcons)
    agent_counts = {}
    vcons.select { |v| v.status == "resolved" }.each do |v|
      name = v.agent&.display_name
      next unless name
      agent_counts[name] = (agent_counts[name] || 0) + 1
    end
    top = agent_counts.sort_by { |_, c| -c }.first(5)
    { partial: "ask/agents_response", locals: { agents: top, total_resolved: vcons.count { |v| v.status == "resolved" } } }
  end

  def resolution_rate_results(parsed, vcons)
    total = vcons.size
    resolved = vcons.count { |v| v.status == "resolved" }
    rate = total > 0 ? (resolved.to_f / total * 100).round(1) : 0
    { partial: "ask/resolution_response", locals: { rate: rate, resolved: resolved, total: total, description: describe(parsed) } }
  end

  def sentiment_results(parsed, vcons)
    sentiments = vcons.map(&:sentiment).compact.select { |s| s.is_a?(Hash) }
    scores = sentiments.filter_map { |s| s["score"] }
    avg = scores.any? ? (scores.sum.to_f / scores.size).round(2) : nil
    label_counts = sentiments.group_by { |s| s["label"] || "unknown" }.transform_values(&:size)
    { partial: "ask/sentiment_response", locals: { avg_score: avg, label_counts: label_counts, total: sentiments.size, description: describe(parsed) } }
  end

  def consent_results(parsed)
    vcons = Vcon.includes(:parties, :vcon_attachments).recent.to_a
    vcons = vcons.select { |v| v.branch&.downcase == parsed[:branch].downcase } if parsed[:branch]

    expired = []
    expiring = []
    valid = []

    vcons.each do |v|
      consent = v.consent_data
      next if consent.empty?

      if consent["consent_expiry_date"].present?
        begin
          expiry = Date.parse(consent["consent_expiry_date"])
          if expiry < Date.today
            expired << v
          elsif expiry <= 7.days.from_now.to_date
            expiring << v
          else
            valid << v
          end
        rescue
          valid << v
        end
      else
        valid << v
      end
    end

    {
      partial: "ask/consent_response",
      locals: {
        expired: expired,
        expiring: expiring,
        valid: valid,
        description: parsed[:branch] ? "in #{parsed[:branch]}" : "all branches"
      }
    }
  end

  def compare_results(parsed)
    branches = parsed[:branches] || []
    all_vcons = Vcon.includes(:parties, :vcon_attachments, :analyses).recent.to_a

    all_vcons = all_vcons.select { |v| v.issue_category == parsed[:issue_category] } if parsed[:issue_category]
    all_vcons = all_vcons.select { |v| v.status == parsed[:status] } if parsed[:status]
    all_vcons = all_vcons.select { |v| v.priority == parsed[:priority] } if parsed[:priority]

    branch_data = branches.map do |branch_name|
      branch_vcons = all_vcons.select { |v| v.branch&.downcase == branch_name.downcase }
      resolved = branch_vcons.select { |v| v.status == "resolved" }

      avg_hours = if resolved.any?
        total_h = resolved.sum { |v| ((v.updated_at - v.created_at) / 1.hour).round(1) }
        (total_h / resolved.size).round(1)
      else
        0
      end

      top_agent = nil
      agent_counts = {}
      resolved.each do |v|
        name = v.agent&.display_name
        next unless name
        agent_counts[name] = (agent_counts[name] || 0) + 1
      end
      if agent_counts.any?
        top = agent_counts.max_by { |_, c| c }
        top_agent = { name: top[0], count: top[1] }
      end

      sentiments = branch_vcons.map(&:sentiment).compact.select { |s| s.is_a?(Hash) }
      scores = sentiments.filter_map { |s| s["score"] }
      avg_sentiment = scores.any? ? (scores.sum.to_f / scores.size).round(2) : nil

      {
        name: branch_name,
        total: branch_vcons.size,
        open: branch_vcons.count { |v| v.status == "open" },
        in_progress: branch_vcons.count { |v| v.status == "in_progress" },
        resolved: resolved.size,
        resolution_rate: branch_vcons.any? ? (resolved.size.to_f / branch_vcons.size * 100).round(1) : 0,
        avg_resolution_hours: avg_hours,
        top_agent: top_agent,
        avg_sentiment: avg_sentiment
      }
    end

    filter_label = parsed[:issue_category]&.humanize || "all"
    { partial: "ask/compare_response", locals: { branch_data: branch_data, filter_label: filter_label } }
  end

  def describe(parsed)
    parts = []
    parts << parsed[:status]&.humanize if parsed[:status]
    parts << "#{parsed[:priority]} priority" if parsed[:priority]
    parts << parsed[:channel] if parsed[:channel]
    parts << "#{parsed[:issue_category]&.humanize} issues" if parsed[:issue_category]
    parts << "in #{parsed[:branch]}" if parsed[:branch]
    parts << parsed[:time_range]&.tr("_", " ") if parsed[:time_range]
    parts.any? ? parts.join(" ") : "all conversations"
  end

  def render_error(message)
    render turbo_stream: turbo_stream.append("ask-messages", partial: "ask/error_response", locals: { message: message })
  end
end
