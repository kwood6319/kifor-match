module Admins
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    def show
      # The symbol :admin_dashboard tells Pundit to look for AdminDashboardPolicy
      authorize :admin_dashboard, :show?
      
      # Unapproved items (priority)
      @unapproved_charities = Charity.where(approved: false).order(created_at: :desc)
    end
  end
end
