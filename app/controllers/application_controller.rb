class ApplicationController < ActionController::Base
  include Paginatable

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_person,
                :current_collaborator,
                :current_student,
                :current_dean?,
                :current_admin_or_dean?,
                :units_path_for_current_account,
                :unit_path_for_current_account,
                :new_unit_grade_path_for_current_account,
                :unit_grade_path_for_current_account,
                :edit_unit_grade_path_for_current_account

  protected

  def after_sign_in_path_for(resource)
    return admin_people_path if resource.is_a?(Account) && resource.admin_or_dean?
    return profile_path if resource.is_a?(Account)

    super
  end

  def current_person
    current_account&.person
  end

  def current_collaborator
    current_person&.collaborator
  end

  def current_student
    current_person&.student
  end

  def current_dean?
    current_account&.dean? || false
  end

  def current_admin_or_dean?
    current_account&.admin_or_dean? || false
  end

  def units_path_for_current_account
    current_admin_or_dean? ? admin_units_path : units_path
  end

  def unit_path_for_current_account(unit)
    current_admin_or_dean? ? admin_unit_path(unit) : unit_path(unit)
  end

  def new_unit_grade_path_for_current_account(unit)
    current_admin_or_dean? ? new_admin_unit_grade_path(unit) : new_unit_grade_path(unit)
  end

  def unit_grade_path_for_current_account(unit, grade)
    current_admin_or_dean? ? admin_unit_grade_path(unit, grade) : unit_grade_path(unit, grade)
  end

  def edit_unit_grade_path_for_current_account(unit, grade)
    current_admin_or_dean? ? edit_admin_unit_grade_path(unit, grade) : edit_unit_grade_path(unit, grade)
  end
end
