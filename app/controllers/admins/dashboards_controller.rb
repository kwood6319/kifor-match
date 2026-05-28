module Admins
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    def show
      # The symbol :admin_dashboard tells Pundit to look for AdminDashboardPolicy
      authorize :admin_dashboard, :show?
      
      # Unapproved items (priority)
      @unapproved_charities = Charity.where(approved: false).order(created_at: :desc)
      
      # Recent items
      @recent_charities = Charity.order(created_at: :desc).limit(3)
      @recent_requests = Request.order(created_at: :desc).limit(3)
      @recent_offers = Offer.order(created_at: :desc).limit(3)
    end
  end
end
