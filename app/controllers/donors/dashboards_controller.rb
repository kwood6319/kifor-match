module Donors
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    def show
      authorize :donor_dashboard, :show?
      @requests = policy_scope(Request).includes(:charity)
    end
  end
end
