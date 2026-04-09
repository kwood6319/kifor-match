class RequestsController < ApplicationController
  before_action :set_request, only: %i[show edit update]

  def index
    @requests = current_user.charity.requests
  end

  def show
  end

  def new
    @request = Request.new
  end

  def create
    if current_user.charity.nil?
      redirect_to root_path
      return
    end
    @request = Request.new(request_params)
    @request.charity = current_user.charity
    @request.save ? redirect_to(requests_path) : render(:new, status: :unprocessable_entity)
  end

  def edit
  end

  def update
    if @request.update(request_params)
      redirect_to requests_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # def activate
  # end

  # def deactivate
  # end

  private

  def set_request
    @request = Request.find(params[:id])
  end

  def request_params
    params.require(:request).permit(:title, :category, :description, :quantity_needed, :quantity_remaining, :units,
                                    :condition, :region, :city, :urgency)
  end
end
