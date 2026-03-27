class DashboardController < ApplicationController
  before_action :authenticate_account!
  before_action :redirect_non_admins

  def show
  end

  private

  def redirect_non_admins
    return if current_admin_or_dean?

    redirect_to profile_path
  end
end
