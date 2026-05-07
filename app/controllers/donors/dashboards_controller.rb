module Donors
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    def show
      authorize :donor_dashboard, :show?
    end
  end
end
