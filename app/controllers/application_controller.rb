class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_person, :current_collaborator

  protected

  def after_sign_in_path_for(resource)
    return admin_people_path if resource.is_a?(Account) && resource.admin?
    return profile_path if resource.is_a?(Account)

    super
  end

  def current_person
    current_account&.person
  end

  def current_collaborator
    current_person&.collaborator
  end
end
