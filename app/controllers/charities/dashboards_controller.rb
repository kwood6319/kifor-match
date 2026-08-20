module Charities
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    SORT_OPTIONS = {
      "urgency" => lambda { |scope|
        scope.order(Arel.sql("array_position(ARRAY['urgent','high','medium','low'], urgency)"))
      },
      "newest" => ->(scope) { scope.order(created_at: :desc) },
      "oldest" => ->(scope) { scope.order(created_at: :asc) },
      "title" => ->(scope) { scope.order(:title) }
    }.freeze

    INCOMING_STATUSES = %w[approved shipped received completed].freeze
    ACTIONABLE_STATUSES = %w[submitted shipped].freeze

    def show
      authorize :charity_dashboard, :show?

      # for some reason, this page reroutes to the Donors dashboard_controller
      base_requests = policy_scope(Request).where.not(status: "archived")
      sort_key = SORT_OPTIONS.key?(params[:sort]) ? params[:sort] : "urgency"
      @sort = sort_key
      @requests = SORT_OPTIONS[sort_key].call(base_requests)

      @archived_requests = policy_scope(Request).where(status: "archived")

      all_offers = Offer.joins(:request)
                        .merge(policy_scope(Request))
                        .includes(:donor, request: :charity)

      # Completed offers only show if their parent request hasn't been archived
      @incoming_offers = all_offers.where(status: INCOMING_STATUSES)
                                   .where("offers.status != 'completed' OR requests.status != 'archived'")
                                   .group_by(&:status)

      @actionable_offers = all_offers.where(status: ACTIONABLE_STATUSES)
                                     .order(updated_at: :desc)
    end
  end
end
