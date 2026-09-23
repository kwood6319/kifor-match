class DonorsController < ApplicationController
  before_action :set_donor, only: %i[show approve destroy]
  before_action :show_back_button, only: %i[index show]

  def index
    authorize Donor
    @donors = policy_scope(Donor).includes(:user)

    if params[:query].present?
      # We must join users so SQL knows what 'users.email' is
      sql_query = "donors.display_name ILIKE :query OR users.email ILIKE :query"
      @donors = @donors.joins(:user).where(sql_query, query: "%#{params[:query]}%")
    end

    @donors = @donors.where(region: params[:region]) if params[:region].present?
    @donors = apply_approval_filter(@donors)
  end

  def show
    authorize @donor

    @offers = @donor.offers.active.includes(request: :charity).order(created_at: :desc)
    @total_offers_count = @donor.offers.count
    @completed_offers_count = @donor.offers.where(status: "completed").count
  end

  def destroy
    authorize @donor
    @donor.destroy
    redirect_to donors_path
  end

  def approve
    authorize @donor
    @donor.update(approved: true)

    redirect_back fallback_location: donors_path, status: :see_other, notice: "Donor approved!"
  end

  private

  # Checking both (or neither) box means "no opinion", so only filter
  # when exactly one of the two is checked.
  def apply_approval_filter(donors)
    approved_only = params[:approved_only] == "1"
    unapproved_only = params[:unapproved_only] == "1"

    return donors.where(approved: true) if approved_only && !unapproved_only
    return donors.where(approved: false) if unapproved_only && !approved_only

    donors
  end

  def set_donor
    @donor = Donor.find(params[:id])
  end
end
