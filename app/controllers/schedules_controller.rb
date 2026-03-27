class SchedulesController < ApplicationController
  before_action :authenticate_account!
  before_action :require_schedule_access!

  def show
    @start_date = parsed_start_date
    @lectures = schedule_lectures
    @schedule_role_label = current_collaborator.present? ? "Collaborator" : "Student"
    @schedule_owner_name = current_collaborator&.full_name || current_student&.full_name
    @formation_plan_names = current_student ? current_student.formation_plans.pluck(:name) : []
  end

  private

  def require_schedule_access!
    return if current_collaborator.present? || current_student.present?

    redirect_to profile_path, alert: "You do not have a schedule."
  end

  def schedule_lectures
    return current_collaborator.lectures.includes(:room, :unit).where(date: visible_range).order(:date, :start_time) if current_collaborator.present?

    current_student.scheduled_lectures_between(visible_range)
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
