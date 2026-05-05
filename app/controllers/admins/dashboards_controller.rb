module Admins
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    def show
      # The symbol :admin_dashboard tells Pundit to look for AdminDashboardPolicy
      authorize :admin_dashboard, :show?
      # TODO @charities = policy_scope(Charity)
    end
  end
end
