class DonorsController < ApplicationController
  before_action :set_donor, only: %i[approve destroy]

  def index
    @donors = policy_scope(Donor)
  end

  def destroy
    authorize @donor
    @donor.destroy
    redirect_to donors_path
  end

  def approve
    authorize @donor
    @donor.update(approved: true)

    redirect_to donors_path, status: :see_other
  end

  private

  def set_donor
    @donor = Donor.find(params[:id])
  end
end
