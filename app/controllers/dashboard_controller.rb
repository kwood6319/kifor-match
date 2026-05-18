class DashboardController < ApplicationController
  skip_after_action :verify_authorized

  def show
    redirect_to helpers.dynamic_dashboard_path(current_user)
  end
end
