# Performance Board controller — charts and rankings for branch comparison.
# Shows resolution times, top agents, issue categories, and sentiment scores.
class PerformanceController < ApplicationController
  def index
    @vcons = Vcon.includes(:parties, :vcon_attachments, :analyses).recent

    @resolution_by_branch = resolution_times_by_branch
    @top_agents = top_agents_list
    @categories_by_branch = categories_breakdown
    @sentiment_by_branch = sentiment_averages
  end

  private

  def resolution_times_by_branch
    branches = ["Nairobi", "Lagos", "New York"]
    branches.each_with_object({}) do |branch, hash|
      resolved = @vcons.select { |v| v.branch == branch && v.status == "resolved" }
      if resolved.any?
        avg = resolved.sum { |v| ((v.updated_at - v.created_at) / 1.hour).round(1) } / resolved.size
        hash[branch] = avg.round(1)
      else
        hash[branch] = 0
      end
    end
  end

  def top_agents_list
    agent_stats = {}
    @vcons.select { |v| v.status == "resolved" }.each do |v|
      agent = v.agent
      next unless agent
      name = agent.display_name
      agent_stats[name] ||= { resolved: 0, branch: v.branch }
      agent_stats[name][:resolved] += 1
    end
    agent_stats.sort_by { |_name, data| -data[:resolved] }.first(5).map do |name, data|
      { name: name, resolved: data[:resolved], branch: data[:branch] }
    end
  end

  def categories_breakdown
    branches = ["Nairobi", "Lagos", "New York"]
    result = {}
    branches.each do |branch|
      vcons_for_branch = @vcons.select { |v| v.branch == branch }
      cats = vcons_for_branch.group_by(&:issue_category).transform_values(&:size)
      result[branch] = cats
    end
    result
  end

  def sentiment_averages
    branches = ["Nairobi", "Lagos", "New York"]
    branches.each_with_object({}) do |branch, hash|
      vcons_for_branch = @vcons.select { |v| v.branch == branch }
      sentiments = vcons_for_branch.map { |v| v.sentiment }.compact
      scores = sentiments.map { |s| s.is_a?(Hash) ? s["score"] : nil }.compact
      hash[branch] = scores.any? ? (scores.sum.to_f / scores.size).round(2) : 0
    end
  end
end
