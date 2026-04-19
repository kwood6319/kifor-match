class CharitiesController < ApplicationController
  before_action :set_charity, only: %i[approve destroy]

  def index
    @charities = policy_scope(Charity)
  end

  def approve
    authorize @charity
    @charity.update(approved: true)
    redirect_to charities_path
  end

  def destroy
    authorize @charity
    @charity.destroy
    redirect_to charities_path
  end

  private

  def set_charity
    @charity = Charity.find(params[:id])
  end
end
