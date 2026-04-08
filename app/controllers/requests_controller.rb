class RequestsController < ApplicationController
  def index
    @requests = current_user.charity.requests
  end

  def show
    # @request = Request.find(params[:id])
  end

  def new
    # @request = Request.new
  end

  def create
    # @request = Request.new(request_params)
    # @request.charity = current_user.charity
  end

  def edit
  end

  def update
  end

  def activate
  end

  def deactivate
  end

  private

  def request_params
    params.require(:request).permit(:title, :category, :description, :quantity_needed, :quantity_remaining, :units, :condition, :region, :city, :urgency, :status)
  end
end
