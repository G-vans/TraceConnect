# Application-wide view helpers for TraceConnect.
# Provides navigation, status badges, and formatting helpers.
module ApplicationHelper
  def nav_link(text, path)
    active = current_page?(path)
    css = if active
      "rounded-md bg-slate-800 px-3 py-2 text-sm font-medium text-white"
    else
      "rounded-md px-3 py-2 text-sm font-medium text-slate-300 hover:bg-slate-700 hover:text-white"
    end
    link_to text, path, class: css
  end

  def status_badge(status)
    colors = {
      "open" => "bg-yellow-100 text-yellow-800",
      "in_progress" => "bg-blue-100 text-blue-800",
      "resolved" => "bg-green-100 text-green-800"
    }
    css = colors[status] || "bg-gray-100 text-gray-800"
    content_tag :span, status&.titleize || "Unknown",
      class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{css}"
  end

  def priority_badge(priority)
    colors = {
      "high" => "bg-red-100 text-red-800",
      "medium" => "bg-yellow-100 text-yellow-800",
      "low" => "bg-green-100 text-green-800"
    }
    css = colors[priority] || "bg-gray-100 text-gray-800"
    content_tag :span, priority&.titleize || "—",
      class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{css}"
  end

  def channel_icon(channel)
    icons = { "call" => "📞", "email" => "📧", "chat" => "💬" }
    icons[channel] || "📝"
  end

  def consent_badge(status)
    colors = {
      "green" => "bg-green-100 text-green-800",
      "yellow" => "bg-yellow-100 text-yellow-800",
      "red" => "bg-red-100 text-red-800"
    }
    labels = { "green" => "Compliant", "yellow" => "Expiring Soon", "red" => "Expired" }
    css = colors[status] || "bg-gray-100 text-gray-800"
    content_tag :span, labels[status] || "Unknown",
      class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{css}"
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
