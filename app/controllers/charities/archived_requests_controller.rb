module Charities
  class ArchivedRequestsController < ApplicationController
    before_action :authenticate_user!
    before_action :show_back_button, only: %i[index]

    def index
      authorize :charity_dashboard, :show?

      requests = policy_scope(Request).where(status: "archived").order(updated_at: :desc)

      @requests_by_year = requests.group_by { |request| request.updated_at.year }.transform_values do |year_requests|
        year_requests.group_by { |request| request.updated_at.beginning_of_month }
      end
    end
  end
end
