module Admins
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    def show
      # The symbol :admin_dashboard tells Pundit to look for AdminDashboardPolicy
      authorize :admin_dashboard, :show?

      # Unapproved items (priority)
      @unapproved_charities = Charity.includes(:user).where(approved: false).order(created_at: :desc)
      @unapproved_donors = Donor.includes(:user).where(approved: false).order(created_at: :desc)
    end
  end
end
