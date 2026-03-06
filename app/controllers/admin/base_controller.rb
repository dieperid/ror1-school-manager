module Admin
  class BaseController < ApplicationController
    before_action :authenticate_account!
    before_action :require_admin!

    private

    def require_admin!
      return if current_account&.admin?

      redirect_to root_path, alert: "You are not allowed to access the admin area."
    end
  end
end
