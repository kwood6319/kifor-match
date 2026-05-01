module Charity
  class DashboardsController < ApplicationController
    def show
      authorize :charity_dashboard, :show?
    end
  end
end
