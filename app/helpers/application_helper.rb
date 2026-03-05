# Application-wide view helpers for TraceConnect.
# Provides navigation, status badges, and formatting helpers.
module ApplicationHelper
  def nav_link(text, path)
    active = current_page?(path)
    css = active ? "nav-link nav-link-active" : "nav-link"
    link_to text, path, class: css
  end

  def status_badge(status)
    css_map = {
      "open" => "badge badge-open",
      "in_progress" => "badge badge-in-progress",
      "resolved" => "badge badge-resolved"
    }
    css = css_map[status] || "badge badge-neutral"
    content_tag :span, status&.humanize || "Unknown", class: css
  end

  def priority_badge(priority)
    css_map = {
      "high" => "badge badge-high",
      "medium" => "badge badge-medium",
      "low" => "badge badge-low"
    }
    css = css_map[priority] || "badge badge-neutral"
    content_tag :span, priority&.humanize || "—", class: css
  end

  def channel_label(channel)
    icons = { "call" => "📞", "email" => "📧", "chat" => "💬" }
    "#{icons[channel] || '📝'} #{channel&.humanize}"
  end

  def consent_badge(status)
    css_map = {
      "green" => "badge badge-compliant",
      "yellow" => "badge badge-expiring",
      "red" => "badge badge-expired"
    }
    labels = { "green" => "Compliant", "yellow" => "Expiring Soon", "red" => "Expired" }
    css = css_map[status] || "badge badge-neutral"
    content_tag :span, labels[status] || "Unknown", class: css
  end

  def format_hours(hours)
    return "—" if hours.nil? || hours == 0
    if hours < 1
      "#{(hours * 60).round}m"
    elsif hours < 24
      "#{hours.round(1)}h"
    else
      "#{(hours / 24).round(1)}d"
    end
  end
end
