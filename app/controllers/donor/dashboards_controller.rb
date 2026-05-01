module Donor
  class DashboardsController < ApplicationController
    def show
      authorize :donor_dashboard, :show?
    end
  end
end
