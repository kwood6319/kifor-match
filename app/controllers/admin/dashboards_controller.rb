module Admin
  class DashboardsController < ApplicationController
    def show
      # The symbol :admin_dashboard tells Pundit to look for AdminDashboardPolicy
      authorize :admin_dashboard, :show?
    end
  end
end
