class SchedulesController < ApplicationController
  before_action :authenticate_account!
  before_action :require_collaborator!

  def show
    @start_date = parsed_start_date
    @lectures = current_collaborator.lectures
                                  .includes(:room, :unit)
                                  .where(date: visible_range)
                                  .order(:date, :start_time)
  end

  private

  def require_collaborator!
    return if current_collaborator.present?

    redirect_to profile_path, alert: "You do not have a collaborator schedule."
  end

  def parsed_start_date
    params.fetch(:start_date, Date.current).to_date
  rescue ArgumentError
    Date.current
  end

  def visible_range
    @visible_range ||= @start_date.beginning_of_month.beginning_of_week(:monday)..@start_date.end_of_month.end_of_week(:monday)
  end
end
