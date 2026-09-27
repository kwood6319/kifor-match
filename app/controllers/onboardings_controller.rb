class OnboardingsController < ApplicationController
  skip_before_action :require_profile
  skip_before_action :require_approval
  skip_after_action :verify_authorized

  ROLES = %w[donor charity].freeze

  before_action :redirect_if_onboarded, only: %i[show create]

  # Without a role param, show the donor/charity choice; with one, show that
  # profile's form.
  def show
    @role = params[:role].presence_in(ROLES)
    @profile = build_profile(@role) if @role
  end

  def create
    @role = params[:role].presence_in(ROLES)
    return redirect_to onboarding_path unless @role

    @profile = build_profile(@role)
    @profile.assign_attributes(profile_params)

    saved = ActiveRecord::Base.transaction do
      current_user.update!(role: @role)
      @profile.save || raise(ActiveRecord::Rollback)
    end

    if saved
      redirect_to @role == "charity" ? pending_approval_path : helpers.dynamic_dashboard_path(current_user)
    else
      render :show, status: :unprocessable_entity
    end
  end

  def pending
    return redirect_to onboarding_path unless current_profile
    redirect_to helpers.dynamic_dashboard_path(current_user) unless current_charity && !current_charity.approved?
  end

  private

  def redirect_if_onboarded
    return unless current_user.admin? || current_user.donor || current_user.charity

    redirect_to helpers.dynamic_dashboard_path(current_user)
  end

  def build_profile(role)
    role == "donor" ? Donor.new(user: current_user) : Charity.new(user: current_user)
  end

  def profile_params
    if @role == "donor"
      params.require(:donor).permit(:display_name, :donor_type, :region, :prefecture)
    else
      params.require(:charity).permit(:org_name, :description, :region, :prefecture, :shipping_address)
    end
  end
end
