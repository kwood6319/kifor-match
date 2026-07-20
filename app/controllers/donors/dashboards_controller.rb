module Donors
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    def show
      authorize :donor_dashboard, :show?
      # Start with your policy scope and include charity to avoid N+1 queries
      @requests = policy_scope(Request).includes(:charity).where.not(status: "inactive")

      @top_categories = CategoryList.top_categories

      @pending_offers = current_donor.offers.active.includes(request: :charity).order(updated_at: :desc)
      @notifications = current_donor.notifications.undismissed.includes(offer: :request).order(created_at: :desc)

      # # Setup dynamic variables for your dropdown menus
      # @categories = Request.pluck(:category).uniq.sort

      # # 1. Text Search (Title or Charity Name)
      # if params[:query].present?
      #   # ILIKE is PostgreSQL's case-insensitive search
      #   sql_query = "requests.title ILIKE :query OR charities.org_name ILIKE :query"
      #   # We must join the charities table so SQL knows what 'charities.org_name' is
      #   @requests = @requests.joins(:charity).where(sql_query, query: "%#{params[:query]}%")
      # end

      # # 2. Category Filter
      # @requests = @requests.where(category: params[:category]) if params[:category].present?

      # # 3. Prefecture Filter
      # if params[:prefecture].present?
      #   # We join charities again to filter by the associated charity's prefecture
      #   @requests = @requests.joins(:charity).where(charities: { prefecture: params[:prefecture] })
      # end

      # # 4. "No Offers Yet" Checkbox
      # if params[:no_offers] == "1"
      #   # left_outer_joins grabs all requests, even if they have no offers.
      #   # where(offers: { id: nil }) filters it down to ONLY the ones with no matches.
      #   @requests = @requests.left_outer_joins(:offers).where(offers: { id: nil })
      # end

      # @requests = @requests.order(created_at: :desc)
    end
  end
end
