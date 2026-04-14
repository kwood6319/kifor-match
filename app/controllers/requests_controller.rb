class RequestsController < ApplicationController
  before_action :set_request, only: %i[show edit update]

  def index
    @requests = policy_scope(Request)
  end

  def show
    authorize @request
  end

  def new
    @request = Request.new
    authorize @request
  end

  def create
    if current_user.charity.nil?
      redirect_to root_path
      return
    end
    @request = Request.new(request_params)
    @request.charity = current_user.charity
    @request.save ? redirect_to(requests_path) : render(:new, status: :unprocessable_entity)
    authorize @request
  end

  def edit
    authorize @request
  end

  def update
    if @request.update(request_params)
      redirect_to requests_path
    else
      render :edit, status: :unprocessable_entity
    end

    authorize @request
  end

  # def activate
  # end

  # def deactivate
  #   authorize @request
  # end

  private

  def set_request
    @request = Request.find(params[:id])
  end

  def request_params
    params.require(:request).permit(:title, :category, :description, :quantity_needed, :quantity_remaining, :units,
                                    :condition, :region, :city, :urgency, :status)
  end
end
