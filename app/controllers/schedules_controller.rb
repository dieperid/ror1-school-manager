class SchedulesController < ApplicationController
  before_action :authenticate_account!
  before_action :require_collaborator!

  def show
    @month = parsed_month
    @calendar_days = calendar_range.to_a
    @lectures_by_date = current_collaborator.lectures
                                          .includes(:room, :unit)
                                          .where(date: calendar_range)
                                          .order(:date, :start_time)
                                          .group_by(&:date)
  end

  private

  def require_collaborator!
    return if current_collaborator.present?

    redirect_to profile_path, alert: "You do not have a collaborator schedule."
  end

  def parsed_month
    return Date.current.beginning_of_month if params[:month].blank?

    Date.strptime(params[:month], "%Y-%m").beginning_of_month
  rescue ArgumentError
    Date.current.beginning_of_month
  end

  def calendar_range
    @calendar_range ||= @month.beginning_of_month.beginning_of_week(:monday)..@month.end_of_month.end_of_week(:monday)
  end
end
