class DonorsController < ApplicationController
  before_action :set_donor, only: %i[destroy]

  def index
    @donors = policy_scope(Donor)
  end

  def destroy
    authorize @donor
    @donor.destroy
    redirect_to donors_path
  end

  private

  def set_donor
    @donor = Donor.find(params[:id])
  end
end
