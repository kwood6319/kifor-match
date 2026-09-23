module Charities
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    # We want to let charities know when an offer has been left too long.
    ATTENTION_STATUSES = %w[submitted received].freeze
    ATTENTION_AGE = 1.day

    def show
      authorize :charity_dashboard, :show?

      # for some reason, this page reroutes to the Donors dashboard_controller
      urgency_order = Arel.sql("array_position(ARRAY['urgent','high','medium','low'], urgency)")
      @requests = policy_scope(Request).where.not(status: "archived").order(urgency_order)

      all_offers = Offer.joins(:request)
                        .merge(policy_scope(Request))
                        .includes(:donor, request: :charity)

      @actionable_offers = all_offers.where(status: ATTENTION_STATUSES, offers: { updated_at: ..ATTENTION_AGE.ago })
                                     .order(updated_at: :asc)
      assign_tracker_offers(all_offers)
    end

    private

    def assign_tracker_offers(all_offers)
      @submitted_offers = all_offers.where(status: "submitted").order(updated_at: :desc)
      @shipped_offers = all_offers.where(status: "shipped").order(updated_at: :desc)
      @received_offers = all_offers.where(status: "received").order(updated_at: :desc)
    end
  end
end
