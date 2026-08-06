module Charities
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    def show
      authorize :charity_dashboard, :show?
      # for some reason, this page reroutes to the Donors dashboard_controller
      @requests = policy_scope(Request).where.not(status: "archived")
      @archived_requests = policy_scope(Request).where(status: "archived")
    end
  end
end
