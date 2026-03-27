module Admin
  class BaseController < ApplicationController
    before_action :authenticate_account!
    before_action :require_admin!

    private

    def require_admin!
      return if current_admin_or_dean?
      return if collaborator_access_allowed?

      redirect_to root_path, alert: "You are not allowed to access the admin area."
    end

    def collaborator_access_allowed?
      false
    end
  end
end
