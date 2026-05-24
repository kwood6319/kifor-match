class DashboardController < ApplicationController
  skip_after_action :verify_authorized

  def show
    @submitted_offers = Offer.where(status: "submitted").count
    @accepted_offers = Offer.where(status: "accepted").count
    @in_progress_offers = Offer.where(status: "accepted").count
    redirect_to helpers.dynamic_dashboard_path(current_user)
  end
end
