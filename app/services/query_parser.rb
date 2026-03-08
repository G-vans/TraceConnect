# Parses natural language queries about vCon data into structured filters.
# Uses keyword matching and synonym maps — no external AI API needed.
class QueryParser
  BRANCHES = {
    "lagos" => "Lagos", "nairobi" => "Nairobi",
    "new york" => "New York", "newyork" => "New York", "ny" => "New York",
    "kenya" => "Nairobi", "nigeria" => "Lagos", "usa" => "New York", "us" => "New York"
  }.freeze

  STATUSES = {
    "open" => "open", "opened" => "open", "unresolved" => "open", "pending" => "open",
    "in progress" => "in_progress", "in-progress" => "in_progress",
    "ongoing" => "in_progress", "active" => "in_progress",
    "resolved" => "resolved", "closed" => "resolved", "done" => "resolved",
    "completed" => "resolved", "fixed" => "resolved"
  }.freeze

  PRIORITIES = {
    "high" => "high", "urgent" => "high", "critical" => "high",
    "medium" => "medium", "moderate" => "medium", "normal" => "medium",
    "low" => "low", "minor" => "low"
  }.freeze

  CHANNELS = {
    "call" => "call", "calls" => "call", "phone" => "call",
    "email" => "email", "emails" => "email", "mail" => "email",
    "chat" => "chat", "chats" => "chat", "message" => "chat", "messages" => "chat"
  }.freeze

  CATEGORIES = {
    "billing complaint" => "billing",
    "billing" => "billing", "payment" => "billing",
    "technical support" => "technical_support", "tech support" => "technical_support",
    "technical" => "technical_support",
    "account management" => "account_management", "account" => "account_management",
    "service complaint" => "service_complaint",
    "network issue" => "network_issue", "network" => "network_issue",
    "connectivity" => "network_issue",
    "complaint" => "service_complaint", "service" => "service_complaint"
  }.freeze

  TIME_RANGES = {
    "today" => "today",
    "this week" => "this_week", "weekly" => "this_week",
    "this month" => "this_month", "monthly" => "this_month"
  }.freeze

  COMPARE_KEYWORDS = %w[compare comparison vs versus difference different between].freeze
  AGENT_KEYWORDS = ["top agents", "best agents", "top performers", "best performers", "agent ranking", "who resolved", "who resolves"].freeze
  RESOLUTION_KEYWORDS = ["resolution rate", "resolve rate", "completion rate", "how fast", "resolves faster", "resolved faster"].freeze
  SENTIMENT_KEYWORDS = %w[sentiment mood feeling satisfaction].freeze
  STATS_KEYWORDS = %w[stats statistics overview breakdown summary].freeze
  COUNT_KEYWORDS = %w[count number total].freeze
  LIST_KEYWORDS = %w[show list find get display].freeze
  HELP_KEYWORDS = %w[help what commands examples how].freeze
  CONSENT_KEYWORDS = %w[consent expired expiring gdpr compliance privacy].freeze

  def self.parse(raw_query)
    new(raw_query).parse
  end

  def initialize(raw_query)
    @raw = raw_query
    @query = raw_query.downcase.strip
    @result = { raw: raw_query }
  end

  def parse
    extract_all_branches
    extract_intent
    extract_status
    extract_priority
    extract_channel
    extract_category
    extract_time_range
    @result
  end

  private

  def extract_all_branches
    found = []
    BRANCHES.sort_by { |k, _| -k.length }.each do |keyword, branch|
      if @query.include?(keyword) && !found.include?(branch)
        found << branch
      end
    end
    if found.size >= 2
      @result[:branches] = found
    elsif found.size == 1
      @result[:branch] = found.first
    end
  end

  def extract_intent
    has_multiple_branches = @result[:branches].present?
    is_compare = COMPARE_KEYWORDS.any? { |k| @query.include?(k) } || has_multiple_branches

    @result[:intent] = if HELP_KEYWORDS.any? { |k| @query == k } || @query.include?("what can")
      :help
    elsif CONSENT_KEYWORDS.any? { |k| @query.include?(k) }
      :consent
    elsif is_compare && has_multiple_branches
      :compare
    elsif AGENT_KEYWORDS.any? { |k| @query.include?(k) }
      :top_agents
    elsif RESOLUTION_KEYWORDS.any? { |k| @query.include?(k) }
      :resolution_rate
    elsif SENTIMENT_KEYWORDS.any? { |k| @query.include?(k) }
      :sentiment
    elsif STATS_KEYWORDS.any? { |k| @query.include?(k) }
      :stats
    elsif COUNT_KEYWORDS.any? { |k| @query.include?(k) }
      :count
    elsif LIST_KEYWORDS.any? { |k| @query.include?(k) }
      :list
    else
      # If we have any filters, default to stats; otherwise show help
      has_filters? ? :stats : :help
    end
  end

  def has_filters?
    @result[:branch].present? || @result[:branches].present?
  end

  def extract_status
    STATUSES.sort_by { |k, _| -k.length }.each do |keyword, status|
      if @query.match?(/\b#{Regexp.escape(keyword)}\b/)
        @result[:status] = status
        return
      end
    end
  end

  def extract_priority
    PRIORITIES.each do |keyword, priority|
      if @query.match?(/\b#{Regexp.escape(keyword)}\b/)
        @result[:priority] = priority
        return
      end
    end
  end

  def extract_channel
    CHANNELS.each do |keyword, channel|
      if @query.match?(/\b#{Regexp.escape(keyword)}\b/)
        @result[:channel] = channel
        return
      end
    end
  end

  def extract_category
    CATEGORIES.sort_by { |k, _| -k.length }.each do |keyword, category|
      if @query.include?(keyword)
        @result[:issue_category] = category
        return
      end
    end
  end

  def extract_time_range
    TIME_RANGES.sort_by { |k, _| -k.length }.each do |keyword, range|
      if @query.include?(keyword)
        @result[:time_range] = range
        return
      end
    end
  end
end
