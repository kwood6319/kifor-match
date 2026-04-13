class CharitiesController < ApplicationController
  def index
    @charities = Charity.all
    # TO DO Handle active/archived charities
  end

  def destroy
    @charity = Charity.find(params[:id])

    if @charity.destroy
      redirect_to charity_path, status: :see_other, notice: "Charity deleted!"
    else
      redirect_to @charity, alert: @charity.errors.full_messages.to_sentence
    end
    # TO DO Change to archive method
  end

  def approve
    # TO DO make so only admin can do this
    @charity = Charity.find(params[:id])
    @charity.update(approved: true)

    redirect_to charity_path, status: :see_other, notice: "Charity approved!"
  end
end
