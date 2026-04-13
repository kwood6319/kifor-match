class CharitiesController < ApplicationController
  def index
    @charities = Charity.all
    # TO DO Handle active/archived charities
  end

  def destroy
    @charity = Charity.find(params[:id])
    @charity.delete
    redirect_to charity_path, status: :see_other, notice: "Charity deleted"
    # TO DO Change to archive method
  end
end
