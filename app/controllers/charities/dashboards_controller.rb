module Charities
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    def show
      authorize :charity_dashboard, :show?
      # TODO @requests =
    end
  end
end
