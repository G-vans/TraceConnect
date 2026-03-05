# Conversations Feed controller — searchable, filterable conversation list.
# Supports filtering by branch, status, channel, priority, and date range.
class ConversationsController < ApplicationController
  def index
    @vcons = Vcon.includes(:parties, :vcon_attachments, :analyses, :dialogs).recent

    @vcons = filter_vcons(@vcons)
  end

  def show
    @vcon = Vcon.includes(:parties, :dialogs, :analyses, :vcon_attachments).find(params[:id])
  end

  private

  def filter_vcons(vcons)
    result = vcons.to_a

    if params[:branch].present?
      result = result.select { |v| v.branch == params[:branch] }
    end

    if params[:status].present?
      result = result.select { |v| v.status == params[:status] }
    end

    if params[:channel].present?
      result = result.select { |v| v.channel == params[:channel] }
    end

    if params[:priority].present?
      result = result.select { |v| v.priority == params[:priority] }
    end

    if params[:search].present?
      search_term = params[:search].downcase
      result = result.select do |v|
        v.subject&.downcase&.include?(search_term) ||
          v.parties.any? { |p| p.name&.downcase&.include?(search_term) }
      end
    end

    result
  end
end
