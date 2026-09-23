class CharitiesController < ApplicationController
  before_action :set_charity, only: %i[show approve destroy]
  before_action :show_back_button, only: %i[index show]

  def index
    authorize Charity
    @charities = policy_scope(Charity).includes(:user)

    if params[:query].present?
      # We must join users so SQL knows what 'users.email' is
      sql_query = "charities.org_name ILIKE :query OR users.email ILIKE :query"
      @charities = @charities.joins(:user).where(sql_query, query: "%#{params[:query]}%")
    end

    @charities = @charities.where(region: params[:region]) if params[:region].present?
    @charities = apply_approval_filter(@charities)
    # TO DO Handle active/archived charities
  end

  def show
    authorize @charity

    @requests = @charity.requests.where.not(status: "archived").order(created_at: :desc)
    @total_requests_count = @charity.requests.count
    @completed_requests_count = @charity.requests.where(status: "fulfilled").count
  end

  def destroy
    authorize @charity

    @charity.destroy
    redirect_to charities_path, status: :see_other, notice: "Charity deleted!"
    # TO DO Change to archive method
  end

  def approve
    # TO DO make so only admin can do this
    authorize @charity
    @charity.update(approved: true)

    redirect_back fallback_location: charities_path, status: :see_other, notice: "Charity approved!"
  end

  private

  # Checking both (or neither) box means "no opinion", so only filter
  # when exactly one of the two is checked.
  def apply_approval_filter(charities)
    approved_only = params[:approved_only] == "1"
    unapproved_only = params[:unapproved_only] == "1"

    return charities.where(approved: true) if approved_only && !unapproved_only
    return charities.where(approved: false) if unapproved_only && !approved_only

    charities
  end

  def set_charity
    @charity = Charity.find(params[:id])
  end
end
